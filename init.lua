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
vim.keymap.set('n', '<C-W>t', ':tab split<CR>')
vim.keymap.set('n', '<C-W>h', ':tab help ')

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
    callback = function(opts)
        if vim.o.buftype == 'help' then
            -- vim.api.nvim_set_option_value('relativenumber', true,
            --     { buf = opts.buf, scope = 'local' })
            vim.wo.relativenumber = true
        end
    end,
})

require("config.tmux")
require("config.ui")
require("config.lazy")
require("config.lsp") -- MUST come after config.lazy
