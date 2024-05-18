local gid = vim.api.nvim_create_augroup("user_autocmds", { clear = true })

-- Text settings
vim.api.nvim_create_autocmd("FileType", {
    group = gid,
    pattern = { "txt" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
        vim.bo.spelllang = "en"
    end,
})

-- Common languages
vim.api.nvim_create_autocmd("FileType", {
    group = gid,
    pattern = { "c", "cpp", "python", "cmake", "go", "markdown" },
    callback = function()
        vim.opt_local.spell = true
        vim.bo.spelllang = "en"
    end,
})

-- No conceal for json, it makes editing hairy
vim.api.nvim_create_autocmd({ "FileType" }, {
    group = gid,
    pattern = { "json", "jsonc" },
    callback = function()
        vim.opt_local.spell = false
        vim.opt_local.conceallevel = 0
    end,
})

-- No spell in Terms
vim.api.nvim_create_autocmd("TermOpen", {
    group = gid,
    pattern = "*",
    callback = function()
        vim.opt_local.spell = false
    end,
})

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = gid,
    command = "checktime",
})

-- Disable search highlighting on startup
vim.api.nvim_create_autocmd("VimEnter", {
    group = gid,
    pattern = "*",
    command = [[let @/ = '']],
})

-- Highlights yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    group = gid,
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = gid,
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
})

-- Disable some features for large files
vim.api.nvim_create_autocmd("BufReadPre", {
    group = gid,
    pattern = "*",
    callback = function()
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
        if ok and stats and (stats.size > 2000000) then
            vim.b.large_buf = true
            vim.opt_local.bufhidden = "unload"
            vim.opt_local.backup = false
            vim.opt_local.complete = ""
            vim.opt_local.eventignore = "all"
            vim.opt_local.foldmethod = "manual"
            vim.opt_local.foldenable = false
            vim.opt_local.swapfile = false
            vim.opt_local.undolevels = -1
            vim.opt_local.writebackup = false
            vim.opt_local.lazyredraw = true
            vim.opt_local.spell = false
            vim.opt_local.cursorline = false
            vim.cmd.syntax("clear")
            vim.cmd.syntax("off")
            if vim.fn.exists(":TSBufDisable") > 0 then
                vim.cmd('TSBufDisable highlight')
                vim.cmd('TSBufDisable incremental_selection')
                vim.cmd('TSBufDisable indent')
                vim.cmd('TSBufDisable matchup')
                vim.cmd('TSBufDisable textobjects.swap')
                vim.cmd('TSBufDisable textobjects.move')
                vim.cmd('TSBufDisable textobjects.lsp_interop')
                vim.cmd('TSBufDisable textobjects.select')
            end
            if vim.fn.exists(":IBLDisable") > 0 then
                vim.cmd("IBLDisable")
            end
        else
            vim.b.large_buf = false
        end
    end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    group = gid,
    callback = function(event)
        if event.match:match("^%w%w+://") then
            return
        end
        local file = vim.uv.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

-- Go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
    group = gid,
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Close some filetypes with <q>
-- Taken from https://github.com/LazyVim/LazyVim
vim.api.nvim_create_autocmd("FileType", {
    group = gid,
    pattern = {
        "checkhealth",
        "help",
        "loclist",
        "lspinfo",
        "man",
        "notify",
        "PlenaryTestPopup",
        "qf",
        "spectre_panel",
        "startuptime",
        "tsplayground",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})

-- Remember folds from one opening to the next
-- vim.api.nvim_create_autocmd("BufWinLeave", {
--     group = gid,
--     pattern = "*.*",
--     command = "mkview",
-- })
-- vim.api.nvim_create_autocmd("BufWinEnter", {
--     group = gid,
--     pattern = "*.*",
--     command = "silent! loadview",
-- })

-- Toggle verbose mode of neovim
vim.api.nvim_create_user_command("ToggleVerbose", function()
    if vim.o.verbose > 0 then
        vim.o.verbosefile = "/tmp/vim_verbose.log"
        vim.o.verbose = 15
    else
        vim.o.verbose = 0
        vim.o.verbosefile = ""
    end
end, {})

-- Search word under cursor in devdocs.io
vim.api.nvim_create_user_command("Devdocs", function(opts)
    local escape_query = function(target)
        local escapes = {
            [" "] = "%20", ["<"]  = "%3C", [">"] = "%3E", ["#"] = "%23",
            ["%"] = "%25", ["+"]  = "%2B", ["{"] = "%7B", ["}"] = "%7D",
            ["|"] = "%7C", ["\\"] = "%5C", ["^"] = "%5E", ["~"] = "%7E",
            ["["] = "%5B", ["]"]  = "%5D", ["‘"] = "%60", [";"] = "%3B",
            ["/"] = "%2F", ["?"]  = "%3F", [":"] = "%3A", ["@"] = "%40",
            ["="] = "%3D", ["&"] = "%26",  ["$"] = "%24",
        }
       return target:gsub(".", escapes)
    end

    local query = table.concat(opts.fargs, " ")
    query = vim.fn.trim(query)
    query = escape_query(query)
    query = vim.bo.filetype .. "%20" .. query
    local url = string.format("https://devdocs.io/#q=%s", query)
    vim.cmd.OpenBrowser(url)
end, { desc = "Search in devdocs", nargs = "*" })

require("config.puml").setup({
    format = "svg",
    viewer = "nomacs",
    tempdir = "/tmp",
    generator = "server",
    server = vim.g.puml_server,
})
