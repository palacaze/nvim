-- A neovim lua plugin to help easily manage multiple terminal windows
return {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
        { "<F1>", "<Cmd>ToggleTermToggleAll<CR>", desc = "Toggle all terminals", mode = { "n", "t", "i" } },
        { "<Leader>Ta", desc = "Toggle all terminals" },
        { "<F2>", desc = "Start a shell in a terminal", mode = { "n", "t", "i" } },
        { "<Leader>Tt", desc = "Start a shell in a terminal" },
        { "<F12>", desc = "Run lazygit in a floating terminal", mode = { "n", "t" } },
        { "<Leader>Tg", desc = "Run lazygit in a floating terminal" },
        { "<Leader>Tp", desc = "Run python3 in a terminal" },
        { "<S-F1>", "<Cmd>ToggleTermSendCurrentLine<CR>", desc = "Send current line to terminal", mode = { "n", "i" } },
        { "<F13>", "<Cmd>ToggleTermSendCurrentLine<CR>", desc = "Send current line to terminal", mode = { "n", "i" } },
        { "<S-F1>", "<Cmd>ToggleTermSendVisualSelection<CR>", desc = "Send selection to terminal", mode = "v" },
        { "<F13>", "<Cmd>ToggleTermSendVisualSelection<CR>", desc = "Send selection to terminal", mode = "v" },
    },
    opts = {
        open_mapping = "<F2>",
        insert_mappings = true,
        terminal_mappings = true,
        persist_size= false,
        shade_terminals = false,
        start_in_insert = true,
        direction = "horizontal",
        close_on_exit = true,
        -- Create a buffer variable "pal_term_name" containing the terminal "name"
        -- on opening. This name will be used by lualine to display a nicer label.
        on_open = function(term)
            if term.term_name == nil then
                term.term_name = "Shell"
            end
            vim.api.nvim_buf_set_var(term.bufnr, "pal_term_name", term.term_name)
            vim.cmd("startinsert!")
        end,
    },
    config = function(_, opts)
        require("toggleterm").setup(opts)

        -- Custom terminals
        local Terminal = require("toggleterm.terminal").Terminal

        local lazygit = Terminal:new({
            cmd = "lazygit",
            direction = "float",
            hidden = true,
            close_on_exit = true,
            float_opts = {
                border = "none",
                winblend = 0,
                width = function(term)
                    term.float_opts.col = 0
                    return vim.o.columns
                end,
                height = function(term)
                    term.float_opts.row = 0
                    return vim.o.lines -1
                end,
            },
            term_name = "Lazygit",
            on_open = function(term)
                -- Remove some keymaps
                vim.keymap.set({"n", "i", "t"}, "<S-Left>", "<Left>", { buffer = term.bufnr })
                vim.keymap.set({"n", "i", "t"}, "<S-Right>", "<Right>", { buffer = term.bufnr })
                vim.keymap.set({"n", "i", "t"}, "<S-Up>", "<Up>", { buffer = term.bufnr })
                vim.keymap.set({"n", "i", "t"}, "<S-Down>", "<Down>", { buffer = term.bufnr })

                vim.api.nvim_buf_set_var(term.bufnr, "pal_term_name", term.term_name)
                vim.cmd("startinsert!")
            end,
            on_close = function(_)
                -- BUG: neotree git status watching is broken
                -- update the tree git status manually after lazygit invocation
                if package.loaded["neo-tree.sources.git_status"] then
                    require("neo-tree.sources.git_status").refresh()
                end
            end,
        })

        local toggle_lazygit = function()
            lazygit:toggle()
        end

        local python = Terminal:new({
            cmd = "ipython",
            direction = "horizontal",
            close_on_exit = true,
            term_name = "IPython",
        })

        local toggle_python = function()
            python:toggle()
        end

        local u = require("utils")
        u.map("n", "<Leader>Tg", toggle_lazygit, "Run lazygit in a floating terminal")
        u.map("nti", "<F12>", toggle_lazygit, "Run lazygit in a floating terminal")
        u.map("n", "<Leader>Tp", toggle_python, "Run python3 in a terminal")
    end,
}
