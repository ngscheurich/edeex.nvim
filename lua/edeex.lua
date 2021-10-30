local function show_error(msg) error("[EdEEx] " .. msg) end
local function show_message(msg) vim.cmd(string.format("echomsg '[EdEEx] %s'", msg)) end

local exists, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
if not exists then show_error("nvim-treesitter is required") end

local M = {}

local function markers(node)
  local start, col = node:start()
  local end_ = node:end_()

  local indent = ""
  for _ = 1, col do indent = indent .. " " end

  return start, end_, indent
end

local function set_buf_opts(buf, src_buf)
  vim.api.nvim_buf_set_option(buf, "filetype", "eelixir")

  for _, opt in pairs({"shiftwidth", "tabstop", "softtabstop"}) do
    local src_opt = vim.api.nvim_buf_get_option(src_buf, opt)
    vim.api.nvim_buf_set_option(buf, opt, src_opt)
  end
end

local function set_buf_mapping(buf, src_buf, start, end_, indent)
  local lhs = vim.g.edeex_mapping

  local cmd_str = "lua require('edeex').apply(%s, %s, %s, %s, '%s')"
  local cmd = string.format(cmd_str, buf, src_buf, start + 1, end_, indent)

  vim.api.nvim_buf_set_keymap(buf, "n", lhs, "<Cmd>" .. cmd .. "<CR>", {noremap = true})
  vim.api.nvim_buf_set_keymap(buf, "i", lhs, "<Cmd>" .. cmd .. "<CR>", {noremap = true})
end

local function format_current_buf()
  if vim.g.edeex_autoformat then
    vim.cmd("silent normal gg=G")
  end
end

local function show_instructions()
  local instructions = "Leave buffer to apply changes"
  if vim.g.edeex_mapping then
    local mapping = vim.g.edeex_mapping
    instructions = string.format("%s or leave buffer to apply changes", mapping)
  end

  show_message(instructions)
end

local function edit_eex(node)
  local src_buf = vim.api.nvim_buf_get_number(0)
  local start, end_, indent = markers(node)

  local buf = vim.api.nvim_create_buf(false, true)

  local quoted_content = ts_utils.get_node_text(node:child(3))
  local lines = {}
  for i, line in ipairs(quoted_content) do
    if i ~= 1 and i < #quoted_content then
      table.insert(lines, line)
    end
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)

  set_buf_opts(buf, src_buf)
  set_buf_mapping(buf, src_buf, start, end_, indent)

  if vim.g.edeex_split then vim.cmd("split") end
  vim.cmd("buffer " .. buf)
  format_current_buf()

  if vim.g.edeex_command then vim.cmd("delcommand EExEdit") end

  show_instructions()
end

function M.edit()
  local node = ts_utils.get_node_at_cursor():parent()

  if node:type() == "sigil" then
    local sigil_name_node = node:child(1)
    local sigil_type = ts_utils.get_node_text(sigil_name_node)[1]

    if sigil_type == "L" or sigil_type == "H" then
      edit_eex(node)
    else
      show_message("Not in a LEEx or HEEx template block")
    end
  end
end

function M.apply(buf, src_buf, start, end_, indent)
  format_current_buf()

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
  for i, line in ipairs(lines) do lines[i] = indent .. line end

  vim.api.nvim_buf_set_lines(src_buf, start, end_, true, lines)

  if vim.g.edeex_split then vim.cmd("close") end
  vim.cmd("buffer " .. src_buf)

  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, {force = true})
  end

  show_message("Changes applied")
end

function M.setup(opts)
  local mapping = opts.mapping
  vim.g.edeex_mapping = mapping

  if mapping then
    local auprefix = "autocmd edeex BufRead *.ex,*.exs"

    vim.cmd("augroup edeex | autocmd! | augroup END")
    vim.cmd(string.format("%s nnoremap %s <Cmd>lua require('edeex').edit()<CR>", auprefix, mapping))
    vim.cmd(string.format("%s inoremap %s <Cmd>lua require('edeex').edit()<CR>", auprefix, mapping))
  end

  local split = opts.split
  if split == nil then split = true end
  vim.g.edeex_split = split

  local autoformat = opts.autoformat
  if autoformat == nil then autoformat = true end
  vim.g.edeex_autoformat = autoformat
end

return M
