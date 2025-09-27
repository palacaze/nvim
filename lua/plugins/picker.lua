-- This file contains setups for both Telescope and Fzf-lua, with equivalent
-- configs and mappings.

-- Returns a function that calls fzf-lua.
-- cwd defaults to project root, if any. the "files" builtin chooses between
-- git_files if we are in a git repo and find_fifes otherwise.
local function fzflua(builtin, opts)
    local params = { builtin = builtin, opts = opts }
    return function()
        builtin = params.builtin
        opts = params.opts
        opts = vim.tbl_deep_extend("force", {
            cwd = require("utils").get_project_root()
        }, opts or {})

        -- pass word under cursor if required
        if opts and opts.cword ~= nil and opts.cword then
            opts.search = vim.fn.expand("<cword>")
        end

        if builtin == "files" then
            -- if vim.uv.fs_stat(((opts and opts.cwd) or vim.uv.cwd()) .. "/.git") then
                builtin = "git_files"
            -- else
                builtin = "files"
            -- end
        end
        require("fzf-lua")[builtin](opts)
    end
end

return {

    -- Finder using fzf
    {
        "ibhagwan/fzf-lua",
        enabled = true,
        lazy = true,
        requires = { 'nvim-tree/nvim-web-devicons' },
        cmd = { "FzfLua" },
        keys = {
            { "_", "<Cmd>FzfLua buffers<CR>", desc = "Switch Buffer" },
            { "<Leader>/", fzflua("live_grep"), desc = "Grep (root dir)" },
            { "<Leader>*", fzflua("live_grep", { cword = true }), desc = "Grep Word under cursor (root dir)" },
            { "<Leader>:", "<Cmd>FzfLua command_history<CR>", desc = "Command History" },
            { "<Leader><Space>", fzflua("files", { formatter =  "path.filename_first" ,winopts = { preview = { hidden = true }}}), desc = "Find files (root dir)" },
            { "<Leader>_", fzflua("lgrep_curbuf", { cword = true }), desc = "Grep the current buffer" },
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
            "default",
            winopts = {
                width   = 0.9,
                height  = 0.9,
                preview = {
                    -- hidden = true,
                    layout = "flex",
                },
            },
            fzf_opts = {
                ["--layout"] = "reverse",
                -- ["--marker"] = "+",
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
            previewers = {
                builtin = {
                    syntax_limit_b = 1024 * 300,
                    snacks_image = { enabled = false },
                },
                man = {
                    cmd = "man %s | col -bx",
                },
            },
            oldfiles = {
                include_current_session = true,
            },
            files = {
                cwd_prompt = false,
            },
            git = {
                files = {
                    -- show untracked too
                    -- cmd = "git ls-files --exclude-standard -c --others",
                    git_icons = true,
                    file_icons = true,
                    color_icons = true,
                },
            },
            grep = {
                no_header = true,
                actions = {
                    ["ctrl-r"] = { function(...) require("fzf-lua").actions.toggle_ignore(...) end }
                },
            },
        },
    },

}
