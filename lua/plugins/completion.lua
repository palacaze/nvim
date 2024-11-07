return {

    {
        "saghen/blink.cmp",
        event = "BufReadPre",
        version = "v0.*", -- REQUIRED release tag to download pre-built binaries
        dependencies = {
            "rafamadriz/friendly-snippets",
        },
        lazy = false,

        ---@module "blink.cmp"
        ---@type blink.cmp.Config
        opts = {
            accept = { auto_brackets = { enabled = true } },
            trigger = {
                completion = {
                    keyword_range = "full",
                },
                signature_help = {
                    enabled = true,
                },
            },
            keymap = {
                ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-e>"] = { "hide" },
                ["<CR>"] = { "accept", "fallback" },
                ["<Tab>"] = {
                    function(cmp)
                        if cmp.is_in_snippet() then return cmp.accept()
                        else return cmp.select_and_accept() end
                    end,
                    "snippet_forward",
                    "fallback"
                },
                ["<S-Tab>"] = { "snippet_backward", "fallback" },
                ["<PageUp>"] = { "scroll_documentation_up", "fallback" },
                ["<PageDown>"] = { "scroll_documentation_down", "fallback" },
                ["<Up>"] = { "select_prev", "fallback" },
                ["<Down>"] = { "select_next", "fallback" },
            },
            highlight = {
                use_nvim_cmp_as_default = true,
            },
            kind_icons = require("config.icons").kind,
            nerd_font_variant = "normal",
            windows = {
                documentation = {
                    min_width = 15,
                    max_width = 80,
                    max_height = 40,
                    border = "single",
                    auto_show = true,
                    auto_show_delay_ms = 200,
                },
                autocomplete = {
                    min_width = 10,
                    max_height = 20,
                    border = "single",
                    selection = "manual",
                    cycle = { from_top = true },
                    draw = "reversed",
                },
                signature_help = {
                    max_height = 20,
                },
            },
        },
    },

    -- Snippet engine, needed for nvim-cmp and snippet template
    {
        "L3MON4D3/LuaSnip",
        enabled = false,
        dependencies = {
            -- Snippets ready for use
            "rafamadriz/friendly-snippets",
        },
        lazy = true,
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
                history = false,
                delete_check_events = "TextChanged,InsertLeave",
                region_check_events = "InsertEnter",
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
            require("luasnip.loaders.from_vscode").lazy_load({ exclude = { "cpp" } })
            require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })

            -- extend snippets to support doc comments
            require("luasnip").filetype_extend("cpp", {"cppdoc"})
            require("luasnip").filetype_extend("javascript", { "jsdoc" })
            require("luasnip").filetype_extend("lua", { "luadoc" })
            require("luasnip").filetype_extend("python", { "python-docstring" })
            require("luasnip").filetype_extend("rust", { "rustdoc" })
            require("luasnip").filetype_extend("sh", { "shelldoc" })
            require("luasnip").filetype_extend("c", { "cdoc" })

            local ls = require("luasnip")
            local s = ls.snippet
            local t = ls.text_node
            local i = ls.insert_node
            local f = ls.function_node

            -- A Comment box snippet
            local function box(opts)
                local function box_width()
                    return opts.box_width or (vim.opt.textwidth:get() > 0 and vim.opt.textwidth:get() or 80)
                end
                local function padding(cs, input_text)
                    local spaces = box_width() - (2 * #cs)
                    spaces = spaces - #input_text
                    return spaces / 2
                end
                local comment_string = function()
                    return require("luasnip.util.util").buffer_comment_chars()[1]
                end

                return {
                    f(function()
                        local cs = comment_string()
                        return string.rep(string.sub(cs, 1, 1), box_width())
                    end, { 1 }),
                    t({ "", "" }),
                    f(function(args)
                        local cs = comment_string()
                        return cs .. string.rep(" ", math.floor(padding(cs, args[1][1])))
                    end, { 1 }),
                    i(1, "placeholder"),
                    f(function(args)
                        local cs = comment_string()
                        return string.rep(" ", math.ceil(padding(cs, args[1][1]))) .. cs
                    end, { 1 }),
                    t({ "", "" }),
                    f(function()
                        local cs = comment_string()
                        return string.rep(string.sub(cs, 1, 1), box_width())
                    end, { 1 }),
                }
            end

            ls.add_snippets("all", {
                s({ trig = "box" }, box({ box_width = 24 })),
                s({ trig = "bbox" }, box({})),
            })

            vim.api.nvim_create_autocmd("InsertLeave", {
                callback = function()
                    if require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
                       and not require("luasnip").session.jump_active
                    then
                        require("luasnip").unlink_current()
                    end
                end,
            })
        end,
    },

    -- Auto-completion engine
    {
        "iguanacucumber/magazine.nvim",
        enabled = false,
        version = false,
        event = "InsertEnter",
        dependencies = {
            "LuaSnip",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",
            "saadparwaiz1/cmp_luasnip",
            "davidsierradz/cmp-conventionalcommits",
            "hrsh7th/cmp-nvim-lsp-signature-help",
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
                    ["<CR>"] = cmp.mapping.confirm({ insert = true }),
                }),
                sources = cmp.config.sources({
                    {
                        name = "nvim_lsp",
                        entry_filter = function(entry, _)
                            local kind = require("cmp.types").lsp.CompletionItemKind[entry:get_kind()]
                            return kind ~= "Keyword" and kind ~= "Text"
                        end,
                    },
                    { name = "nvim_lsp_signature_help" },
                    { name = "luasnip", keyword_length = 2 },
                }, {
                    { name = "path" },
                    { name = "buffer", keyword_length = 3 },
                }),
                sorting = {
                    priority_weight = 2,
                    comparators = {
                        cmp.config.compare.exact,
                        cmp.config.compare.offset,
                        cmp.config.compare.recently_used,
                        -- copied from cmp-under: puts symbols starting with one or more _ at the bottom
                        function(entry1, entry2)
                            local _, entry1_under = entry1.completion_item.label:find "^_+"
                            local _, entry2_under = entry2.completion_item.label:find "^_+"
                            entry1_under = entry1_under or 0
                            entry2_under = entry2_under or 0
                            if entry1_under > entry2_under then
                                return false
                            elseif entry1_under < entry2_under then
                                return true
                            end
                        end,
                        cmp.config.compare.scopes,
                        -- clangd completion scores, replaces compare.scores
                        -- falls back to compare.score if unavailable
                        function(entry1, entry2)
                            local diff
                            if entry1.completion_item.score and entry2.completion_item.score then
                                diff = (entry2.completion_item.score * entry2.score)
                                        - (entry1.completion_item.score * entry1.score)
                            else
                                diff = entry2.score - entry1.score
                            end
                            return (diff < 0)
                        end,
                        -- cmp.config.compare.score
                        cmp.config.compare.locality,
                        cmp.config.compare.kind,
                        cmp.config.compare.sort_text,
                        cmp.config.compare.length,
                        cmp.config.compare.order,
                    },
                },
                view = {
                    entries = "native",
                },
                completion = {
                    autocomplete = { "TextChanged" },
                },
                experimental = { ghost_text = false },
                -- matching = {
                --     disallow_fullfuzzy_matching = true,
                --     disallow_fuzzy_matching = true,
                --     disallow_partial_fuzzy_matching = false,
                --     disallow_partial_matching = false,
                --     disallow_prefix_unmatching = true,
                --     disallow_symbol_nonprefix_matching = true,
                -- },
                -- compare = { locality = { lines_count = 300} },
                formatting = {
                    format = function(entry, vim_item)
                        -- Kind icons
                        vim_item.kind = string.format("%s", require("config.icons").kind[vim_item.kind])
                        -- Source
                        vim_item.menu = ({
                            nvim_lsp = "[LSP]",
                            luasnip = "[Snip]",
                            buffer = "[Buf]",
                            path = "[Path]",
                            conventional_commits = "[commits]",
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

}
