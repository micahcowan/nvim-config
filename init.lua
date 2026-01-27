-- -- This config file is set up to install and load various handlers and
-- -- LSPs for a variety of languages. Using them requires installation of
-- -- a number of tools and resources, which might not be available or
-- -- which one might not wish to install immediately on a new system,
-- -- while still wishing to take advantage of other aspects of this
-- --     Neovim config.
-- --
-- -- In consideration of this, these plugins and LSPs are disabled by
-- -- default, until explicitly enabled by local config.
-- --
-- -- To enable installation of these LSPs and supporting plugins, place
-- -- the following contents into ~/.config/nvim/lua/config/local.lua (or
-- -- select just the specific ones you care about)
--
--      return {
--          mason_packages = {
--              'vtsls',
--              'bash-language-server',
--              'clangd',
--              'basedpyright',
--              'perlnavigator',
--              'lua-language-server',
--          }
--      }

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

-- Set bg color to very, very dark blue
vim.api.nvim_set_hl(0, "Normal", { bg = "#000016" })

vim.keymap.set('n', '<C-W><C-]>', ':tab split<CR><C-]>')
vim.keymap.set('n', '<C-W><C-T>', ':tab split<CR>')
vim.keymap.set('n', '<C-W><C-H>', ':tab help ')
vim.keymap.set('n', '<C-W><C-Q>', ':tabclose<CR>')

-- Open config
vim.keymap.set('n', 'gC',
    [[:tab split ~/.config/nvim/init.lua
      :tcd ~/.config/nvim
    ]])

-- In 'help' buffer, Tab seeks to next tag
vim.api.nvim_create_autocmd('BufAdd', {
    callback = function(opts)
        if vim.o.buftype == 'help' then
            vim.api.nvim_buf_set_keymap(
                opts.buf, 'n', '<Tab>',
                '/\\([|\'`]\\)[^ ]*\\1<CR>:nohls<CR>', { noremap = true })
            vim.api.nvim_buf_set_keymap(
                opts.buf, 'n', '<S-Tab>',
                '?\\([|\'`]\\)[^ ]*\\1<CR>:nohls<CR>', { noremap = true })
        end
    end,
})

vim.api.nvim_create_autocmd({'BufWinEnter', 'BufEnter'}, {
    callback = function()
        if vim.o.buftype == 'help' then
            -- vim.api.nvim_set_option_value('relativenumber', true,
            --     { buf = opts.buf, scope = 'local' })
            vim.wo.relativenumber = true
        end
    end,
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
