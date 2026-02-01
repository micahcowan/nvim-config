-- Bindings and functionality to make using vim a bit more like
-- what I'm used to with tmux

vim.keymap.set('t', '<C-A>', '<C-\\><C-N>', { noremap = true })
vim.keymap.set('t', '<C-A>', '<C-\\><C-N>', { noremap = true })
vim.keymap.set('t', '<C-A>[', '<C-\\><C-N>', { noremap = true })
vim.keymap.set({'t','n'}, '<C-A>m', '<C-\\><C-N>:tab Man ',
    { noremap = true })
vim.keymap.set('t', '<C-kPageDown>', '<C-\\><C-N><C-kPageDown>',
    { noremap = true })
vim.keymap.set('t', '<C-kPageUp>', '<C-\\><C-N><C-kPageUp>',
    { noremap = true })
vim.keymap.set('n', '<C-a>|', '<C-w>v<C-w>w', { noremap = true })
vim.keymap.set({'n','t'}, '<C-A><C-A>', '<C-\\><C-N>g<Tab>',
    { noremap = true })
vim.keymap.set({'n','t'}, '<C-A>e', '<C-\\><C-N>:tab new\n:edit ',
    { noremap = true })
vim.keymap.set('t', '<C-A>]', '<C-\\><C-O>p', { noremap = true })
vim.keymap.set({'n','t'}, '<C-A>c', '<C-\\><C-N>:tab new<CR>:edit .<CR>',
    { noremap = true })

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

-- Bind <C-A>1, <C-A>2, etc, for quick tab-switching
for _, m in ipairs({'n', 't'}) do
    for i = 1,9 do
        vim.keymap.set(m, '<C-A>' .. i, '<C-\\><C-N>:tabnext ' .. i .. '<CR>',
            { noremap = true })
    end
    vim.keymap.set(m, '<C-A>0', '<C-\\><C-N>:tabnext 10<CR>',
            { noremap = true })
end

-- Rename tab (via tabby.nvim!) with <C-A>A (shift-a)
local function prompt_rename_tab()
    local tabname = require('tabby.feature.tab_name')
    vim.ui.input({ prompt = "Rename TAB: " }, function(name)
        if name == nil then return end
        local nr = vim.api.nvim_get_current_tabpage()
        tabname.set(nr, name)
    end)
end
vim.keymap.set({'n','t'}, '<C-A>A', '', {
    noremap = true,
    callback = prompt_rename_tab,
    desc = [[Prompt to rename the current tab]],
})

vim.keymap.set({'n','t'}, '<C-A><Tab>', '', {
    noremap = true,
    callback = function()
        vim.cmd.wincmd('w')
    end,
    desc = [[Equivalent to <C-W><C-W>, but works even while in terminal]],
})

local split_new = function()
    vim.cmd(':vertical split')
    vim.cmd.wincmd('w')
    vim.cmd.terminal()
    vim.cmd.startinsert()
end
vim.keymap.set('n', '<C-A>s', '', {
    callback = split_new,
    desc =
        "Split (vertical) and place a new terminal session at the right",
})
vim.keymap.set('n', '<C-A>S', '', {
    callback = function()
        vim.cmd.tcd('%:p:h')
        split_new()
    end,
    desc =
        "Like <C-A>s, but first set :tcd from current file's containing dir",
})
vim.keymap.set({'n','t'}, '<C-A>C', '', {
    callback = function()
        local dir = vim.fn.expand("%:p:h")
        -- :tab new | tcd %:p:h | terminal
        --   except that %:p:h comes from current buffer, not empty one.
        vim.cmd.new({ mods = { tab = vim.api.nvim_get_current_tabpage() } })
        vim.cmd.tcd(dir)
        vim.cmd.terminal()
        vim.cmd.startinsert()
    end,
    desc = "Create a new terminal tab. :tcd from current file.",
})

vim.keymap.set('n', '<C-W>o', '', {
    desc = [[Close all but current window, unless there's a terminal]],
    callback = function()
        local tnr = vim.api.nvim_get_current_tabpage()
        local wins = vim.api.nvim_tabpage_list_wins(tnr)
        local got_term = false
        for _, wnr in ipairs(wins) do
            local bnr = vim.api.nvim_win_get_buf(wnr)
            local ty = vim.api.nvim_get_option_value(
                'buftype',
                { buf = bnr })
            if ty == 'terminal' then
                got_term = true
                break
            end
        end

        if got_term then
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

vim.api.nvim_create_augroup('mjc-tmux-auto', {})
-- Upon entering a terminal buffer, automatically enter terminal-insert
vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        if vim.o.buftype == 'terminal'
           and vim.api.nvim_get_mode().mode == 'n'
           or  vim.api.nvim_get_mode().mode == 'nt' then

            vim.cmd.startinsert()
        end
    end,
    group = 'mjc-tmux-auto',
})

-- Special (non-insert/T-mode) keybindings and settings for terminals
vim.api.nvim_create_autocmd('TermOpen', {
    callback = function()
        -- like 'q' from copy-mode
        vim.keymap.set('n', 'q', 'i', {
            buffer = true,
            noremap = true,
            nowait = true,
        })
        -- like Space from copy-mode
        vim.keymap.set('n', ' ', 'v', {
            buffer = true,
            noremap = true,
            nowait = true,
        })
        -- like Enter from copy-mode
        vim.keymap.set('v', '<CR>', 'yi', {
            buffer = true,
            noremap = true,
        })
        vim.api.nvim_set_option_value('winfixbuf', true, {
            win = vim.api.nvim_get_current_win()
        })
    end,
    group = 'mjc-tmux-auto',
})

-- netrw: Open file at left, terminal in cwd at right
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'netrw',
    callback = function()
        vim.keymap.set('n', '<C-T>', '', {
            callback = function()
                vim.cmd.normal('\r')
                vim.cmd.tcd('%:p:h')
                split_new()
            end,
            noremap = true,
            buffer = 0,
        })
    end,
    group = 'mjc-tmux-auto',
})
