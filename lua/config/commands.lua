local gid = vim.api.nvim_create_augroup("user_autocmds", { clear = true })

-- Text settings
vim.api.nvim_create_autocmd("FileType", {
    group = gid,
    pattern = { "txt" },
    callback = function()
        vim.wo.wrap = true
        vim.wo.spell = true
        vim.bo.spelllang = "en"
    end,
})

-- Common languages
vim.api.nvim_create_autocmd("FileType", {
    group = gid,
    pattern = { "c", "cpp", "python", "cmake", "go", "markdown" },
    callback = function()
        vim.wo.spell = true
        vim.bo.spelllang = "en"
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
    end,
})

-- No conceal for json, it makes editing hairy
vim.api.nvim_create_autocmd({ "FileType" }, {
    group = gid,
    pattern = { "json", "jsonc" },
    callback = function()
        vim.wo.spell = false
        vim.wo.conceallevel = 0
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
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
        if ok and stats and (stats.size > 1000000) then
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
            if vim.fn.exists(":IndentBlanklineDisable") > 0 then
                vim.cmd("IndentBlanklineDisable")
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
        local file = vim.loop.fs_realpath(event.match) or event.match
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

-- Stop plantuml previewing
local function puml_update_preview_stop(bufnr)
    local grp = vim.api.nvim_buf_get_var(bufnr, "puml_preview_augroup")
    if grp then
        vim.api.nvim_buf_del_var(bufnr, "puml_preview_augroup")
        vim.api.nvim_del_augroup_by_id(grp)
    end
    local viewer_job = vim.api.nvim_buf_get_var(bufnr, "puml_viewer_job")
    if viewer_job then
        vim.api.nvim_buf_del_var(bufnr, "puml_viewer_job")
        vim.fn.jobstop(viewer_job)
    end
    print("Plantuml previewer stopped")
end

-- Start previewing a plantuml file in an image viewer
local function puml_update_preview_start(bufnr)
    local grp = vim.api.nvim_create_augroup("puml_preview_" .. bufnr, { clear = true })
    local file = vim.loop.fs_realpath(vim.api.nvim_buf_get_name(bufnr))
    local out_dir = vim.g.puml_tmpdir or vim.fn.stdpath("cache")
    local out_file = out_dir .. vim.fn.fnamemodify(file, ":p:t") .. ".svg"

    -- First way, using classic GET method
    -- puml_cmd = "curl http://localhost:8080/svg/$(cat " .. file .. " | zlib-flate -compress | base64 --wrap 0 | tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\\-_') > " .. svg_file
    -- Lazy way, POSTING the file, allowing bigger data
    local puml_cmd = string.format("curl --data-binary @'%s' %s/svg >| '%s' 2> /dev/null",
                                   file,
                                   vim.g.puml_server,
                                   out_file)

    vim.fn.mkdir(out_dir, "p")
    vim.api.nvim_buf_set_var(0, "puml_preview_augroup", grp)

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = grp,
        callback = function(_)
            vim.fn.jobstart(puml_cmd)
        end,
    })
    vim.api.nvim_create_autocmd({ "BufDelete" }, {
        group = grp,
        buffer = bufnr,
        callback = function(_)
            puml_update_preview_stop(bufnr)
        end
    })

    -- generate the image immediately and open the result in an viewer
    vim.fn.jobstart(puml_cmd, {
        on_exit = function()
            local viewer_id = vim.fn.jobstart({vim.g.puml_viewer, out_file })
            vim.api.nvim_buf_set_var(bufnr, "puml_viewer_job", viewer_id)
        end
    })

    print("Plantuml previewer started")
end

-- Toggle previsualization of a plantuml file in an image viewer
vim.api.nvim_create_user_command('PumlToggle', function()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.b.puml_preview_augroup then
        puml_update_preview_stop(bufnr)
    else
        puml_update_preview_start(bufnr)
    end
end, {})
