-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local cowboy = require("favot/discipline")
cowboy.cowboy()

local keymaps = vim.keymap
local opts = { noremap = true, silent = true }

-- Select all files
keymaps.set("n", "<C-a>", "gg<S-v>G")

-- New tabs
keymaps.set("n", "te", ":tabedit", opts)
keymaps.set("n", "<tab>", ":tabnext<Return>", opts)
keymaps.set("n", "<s-tab>", ":tabprev<Return>", opts)

-- Slipt windows
keymaps.set("n", "ss", ":split<Return>", opts)
keymaps.set("n", "sv", ":vsplit<Return>", opts)

-- Move windows
keymaps.set("n", "sh", "<C-w>h", opts)
keymaps.set("n", "sk", "<C-w>k", opts)
keymaps.set("n", "sj", "<C-w>j", opts)
keymaps.set("n", "sl", "<C-w>l", opts)

-- Resize windows
keymaps.set("n", "<C-w>left", "<C-w><", opts)
keymaps.set("n", "<C-w>right", "<C-w>>", opts)

-- Diagnostic
keymaps.set("n", "<C-j>", function()
  vim.diagnostic.goto_next()
end, opts)

-- Harpoon config
local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>a", mark.add_file)
vim.keymap.set("n", "<leader>h", ui.toggle_quick_menu)

vim.keymap.set("n", "<C-1>", function()
  ui.nav_file(1)
end)
vim.keymap.set("n", "<C-2>", function()
  ui.nav_file(2)
end)
vim.keymap.set("n", "<C-3>", function()
  ui.nav_file(3)
end)
vim.keymap.set("n", "<C-4>", function()
  ui.nav_file(4)
end)

vim.opt.scrolloff = 8

-- Move  higlighted line up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", opts)
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", opts)

-- Kee  cursor centered
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)

-- keep search results centered
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)

-- Keep copied text in the clipboard
vim.keymap.set("x", "<leader>p", '"_dP', opts)

-- copy to clipboard
vim.keymap.set("v", "<leader>y", '"+y', opts)
vim.keymap.set("n", "<leader>y", '"+y', opts)
vim.keymap.set("n", "<leader>Y", "+Y", opts)

vim.keymap.set("n", "<leader>S", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], opts)
