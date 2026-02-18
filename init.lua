local HOME = vim.env.HOME
local vimrc = HOME .. '/.vimrc'

-- Global Options

vim.opt.runtimepath:prepend(HOME .. '/.vim')
vim.opt.runtimepath:append(HOME .. '/.vim/after')
vim.o.packpath = vim.o.runtimepath

if vim.uv.fs_stat(vimrc) then
    vim.cmd.source(vimrc)
else
    vim.o.exrc = true
    vim.o.number = true
    vim.o.relativenumber = true
    vim.o.expandtab = true
    vim.o.hidden = true
    vim.o.autoindent = true
    vim.o.smartcase = true
    vim.o.ignorecase = true
    vim.o.backup = false
    vim.o.swapfile = false

    vim.o.softtabstop = 4
    vim.o.shiftwidth = 4
    vim.o.textwidth = 77

    vim.o.bg = "dark"

    vim.opt.backspace = {'indent', 'eol', 'start'}
    vim.opt.cino = { "(0", "W2s" }
end

vim.o.tabclose = 'uselast'
vim.o.showtabline = 2   -- always show

-- Tell netrw to display relative line numbers
vim.g.netrw_bufsettings = "noma nomod nonu nobl nowrap ro rnu"

-- Set bg color to very, very dark blue
vim.api.nvim_set_hl(0, "Normal", { bg = "#000016" })

require"config.keymap"
require"config.autocmd"
require"config.cmd"
require"config.tmux"
require"config.ui"
require"config.todo"

local opt = { mason_packages = {} }
if vim.uv.fs_stat(vim.fn.stdpath('config') .. "/lua/config/local.lua")
then
    opt = require("config.local")
end

-- Load config.lazy only if at least one plugin is enabled
do
    local plugins = vim.fn.readdir(vim.fn.stdpath"config"
        .. "/lua/lazy-enabled")
    for _, file in ipairs(plugins) do
        if string.match(file, "%.lua$") then
            require"config.lazy"
            break
        end
    end
end

if package.loaded["mason"] ~= nil then
    -- MUST come after config.lazy:
    require("config.lsp").setup(opt.mason_packages or {})
end
