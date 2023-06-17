local kind_icons = {
    Array = " ",
    Boolean = " ",
    Class = " ",
    Color = " ",
    Constant = "󰏿",
    Constructor = "",
    Enum = "",
    EnumMember = "",
    Event = "",
    Field = "󰇽",
    File = " ",
    Folder = " ",
    Function = "󰡱",
    Interface = "",
    Key = " ",
    Keyword = "󰌋",
    Method = "󰆧",
    Module = "",
    Namespace = " ",
    Null = " ",
    Number = " ",
    Object = " ",
    Operator = " ",
    Package = " ",
    Property = " ",
    Reference = " ",
    Snippet = "",
    String = " ",
    Struct = "",
    Text = "",
    TypeParameter = " ",
    Unit = "",
    Value = "󰎠",
    Variable = "󰂡",
}

git = {
    added = " ",
    modified = " ",
    removed = " ",
}

return {

    -- Snippet engine, needed for nvim-cmp and snippet template
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            -- Snippets ready for use
            "rafamadriz/friendly-snippets",
        },
        keys = {
            {
                "<tab>",
                function()
                    return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
                end,
                expr = true, silent = true, mode = "i",
            },
            { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
            { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
        },
        config = function()
            require("luasnip").setup({
                history = true,
                delete_check_events = "TextChanged",
                ext_opts = {
                    [require("luasnip.util.types").choiceNode] = {
                        active = { virt_text = { { "●", "DiagnosticInfo" } } },
                    },
                    [require("luasnip.util.types").insertNode] = {
                        active = { virt_text = { { "●", "DignosticWarn" } } },
                    },
                }
            })

            -- load snippets provided by friendly-snippets and my snippets
            require("luasnip.loaders.from_vscode").lazy_load()
            require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets"  } })
        end,
    },

    -- Auto-completion engine
    {
        "hrsh7th/nvim-cmp",
        version = false,
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",
            "saadparwaiz1/cmp_luasnip",
            "davidsierradz/cmp-conventionalcommits",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping({
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        elseif luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<Up>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                        else
                            fallback()
                        end
                    end, {"i", "s"}),
                    ["<Down>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        else
                            fallback()
                        end
                    end, {"i", "s"}),
                    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-d>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<Esc>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.abort()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<CR>"] = cmp.mapping({
                        i = function(fallback)
                            if cmp.visible() and cmp.get_active_entry() then
                            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                            else
                                fallback()
                            end
                        end,
                        s = cmp.mapping.confirm({ select = true }),
                    }),
                }),
                sources = cmp.config.sources({
                    {
                        name = "nvim_lsp",
                        entry_filter = function(entry, _)
                            return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Keyword"
                        end,
                    },
                    { name = "luasnip" },
                    {
                        name = "buffer",
                        keyword_length = 2
                    },
                    { name = "path" },
                }),
                view = {
                    entries = { name = "custom", selection_order = "near_cursor" },
                },
                experimental = { ghost_text = false },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                formatting = {
                    format = function(entry, vim_item)
                        -- Kind icons
                        vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
                        -- Source
                        vim_item.menu = ({
                            nvim_lsp = "[LSP]",
                            luasnip = "[Snip]",
                            buffer = "[Buf]",
                            path = "[Path]",
                        })[entry.source.name]
                        -- Truncate text
                        local label = vim_item.abbr
                        local truncated_label = vim.fn.strcharpart(label, 0, 80)
                        if truncated_label ~= label then
                            vim_item.abbr = truncated_label .. "…"
                        end
                        return vim_item
                    end,
                },
            })

            cmp.setup.filetype("gitcommit", {
                sources = cmp.config.sources(
                    {{ name = "conventionalcommits" }},
                    {{ name = "buffer", keyword_length = 2 }}
                ),
            })

            cmp.setup.filetype("neo-tree", { enabled = false })
            cmp.setup.filetype("neo-tree-popup", { enabled = false })
            cmp.setup.filetype("guihua", { enabled = false })
            cmp.setup.filetype("guihua_rust", { enabled = false })

            -- Set a buffer variable that records if the popup is set up top to bottom
            -- or upside down. This is available from a variable that describe the popup
            -- menu dispayed by cmp. That way we can make the <Up> and <Down> key work
            -- as intended.
            cmp.event:on("menu_opened", function(evt)
                vim.api.nvim_buf_set_var(0, "cmp_popup_bottom_up", evt.window.bottom_up)
            end)
        end,
    },

    -- make tables
    {
        "dhruvasagar/vim-table-mode",
        init = function()
            vim.g.table_mode_disable_mappings = 1
            vim.g.table_mode_disable_tableize_mappings = 1
            vim.g.table_mode_map_prefix = "<Leader>T"
        end,
    },

    -- better matchit
    {
        "andymass/vim-matchup",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            vim.g.matchup_matchparen_offscreen = { method = "popup" }
            vim.g.matchup_surround_enabled = 1
        end
    },

    -- Automatic insertion and deletion of a pair of characters
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true,
                -- to make backspace work in some situations inside prompts and popups
                disable_filetype = {
                    "clap_input",
                    "dropbar_menu",
                    "guihua",
                    "guihua_rust",
                    "neo-tree",
                    "neo-tree-popup",
                    "prompt",
                    "spectre_panel",
                    "TelescopePrompt",
                },
            })
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    },

    -- Smart and powerful comment plugin for neovim
    {
        "numToStr/Comment.nvim",
        keys = {
            "gcc",
            "gbc",
            {
                "<M-x>",
                function()
                    require("Comment.api").toggle.linewise.current()
                end,
                desc = "Toggle comment",
                mode = {"n", "i"}
            },
            {
                "<M-x>",
                function()
                    local u = require("config.utils")
                    vim.api.nvim_feedkeys(u.esc, "nx", false)
                    require("Comment.api").toggle.linewise(vim.fn.visualmode())
                end,
                desc = "Toggle comment (linewise)",
                mode = "v",
            },
            {
                "<M-y>",
                function()
                    local u = require("config.utils")
                    vim.api.nvim_feedkeys(u.esc, "nx", false)
                    require("Comment.api").toggle.blockwise(vim.fn.visualmode())
                end,
                desc = "Toggle comment (blockwise)",
                mode = "v",
            },
        },
        config = true
    },

    -- A breadcrumb bar showing symbols
    {
        "Bekaboo/dropbar.nvim",
        event = { "VeryLazy" },
        keys = {
            { "<Leader>.", function() require('dropbar.api').pick() end, desc = "Pick symbol" },
            { "<M-.>", function() require('dropbar.api').pick() end, desc = "Pick symbol" },
        },
        opts = {
            menu = {
                keymaps = {
                    ["<Esc>"] = function()
                        local menu = require("dropbar.api").get_current_dropbar_menu()
                        if menu then
                            menu:close(true)
                        end
                    end,
                },
            },
        },
        config = true,
    },

    -- Annotation generator
    {
        "danymat/neogen",
        keys = {
             { "<Leader>C", function() require("neogen").generate({}) end, desc = "Neogen Comment" }
        },
        opts = {
            snippet_engine = "luasnip",
            languages = {
                python = {
                    template = {
                        annotation_convention = "reST",
                    },
                },
            },
        },
    },

}
