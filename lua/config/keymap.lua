-- config.keymap: GENERAL KEYMAP CHANGES --

local util = require 'mjc-util'

vim.keymap.set('n', '<C-W><C-]>', ':tab split<CR><C-]>')
vim.keymap.set('n', '<C-W><C-T>', ':tab split<CR>')

-- For MacBook Pro, which lacks some keys
vim.keymap.set({'n','t'}, '<D-Left>', ':tabprev<CR>')
vim.keymap.set({'n','t'}, '<D-Right>', ':tabnext<CR>')
vim.keymap.set({'n','t'}, '<A-Left>', ':tabprev<CR>')
vim.keymap.set({'n','t'}, '<A-Right>', ':tabnext<CR>')

-- Execute line or selected block of lua code
vim.keymap.set('n', 'g==', ':. lua<CR>', { noremap = true })
-- following line will get '<.'> prepended automatically!
vim.keymap.set('v', 'g==', ":lua<CR>",   { noremap = true })

vim.keymap.set('n', '<C-W>o', '', {
    desc = [[Close all but current window, unless there's a terminal]],
    callback = function()
        local terms = util.get_terms_in_curtab()

        if #terms ~= 0 then
            vim.notify(
                "Not closing other windows: TERMINAL present!",
                vim.log.levels.ERROR,
                {}
            )
        else
            vim.cmd.wincmd('o')
        end
    end,
})

vim.keymap.set('n', '<C-W><C-Q>', '', {
    desc = [[:tabclose, but unload any terminal windows]],
    callback = function()
        local tnr = vim.api.nvim_get_current_tabpage()
        local wins = vim.api.nvim_tabpage_list_wins(tnr)
        local terms = util.filter_term_wins(wins)
        for _, term in ipairs(terms) do
            local termbuf = vim.api.nvim_win_get_buf(term)
            local attached = vim.fn.win_findbuf(termbuf)
            if #attached == 1 then
                -- terminal not attached anywhere else.
                -- We don't want hidden terminals left running
                -- (unless we're explicit about it), so kill it
                vim.cmd.bwipeout({ args = { termbuf }, bang = true })
            end
        end
        if #wins ~= #terms then
            vim.cmd.tabclose()
        --  else: all windows removed, tabs already closed
        end
    end,
})

-- Open help in new tab
vim.keymap.set('n', '<C-W><C-H>', ':tab help ')
vim.keymap.set('v', '<C-W><C-H>', '', {
    callback = function()
        local p1 = vim.fn.getpos('.')
        local p2 = vim.fn.getpos('v')
        local helpstr  = vim.fn.getregion(p1, p2)[1]
        vim.cmd.help {
            args = { helpstr },
            mods = {
                tab = vim.api.nvim_get_current_tabpage(),
            },
        }
    end
})

-- Open config
vim.keymap.set('n', 'gC', '', {
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
        if tabname ~= nil and tabname.set ~= nil then
            local tnr = vim.api.nvim_get_current_tabpage()
            tabname.set(tnr, 'CONFIG')
        end
    end})

-- Set local dir to buffer's dir
vim.keymap.set('n', 'g<C-L>', ':lcd %:p:h<CR>')
-- Set tab-local dir to buffer's dir
vim.keymap.set('n', 'g<C-T>', ':tcd %:p:h<CR>')
