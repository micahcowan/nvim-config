local M = {}

-- edits a file in the designated buffer,
-- UNLESS it's already loaded there (in case of existing modifications).
function M.maybe_edit(bufnr, path)
    local name = vim.api.nvim_buf_call(bufnr, function()
        return vim.fn.expand("%:p")
    end)

    if name ~= path then
        vim.cmd.edit(path)
    end
end

function M.filter_term_wins(wins)
    local terms = {}
    for _, wnr in ipairs(wins) do
        local bnr = vim.api.nvim_win_get_buf(wnr)
        local ty = vim.api.nvim_get_option_value(
            'buftype',
            { buf = bnr })
        if ty == 'terminal' then
            table.insert(terms, wnr)
        end
    end

    return terms
end

function M.get_terms_in_tab(tab_nr)
    local wins = vim.api.nvim_tabpage_list_wins(tab_nr)
    return M.filter_term_wins(wins)
end

function M.get_terms_in_curtab()
    local tnr = vim.api.nvim_get_current_tabpage()
    return M.get_terms_in_tab(tnr)
end

-- string ops

function M.first_nonspace(str)
    local fidx = vim.fn.match(str, "\\S") -- zero-index result
    if fidx == -1 then
        return nil
    else
        fidx = fidx + 1     -- zero-index -> one-index
    end
    return string.sub(str, fidx, fidx)
end

-- doesn't work with tabs!
function M.get_indent(str)
    local i = vim.fn.match(str, "\\S")
    if i < 0 then i = 0 end
    return i
end

-- buffer line ops

function M.get_current_lnum(...)
    local win = ...
    win = win or 0
    local lnum = vim.api.nvim_win_get_cursor(win)[1] -- one-indexed
    return lnum - 1 -- zero-indexed
end

function M.get_line(buf, lnum)
    if lnum == nil then return nil end
    local ltbl = vim.api.nvim_buf_get_lines(buf, lnum, lnum+1, false)
    if ltbl == nil or #ltbl == 0 then return nil end
    return ltbl[1]
end

function M.get_current_lnum_line(...)
    local lnum = M.get_current_lnum(...)
    local win = ...
    win = win or 0
    local buf = vim.api.nvim_win_get_buf(win)
    local line = M.get_line(buf, lnum)

    return lnum, line
end

function M.get_current_line(...)
    local _, line = M.get_current_lnum_line(...)
    return line
end

function M.get_prev_nonempty_lnum_line(buf, lnum)
    local line
    repeat
        lnum = lnum - 1
        if lnum < 0 then return nil, nil end
        line = vim.api.nvim_buf_get_lines(buf, lnum, lnum+1, true)[1]
    until vim.fn.match(line, "^\\s*$") == -1
    return lnum, line
end

--
--
return M
