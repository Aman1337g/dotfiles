-- Auto-start preview
vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 1
vim.g.mkdp_refresh_slow = 0
vim.g.mkdp_command_for_global = 0
vim.g.mkdp_open_to_the_world = 0
vim.g.mkdp_open_ip = ""
vim.g.mkdp_echo_preview_url = 0

-- vim.g.mkdp_browserfunc = "MkdpBrowserFn"
-- local cmd = "brave-browser"
-- vim.api.nvim_exec2(
--   string.format(
--     [[
--                 function! MkdpBrowserFn(url)
--                     execute '!%s' a:url
--                 endfunction
--                 ]],
--     cmd
--   ),
--   {}
-- )

-- Use qutebrowser as the preview browser
vim.g.mkdp_browserfunc = "MkdpQutebrowserFn"
vim.api.nvim_exec2(
  [[
  function! MkdpQutebrowserFn(url)
      " Launch qutebrowser in a non-blocking way
     call jobstart(['/home/aman/qutebrowser/.venv/bin/python3', '-m', 'qutebrowser', a:url])
  endfunction
  ]],
  {}
)

-- Preview options
vim.g.mkdp_preview_options = {
  mkit = {},
  katex = {},
  uml = {},
  maid = {},
  disable_sync_scroll = 0,
  sync_scroll_type = "middle",
  hide_yaml_meta = 1,
  sequence_diagrams = {},
  flowchart_diagrams = {},
  content_editable = false,
  disable_filename = 0,
  toc = {},
}

-- Optional settings
vim.g.mkdp_markdown_css = ""
vim.g.mkdp_highlight_css = ""
vim.g.mkdp_port = "8177"
vim.g.mkdp_page_title = "「${name}」"
vim.g.mkdp_filetypes = { "markdown" }
vim.g.mkdp_theme = "dark"
vim.g.mkdp_combine_preview = 0
vim.g.mkdp_combine_preview_auto_refresh = 1
