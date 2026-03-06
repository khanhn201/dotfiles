require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!


-- local opt = vim.opt
-- opt.wrap = false
-- opt.shiftwidth = 4
-- opt.smartindent = true
-- opt.tabstop = 4
-- opt.softtabstop = 4
-- opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop=2
vim.opt.shiftwidth=2



vim.opt.clipboard = "unnamedplus"
vim.filetype.add({
  extension = {
    usr = 'fortran',
  },
})
