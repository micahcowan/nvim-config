--vim.o.guifont = "FiraCode Nerd Font Mono,Ubuntu Mono:h9"
vim.o.guifont = "Ubuntu Mono:h10,Monaco:h10"
vim.g.neovide_remember_window_size = true

---- Following doesn't work, bc the default TUI does UIEnter.
---- Would need to differentiate UIs or something.
--
-- vim.api.nvim_create_autocmd('UIEnter', {
--     callback = function()
--         
-- 	   vim.o.lines = 46
-- 	   vim.o.columns = 161
--     end
-- })
