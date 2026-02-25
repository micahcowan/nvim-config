return {
    "nanozuki/tabby.nvim",
    opts = {
        -- See the following URL for tabby presets:
        -- github.com/nanozuki/tabby.nvim/blob/main/lua/tabby/init.lua
        preset = "tab_only",
        option = {
            tab_name = {
                name_fallback = function(tab_nr)
                    local win_name = require('tabby.feature.win_name')
                    local wins = vim.api.nvim_tabpage_list_wins(tab_nr)
                    local name

                    for _, w in ipairs(wins) do
                        local b = vim.api.nvim_win_get_buf(w)
                        name = vim.api.nvim_buf_get_name(b)
                        -- Use tabby's default resolver for the name4
                        if name ~= nil and name ~= '' then
                            -- Use tabby's default resolver for the name
                            name = win_name.get(w)
                            break
                        end
                    end
                    if name ~= nil and name ~= '' then
                        return name
                    else
                        return '[No Name]'
                    end
                end
            },
        },
    },
}
