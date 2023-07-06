local M = {}

-- Toggle diagnostics
local function toggle_diagnostics()
    if vim.diagnostic.is_disabled(0) then
        vim.diagnostic.enable(0)
    else
        vim.diagnostic.disable(0)
    end
end

-- Toggle virtual diagnostics
local function toggle_virtual_diagnostics()
    local cfg = vim.diagnostic.config()
    if cfg.virtual_text and cfg.virtual_text == true then
        vim.diagnostic.config({ virtual_text = false })
    else
        vim.diagnostic.config({ virtual_text = true })
    end
end

-- Toggle inlay hints
local function toggle_inlay_hints()
    if vim.lsp.inlay_hint then
        vim.lsp.inlay_hint(0, nil)
    end
end

-- Use a picker to display results
local function pick(method)
    local with_fzf, fzflua = pcall(require, "fzf-lua")
    if with_fzf then
        return function()
            fzflua[method](--[[ { winopts = { width = 0.5, height = 0.5 }} ]])
        end
    end

    local tel = require("telescope.builtin")
    return function()
        local theme = require("telescope.themes").get_ivy()
        tel[method](theme)
    end
end

local config = {
    prev_diagnostic = { desc = "Go to previous diagnostic", keys = { "<S-F2>", "<F14>", "[e" } },
    next_diagnostic = { desc = "Go to next diagnostic", keys = { "<S-F3", "<F15>", "]e" } },
    prev_error = { desc = "Go to previous error", keys = {"[E"} },
    next_error = { desc = "Go to next error", keys = {"]E"} },
    set_loclist = { desc = "Fill loclist with diagnostics", keys = {"<Leader>lq"} },
    hover_diagnostic = { desc = "Hover diagnostic", keys = {"<M-d>"} },
    toggle_diagnostics = { desc = "Toggle diagnostics", keys = {"<Leader>lt"}  },
    toggle_virtual_diagnostics = { desc = "Toggle diagnostics (virtual text)", keys = {"<leader>lT"} },
    declaration = { desc = "Jump to declaration", keys = {"gD"}, cap = "declarationProvider" },
    definition = { desc = "Jump do definition", keys = {"gd"}, cap = "definitionProvider" },
    references = { desc = "Display references", keys = { "gr", "<Leader>lR" }, cap = "referencesProvider" },
    type_definition = { desc = "Display type definition", keys = {"gT"}, cap = "typeDefinitionProvider" },
    implementations = { desc = "List implementations", keys = {"<Leader>li"}, cap = "implementationProvider" },
    code_action = { desc = "Execute code action", keys = { "<Leader>la", "<M-a>" }, cap = "codeActionProvider" },
    incoming_calls = { desc = "Incoming calls", keys = {"<Leader>lI"}, cap = "callHierarchyProvider" },
    outgoing_calls = { desc = "Outgoing calls", keys = {"<Leader>lO"}, cap = "callHierarchyProvider" },
    document_symbols = { desc = "Document symbols", keys = {"<Leader>ls"}, cap = "documentSymbolProvider" },
    workspace_symbols = { desc = "Workspace symbols", keys = {"<Leader>lS"}, cap = "workspaceSymbolProvider" },
    rename = { desc = "Rename Symbol", keys = {"<Leader>lr"}, cap = "renameProvider" },
    signature_help = { desc = "Display symbol signature", keys = {"<Leader>lh"}, cap = "signatureHelpProvider" },
    format = { desc = "Format code", keys = { "<Leader>lf", "<Leader>F" }, mode = { "n", "v" }, cap = "documentFormattingProvider" },
    hover_help = { desc = "symbol information", keys = {"K"}, cap = "hoverProvider" },
    toggle_inlay_hints = { desc = "Toggle inlay hints", keys = { "<Leader>lH" }, cap = "inlayHintProvider" },
    outline = { desc = "Display symbols outline", keys = {"<Leader>lo"} },
}

local native_proto = {
    prev_diagnostic = vim.diagnostic.goto_prev,
    next_diagnostic = vim.diagnostic.goto_next,
    prev_error = function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end,
    next_error = function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end,
    set_loclist = vim.diagnostic.setloclist,
    hover_diagnostic = vim.diagnostic.open_float,
    toggle_diagnostics = toggle_diagnostics,
    toggle_virtual_diagnostics = toggle_virtual_diagnostics,
    declaration = vim.lsp.buf.declaration,
    definition = vim.lsp.buf.definition,
    references = vim.lsp.buf.references,
    type_definition = vim.lsp.buf.type_definition,
    implementations = vim.lsp.buf.implementation,
    code_action = vim.lsp.buf.code_action,
    incoming_calls = vim.lsp.buf.incoming_calls,
    outgoing_calls = vim.lsp.buf.outgoing_calls,
    document_symbols = vim.lsp.buf.document_symbol,
    workspace_symbols = vim.lsp.buf.workspace_symbol,
    rename = vim.lsp.buf.rename,
    signature_help = vim.lsp.buf.signature_help,
    format = vim.lsp.buf.format,
    hover_help = vim.lsp.buf.hover,
    toggle_inlay_hints = toggle_inlay_hints,
}

local picker_proto = {
    definition = pick("lsp_definitions"),
    references = pick("lsp_references"),
    implementations = pick("lsp_implementations"),
    incoming_calls = pick("lsp_incoming_calls"),
    outgoing_calls = pick("lsp_outgoing_calls"),
    document_symbols = pick("lsp_document_symbols"),
    workspace_symbols = pick("lsp_workspace_symbols"),
}

local saga_proto = {
    prev_diagnostic = "<Cmd>Lspsaga diagnostic_jump_prev<CR>",
    next_diagnostic = "<Cmd>Lspsaga diagnostic_jump_next<CR>",
    prev_error = function() require("lspsaga.diagnostic").goto_prev({ severity = vim.diagnostic.severity.ERROR }) end,
    next_error = function() require("lspsaga.diagnostic").goto_next({ severity = vim.diagnostic.severity.ERROR }) end,
    hover_diagnostic = "<Cmd>Lspsaga show_line_diagnostics ++unfocus<CR>",
    definition = "<Cmd>Lspsaga peek_definition<CR>",
    references = "<Cmd>Lspsaga lsp_finder<CR>",
    code_action = "<Cmd>Lspsaga code_action<CR>",
    incoming_calls = "<cmd>Lspsaga incoming_calls<CR>",
    outgoing_calls = "<cmd>Lspsaga outgoing_calls<CR>",
    rename = "<Cmd>Lspsaga rename<CR>",
    hover_help = "<Cmd>Lspsaga hover_doc ++keep<CR>",
    outline = "<Cmd>Lspsaga outline<CR>",
}

function M.setup()
    -- Configure the functions to use once
    if M.config then
        return
    end

    M.config = config

    -- Assign implementations for each feature, if not already setup by another
    -- implementation in a previous call to add_functions.
    local add_functions = function(proto)
        for feat, func in pairs(proto) do
            if not M.config[feat].func then
                M.config[feat].func = func
            end
        end
    end

    -- lspsage if available
    local with_saga, _ = pcall(require, "lspsaga")
    if with_saga then
        add_functions(saga_proto)
    end

    -- telescope if available
    local with_picker, _ = pcall(require, "telescope.builtin")
    if with_picker then
        add_functions(picker_proto)
    end

    -- defaults
    add_functions(native_proto)
end

function M.map(bufnr, cfg)
    if not cfg.func then
        return
    end

    for _, k in ipairs(cfg.keys) do
        vim.keymap.set(cfg.mode or "n", k, cfg.func, {
            noremap = true,
            silent = true,
            nowait = true,
            buffer = bufnr,
            desc = cfg.desc
        })
    end
end

function M.on_attach(client, bufnr)
    -- Configure once
    if not M.config then
        M.setup()
    end

    local caps = client.server_capabilities

    for _, cfg in pairs(config) do
        if not cfg.cap or (caps[cfg.cap] and caps[cfg.cap] == true) then
            M.map(bufnr, cfg)
        end
    end
end

return M
