-- Bindings and functionality to make using vim a bit more like
-- what I'm used to with tmux

vim.keymap.set('t', '<C-A>', '<C-\\><C-N>', { noremap = true })
vim.keymap.set('t', '<C-A>', '<C-\\><C-N>', { noremap = true })
vim.keymap.set('t', '<C-A>[', '<C-\\><C-N>', { noremap = true })
vim.keymap.set('t', '<C-A>m', '<C-\\><C-N>:tab Man ',
    { noremap = true })
vim.keymap.set('t', '<C-kPageDown>', '<C-\\><C-N><C-kPageDown>',
    { noremap = true })
vim.keymap.set('t', '<C-kPageUp>', '<C-\\><C-N><C-kPageUp>',
    { noremap = true })
vim.keymap.set('n', '<C-a>|', '<C-w>v<C-w>w', { noremap = true })

-- Send raw C-a, if C-a a is typed
vim.keymap.set('t', '<C-A>a', '', {
    noremap = true,
    callback = function()
        local ctrl_a = vim.api.nvim_replace_termcodes('<C-A>', true, false,
            true)
        vim.api.nvim_paste(ctrl_a, false, -1)
    end,
    desc = [[Send a literal <C-A>]]
})

-- Do a C-W w to switch to another window (even if in terminal-insert
-- mode), and if the new window holds a terminal buffer, enter input mode
local other_wnd = function()
    vim.cmd.wincmd('w') -- Move to other window
    -- if vim.o.buftype == 'terminal' then
    --     vim.api.nvim_feedkeys('i', 'm', false) -- Terminal-insert
    -- end
end
local other_wnd_desc
    = [[Equivalent to <C-W><C-W>, but works even while in terminal]]
vim.keymap.set('t', '<C-A><Tab>', '', {
    noremap = true,
    callback = other_wnd,
    desc = other_wnd_desc,
})
vim.keymap.set('n', '<C-A><Tab>', '', {
    noremap = true,
    callback = other_wnd,
    desc = other_wnd_desc,
})

local create_new = function()
    vim.cmd(':tab new')
    vim.cmd(':vertical split')
    vim.cmd.wincmd('w')
    vim.cmd.terminal()
    vim.cmd.startinsert()
end
local create_new_desc
    = [[Create a new tab with an empty buffer at left, terminal at right]]
vim.keymap.set('t', '<C-A>c', '', {
    callback = create_new,
    desc = create_new_desc,
})
vim.keymap.set('n', '<C-A>c', '', {
    callback = create_new,
    desc = create_new_desc,
})

vim.api.nvim_create_augroup('mjc-tmux-auto', {})
-- Upon entering a terminal buffer, automatically enter terminal-insert
vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        if vim.o.buftype == 'terminal'
           and vim.api.nvim_get_mode().mode == 'n'
           or  vim.api.nvim_get_mode().mode == 'nt' then
            vim.api.nvim_feedkeys('i', 'm', false) -- Terminal-insert
        end
    end,
    group = 'mjc-tmux-auto',
})

-- Terminals get a special, buffer-local binding for the 'q' key,
-- to just re-enter insert mode (to emulate leaving tmux history mode)
vim.api.nvim_create_autocmd('TermOpen', {
    callback = function()
        vim.keymap.set('n', 'q', 'i', {
            buffer = true,
            noremap = true,
            nowait = true,
        })
    end,
    group = 'mjc-tmux-auto',
})
