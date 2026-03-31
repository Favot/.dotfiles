-- Deno LSP configuration (denols)
-- Use with Deno projects - auto-detected via deno.json presence
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        denols = {
          cmd = { "denols" },
          filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
          root_files = { "deno.json", "deno.jsonc" },
          settings = {
            denols = {
              completeEnable = true,
              lint = true,
            },
          },
        },
      },
    },
  },
}