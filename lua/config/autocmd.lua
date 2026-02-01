-- config.autocmd: MISC AUTOCMD CHANGES

vim.api.nvim_create_augroup('mcowan-init', {})

-- Bindings to jump forward/back by hyperlink
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'help',
    callback = function()
        vim.wo.relativenumber = true

        vim.keymap.set('n', '<Tab>', '', {
            callback = function()
                vim.fn.search('\\([|\'`]\\)[^ ]*\\1')
            end,
            noremap = true,
            buffer = 0,
        })
        vim.keymap.set('n', '<S-Tab>', '', {
            callback = function()
                vim.fn.search('\\([|\'`]\\)[^ ]*\\1', 'b')
            end,
            noremap = true,
            buffer = 0,
        })
        vim.keymap.set('n', '<CR>', '<C-]>', { buffer = 0 })
    end,
    group = 'mcowan-init'
})

-- help/man keybindings to be more like "less" (the pager)
vim.api.nvim_create_autocmd('FileType', {
    pattern = {'help', 'man'},
    callback = function()
        local opts = { noremap = true, buffer = 0 }
        vim.keymap.set('n', '<Space>', '<C-F>', opts)
        vim.keymap.set('n', 'b', '<C-B>', opts)
        -- Man already has this, but help doesn't:
        vim.keymap.set('n', 'q', ':q<CR>', opts)
    end,
    group = 'mcowan-init',
})
