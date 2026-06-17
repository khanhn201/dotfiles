require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "rust-analyzer"}

vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        features = 'all'
      }
    }
  }
})

vim.lsp.enable(servers)
-- read :h vim.lsp.config for changing options of lsp servers
