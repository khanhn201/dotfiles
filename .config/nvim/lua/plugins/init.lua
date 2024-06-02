return {
    {
        "stevearc/conform.nvim",
        -- event = 'BufWritePre', -- uncomment for format on save
        config = function()
          require "configs.conform"
        end,
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
          require("nvchad.configs.lspconfig").defaults()
          require "configs.lspconfig"
        end,
    },
    {
        "norcalli/nvim-colorizer.lua",
    },
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "lua-language-server", "stylua",
                "html-lsp", "css-lsp" , "prettier"
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
  	    opts = {
  		    ensure_installed = {
  			    "vim", "lua", "vimdoc",
                "html", "css"
  	        },
  	    },
    },
    {
        "lervag/vimtex",
        ft = { "tex" },
        init = function()
          vim.g.tex_flavor = "latex"
          vim.g.vimtex_quickfix_mode = 0
          vim.g.vimtex_mappings_enabled = 0
          vim.g.vimtex_indent_enabled = 0

          vim.g.vimtex_view_method = "zathura"
          vim.g.vimtex_context_pdf_viewer = "zathura"
        end
    }
}
