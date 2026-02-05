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
                    -- set to `false` to disable one of the mappings
                    init_selection = "gnn",
                    scope_incremental = "grc",

                    -- "grn" conflicts with lsp "rename" binding:
                    node_incremental = "gr]",
                    node_decremental = "gr[",
                },
            },
        })
    end,
}
