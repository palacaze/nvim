local M = {}

-- Simple implementation of highlighting of the current variable and its usages
-- if navigator.lua is missing.
local function highlight_symbols(bufnr)
    vim.cmd([[
        hi! link LspReferenceRead Visual
        hi! link LspReferenceText Visual
        hi! link LspReferenceWrite Visual
    ]])

    local gid = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
    vim.api.nvim_clear_autocmds({
        group = gid,
        buffer = bufnr,
    })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = gid,
        buffer = bufnr,
        callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = gid,
        buffer = bufnr,
        callback = vim.lsp.buf.clear_references,
    })
end

-- Toggle diagnostics
local function toggle_diagnostics()
    if vim.b.diagnostics_enabled == nil then
        vim.b.diagnostics_enabled = true
    end

    vim.b.diagnostics_enabled = not vim.b.diagnostics_enabled
    if vim.b.diagnostics_enabled then
        vim.diagnostic.enable()
    else
        vim.diagnostic.disable()
    end
end

function M.setup_native(client, bufnr)
    local telescope_ok, tel_builtin = pcall(require, "telescope.builtin")
    local caps = client.server_capabilities

    -- Mappings
    local lmap = function(mode, keys, func, desc)
        if desc then
            desc = "LSP: " .. desc
        end
        local opts = { noremap = true, silent = true, nowait = true, buffer = bufnr, desc = desc }
        vim.keymap.set(mode, keys, func, opts)
    end

    lmap("n", "<S-F2>", vim.diagnostic.goto_prev, "Go to previous diagnostic")
    lmap("n", "<S-F3>", vim.diagnostic.goto_next, "Go to next diagnostic")

    lmap("n", "<M-d>", vim.diagnostic.open_float, "Hover diagnostics")
    lmap("n", "<leader>lq", vim.diagnostic.setloclist, "Fill loclist with diagnostics")
    lmap("n", "<leader>lt", toggle_diagnostics, "Toggle diagnostics")

    if caps.declarationProvider then
        lmap("n", "gD", vim.lsp.buf.declaration, "Go to symbol declaration")
    end

    if caps.definitionProvider then
        if telescope_ok then
            lmap("n", "gd", tel_builtin.lsp_definitions, "Go to symbol definition")
        else
            lmap("n", "gd", vim.lsp.buf.definition, "Go to symbol definition")
        end
    end

    if caps.referencesProvider then
        if telescope_ok then
            lmap("n", "gr", tel_builtin.lsp_references, "Find references to symbol")
            lmap("n", "<leader>lR", tel_builtin.lsp_references, "Find references to symbol")
        else
            lmap("n", "gr", vim.lsp.buf.references, "Find references to symbol")
            lmap("n", "<leader>lR", vim.lsp.buf.references, "Find references to symbol")
        end
    end

    if caps.typeDefinitionProvider then
        lmap("n", "gT", vim.lsp.buf.type_definition, "Display symbol type definition")
    end

    if caps.implementationProvider then
        if telescope_ok then
            lmap("n", "gi", tel_builtin.lsp_implementations, "List Implementations")
        else
            lmap("n", "gi", vim.lsp.buf.implementation, "List Implementations")
        end
    end

    if caps.codeActionProvider then
        lmap({ "n", "x" }, "<leader>la", vim.lsp.buf.code_action, "Execute code action")
    end

    if caps.callHierarchyProvider then
        if telescope_ok then
            lmap("n", "<leader>lI", tel_builtin.lsp_incoming_calls, "Incoming calls")
            lmap("n", "<leader>lO", tel_builtin.lsp_outgoing_calls, "Outgoing calls")
        else
            lmap("n", "<leader>lI", vim.lsp.buf.incoming_calls, "Incoming calls")
            lmap("n", "<leader>lO", vim.lsp.buf.outgoing_calls, "Outgoing calls")
        end
    end

    if caps.documentSymbolProvider then
        if telescope_ok then
            lmap("n", "<leader>ls", tel_builtin.lsp_document_symbols, "Document symbols")
        else
            lmap("n", "<leader>ls", vim.lsp.buf.document_symbol, "Document symbol")
        end
    end

    if caps.workspaceSymbolProvider then
        if telescope_ok then
            lmap("n", "<leader>lS", tel_builtin.lsp_workspace_symbols, "Workspace symbols")
        else
            lmap("n", "<leader>lS", vim.lsp.buf.workspace_symbol, "Workspace symbols")
        end
    end

    if caps.renameProvider then
        lmap("n", "<leader>lr", vim.lsp.buf.rename, "Rename symbol")
    end

    if caps.signatureHelpProvider then
        lmap("n", "<leader>lh", vim.lsp.buf.signature_help, "Display symbol signature")
    end

    if caps.documentFormattingProvider then
        lmap({"n", "v"}, "<leader>ff", vim.lsp.buf.format, "Format code")
    end

    if caps.hoverProvider then
        lmap("n", "K", vim.lsp.buf.hover, "Hover symbol")
    end

    -- if caps.documentHighlightProvider then
        -- highlight_symbols(bufnr)
    -- end
end

-- create LSP key mappings for the given buffer and lspsaga.lua
function M.setup_lspsaga(client, bufnr)
    local telescope_ok, tel_builtin = pcall(require, "telescope.builtin")
    local caps = client.server_capabilities

    -- Mappings
    local lmap = function(mode, keys, func, desc)
        if desc then
            desc = "LSP: " .. desc
        end
        local opts = { noremap = true, silent = true, nowait = true, buffer = bufnr, desc = desc }
        vim.keymap.set(mode, keys, func, opts)
    end

    lmap("n", "<S-F2>", "<Cmd>Lspsaga diagnostic_jump_prev<CR>", "Go to previous diagnostic")
    lmap("n", "<S-F3>", "<Cmd>Lspsaga diagnostic_jump_next<CR>", "Go to next diagnostic")
    lmap("n", "[e", "<Cmd>Lspsaga diagnostic_jump_prev<CR>", "Go to previous diagnostic")
    lmap("n", "]e", "<Cmd>Lspsaga diagnostic_jump_next<CR>", "Go to next diagnostic")
    -- Only jump to error
    lmap("n", "[E", function()
        require("lspsaga.diagnostic").goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end, "Go to previous error")
    lmap("n", "]E", function()
        require("lspsaga.diagnostic").goto_next({ severity = vim.diagnostic.severity.ERROR })
    end, "Go to next error")

    -- lmap("n", "<M-d>", vim.diagnostic.open_float, "Hover diagnostics")
    lmap("n", "<M-d>", "<Cmd>Lspsaga show_line_diagnostics<CR>", "Hover diagnostics")
    lmap("n", "<leader>lq", vim.diagnostic.setloclist, "Fill loclist with diagnostics")
    lmap("n", "<leader>lt", toggle_diagnostics, "Toggle diagnostics")

    if caps.declarationProvider then
        lmap("n", "gD", vim.lsp.buf.declaration, "Go to symbol declaration")
    end

    if caps.definitionProvider then
        lmap("n", "gd", "<Cmd>Lspsaga peek_definition<CR>", "Display symbol definition")
    end

    if caps.referencesProvider then
        lmap("n", "gr", "<Cmd>Lspsaga lsp_finder<CR>", "Find references to symbol")
        lmap("n", "<Leader>lR", "<Cmd>Lspsaga lsp_finder<CR>", "Find references to symbol")
    end

    if caps.typeDefinitionProvider then
        lmap("n", "gT", vim.lsp.buf.type_definition, "Display symbol type definition")
    end

    if caps.implementationProvider then
        if telescope_ok then
            lmap("n", "gi", tel_builtin.lsp_implementations, "List Implementations")
        else
            lmap("n", "gi", vim.lsp.buf.implementation, "List Implementations")
        end
    end

    if caps.codeActionProvider then
        lmap({"n", "v"}, "<leader>la", "<Cmd>Lspsaga code_action<CR>", "Execute code action")
    end

    if caps.callHierarchyProvider then
        lmap("n", "<Leader>lI", "<cmd>Lspsaga incoming_calls<CR>", "Incoming calls")
        lmap("n", "<Leader>lO", "<cmd>Lspsaga outgoing_calls<CR>", "Outgoing calls")
    end

    if caps.documentSymbolProvider then
        if telescope_ok then
            lmap("n", "<leader>ls", tel_builtin.lsp_document_symbols, "Document symbols")
        else
            lmap("n", "<leader>ls", vim.lsp.buf.document_symbol, "Document symbol")
        end
    end

    if caps.workspaceSymbolProvider then
        if telescope_ok then
            lmap("n", "<leader>lS", tel_builtin.lsp_dynamic_workspace_symbols, "Workspace symbols")
        else
            lmap("n", "<leader>lS", vim.lsp.buf.workspace_symbol, "Workspace symbols")
        end
    end

    if caps.renameProvider then
        lmap("n", "<leader>lr", "<Cmd>Lspsaga rename<CR>", "Rename symbol")
    end

    if caps.signatureHelpProvider then
        lmap("n", "<leader>lh", vim.lsp.buf.signature_help, "Display symbol signature")
    end

    if caps.documentFormattingProvider then
        lmap({"n", "v"}, "<leader>ff", vim.lsp.buf.format, "Format code")
    end

    if caps.hoverProvider then
        lmap("n", "K", "<Cmd>Lspsaga hover_doc<CR>", "Hover symbol")
    end

    -- if caps.documentHighlightProvider then
        -- highlight_symbols(bufnr)
    -- end

    -- Outline
    lmap("n", "<Leader>lo", "<Cmd>Lspsaga outline<CR>", "Display symbols outline")
end

function M.on_attach(client, bufnr)
    local have_lspsaga, _ = pcall(require, "lspsaga")
    if have_lspsaga then
        M.setup_lspsaga(client, bufnr)
    else
        M.setup_native(client, bufnr)
    end
end

return M
