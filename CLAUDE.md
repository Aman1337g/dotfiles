@AGENTS.md

- Use the Edit/Write tools for file changes — never `sed -i`, heredocs, or `python3 -c` to write a repo file.
- This sandbox cannot sign commits — never add `--no-gpg-sign`; hand over a copy-paste `git commit -S -m` block instead.
- If `gh`/`git` network calls are denied, say so plainly and ask — don't fabricate stub binaries to fake a result.
