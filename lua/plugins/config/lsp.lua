-- setup lsp
local ok_mason, mason = pcall(require, "mason")
if ok_mason then
    mason.setup()
end

local ok_masonlsp, mason_lsp = pcall(require, "mason-lspconfig")
if ok_masonlsp then
    mason_lsp.setup()
end

local ok, lspconfig = pcall(require, "lspconfig")
if not ok then
    return
end

local sig_ok, lsp_signature = pcall(require, "lsp_signature")
local telescope_ok, tel_builtin = pcall(require, "telescope.builtin")

local util = require("lspconfig/util")

local is_executable = function(name)
    return vim.fn.executable(name) > 0
end

-- Nicer diagnostics signs
local signs = {
    Error = " ",
    Warn  = " ",
    Info  = " ",
    Hint  = " ",
}
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local on_attach = function(client, bufnr)
    local caps = client.server_capabilities

    -- Mappings
    local lmap = function(mode, keys, func, desc)
        if desc then
            desc = "LSP: " .. desc
        end
        vim.keymap.set(mode, keys, func, { noremap = true, silent = true, buffer = bufnr, desc = desc })
    end

    lmap("n", "<leader>h", vim.diagnostic.open_float, "Hover diagnostics")
    lmap("n", "<S-F2>", vim.diagnostic.goto_prev, "Go to previous diagnostic")
    lmap("n", "<S-F3>", vim.diagnostic.goto_next, "Go to next diagnostic")
    lmap("n", "<leader>q", vim.diagnostic.setloclist, "Fill loclist with diagnostics")

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
        if telescope_ok then
            lmap("n", "gT", tel_builtin.lsp_type_definitions, "Display symbol type definition")
        else
            lmap("n", "gT", vim.lsp.buf.type_definition, "Display symbol type definition")
        end
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

    if caps.codeLensProvider then
        lmap("n", "<leader>ll", vim.lsp.codelens.refresh, "Codelens refresh")
        lmap("n", "<leader>lL", vim.lsp.codelens.run, "Codelens run")
    end

    if caps.callHierarchyProvider then
        if telescope_ok then
            lmap("n", "<leader>li", vim.lsp.buf.incoming_calls, "Incoming calls")
            lmap("n", "<leader>lo", vim.lsp.buf.outgoing_calls, "Outgoing calls")
        else
            lmap("n", "<leader>li", tel_builtin.lsp_incoming_calls, "Incoming calls")
            lmap("n", "<leader>lo", tel_builtin.lsp_outgoing_calls, "Outgoing calls")
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
        lmap({ "n", "x" }, "<leader>lf", vim.lsp.buf.format, "Format code")
    end

    if caps.hoverProvider then
        lmap("n", "K", vim.lsp.buf.hover, "Hover symbol")
    end

    -- Signature hint
    if sig_ok then
        lsp_signature.on_attach({
            bind = true,
            doc_lines = 10,
            fix_pos = false,
            floating_window = true,
            floating_window_above_cur_line = true,
            hint_enable = true,
            always_trigger = false,
            transpancy = 0,
            max_height = 10,
            max_width = 120,
            toggle_key = "<C-k>"
        }, bufnr)
    end

    -- Display the diagnostics for the current line in a floating window
    vim.api.nvim_create_autocmd("CursorHold", {
        buffer = bufnr,
        callback = function()
            local opts = {
                focusable = false,
                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                border = "rounded",
                source = "always",
                prefix = " ",
            }

            if not vim.b.diagnostics_pos then
                vim.b.diagnostics_pos = { nil, nil }
            end

            local cursor_pos = vim.api.nvim_win_get_cursor(0)
            if
                (cursor_pos[1] ~= vim.b.diagnostics_pos[1] or cursor_pos[2] ~= vim.b.diagnostics_pos[2])
                and #vim.diagnostic.get() > 0
            then
                vim.diagnostic.open_float(nil, opts)
            end

            vim.b.diagnostics_pos = cursor_pos
        end,
    })

    -- Highlight the current variable and its usages in the buffer
    if client.server_capabilities.documentHighlightProvider then
        vim.cmd([[
            hi! link LspReferenceRead Visual
            hi! link LspReferenceText Visual
            hi! link LspReferenceWrite Visual
        ]])
        local gid = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = gid,
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
            group = gid,
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
        })
    end
end

-- Update capabilities with those of cmp_nvim_lsp and what other plugins offer
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
}
capabilities.offsetEncoding = { "utf-16" } -- for null-ls

if is_executable("pylsp") then
    lspconfig.pylsp.setup({
        on_attach = on_attach,
        settings = {
            pylsp = {
                plugins = {
                    pylint = { enabled = false, executable = "pylint" },
                    pyflakes = { enabled = true },
                    pycodestyle = { enabled = false },
                    jedi_completion = { enabled = true, fuzzy = false },
                    jedi_hover = { enabled = true },
                    jedi_references = { enabled = true },
                    jedi_signature_help = { enabled = true },
                    jedi_symbols = { enabled = true, all_scopes = true },
                },
            },
        },
        root_dir = util.find_git_ancestor,
        flags = {
            debounce_text_changes = 200,
        },
        single_file_support = true,
        capabilities = capabilities,
    })
end

if is_executable("clangd") then
    lspconfig.clangd.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = util.root_pattern(".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", ".git"),
        single_file_support = true,
        flags = {
            debounce_text_changes = 500,
        },
    })
end

if is_executable("lua-language-server") then
    lspconfig.sumneko_lua.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        single_file_support = true,
        settings = {
            Lua = {
                runtime = {
                    -- Tell the language server which version of Lua you're using
                    -- (most likely LuaJIT in the case of Neovim)
                    version = "LuaJIT",
                },
                diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = { "vim", "awesome" },
                },
                workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = vim.api.nvim_get_runtime_file("", true),
                    maxPreload = 2000,
                    preloadFileSize = 50000,
                },
                telemetry = { enable = false },
            },
        },
    })
end

if is_executable("gopls") then
    lspconfig.gopls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        single_file_support = true,
    })
end

if is_executable("rust_analyzer") then
    lspconfig.rust_analyzer.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        single_file_support = true,
    })
end

if is_executable("zls") then
    lspconfig.zls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        single_file_support = true,
    })
end

-- global config for diagnostic
vim.diagnostic.config({
    underline = true,
    virtual_text = false,
    float = {
        source = "always",
        border = "rounded",
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
    },
    signs = true,
    update_in_insert = true,
    severity_sort = true,
})
