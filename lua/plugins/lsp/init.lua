-- Configure Vim diagnostics
local function configure_diagnostics()
    -- Nicer diagnostics signs
    local signs = {
        Error = "",
        Warn = "",
        Info = "",
        Hint = "",
    }
    for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end

    vim.diagnostic.config({
        underline = true,
        virtual_text = false,
        float = false,
        {
            source = "always",
            border = "single",
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        },
        signs = true,
        update_in_insert = false,
        severity_sort = true,
    })
end

-- Display the diagnostics for the current line in a floating window
local function hover_diagnostics(bufnr)
    vim.api.nvim_create_autocmd("CursorHold", {
        buffer = bufnr,
        callback = function()
            local opts = {
                focusable = false,
                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                border = "single",
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
end

-- Execute a function(client, buffer) when lsp client gets attached to a buffer
local function on_attach(attached_func)
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            local buffer = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            attached_func(client, buffer)
        end,
    })
end


return {

    -- nvim-lsp configuration
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            -- LSP lua symbols for nvim config development
            { "folke/neodev.nvim", config = true },
            "mason.nvim",
            "nvim-treesitter",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "lspsaga.nvim",
        },
        config = function()
            -- Configure lsp diagnostics
            configure_diagnostics()

            -- Configure functions to be executed on lsp client attaching to a buffer
            on_attach(function(client, buffer)
                require("plugins.lsp.mappings").on_attach(client, buffer)
            end)

            -- Configure servers
            local servers = require("plugins.lsp.servers")

            -- Update capabilities with those of cmp_nvim_lsp and what other plugins offer
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                require("cmp_nvim_lsp").default_capabilities()
            )

            -- server configuration functon
            local function setup_server(name, server)
                if vim.fn.executable(server.executable) > 0 then
                    if vim.tbl_get(server, "setup") then
                        server.setup()
                    end

                    local server_opts = vim.tbl_deep_extend("force", {
                        single_file_support = true,
                        capabilities = vim.deepcopy(capabilities),
                    }, server.config or {})

                    require("lspconfig")[name].setup(server_opts)
                end
            end

            -- configure all the servers known to us
            for name, server in pairs(servers) do
                setup_server(name, server)
            end
        end,
    },

    -- mason automatic lsp & other tools installation
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        cmd = { "Mason", "MasonUpdate", "MasonInstall", "MasonUninstall" },
        opts = {
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗"
                }
            },
            ensure_installed = {
                "selene",
                "shellcheck",
                "shfmt",
            },
            PATH = "append",
        },
    },

    -- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua
    {
        "jose-elias-alvarez/null-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "mason.nvim" },
        opts = function()
            local nls = require("null-ls")
            local b = nls.builtins

            return {
                save_after_format = false,
                root_dir = require("null-ls.utils").root_pattern(".git"),
                sources = {
                    b.formatting.black.with({ extra_args = { "--fast" } }),
                    b.formatting.isort,
                    b.formatting.shfmt,
                    b.formatting.stylua.with({
                        condition = function(utils)
                            return utils.root_has_file({"stylua.toml"})
                        end,
                    }),

                    b.diagnostics.markdownlint,
                    b.diagnostics.shellcheck,
                    b.diagnostics.selene.with({
                        condition = function(utils)
                            return utils.root_has_file({ "selene.toml" })
                        end,
                    }),
                    b.diagnostics.flake8,
                },
            }
        end,
    },

    -- LSP helper plugins
    {
        "ray-x/lsp_signature.nvim",
        event = "LspAttach",
        opts = {
            bind = true,
            fix_pos = false,
            floating_window = false,
            floating_window_above_cur_line = true,
            hint_enable = false,
            always_trigger = false,
            transparency = 0,
            toggle_key = "<M-k>",
            select_signature_key = "<M-n>",
        },
    },

    -- Server progress information
    {
        "j-hui/fidget.nvim",
        event = "LspAttach",
        opts = {
            text = { spinner = "dots" },
            window = { blend = 0 },
        },
    },

    -- UI for LSP
    {
        "glepnir/lspsaga.nvim",
        branch = "main",
        lazy = true,
        opts = {
            scroll_preview = {
                scroll_down = "<C-Down>",
                scroll_up = "<C-Up>",
            },
            finder = {
                edit = { "o", "<CR>" },
                vsplit = "s",
                split = "S",
                tabe = "t",
                quit = { "q", "<ESC>" },
            },
            definition = {
                edit = "<CR>",
                vsplit = "<C-v>",
                split = "<C-x>",
                tabe = "<C-t>",
                quit = "q",
                close = "<Esc>",
            },
            code_action = {
                keys = {
                    quit = { "q", "<Esc>" },
                    exec = "<CR>",
                },
            },
            lightbulb = {
                enable = true,
                enable_in_insert = false,
                sign = true,
                sign_priority = 40,
                virtual_text = false,
            },
            diagnostic = {
            },
            rename = {
            },
            outline = {
            },
            callhierarchy = {
                edit = "o",
                vsplit = "s",
                split = "S",
                tabe = "t",
                jump = "<CR>",
                quit = "q",
            },
            symbol_in_winbar = {
                -- FIXME: winbar is broken as per https://github.com/neovim/neovim/issues/19464
                enable = false,
            },
            ui = {
                kind = require("catppuccin.groups.integrations.lsp_saga").custom_kind(),
                border = "single",
                winblend = 10,
            },
        },
    },

    -- LSP Symbols outline
    {
        "simrat39/symbols-outline.nvim",
        cmd = { "SymbolsOutline", "SymbolsOutlineOpen", "SymbolsOutlineClose" },
        keys = {
            { "<S-F5>", "<Cmd>SymbolsOutline<CR>", desc = "Toggle Symbols outline", mode = {"n", "i"} },
        },
        config = true,
    }

}
