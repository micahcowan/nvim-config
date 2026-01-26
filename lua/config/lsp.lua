local packages = {
    'vtsls',
    'bash-language-server',
    'clangd',
    'basedpyright',
    'perlnavigator',
    'stylua',
}

-- vim.lsp.config['vtsls'] = {
--     -- Command and arguments to start the server.
--     cmd = { 'vtsls', '--stdio' },
--     -- Filetypes to automatically attach to.
--     filetypes = { 'typescript' },
--     -- Sets the "workspace" to the directory where any of these files is found.
--     -- Files that share a root directory will reuse the LSP server connection.
--     -- Nested lists indicate equal priority, see |vim.lsp.Config|.
--     root_markers = { 'package.json', '.git' },
-- }

local function make_install_handler(name)
    return function()
        if ok then
            vim.lsp.enable(name)
        end
    end
end

local function mason_refresh_cb()
    local reg = require('mason-registry')
    local installing = false
    for _, name in ipairs(packages) do
        pkg = reg.get_package(name)
        if pkg:is_installed() then
            vim.lsp.enable(name)
        else
            installing = true
            pkg:install({}, make_install_handler(name))
            vim.cmd.Mason() -- show installation in progress
        end
    end
end

local function mason_config()
    local reg = require('mason-registry')
    reg.refresh(mason_refresh_cb)
end

mason_config()
