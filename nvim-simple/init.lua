
-- Mostrar números das linhas
vim.opt.number = true
vim.opt.relativenumber = true

-- Indentação básica
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Syntax highlight
vim.cmd("syntax on")

-- True color
vim.opt.termguicolors = true

-- Auto fechar pares
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
