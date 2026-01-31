return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    config = function()
        require 'nvim-treesitter' .setup()
        require 'nvim-treesitter.configs' .setup({
            ensure_installed = { 'lua', 'bash', 'perl' },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "gnn", -- set to `false` to disable one of the mappings
                    node_incremental = "grn",
                    scope_incremental = "grc",
                    node_decremental = "grm",
                },
            },
        })
    end,
}
