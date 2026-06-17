require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")


if require("nvconfig").ui.tabufline.enabled then
    map("n", "<C-S-kPageUp>", function()
        require("nvchad.tabufline").move_buf(-1)
    end, {desc = 'Move Buffer Right'})
    map("n", "<C-S-kPageDown>", function()
        require("nvchad.tabufline").move_buf(1)
    end, {desc = 'Move Buffer Left'})
end

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
