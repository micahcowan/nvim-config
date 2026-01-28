-- guifont is supposed to allow multiple fonts.
-- Neovide doesn't handle that well.
--   vim.fn.has('mac') returns false positive at init time.
if vim.loop.os_uname().sysname == 'Linux' then
    vim.o.guifont = "Ubuntu Mono:h10"
else
    vim.o.guifont = "Monaco:h10"
end
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
