require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "rust-analyzer", "qmlls"}
vim.lsp.enable(servers)

vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        features = 'all'
      }
    }
  }
})

-- read :h vim.lsp.config for changing options of lsp servers
