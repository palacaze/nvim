return {

    {
        "saghen/blink.cmp",
        event = "BufReadPre",
        version = "v0.*", -- REQUIRED release tag to download pre-built binaries
        dependencies = {
            "rafamadriz/friendly-snippets",
        },
        enabled = false,
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
                ["<C-e>"] = { "hide", "fallback" },
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
        enabled = true,
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

}
