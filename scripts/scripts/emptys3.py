#!/usr/bin/env python3
"""
emptys3.py — Empty an S3 bucket as fast as possible.

Usage:
    python3 emptys3.py <bucket> [--profile PROFILE] [--threads N]

Dependencies:
    pip install boto3
"""

import argparse
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timedelta, timezone

import boto3
from botocore.exceptions import ClientError, NoCredentialsError, ProfileNotFound


# ── CLI ───────────────────────────────────────────────────────────────────────

def parse_args():
    p = argparse.ArgumentParser(
        description="Empty an S3 bucket (versioned or plain), fast."
    )
    p.add_argument("bucket", help="S3 bucket name")
    p.add_argument("--profile", default=None, help="AWS CLI profile name")
    p.add_argument("--threads", type=int, default=10,
                   help="Parallel delete threads (default: 10)")
    return p.parse_args()


# ── Helpers ───────────────────────────────────────────────────────────────────

def fmt_bytes(n):
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if n < 1024 or unit == "TB":
            return f"{n:.2f} {unit}"
        n /= 1024


def fmt_elapsed(seconds):
    h, r = divmod(int(seconds), 3600)
    m, s = divmod(r, 60)
    return f"{h:02d}h {m:02d}m {s:02d}s"


def confirm(prompt):
    return input(prompt).strip().lower() == "y"


# ── AWS info ──────────────────────────────────────────────────────────────────

def get_identity(session):
    sts = session.client("sts")
    r = sts.get_caller_identity()
    return r["Account"], r["Arn"]


def get_region(session):
    return session.region_name or "unknown"


def get_bucket_region(s3_client, bucket):
    r = s3_client.get_bucket_location(Bucket=bucket)
    loc = r.get("LocationConstraint")
    return loc or "us-east-1"


def get_versioning(s3_client, bucket):
    r = s3_client.get_bucket_versioning(Bucket=bucket)
    return r.get("Status", "Disabled") or "Disabled"


def get_cloudwatch_stats(session, bucket):
    """Returns (size_str, object_count_str) from CloudWatch daily metrics."""
    cw = session.client("cloudwatch")
    now = datetime.now(timezone.utc)
    start = (now - timedelta(days=3)).strftime("%Y-%m-%dT%H:%M:%SZ")
    end = now.strftime("%Y-%m-%dT%H:%M:%SZ")

    def fetch(metric, storage_type):
        try:
            r = cw.get_metric_statistics(
                Namespace="AWS/S3",
                MetricName=metric,
                Dimensions=[
                    {"Name": "BucketName", "Value": bucket},
                    {"Name": "StorageType", "Value": storage_type},
                ],
                StartTime=start,
                EndTime=end,
                Period=86400,
                Statistics=["Average"],
            )
            points = sorted(r["Datapoints"], key=lambda x: x["Timestamp"])
            return points[-1]["Average"] if points else None
        except ClientError:
            return None

    size = fetch("BucketSizeBytes", "StandardStorage")
    count = fetch("NumberOfObjects", "AllStorageTypes")

    size_str = fmt_bytes(size) if size is not None else "unknown (CloudWatch metrics may not be enabled)"
    count_str = f"{count:,.0f}" if count is not None else "unknown"
    return size_str, count_str


def get_first_page_counts(s3_client, bucket):
    """Returns (version_count, marker_count) from the first page only (capped at 1000)."""
    try:
        r = s3_client.list_object_versions(Bucket=bucket, MaxKeys=1000)
        return len(r.get("Versions") or []), len(r.get("DeleteMarkers") or [])
    except ClientError:
        return 0, 0


# ── Deletion ──────────────────────────────────────────────────────────────────

class ProgressCounter:
    def __init__(self, label):
        self.label = label
        self.total = 0
        self.lock = threading.Lock()

    def add(self, n):
        with self.lock:
            self.total += n
            print(f"  [{self.label}] {self.total:,} deleted...", end="\r", flush=True)


def delete_batch(s3_client, bucket, objects, counter, errors_list):
    """Delete one batch of up to 1000 objects. Called from thread pool."""
    try:
        resp = s3_client.delete_objects(
            Bucket=bucket,
            Delete={"Objects": objects, "Quiet": True},
        )
        errors = resp.get("Errors", [])
        if errors:
            errors_list.extend(errors)
        counter.add(len(objects) - len(errors))
    except ClientError as e:
        errors_list.append({"Message": str(e)})


def delete_versioned(s3_client, bucket, kind, label, threads):
    """
    Producer-consumer pipeline:
      - Main thread paginates list_object_versions and submits batches to the pool immediately.
      - Thread pool workers delete batches concurrently while listing continues.
    """
    print(f"\n  Deleting {label} (listing + deleting in parallel)...")
    counter = ProgressCounter(label)
    errors_list = []
    futures = []

    paginator = s3_client.get_paginator("list_object_versions")

    with ThreadPoolExecutor(max_workers=threads) as pool:
        for page in paginator.paginate(Bucket=bucket):
            items = page.get(kind) or []
            if not items:
                continue
            batch = [{"Key": v["Key"], "VersionId": v["VersionId"]} for v in items]
            # Submit immediately — deletion overlaps with continued listing
            futures.append(
                pool.submit(delete_batch, s3_client, bucket, batch, counter, errors_list)
            )

        # Drain any remaining futures (pool.__exit__ waits anyway, but surface errors)
        for f in as_completed(futures):
            exc = f.exception()
            if exc:
                print(f"\n  ERROR in worker: {exc}", file=sys.stderr)

    print()  # newline after \r progress
    if errors_list:
        print(f"  WARNING: {len(errors_list)} item(s) failed to delete:")
        for e in errors_list[:5]:
            print(f"    {e.get('Key', '?')} — {e.get('Code', e.get('Message', '?'))}")
        if len(errors_list) > 5:
            print(f"    ... and {len(errors_list) - 5} more")

    print(f"  Done — {counter.total:,} {label} deleted.")
    return counter.total


def delete_plain(s3_client, bucket, threads):
    """Delete all objects from a non-versioned bucket."""
    print("\n  Deleting objects (no versioning)...")
    counter = ProgressCounter("objects")
    errors_list = []
    futures = []

    paginator = s3_client.get_paginator("list_objects_v2")

    with ThreadPoolExecutor(max_workers=threads) as pool:
        for page in paginator.paginate(Bucket=bucket):
            items = page.get("Contents") or []
            if not items:
                continue
            batch = [{"Key": obj["Key"]} for obj in items]
            futures.append(
                pool.submit(delete_batch, s3_client, bucket, batch, counter, errors_list)
            )

        for f in as_completed(futures):
            exc = f.exception()
            if exc:
                print(f"\n  ERROR in worker: {exc}", file=sys.stderr)

    print()
    if errors_list:
        print(f"  WARNING: {len(errors_list)} item(s) failed to delete.")
    print(f"  Done — {counter.total:,} objects deleted.")
    return counter.total


def abort_multipart_uploads(s3_client, bucket):
    """Abort all incomplete multipart uploads."""
    paginator = s3_client.get_paginator("list_multipart_uploads")
    count = 0
    try:
        for page in paginator.paginate(Bucket=bucket):
            for upload in page.get("Uploads") or []:
                s3_client.abort_multipart_upload(
                    Bucket=bucket,
                    Key=upload["Key"],
                    UploadId=upload["UploadId"],
                )
                print(f"  Aborted: {upload['Key']} ({upload['UploadId']})")
                count += 1
    except ClientError as e:
        print(f"  Warning: could not list multipart uploads — {e}")
    return count


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    args = parse_args()
    bucket = args.bucket
    threads = args.threads

    print(f"WARNING: This will permanently delete ALL objects in bucket: s3://{bucket}")
    confirm_name = input("Type the bucket name to confirm: ").strip()
    if confirm_name != bucket:
        print("Confirmation did not match. Aborting.")
        sys.exit(1)

    # Build session
    try:
        session = boto3.Session(profile_name=args.profile)
    except ProfileNotFound:
        print(f"ERROR: AWS profile '{args.profile}' not found.")
        sys.exit(1)

    s3 = session.client("s3")

    # Identity
    try:
        account_id, user_arn = get_identity(session)
    except (NoCredentialsError, ClientError) as e:
        print(f"ERROR: Unable to retrieve AWS identity — {e}")
        sys.exit(1)

    region = get_region(session)

    print(f"""
--- AWS Identity ---
  Account ID : {account_id}
  Identity   : {user_arn}
  Region     : {region}
  Bucket     : s3://{bucket}
  Threads    : {threads}
--------------------""")

    if not confirm(f"Proceed with emptying s3://{bucket} in account {account_id}? [y/N] "):
        print("Aborted.")
        sys.exit(0)

    # Bucket info
    print("\n--- Bucket Info ---")
    bucket_region = get_bucket_region(s3, bucket)
    print(f"  Bucket Region : {bucket_region}")

    versioning = get_versioning(s3, bucket)
    print(f"  Versioning    : {versioning}")

    print("  Fetching size and object count from CloudWatch metrics (daily granularity)...")
    # Use a region-specific CloudWatch client matching the bucket's region
    cw_session = boto3.Session(profile_name=args.profile, region_name=bucket_region)
    size_str, count_str = get_cloudwatch_stats(cw_session, bucket)
    print(f"  Total Objects : {count_str}  (approx, updated daily)")
    print(f"  Total Size    : {size_str}  (approx, updated daily)")

    if versioning in ("Enabled", "Suspended"):
        vc, mc = get_first_page_counts(s3, bucket)
        print(f"  Versions      : {vc}  (first page only, capped at 1000)")
        print(f"  Delete Markers: {mc}  (first page only, capped at 1000)")

    print("-------------------\n")

    if not confirm(f"Confirmed — permanently delete everything in s3://{bucket}? [y/N] "):
        print("Aborted.")
        sys.exit(0)

    # Use a region-aware S3 client for all deletions to avoid cross-region redirect overhead
    s3 = session.client("s3", region_name=bucket_region)

    delete_start = time.monotonic()

    if versioning in ("Enabled", "Suspended"):
        delete_versioned(s3, bucket, "Versions",      "versions", threads)
        delete_versioned(s3, bucket, "DeleteMarkers", "markers",  threads)
    else:
        delete_plain(s3, bucket, threads)

    print("\nAborting any incomplete multipart uploads...")
    aborted = abort_multipart_uploads(s3, bucket)
    if aborted == 0:
        print("  None found.")

    elapsed = time.monotonic() - delete_start
    print(f"\nDone. Bucket s3://{bucket} is now empty.")
    print(f"Time taken: {fmt_elapsed(elapsed)}")


if __name__ == "__main__":
    main()
