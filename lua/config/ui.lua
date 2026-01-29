-- guifont is supposed to allow multiple fonts.
-- Neovide doesn't handle that well.
--   vim.fn.has('mac') returns false positive at init time,
-- so can't use that to check if we're mac

-----  DISABLED: do this in config.local instead!
-----  if vim.loop.os_uname().sysname == 'Linux' then
-----      vim.o.guifont = "Ubuntu Mono:h10"
-----  else
-----      vim.o.guifont = "Monaco:h10"
-----  end

vim.g.neovide_remember_window_size = true
