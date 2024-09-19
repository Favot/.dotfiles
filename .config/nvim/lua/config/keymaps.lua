-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- Function to create a new split with an empty buffer
local function new_split(command)
  vim.cmd(command)
  vim.cmd("enew")
end

-- Create custom commands
vim.api.nvim_create_user_command("NewVerticalSplit", function()
  new_split("vnew")
end, {})

vim.api.nvim_create_user_command("NewHorizontalSplit", function()
  new_split("new")
end, {})

-- Set leader key to space
vim.g.mapleader = " "

-- Set up keybindings
-- Open a new vertical split with no file loaded
vim.api.nvim_set_keymap("n", "<Leader>sv", ":NewVerticalSplit<CR>", { noremap = true, silent = true })

-- Open a new horizontal split with no file loaded
vim.api.nvim_set_keymap("n", "<Leader>sh", ":NewHorizontalSplit<CR>", { noremap = true, silent = true })

-- Close the current split view
vim.api.nvim_set_keymap("n", "<Leader>sx", ":close<CR>", { noremap = true, silent = true })

-- Add comments explaining each keybinding
vim.cmd([[
  " <Space>sv - Open a new vertical split with no file loaded
  " <Space>sh - Open a new horizontal split with no file loaded
  " <Space>sx - Close the current split view
]])
