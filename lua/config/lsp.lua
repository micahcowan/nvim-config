local function make_install_handler(name)
    return function(ok)
        if ok then
            vim.defer_fn(function() vim.lsp.enable(name) end, 50)
        end
    end
end

local function mason_refresh_cb(packages)
    local reg = require('mason-registry')
    local installing = false
    for _, name in ipairs(packages) do
        pkg = reg.get_package(name)
        if pkg:is_installed() then
            vim.lsp.enable(name)
        else
            installing = true
            pkg:install({}, make_install_handler(name))
        end

        if installing then
            vim.cmd({cmd = 'fclose', bang = true})
            vim.cmd.Mason() -- show installation in progress
        end
    end
end

local function mason_config(packages)
    local reg = require('mason-registry')
    reg.refresh(function() mason_refresh_cb(packages) end)
end

return {
    setup = mason_config
}
