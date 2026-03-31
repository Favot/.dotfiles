-- Swift LSP configuration (sourcekit-lsp from Xcode)
-- Install: Xcode command line tools provide sourcekit-lsp
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          -- sourcekit-lsp comes from Xcode
          cmd = { "sourcekit-lsp" },
          -- For Swift works perfectly, for ObjC/C++ useful too
          filetypes = { "swift", "objective-c", "objective-cpp", "c", "cpp" },
        },
      },
    },
  },
  -- Treesitter for Swift
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "swift" },
    },
  },
}