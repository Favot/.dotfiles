-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local react_native_filetypes = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
}

local function copy_to_clipboard(text)
  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text)

  if vim.fn.has("mac") == 1 and vim.fn.executable("pbcopy") == 1 then
    vim.fn.system("pbcopy", text)
  end
end

local function relative_to_project_root(path)
  local normalized_path = vim.fs.normalize(path)
  local root = vim.fs.root(normalized_path, { ".git" }) or vim.fn.getcwd()
  local normalized_root = vim.fs.normalize(root)
  local prefix = normalized_root .. "/"

  if vim.startswith(normalized_path, prefix) then
    return normalized_path:sub(#prefix + 1)
  end

  return vim.fn.fnamemodify(normalized_path, ":.")
end

vim.keymap.set("n", "gf", function()
  if react_native_filetypes[vim.bo.filetype] and #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
    vim.lsp.buf.definition()
    return
  end

  vim.cmd.normal({ args = { "gf" }, bang = true })
end, { desc = "Go to component or file" })

vim.keymap.set({ "n", "i", "v" }, "<D-w>", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.bufdelete then
    snacks.bufdelete()
    return
  end

  vim.cmd.bdelete()
end, { desc = "Delete buffer" })

vim.keymap.set({ "n", "i", "v" }, "<D-S-c>", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file in current buffer", vim.log.levels.WARN)
    return
  end

  local relative = relative_to_project_root(file)
  copy_to_clipboard(relative)
  vim.notify("Copied: " .. relative)
end, { desc = "Copy relative file path" })
