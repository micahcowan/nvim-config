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

local todo_date_re = "^\\(Sunday\\|Monday\\|Tuesday\\|Wednesday\\|Thursday\\|Friday\\|Saturday\\),\\? \\+2[0-9]\\{3\\}-[01][0-9]"
-- Go to the right window of the TODO tab, open the current
-- month's journal, and position cursor at buffer end
local journal_entry = function(move_entry)
    open_todo_tab()
    -- Go to TODAY, and get the date from the first entry found
    vim.cmd.wincmd('t')
    util.maybe_edit(0, vim.env.HOME .. "/TODO/JOURNAL/TODAY")
    vim.fn.cursor(1,1)
    local lnum
    lnum = vim.fn.search(todo_date_re, 'cW')
    lnum = lnum - 1 -- 0-based (API) indexing
    if lnum == -1 then
        vim.notify("No date entry found in TODAY!", vim.log.levels.WARN)
        return
    end
    local line = util.get_line(0, lnum)

    local month = util.parse_month(line)
    lnum = lnum + 1 -- convert back to 1-based (vim) line indexing

    -- Now find the *next* occurrance of a date, or a lone period on its
    -- own, or the end of the file
    local nxlnum = vim.fn.search(todo_date_re, 'W')
    if nxlnum == 0 or nxlnum == lnum then
        -- didn't find a following date
        -- search for "." alone on a line
        nxlnum = vim.fn.search("^.$", 'W')
    end
    if nxlnum == 0 then
        -- STILL didn't find. Just use end of file
        nxlnum = vim.fn.getpos('$')[2] + 1
    end
    if nxlnum <= lnum then
        vim.notify("Move to journal: nothing to move!",
                   vim.log.levels.WARN)
        vim.notify("(start is " .. lnum .. ", end is " .. nxlnum .. ")",
                   vim.log.levels.WARN)
        return
    end

    if (move_entry) then
        -- Delete the journal entry
        vim.fn.cursor(lnum, 1) -- move cursor to date entry start
        vim.cmd.normal{tostring(nxlnum - lnum) .. 'dd', bang = true} -- perform delete!
    end

    -- Open the month's journal
    vim.cmd.wincmd('b')
    util.maybe_edit(0, vim.env.HOME .. "/TODO/JOURNAL/" .. month .. ".txt")
    vim.cmd.normal{'G', bang = true}

    if (move_entry) then
        -- Ensure the last line is blank, before pasting
        local s = util.get_current_line()
        if s ~= "" then
            -- not blank, add a new empty line
            local last = vim.fn.getpos('$')[2]
            vim.fn.setline(last+1, "")
        end
        -- Paste the deleted journal entry (from "TODAY")
        vim.cmd.normal{'pG', bang = true}

        -- Return to TODAY, delete any . at the top, and start a new date
        -- entry if there are none
        vim.cmd.wincmd('t')
        s = util.get_current_line()
        if s == "." then
            vim.cmd.normal{'dd', bang = true}
        end

        local found = vim.fn.search(todo_date_re, 'c')
        if found == 0 then
            -- Create day entry!
            local keys = vim.api.nvim_replace_termcodes('<C-T>d',
                true, false, true)
            vim.fn.feedkeys(keys)
        end
    end

    -- done!
end
vim.keymap.set({'n', 't'}, '<C-A>j', function() journal_entry(true) end)
vim.keymap.set({'n', 't'}, '<C-A>J', function() journal_entry(false) end)


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
        for _, key in ipairs({'t','r','n', 'j'}) do
            vim.keymap.set('n', "g" .. key, "<C-A>" .. key, {
                nowait = true,
                buffer = b,
                remap = true,
            })
        end
    end,
    group = 'mcowan-local',
})
