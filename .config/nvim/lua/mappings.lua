require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("n", "<leader>ss", "<cmd> :wqa <cr>", { desc = "Save and Close all"})
map("n", "<leader>z", "<cmd> :qa <cr>", { desc = "Close all without save"})


map("i", "jk", "<ESC>")


-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
