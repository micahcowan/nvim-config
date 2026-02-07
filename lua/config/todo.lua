-- config.todo: a "mjc-todo" file-type for my TODO files

local util = require "mjc-util"

---- TODO indentation functions ----

vim.g.mjc_todo_bullets = ".-/x|+"
vim.g.mjc_todo_indentkeys = (function()
    local str = "O,o,!^F"
    for i = 1, #vim.g.mjc_todo_bullets do
        local c = string.sub(vim.g.mjc_todo_bullets, i, i)
        str = str .. ",0" .. c
    end
    return str
end)()

local function get_bullet_loc(str)
    local first, loc = util.first_nonspace(str)
    if first == nil then return nil, nil end
    if string.find(vim.g.mjc_todo_bullets, first, 1, true) == nil then
        return nil, loc
    else
        return first, loc
    end
end

local function get_bullet(str)
    return get_bullet_loc(str)
end

local function find_item_bullet()
    local lnum, line = util.get_current_lnum_line()
    local bullet, col = get_bullet_loc(line)
    if bullet ~= nil then return { lnum = lnum, col = col, bullet = bullet } end

    local indent = util.get_indent(line)
    repeat
        lnum = lnum - 1
        line = util.get_line(0, lnum)
        bullet, col = get_bullet_loc(line)
        if bullet ~= nil and col == indent - 2 then
            return { lnum = lnum, col = col, bullet = bullet }
        end
        local idt = util.get_indent(line)
    until idt ~= indent
    return nil
end

local function swap_bullet(...)
    local a, b = ...
    local args
    if type(a) == "string" and type(b) == "string" then
        return swap_bullet({a, b})
    elseif type(a) == "string" and a == "--args--" then
        args = b
    else
        args = {...}
    end

    -- Find bullet location for this item (may be on a preceding line)
    local st = find_item_bullet()
    if st == nil then return false end

    -- Loop over mappings until we find one that matchs the bullet found.
    for _, map in ipairs(args) do
        local seek, replace = map[1], map[2]
        if seek == st.bullet then
            local pos = vim.fn.getpos(".")
            vim.fn.cursor(st.lnum+1, st.col+1)
            vim.print("lnum = " .. st.lnum+1 .. ", col = " .. st.col+1)
            vim.fn.feedkeys('r' .. replace, 'x')
            vim.fn.setpos(".", pos)
        end
    end
    return false
end

local function mk_bullet_swapper(...)
    local args = {...}
    return function()
        return swap_bullet("--args--", args)
    end
end

-- Set 'indentexpr' to v:lua.MjcTodoIndent()
-- GLOBAL
local ident_use_following = false -- set by (wrapped) "O" normal command
function MjcTodoIndent()
    local lnum, line = util.get_current_lnum_line()
    local pnum, prev = util.get_prev_nonempty_lnum_line(0, lnum)
    -- If we're on the first non-empty line, no indent
    if prev == nil then
        return 0
    end

    if ident_use_following then
        -- when 'O' was pressed, use following line's indent instead
        pnum = lnum+1
        prev = util.get_line(0, pnum)
    end

    local bullet = get_bullet(line)
    local prev_indent = util.get_indent(prev)

    -- -- If we're not empty and aren't just a bullet, keep existing indent
    -- Is there an immediately-adjacent, non-empty line?
    if pnum == lnum - 1 or pnum == lnum + 1 then
        if get_bullet(prev) then
            if bullet then
                return prev_indent
            else
                return prev_indent + 2
            end
        else
            if bullet then
                return math.max(0, prev_indent - 2)
            else
                return prev_indent
            end
        end
    -- (non-empty line doesn't immediately precede this one):
    elseif not bullet or bullet == '.' then
        return 0
    else
        return 2
    -- elseif prev_indent == 0 then
    --     return 2
    -- else -- have bullet, prev line isn't flush left
    --     return math.max(0, prev_indent - 2)
    end
end

---- autocmd for TODO stuff ----

vim.api.nvim_create_augroup('mcowan-todo', {})

-- Set up TODO buffers
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'mjc-todo',
    group = 'mcowan-todo',
    callback = function(opts)
        local b = opts.buf
        vim.api.nvim_set_option_value('softtabstop', 2, { buf = b })
        vim.api.nvim_set_option_value('shiftwidth',  2, { buf = b })
        vim.api.nvim_set_option_value('autoindent', true, { buf = b })
        vim.api.nvim_set_option_value('syntax', 'mjc-todo', { buf = b })
        vim.api.nvim_set_option_value(
            'indentkeys',
            vim.g.mjc_todo_indentkeys,
            { buf = b })
        vim.api.nvim_set_option_value(
            'indentexpr',
            'v:lua.MjcTodoIndent()',
            { buf = b })

        -- keybindings
        -- NeoVim ALREADY HAS these, as C-T, C-D
        -- -- indent/dedent
        -- vim.keymap.set(
        --     'i',
        --     "<C-\\>,",
        --     "<Left><Left><C-O><Lt><Lt>",
        --     {
        --         noremap = true,
        --         buffer = b,
        --     })
        -- vim.keymap.set(
        --     'i',
        --     "<C-\\>.",
        --     "<C-O>>><Right><Right>",
        --     {
        --         noremap = true,
        --         buffer = b,
        --     })

        -- The following sets up "O" (normal mode) to use indentation from
        -- the line that immediately _follows_ it, rather than the one that
        -- precedes it
        vim.keymap.set('n', 'O', '', {
            callback = function()
                ident_use_following = true

                -- set up to disable "use following" on exit from O:
                vim.api.nvim_create_augroup('mcowan-exit-big-oh', {})
                vim.api.nvim_create_autocmd('ModeChanged', {
                    group = 'mcowan-exit-big-oh',
                    pattern = 'i:n',
                    callback = function()
                        ident_use_following = false
                        vim.api.nvim_create_augroup('mcowan-exit-big-oh', {})
                    end,
                })

                -- Now feed an _unmapped_ O so we open the line, as expected
                vim.api.nvim_feedkeys('O', 'n', false)
            end,
            buffer = b,
        })

        -- Mark an item completed
        vim.keymap.set('n', 'gx', '', {
            callback = mk_bullet_swapper({'-', 'x'}, {'/', 'x'}, {'|', '+'}),
            nowait = true,
            buffer = b,
        })

        -- Mark an item uncompleted
        vim.keymap.set('n', 'g-', '', {
            callback = mk_bullet_swapper({'x', '-'}, {'/', '-'}, {'+', '|'}),
            nowait = true,
            buffer = b,
        })

        -- Mark an item in-progress
        vim.keymap.set('n', 'g/', '', {
            callback = mk_bullet_swapper({'x', '/'}, {'-', '/'}),
            nowait = true,
            buffer = b,
        })

        -- Move by (root) items: J/K
        vim.keymap.set('n', 'J', '', {
            callback = function()
                vim.fn.search("^  [-./x|+]", 'W')
            end,
            buffer = b,
        })
        vim.keymap.set('n', 'K', '', {
            callback = function()
                vim.fn.search("^  [-./x|+]", 'bW')
            end,
            buffer = b,
        })

        -- Move by (any) items: Ctrl-J/K
        --   (Ctrl-J is newline/probably translated to <CR>. But that's fine.)
        vim.keymap.set('n', '<C-J>', '', {
            callback = function()
                vim.fn.search("^  \\+[-./x|+]", 'W')
            end,
            buffer = b,
        })
        vim.keymap.set('n', '<C-K>', '', {
            callback = function()
                vim.fn.search("^  \\+[-./x|+]", 'bW')
            end,
            buffer = b,
        })

        -- Insert today's date
        vim.keymap.set('n', '<C-T>d', ":.-1 read !date +'\\%A, \\%Y-\\%m-\\%d:'<CR>",
                       { noremap = true, buffer = b, })

        -- For every "bullet" char: if it's the only character, add a space after
        local bullets = vim.g.mjc_todo_bullets
        for i = 1, #bullets do
            local bullet = string.sub(bullets, i, i)
            vim.keymap.set('i', bullet, '', {
                callback = function()
                    vim.api.nvim_feedkeys(bullet, 'n', false) -- send the key
                    local line = util.get_current_line()
                    if util.first_nonspace(line) == nil then
                        -- line contains only indentation
                        if bullet ~= '.' or #line ~= 0 then
                            vim.api.nvim_feedkeys(' ', 'n', false) -- send space
                        end
                    end
                end,
                buffer = b,
            })
        end

        vim.keymap.set('i', '<Space>', '', {
            callback = function()
                -- If we are already at a "bullet" with a single space after
                -- it, we don't want to insert more spaces. (We assume that
                -- any single character at line start with a space after it,
                -- is a "bullet": user is unlikely to need two spaces after
                -- an "a" or an "I" in running text, anyway.)
                local line = util.get_current_line()
                if vim.fn.match(line, "^\\s\\+\\S\\s$") == -1 then
                    vim.api.nvim_feedkeys(' ', 'n', false) -- send space
                end
            end,
            buffer = b,
        })
    end,
})
