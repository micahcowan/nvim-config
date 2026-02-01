-- config.keymap: GENERAL KEYMAP CHANGES --

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
