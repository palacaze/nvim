-- Neovim configuration file trimmed down for server use.
--
-- It only uses a few plugins and downloads them from github on first start.
-- It does not rely on git, because it must be used in air gapped environments with
-- no *direct* access to github. It downloads code archives instead.
--
-- If the ARTEFACT_GITHUB_URL environment exists, uses it instead for github.com

vim.uv = vim.uv or vim.loop

local opt = vim.opt
local g = vim.g

-- {{{ SETTINGS

-- disable unused default vim plugins
g.loaded_node_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0

g.mapleader = " "
g.maplocalleader = " "

opt.background = "dark"
opt.backup = false
opt.cindent = true
opt.cinoptions = "g0N-s"
opt.clipboard = "unnamedplus"
opt.completeopt = "menu,menuone,noinsert,noselect"
opt.conceallevel = 3
opt.cursorline = false
opt.diffopt = {
    "internal",
    "filler",
    "closeoff",
    "context:12",
    "algorithm:histogram",
    "linematch:200",
    "indent-heuristic",
    "iwhite",
}
opt.emoji = true
opt.encoding = "utf8"
opt.errorbells = false
opt.expandtab = true
opt.fillchars = {
    fold = " ",
    foldopen = " ", -- "",
    foldsep = " ",
    foldclose = "",
    horiz = "━",
    horizup = "┻",
    horizdown = "┳",
    stlnc = " ",
    vert = "┃",
    vertleft = "┫",
    vertright = "┣",
    verthoriz = "╋",
    eob = " ",
    diff = "",
}
opt.foldenable = true
opt.foldmethod = "marker"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldcolumn = "auto:1"
opt.formatoptions = "lcqtrnj2"
if vim.fn.executable("rg") then
    opt.grepformat:append("%f:%l:%c:%m")
    opt.grepprg = "rg --vimgrep --smart-case --trim"
end
opt.guicursor = {
    "n-v:block-Cursor/lCursor-blinkon0",
    "i-c-ci-ve:ver25-Cursor/lCursor",
    "r-cr:hor20-Cursor/lCursor",
    "o:hor50",
}
opt.hidden = true
opt.history = 1000
opt.hlsearch = true
opt.ignorecase = true
opt.inccommand = "nosplit"
opt.incsearch = true
opt.iskeyword:append({ "_", "$", "@", "%", "#", "-" })
opt.laststatus = 1
opt.lazyredraw = true
opt.linebreak = true
opt.list = false
opt.listchars = {
    eol = "↲",
    tab = "▶ ",
    trail = "•",
    precedes = "«",
    extends = "»",
    nbsp = "␣",
    space = ".",
}
opt.modeline = true
opt.modelineexpr = false
opt.modelines = 5
opt.mouse = "a"
opt.mousemoveevent = true
opt.number = true
opt.numberwidth = 2
opt.pumblend = 15
opt.pumheight = 15
opt.relativenumber = false
opt.ruler = false
opt.scrolloff = 3
opt.shada = "'10000,:10000,/10000"
opt.shiftround = true
opt.shiftwidth = 4
opt.shortmess = "atIF"
opt.showcmd = false
opt.showfulltag = true
opt.showmatch = true
opt.showmode = false
opt.sidescrolloff = 8
opt.smartcase = true
opt.smartindent = true
opt.smarttab = true
opt.spelllang = { "en" }
opt.spelloptions = "camel"
opt.softtabstop = 4
opt.splitkeep = "topline"
opt.splitbelow = true
opt.splitright = true
opt.swapfile = false
opt.synmaxcol = 200
opt.tabstop = 4
opt.termguicolors = true
opt.timeout = true
opt.timeoutlen = 500
opt.ttimeoutlen = 10
-- enable undo
local undodir = vim.fn.stdpath("cache") .. "/undo//"
vim.fn.mkdir(undodir, "p", "0700")
opt.undodir = undodir
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.virtualedit = "block,onemore"
opt.whichwrap:append("<>[]")
opt.wildignorecase = true
opt.wildmode = "longest:full,full"
opt.wrap = false
opt.writebackup = false

-- }}}

-- {{{ HELPERS

--- Escape key
local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)

--- Icons
local icons = {
    Space    = "󱁐 ",
    Spell    = "󰓆 ",
    Tab      = "󰌒 ",
    Branch   = "",
    Error    = " ",
    Warn     = " ",
    Info     = " ",
    Question = " ",
    Hint     = " ",
}

--- Create a key mapping with a description
--- @param modes string All the modes to support, as a string instead of an array
--- @param lhs string The lhs of the mapping
--- @param rhs string | function  The rhs of the mapping
--- @param desc string The description of the mapping
--- @param opts table | nil The mapping options
local function map(modes, lhs, rhs, desc, opts)
    opts = opts or { silent = true, noremap = true, nowait = true }
    opts["desc"] = desc
    local m = {}
    for i = 1, #modes do
        table.insert(m, string.sub(modes, i, i))
    end
    vim.keymap.set(m, lhs, rhs, opts)
end

--- Create a key mapping with a description for the given buffer
--- @param buf integer The buffer id
--- @param modes string All the modes to support, as a string instead of an array
--- @param lhs string The lhs of the mapping
--- @param rhs string | function  The rhs of the mapping
--- @param desc string The description of the mapping
--- @param opts table | nil The mapping options
local function bufmap(buf, modes, lhs, rhs, desc, opts)
    opts = opts or { silent = true, noremap = true, nowait = true }
    opts["desc"] = desc
    opts["buffer"] = buf
    local m = {}
    for i = 1, #modes do
        table.insert(m, string.sub(modes, i, i))
    end
    vim.keymap.set(m, lhs, rhs, opts)
end

--- Test whether a mapping already exist for lhs in mode
--- @param lhs string the key mapping to test
--- @param mode string | nil the mode concerned by the test, defaults to "n"
local function has_mapping(lhs, mode)
    return string.len(vim.fn.maparg(lhs, mode)) > 0
end

-- Get selected text or word under cursor
local function get_selection()
    local visual = vim.fn.mode() == "v"

    if visual == true then
        local saved_reg = vim.fn.getreg("v")
        vim.cmd([[noautocmd sil norm "vy]])
        local selection = vim.fn.getreg("v")
        vim.fn.setreg("v", saved_reg)
        return selection
    else
        return vim.fn.expand("<cword>")
    end
end

-- Returns the root directory based on:
-- lsp workspace folders
-- lsp root_dir
-- root pattern of filename of the current buffer
-- root pattern of cwd
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
        root = vim.fs.find({ ".git", ".clang-format", "pyproject.toml" }, { path = path, upward = true })[1]
        root = root and vim.fs.dirname(root) or vim.uv.cwd()
    end
    ---@cast root string
    return root
end

-- Detect training spaces and returns a string telling giving offender
local function trailing_spaces()
    if not vim.o.modifiable then
        return ""
    end
    local space = vim.fn.search([[\s\+$]], "nwc")
    return space ~= 0 and  icons.Space .. space or ""
end

-- Detect mixed indents
-- Report either the first line with both spaces and tabs, or the first line
-- not conforming to the majority of indented lines.
local function mixed_indent()
    if not vim.o.modifiable then
        return ""
    end
    local space_pat = [[\v^ +]]
    local tab_pat = [[\v^\t+]]
    local space_indent = vim.fn.search(space_pat, "nwc")
    local tab_indent = vim.fn.search(tab_pat, "nwc")
    local mixed = (space_indent > 0 and tab_indent > 0)
    local mixed_same_line
    if not mixed then
        mixed_same_line = vim.fn.search([[\v^(\t+ | +\t)]], "nwc")
        mixed = mixed_same_line > 0
    end
    if not mixed then
        return ""
    end
    local tab_icon = icons.Tab
    if mixed_same_line ~= nil and mixed_same_line > 0 then
        return tab_icon .. mixed_same_line
    end
    local space_indent_cnt = vim.fn.searchcount({ pattern = space_pat, max_count = 1e3 }).total
    local tab_indent_cnt = vim.fn.searchcount({ pattern = tab_pat, max_count = 1e3 }).total
    if space_indent_cnt > tab_indent_cnt then
        return tab_icon .. tab_indent
    else
        return tab_icon .. space_indent
    end
end

-- Improves the "files" fzf-lua picker with auto cwd and cword options
local function fzflua(builtin, opts)
    local params = { builtin = builtin, opts = opts }
    return function()
        builtin = params.builtin
        opts = params.opts
        opts = vim.tbl_deep_extend("force", {
            cwd = get_project_root()
        }, opts or {})

        -- pass word under cursor if required
        if opts and opts.cword ~= nil and opts.cword then
            opts.search = vim.fn.expand("<cword>")
        end

        require("fzf-lua")[builtin](opts)
    end
end

local function setup_plugin(spec)

end

-- }}}

-- {{{ PLUGINS

local data = vim.fn.stdpath("data")
local packages_root = data .. "/site"
local plugin_root = packages_root .. "/pack/packages/start"

vim.fn.mkdir(plugin_root, "p")
vim.opt.pp:prepend(packages_root)
vim.opt.rtp:prepend(packages_root)

local plugins = {
    { name = "vim-matchup",  url = "https://github.com/andymass/vim-matchup" },
    { name = "dropbar.nvim", url = "https://github.com/Bekaboo/dropbar.nvim" },
}

for _, plugin in ipairs(plugins) do
    local cloned_path = plugin_root .. '/' + plugin.name
    if not vim.uv.fs_stat(cloned_path) then
        vim.fn.system({ 'git', 'clone', plugin.url, cloned_path })
    end
end

setup_plugin({
    "nvim-mini/mini.icons",
    setup = function(opts)
        require("mini.icons").setup(opts)
        MiniIcons.mock_nvim_web_devicons()
    end,
})

setup_plugin({
    "saghen/blink.cmp",
    opts = {
        cmdline = { enabled = false },
        completion = {
            list = {
                selection = {
                    preselect = false,
                    auto_insert = false,
                },
            },
            documentation = {
                auto_show = true,
                window = { max_height = 40 },
            },
        },
        signature = {
            enabled = true,
        },
        fuzzy = {
            implementation = "lua",
        },
        keymap = {
            preset = "enter",
            ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
            ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
            ["<C-Up>"] = { "scroll_documentation_up", "fallback" },
            ["<C-Down>"] = { "scroll_documentation_down", "fallback" },
        },
        appearance = {
            use_nvim_cmp_as_default = true,
            nerd_font_variant = "normal",
        },
    },
    setup = function(opts)
        require("blink").setup(opts)
    end,
})

setup_plugin({
    "ibhagwan/fzf-lua",
    keys = {
        { "_", "<Cmd>FzfLua buffers<CR>", desc = "Switch Buffer" },
        { "<Leader>/", fzflua("live_grep"), desc = "Grep (root dir)" },
        { "<Leader>*", fzflua("live_grep", { cword = true }), desc = "Grep Word under cursor (root dir)" },
        { "<Leader>:", "<Cmd>FzfLua command_history<CR>", desc = "Command History" },
        { "<Leader><Space>", fzflua("files", { formatter =  "path.filename_first" ,winopts = { preview = { hidden = true } } }), desc = "Find files (root dir)" },
        { "<Leader>_", fzflua("lgrep_curbuf", { cword = true }), desc = "Grep the current buffer" },
        { "<F3>", "<Cmd>FzfLua resume<CR>", desc = "Resume last search (fzf)" },
        { "<Leader>ff", fzflua("files"), desc = "Find files (root dir)" },
        { "<Leader>fF", fzflua("files", { cwd = false }), desc = "Find files (cmd)" },
        { "<Leader>fg", fzflua("live_grep"), desc = "Grep (root dir)" },
        { "<Leader>fG", fzflua("live_grep", { cwd = vim.uv.cwd() }), desc = "Grep (cwd)" },
        { "<Leader>fr", fzflua("oldfiles"), desc = "Recent files (root dir)" },
        { "<Leader>fR", fzflua("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent files (cwd)" },
        { "<Leader>fh", "<Cmd>FzfLua help_tags<CR>", desc = "Find help" },
        { "<Leader>fm", "<Cmd>FzfLua man_pages<CR>", desc = "Find man pages" },
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
            preview = { layout = "flex" },
        },
        fzf_opts = {
            ["--layout"] = "reverse",
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
            man = { cmd = "man %s | col -bx" },
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
                cmd = "git ls-files --exclude-standard -c --others",
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
    setup = function(opts)
        require("fzf-lua").setup(opts)
    end,
})

setup_plugin({
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        signcolumn = true,
        numhl = false,
    },
    setup = function(opts)
        require("gitsigns").setup(opts)
    end
})

setup_plugin({
    "nvim-lualine/lualine.nvim",
    init = function()
        -- Detect trailing spaces and mixed indent on file saving
        vim.api.nvim_create_autocmd({ "BufWritePost", "BufWinEnter" }, {
            desc = "Detect trailing spaces and mixed indentation",
            group = vim.api.nvim_create_augroup("MyLualineTSMI", { clear = true }),
            pattern = "*",
            callback = function()
                vim.b.pal_mixed_indent = mixed_indent()
                vim.b.pal_trailing_spaces = trailing_spaces()
            end,
        })
    end,
    opts = {
        options = {
            component_separators = "",
            section_separators = "",
            globalstatus = false,
            icons_enabled = true,
            theme = "pal",
        },
        sections = {
            lualine_a = {
                {
                    "filetype",
                    icon_only = true,
                    padding = { left = 1, right = 0 },
                },
                {
                    "filename",
                }
            },
            lualine_b = {},
            lualine_c = {
                {
                    -- Get git branch from gitsigns
                    "b:gitsigns_head",
                    icon = icons.Branch,
                    color = { fg = "#A292B3" },
                    padding = { left = 1, right = 0 },
                },
                {
                    -- Get git diff from gitsigns
                    "diff",
                    source = function()
                        local gitsigns = vim.b.gitsigns_status_dict
                        if gitsigns then
                            return {
                                added = gitsigns.added,
                                modified = gitsigns.changed,
                                removed = gitsigns.removed,
                            }
                        end
                    end,
                },
            },
            lualine_x = {
                {
                    "overseer",
                },
                {
                    "diagnostics",
                    symbols = {
                        error = icons.Error,
                        warn = icons.Warning,
                        info = icons.Information,
                    },
                    sections = { "error", "warn", "info" },
                },
            },
            lualine_y = {
                {
                    -- spell
                    function() return icons.Spell .. vim.bo.spelllang end,
                    cond = function() return vim.opt_local.spell:get() end,
                },
                {
                    "encoding",
                    padding = 0,
                },
                {
                    "fileformat",
                    icons_enabled = true,
                    padding = { left = 1, right = 2 },
                },
            },
            lualine_z = {
                {
                    "progress",
                },
                {
                    "location",
                    padding = { left = 0, right = 1 },
                },
                {
                    "mode",
                },
                {
                    "b:pal_trailing_spaces",
                    color = { fg = "#111111", bg = "#FF9E3B", gui = "bold" },
                },
                {
                    "b:pal_mixed_indent",
                    color = { fg = "#111111", bg = "#FF9E3B", gui = "bold" },
                },
            },
        },
        inactive_sections = {
            lualine_a = {
                {
                    "filetype",
                    icon_only = true,
                    padding = { left = 1, right = 0 },
                },
                {
                    "filename",
                },
            },
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {
                {
                    "progress",
                },
                {
                    "location",
                    padding = { left = 0, right = 1 },
                },
            },
        },
    },
    setup = function(opts)
        require("lualine").setup(opts)
    end,
})

setup_plugin({
    "stevearc/oil.nvim",
    keys = {
        { "-", function() require("oil").toggle_float() end, mode = "n", desc = "Open parent directory" },
        { "<Leader>m", function() require("oil").toggle_float() end, mode = "n", desc = "Open parent directory" },
    },
    opts = {
        float = { padding = 2, win_options = { winblend = 0 }, },
        default_file_explorer = true,
        skip_confirm_for_simple_edits = true,
        preview_win = {
            preview_method = "load",
        },
        keymaps = {
            ["q"] = {
                "actions.close",
                opts = { exit_if_last_buf = true },
                desc = "Close oil",
            },
            ["<C-down>"] = "actions.preview_scroll_down",
            ["<C-up>"] = "actions.preview_scroll_up",
            ["<BS>"] = "actions.parent",
            ["gh"] = "actions.toggle_hidden",
            ["gd"] = {
                desc = "Toggle file detail view",
                callback = function()
                    OilDetail = not OilDetail
                    if OilDetail then
                        require("oil").set_columns({
                            "icon",
                            { "permissions", highlight = "Number" },
                            { "mtime", highlight = "String", format = "%Y-%m-%d %H:%M:%S" },
                            { "size", highlight = "Keyword" },
                        })
                    else
                        require("oil").set_columns({ "icon" })
                    end
                end,
            },
        },
    },
    setup = function(opts)
        require("oil").setup(opts)
    end,
})

setup_plugin({
    "mrjones2014/smart-splits.nvim",
    keys = {
        -- Move between splits
        { "<S-Left>",  function() require("smart-splits").move_cursor_left() end, desc = "Move to left split", mode = {"n", "i", "t"} },
        { "<S-Down>",  function() require("smart-splits").move_cursor_down() end, desc = "Move to below split", mode = {"n", "i", "t"} },
        { "<S-Up>",    function() require("smart-splits").move_cursor_up() end, desc = "Move to above split", mode = {"n", "i", "t"} },
        { "<S-Right>", function() require("smart-splits").move_cursor_right() end, desc = "Move to right split", mode = {"n", "i", "t"} },

        -- Resize with arrows
        { "<C-S-Left>",  function() require("smart-splits").resize_left() end, desc = "Resize split left", mode = {"n", "i", "t"} },
        { "<C-S-Down>",  function() require("smart-splits").resize_down() end, desc = "Resize split down", mode = {"n", "i", "t"} },
        { "<C-S-Up>",    function() require("smart-splits").resize_up() end, desc = "Resize split up", mode = {"n", "i", "t"} },
        { "<C-S-Right>", function() require("smart-splits").resize_right() end, desc = "Resize split right", mode = {"n", "i", "t"} },
    },
    opts = {
        ignored_filetypes = {
            "nofile",
            "quickfix",
            "qf",
            "prompt",
        },
        ignored_buftypes = { "nofile", "prompt" },
    },
    setup = function(opts)
        require("smart-splits").setup(opts)
    end
})

-- }}}

-- {{{ MAPPINGS

-- }}}

-- {{{ AUTOCOMMANDS

-- }}}

-- {{{ LSP

-- }}}
