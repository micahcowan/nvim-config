local M = {}

-- edits a file in the designated buffer,
-- UNLESS it's already loaded there (in case of existing modifications).
function M.maybe_edit(bufnr, path)
    local name       = vim.api.nvim_buf_get_name(bufnr)
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

return M
