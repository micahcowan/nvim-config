-- config.akamai.todo: Akamai-specific todo stuff

local util = require 'mjc-util'

-- TODO engine

local function get_tabbies()
    return {
        tn = require('tabby.feature.tab_name'),
    }
end

local function find_todo_tab()
    local t = get_tabbies()
    if t == nil then return nil end
    local tabs = vim.api.nvim_list_tabpages()

    for _, tnr in ipairs(tabs) do
        local name = t.tn.get(tnr)
        if name == 'TODO' then
            return tnr
        end
    end
    return nil
end

local function create_todo_tab()
    local t = get_tabbies()

    vim.cmd(
        [[
            tab split
            tabmove 0
            edit ~/TODO/JOURNAL/TODAY
            vertical split
            wincmd w
            edit ~/TODO/RADAR
            wincmd w
            tcd ~/TODO
        ]])
    local tnr = vim.api.nvim_get_current_tabpage()
    t.tn.set(tnr,'TODO')
    return tnr
end

local function find_or_create_todo_tab()
    local tnr = find_todo_tab()
    if tnr ~= nil then
        return tnr
    else
        return create_todo_tab()
    end
end

local function open_todo_tab()
    local tnr = find_or_create_todo_tab()
    vim.api.nvim_set_current_tabpage(tnr)
end

local function open_in_right_tab(fname)
    open_todo_tab()
    vim.cmd.wincmd('b')
    util.maybe_edit(0, fname)
end

local function make_rtab_opener(fname)
    return function()
        open_in_right_tab(fname)
    end
end

-- Go to the left window of the TODO tab, open TODO/JOURNAL/TODAY in it
-- (create TODO tab if doesn't exist)
vim.keymap.set({'n','t'}, '<C-A>t', function()
    open_todo_tab()
    vim.cmd.wincmd('t')
    util.maybe_edit(0, vim.env.HOME .. "/TODO/JOURNAL/TODAY")
end)
-- Go to the right window of the TODO tab, open TODO/RADAR in it
vim.keymap.set({'n','t'}, '<C-A>r', make_rtab_opener(vim.env.HOME .. "/TODO/RADAR"))
-- Go to the right window of the TODO tab, open the command line
--   with ":edit ~/TODO/NOTES/" in it
vim.keymap.set({'n','t'}, '<C-A>n', function()
    open_todo_tab()
    vim.cmd.wincmd('b')
    vim.api.nvim_feedkeys(":edit ~/TODO/NOTES/", 'n', false)
end)
-- Go to the right window of the TODO tab, open the current month's journal
-- vim.keymap.set({'

-- Associate 'mjc-todo' filetype
vim.api.nvim_create_augroup('mcowan-local', {})
vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
    pattern = vim.env.HOME .. '/TODO/*',
    callback = function(opts)
        local b = opts.buf
        vim.api.nvim_set_option_value('filetype', 'mjc-todo', { buf = b })

        -- Add NOTES dir to path, so we can jump there from RADAR
        vim.api.nvim_set_option_value('path', vim.env.HOME .. "/TODO/NOTES", {buf=b})

        -- Convenient aliases for <C-A>{t,r,n}
        for _, key in ipairs({'t','r','n'}) do
            vim.keymap.set('n', "g" .. key, "<C-A>" .. key, {
                nowait = true,
                buffer = b,
                remap = true,
            })
        end
    end,
    group = 'mcowan-local',
})
