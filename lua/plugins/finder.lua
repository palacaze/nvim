-- This file contains setups for both Telescope and Fzf-lua, with equivalent
-- configs and mappings.

-- The following two functions are taken form LazyVim
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/init.lua

-- Returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@return string
local function get_project_root()
    ---@type string?
    local path = vim.api.nvim_buf_get_name(0)
    path = path ~= "" and vim.uv.fs_realpath(path) or nil
    ---@type string[]
    local roots = {}
    if path then
        for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
            local workspace = client.config.workspace_folders
            local paths = workspace
                and vim.tbl_map(function(ws)
                    return vim.uri_to_fname(ws.uri)
                end, workspace)
                or client.config.root_dir and { client.config.root_dir }
                or {}
            for _, p in ipairs(paths) do
                local r = vim.uv.fs_realpath(p)
                if path:find(r, 1, true) then
                    roots[#roots + 1] = r
                end
            end
        end
    end
    table.sort(roots, function(a, b)
        return #a > #b
    end)
    ---@type string?
    local root = roots[1]
    if not root then
        path = path and vim.fs.dirname(path) or vim.uv.cwd()
        ---@type string?
        root = vim.fs.find({ ".git", ".clang-format" }, { path = path, upward = true })[1]
        root = root and vim.fs.dirname(root) or vim.uv.cwd()
    end
    ---@cast root string
    return root
end


-- Returns a function that calls telescope.
-- cwd defaults to project root, if any. the "files" builtin chooses between
-- git_files if we are in a git repo and find_fifes otherwise.
local function telescope(builtin, opts)
    local params = { builtin = builtin, opts = opts }
    return function()
        builtin = params.builtin
        opts = params.opts
        opts = vim.tbl_deep_extend("force", { cwd = get_project_root() }, opts or {})

        -- pass word under cursor if required
        if opts.cword ~= nil and opts.cword then
            opts.default_text = vim.fn.expand("<cword>")
        end

        if builtin == "files" then
            if vim.uv.fs_stat((opts.cwd or vim.uv.cwd()) .. "/.git") then
                opts.show_untracked = true
                builtin = "git_files"
            else
                builtin = "find_files"
            end
        end
        require("telescope.builtin")[builtin](opts)
    end
end

-- Returns a function that calls fzf-lua.
-- cwd defaults to project root, if any. the "files" builtin chooses between
-- git_files if we are in a git repo and find_fifes otherwise.
local function fzflua(builtin, opts)
    local params = { builtin = builtin, opts = opts }
    return function()
        builtin = params.builtin
        opts = params.opts
        opts = vim.tbl_deep_extend("force", { cwd = get_project_root() }, opts or {})

        -- pass word under cursor if required
        if opts and opts.cword ~= nil and opts.cword then
            opts.default_text = vim.fn.expand("<cword>")
        end

        if builtin == "files" then
            if vim.uv.fs_stat(((opts and opts.cwd) or vim.uv.cwd()) .. "/.git") then
                opts.show_untracked = true
                builtin = "git_files"
            else
                builtin = "files"
            end
        end
        require("fzf-lua")[builtin](opts)
    end
end

return {

    -- Nicer search
    {
        "kevinhwang91/nvim-hlslens",
        enabled = false,
        lazy = true,
        keys = {
            { "n", [[<Cmd>execute("normal! " . v:count1 . "n")<CR><Cmd>lua require("hlslens").start()<CR>]], desc = "Next match" },
            { "N", [[<Cmd>execute("normal! " . v:count1 . "N")<CR><Cmd>lua require("hlslens").start()<CR>]], desc = "Previous match" },
            { "*", [[*<Cmd>lua require("hlslens").start()<CR>]], desc = "Search forward" },
            { "#", [[#<Cmd>lua require("hlslens").start()<CR>]], desc = "Search backward" },
            { "g*", [[g*<Cmd>lua require("hlslens").start()<CR>]], desc = "Like *, but also incomplete match" },
            { "g#", [[g#<Cmd>lua require("hlslens").start()<CR>]], desc = "Like #, but also incomplete match" },
        },
        main = "hlslens",
        opts = {
            nearest_only = true,
            nearest_float_when = "never",
            build_position_cb = function(plist, _, _, _)
                require("scrollbar.handlers.search").handler.show(plist.start_pos)
            end,
        },
        config = function(_, opts)
            require("hlslens").setup(opts)
            require("scrollbar.handlers.search").setup({
                handlers = { search = true },
            })
            vim.cmd([[
                augroup scrollbar_search_hide
                    autocmd!
                    autocmd CmdlineLeave : lua require('scrollbar.handlers.search').handler.hide()
                augroup END
            ]])
        end,
    },

    -- Find, Filter, Preview, Pick. All lua, all the time
    {
        "nvim-telescope/telescope.nvim",
        lazy = true,
        enabled = true,
        version = false,
        dependencies = {
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },
            { "nvim-telescope/telescope-symbols.nvim", lazy = true },
        },
        cmd = "Telescope",
        keys = {
            { "<Leader>,", "<Cmd>Telescope buffers<CR>", desc = "Switch Buffer" },
            { "<M-Tab>", "<Cmd>Telescope buffers<CR>", desc = "Switch Buffer", mode = { "n", "i" } },
            { "<Leader>/", telescope("live_grep"), desc = "Grep (root dir)" },
            { "<Leader>*", telescope("live_grep", { cword = true }), desc = "Grep Word under cursor (root dir)" },
            { "<Leader>:", "<Cmd>Telescope command_history<CR>", desc = "Command History" },
            { "<Leader><Space>", telescope("files", { hidden = true }), desc = "Find files (root dir)" },
            -- { "<Leader><Space>", "<Cmd>Telescope smart_open<CR>", desc = "Find files (smart)" },
            { "<Leader>_", telescope("find_files", { hidden = true, cwd = false, no_ignore = true, no_ignore_parents = true }), desc = "Find files (cwd)" },
            { "<F3>", "<Cmd>Telescope resume<CR>", desc = "Resume last search" },
            { "<Leader>p", "<Cmd>Telescope yank_history<CR>", desc = "Paste from yank history" },

            { "<Leader>ff", telescope("files", { hidden = true }), desc = "Find files (root dir)" },
            { "<Leader>fF", telescope("files", { hidden = true, cwd = false }), desc = "Find files (cwd)" },
            { "<Leader>fg", telescope("live_grep"), desc = "Grep (root dir)" },
            { "<Leader>fG", telescope("live_grep", { cwd = vim.uv.cwd() }), desc = "Grep (cwd)" },
            { "<Leader>fr", telescope("oldfiles"), desc = "Recent files (root dir)" },
            { "<Leader>fR", telescope("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent files (cwd)" },

            { "<Leader>fh", "<Cmd>Telescope help_tags<CR>", desc = "Find help" },
            { "<Leader>fs", "<Cmd>Telescope symbols<CR>", desc = "Find symbols" },
            { "<Leader>gc", "<Cmd>Telescope git_bcommits<CR>", desc = "Find buffer git commits" },
            { "<Leader>gC", "<Cmd>Telescope git_commits<CR>", desc = "Find git commits" },
            { "<Leader>gb", "<Cmd>Telescope git_branches<CR>", desc = "Find git branches" },
            { "<Leader>gs", "<Cmd>Telescope git_status<CR>", desc = "Find git status" },
            {
                "<Leader>fm",
                function()
                    require("telescope.builtin").man_pages({ sections = { "ALL" } })
                end,
                desc = "Find man pages"
            },
            {
                "<Leader>fv",
                function()
                    require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
                end,
                desc = "Find files in vim config"
            },
            {
                "<Leader>fS",
                function()
                    require("telescope.builtin").find_files({ cwd = "~/travail/SURFO/indu" })
                end,
                desc = "Find files in SURFO"
            },
            {
                "z=",
                function()
                    local word = vim.fn.expand("<cword>")
                    local theme = require("telescope.themes").get_cursor({
                        prompt_title = "Spell suggestions for " .. word
                    })
                    require("telescope.builtin").spell_suggest(theme)
                end,
                desc = "Spell suggestions",
            },
        },
        opts = {
            defaults = {
                vimgrep_arguments = {
                    "rg",
                    "--vimgrep",
                    "--smart-case",
                    "--trim",
                },
                path_display = { "filename_first" },
                file_ignore_patterns = { "^cmake/vcpkg/" },
                prompt_prefix = " " .. require("config.icons").ui.Search .. " ",
                initial_mode = "insert",
                sorting_strategy = "ascending",
                layout_strategy = "flex",
                layout_config = {
                    horizontal = {
                        prompt_position = "top",
                        preview_width = 0.5,
                    },
                    vertical = {
                        mirror = false,
                    },
                    width = 0.9,
                    height = 0.9,
                },
                winblend = 0,
                border = true,
                color_devicons = true,
                mappings = {
                    n = {
                        ["q"] = "close",
                        ["<C-Up>"] = "preview_scrolling_up",
                        ["<C-Down>"] = "preview_scrolling_down",
                    },
                    i = {
                        ["<esc>"] = "close",
                        ["<C-Up>"] = "preview_scrolling_up",
                        ["<C-Down>"] = "preview_scrolling_down",
                        ["<F1>"] = "which_key",
                        ["<F4>"] = function(...)
                            return require("telescope.actions.layout").toggle_preview(...)
                        end,
                        ["<F5>"] = function(...)
                            return require("telescope.actions.layout").cycle_layout_next(...)
                        end,
                        ["<F6>"] = function(...)
                            return require("telescope.actions.layout").cycle_layout_prev(...)
                        end,
                        ["<C-t>"] = function(...)
                            return require("trouble.sources.telescope").open(...)
                        end,
                        ["<M-t>"] = function(...)
                            return require("trouble.sources.telescope").open(...)
                        end,
                        ["<M-a>"]  = "toggle_all",
                    },
                },
            },
            pickers = {
                buffers = {
                    previewer = false,
                    show_all_buffers = true,
                    sort_lastused = true,
                    theme = "dropdown",
                    mappings = {
                        n = {
                            ["<M-Tab>"] = "move_selection_next",
                            ["<M-S-Tab>"] = "move_selection_previous",
                        },
                        i = {
                            ["<M-Tab>"] = "move_selection_next",
                            ["<M-S-Tab>"] = "move_selection_previous",
                        }
                    }
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
                fzy_native = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
                file_browser = {
                    grouped = true,
                    hijack_netrw = true,
                },
            },
        },
        init = function()
            -- Fix for files being opened in insert mode
            -- https://github.com/nvim-telescope/telescope.nvim/issues/2501
            vim.api.nvim_create_autocmd("WinLeave", {
                callback = function()
                    if vim.bo.ft == "TelescopePrompt" and vim.fn.mode() == "i" then
                        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "i", false)
                    end
                end,
            })
        end,
        config = function(_, opts)
            require("telescope").setup(opts)
            require("telescope").load_extension("fzf")
            require("telescope").load_extension("yank_history")
        end,
    },

    {
        "ibhagwan/fzf-lua",
        enabled = false,
        lazy = true,
        requires = { 'nvim-tree/nvim-web-devicons' },
        cmd = { "FzfLua" },
        keys = {
            { "<Leader>,", "<Cmd>FzfLua buffers<CR>", desc = "Switch Buffer" },
            { "<M-Tab>", "<Cmd>FzfLua buffers<CR>", desc = "Switch Buffer" },
            { "<Leader>/", fzflua("live_grep"), desc = "Grep (root dir)" },
            { "<Leader>*", fzflua("live_grep", { cword = true }), desc = "Grep Word under cursor (root dir)" },
            { "<Leader>:", "<Cmd>FzfLua command_history<CR>", desc = "Command History" },
            { "<Leader><Space>", fzflua("files"), desc = "Find files (root dir)" },
            { "<Leader>_", fzflua("files", { hidden = true, cwd = false }), desc = "Find files (cwd)" },
            { "<F3>", "<Cmd>FzfLua resume<CR>", desc = "Resume last search (fzf)" },

            { "<Leader>ff", fzflua("files"), desc = "Find files (root dir)" },
            { "<Leader>fF", fzflua("files", { cwd = false }), desc = "Find files (cmd)" },
            { "<Leader>fg", fzflua("live_grep"), desc = "Grep (root dir)" },
            { "<Leader>fG", fzflua("live_grep", { cwd = vim.uv.cwd() }), desc = "Grep (cwd)" },
            { "<Leader>fr", fzflua("oldfiles"), desc = "Recent files (root dir)" },
            { "<Leader>fR", fzflua("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent files (cwd)" },

            { "<Leader>fh", "<Cmd>FzfLua help_tags<CR>", desc = "Find help" },
            { "<Leader>gc", "<Cmd>FzfLua git_bcommits<CR>", desc = "Find buffer git commits" },
            { "<Leader>gC", "<Cmd>FzfLua git_commits<CR>", desc = "Find git commits" },
            { "<Leader>gb", "<Cmd>FzfLua git_branches<CR>", desc = "Find git branches" },
            { "<Leader>gs", "<Cmd>FzfLua git_status<CR>", desc = "Find git status" },
            { "<Leader>fm", "<Cmd>FzfLua man_pages<CR>", desc = "Find man pages" },
            {
                "<Leader>fv",
                function()
                    require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
                end,
                desc = "Find files in vim config"
            },
            {
                "<Leader>fS",
                function()
                    require("fzf-lua").files({ cwd = "~/travail/SURFO/indu" })
                end,
                desc = "Find files in SURFO"
            },
            {
                "z=",
                function()
                    local word = vim.fn.expand("<cword>")
                    local position = vim.api.nvim_win_get_position(0)
                    local line = vim.fn.winline() + position[1]
                    local col = vim.fn.wincol() + position[2]
                    local prompt = "Spell suggestions for " .. word .. ": "
                    require("fzf-lua").spell_suggest({
                        prompt = prompt,
                        winopts = { width = 0.5, height = 0.2, row = line, col = col }
                    })
                end,
                desc = "Spell suggestions",
            },
        },
        opts = {
            winopts = {
                width   = 0.9,
                height  = 0.9,
                preview = { layout = "flex" },
            },
            fzf_opts = {
                ["--layout"] = "reverse",
                ["--marker"] = "+",
            },
            keymap = {
                builtin = {
                    ["<F1>"] = "toggle-help",
                    ["<F2>"] = "toggle-fullscreen",
                    ["<F3>"] = "toggle-preview-wrap",
                    ["<F4>"] = "toggle-preview",
                    ["<F5>"] = "toggle-preview-ccw",
                    ["<F6>"] = "toggle-preview-cw",
                    ["<C-d>"] = "preview-page-down",
                    ["<C-u>"] = "preview-page-up",
                    ["<C-down>"] = "preview-page-down",
                    ["<C-up>"] = "preview-page-up",
                },
                fzf = {
                    ["ctrl-z"] = "abort",
                    ["ctrl-f"] = "half-page-down",
                    ["ctrl-b"] = "half-page-up",
                    ["ctrl-a"] = "beginning-of-line",
                    ["ctrl-e"] = "end-of-line",
                    ["alt-a"]  = "toggle-all",
                    ["ctrl-d"] = "preview-page-down",
                    ["ctrl-u"] = "preview-page-up",
                    ["ctrl-q"] = "select-all+accept",
                },
            },
            files = {
                cwd_prompt = false,
            },
            grep = {
                no_header = true,
            },
            previewers = {
                man = {
                    cmd = "man %s | col -bx",
                },
            },
        },
    },

}
