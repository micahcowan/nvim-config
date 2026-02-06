-- config.todo: a "mjc-todo" file-type for my TODO files

local util = require "mjc-util"

---- TODO indentation function ----

vim.g.mjc_todo_bullets = ".-/x|+"
vim.g.mjc_todo_indentkeys = (function()
    local str = "O,o,!^F"
    for i = 1, #vim.g.mjc_todo_bullets do
        local c = string.sub(vim.g.mjc_todo_bullets, i, i)
        str = str .. ",0" .. c
    end
    return str
end)()

local function get_bullet(str)
    local first = util.first_nonspace(str)
    if first == nil then return false end
    if string.find(vim.g.mjc_todo_bullets, first, 1, true) == nil then
        return nil
    else
        return first
    end
end

-- Set 'indentexpr' to v:lua.MjcTodoIndent()
-- GLOBAL
function MjcTodoIndent()
    local lnum, line = util.get_current_lnum_line()
    local pnum, prev = util.get_prev_nonempty_lnum_line(0, lnum)
    -- If we're on the first non-empty line, no indent
    if prev == nil then
        return 0
    end

    local bullet = get_bullet(line)
    local prev_indent = util.get_indent(prev)

    -- -- If we're not empty and aren't just a bullet, keep existing indent
    -- Is there an immediately-preceding, non-empty line?
    if pnum == lnum - 1 then
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
        vim.keymap.set(
            'i',
            "<C-\\>,",
            "<Left><Left><C-O><Lt><Lt>",
            {
                noremap = true,
                buffer = b,
            })
        vim.keymap.set(
            'i',
            "<C-\\>.",
            "<C-O>>><Right><Right>",
            {
                noremap = true,
                buffer = b,
            })
    end,
    group = 'mcowan-todo',
})
