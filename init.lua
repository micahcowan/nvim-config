local HOME = vim.env.HOME
local vimrc = HOME .. '/.vimrc'

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

vim.keymap.set('n', '<C-W><C-]>', ':tab split<CR><C-]>')
vim.keymap.set('n', '<C-W><C-T>', ':tab split<CR>')
vim.keymap.set('n', '<C-W><C-H>', ':tab help ')
vim.keymap.set('n', '<C-W><C-Q>', ':tabclose<CR>')

-- For MacBook Pro, which lacks some keys
vim.keymap.set({'n','t'}, '<D-Left>', ':tabprev<CR>')
vim.keymap.set({'n','t'}, '<D-Right>', ':tabnext<CR>')
vim.keymap.set({'n','t'}, '<A-Left>', ':tabprev<CR>')
vim.keymap.set({'n','t'}, '<A-Right>', ':tabnext<CR>')

-- Execute line or selected block of lua code
vim.keymap.set('n', 'g==', ':. lua<CR>', { noremap = true })
-- following line will get '<.'> prepended automatically!
vim.keymap.set('v', 'g==', ":lua<CR>",   { noremap = true })

-- Open config
vim.keymap.set('n', 'gC', '', {
    noremap = true,
    callback = function()
        vim.cmd([[
              :tab new
              :tcd ~/.config/nvim/lua/config
              :edit ~/.config/nvim/init.lua
              :vertical split
              :wincmd b
              :terminal
              :normal 1G
              :startinsert
            ]])
        local _, tabname = pcall(function()
            return require'tabby.feature.tab_name' end)
        if tabname ~= nil then
            local tnr = vim.api.nvim_get_current_tabpage()
            tabname.set(tnr, 'CONFIG')
        end
    end})

-- Set local dir to buffer's dir
vim.keymap.set('n', 'g<C-L>', ':lcd %:p:h<CR>')
-- Set tab-local dir to buffer's dir
vim.keymap.set('n', 'g<C-T>', ':tcd %:p:h<CR>')

vim.api.nvim_create_augroup('mcowan-init', {})

-- Bindings to jump forward/back by hyperlink
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'help',
    callback = function(opts)
        vim.wo.relativenumber = true

        vim.keymap.set('n', '<Tab>', '', {
            callback = function()
                vim.fn.search('\\([|\'`]\\)[^ ]*\\1')
            end,
            noremap = true,
        })
        vim.keymap.set('n', '<S-Tab>', '', {
            callback = function()
                vim.fn.search('\\([|\'`]\\)[^ ]*\\1', 'b')
            end,
            noremap = true,
        })
    end,
    group = 'mcowan-init'
})

-- help/man keybindings to be more like "less" (the pager)
vim.api.nvim_create_autocmd('FileType', {
    pattern = {'help', 'man'},
    callback = function()
        vim.keymap.set('n', '<Space>', '<C-F>', { noremap = true })
        vim.keymap.set('n', 'b', '<C-B>', { noremap = true })
        -- Man already has this, but help doesn't:
        vim.keymap.set('n', 'q', ':q<CR>', { noremap = true })
    end,
    group = 'mcowan-init',
})

require("config.tmux")
require("config.ui")
local opt = { mason_packages = {} }
if vim.uv.fs_stat(vim.fn.stdpath('config') .. "/lua/config/local.lua")
then
    opt = require("config.local")
end

if opt.mason_packages and #opt.mason_packages > 0 then
    require("config.lazy")
    -- MUST come after config.lazy:
    require("config.lsp").setup(opt.mason_packages or {})
end
