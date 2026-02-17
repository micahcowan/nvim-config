-- config.cmd: define commands

-- MjcEditTab: open a tab for editing, or switch to it if already open
local function open_edit_tab()
    local tab = vim.api.nvim_get_current_tabpage()
    local wins = vim.api.nvim_tabpage_list_wins(tab)
    if wins ~= nil and #wins > 1 then
        -- current tab has more than one window? just switch to other one
        vim.cmd.wincmd('w')
    else
        -- only one window? Open new one at left
        vim.cmd.new{ mods = { vertical = true } }
        vim.cmd.wincmd('H')
    end
end
vim.api.nvim_create_user_command('MjcEditTab', open_edit_tab, {})
