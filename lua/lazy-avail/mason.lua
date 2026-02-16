return {
    "mason-org/mason.nvim",
    enabled = function()
        local _, cfg = pcall(function() return require("config.local") end)
        if not cfg then cfg = {} end

        return cfg.mason_packages and #cfg.mason_packages > 0
    end,
    opts = {},
}
