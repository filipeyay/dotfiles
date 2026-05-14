-- background
vim.api.nvim_set_hl(0, "Normal", { bg = "#101010" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#101010" })

-- cliboard
vim.opt.clipboard = "unnamedplus"

-- show line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- identation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- syntax highlight
vim.cmd("syntax on")

-- true color
vim.opt.termguicolors = true

-- auto close
local autopairs = {
    ["("] = ")",
    ["["] = "]",
    ["{"] = "}",
    ['"'] = '"',
    ["'"] = "'"
}

for open, close in pairs(autopairs) do
    vim.keymap.set("i", open, open .. close .. "<Left>")
end
