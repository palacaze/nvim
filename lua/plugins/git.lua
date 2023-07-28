return {

    -- Git diff viewer
    {
        "sindrets/diffview.nvim",
        keys = {
            { "<F11>", function()
                  if next(require('diffview.lib').views) == nil then
                      vim.cmd('DiffviewOpen')
                  else
                      vim.cmd('DiffviewClose')
                  end
              end, desc = "Open projet diffview", mode = {"n", "i"} },
            { "<Leader>gD", "<Cmd>DiffviewOpen<CR>", desc = "Open projet diffview" },
            { "<Leader>gd", "<Cmd>DiffviewOpen HEAD -- %<CR>", desc = "Open buffer diffview", mode = {"n", "v"} },
            { "<Leader>gH", "<Cmd>DiffviewFileHistory<CR>", desc = "Open projet git history" },
            { "<Leader>gh", "<Cmd>DiffviewFileHistory %<CR>", desc = "Open buffer git history", mode = {"n", "v"} },
        },
        cmd = {
            "DiffviewOpen",
            "DiffviewClose",
            "DiffviewToggleFiles",
            "DiffviewFocusFiles",
            "DiffviewFileHistory",
            "DiffviewRefresh",
            "DiffviewLog",
        },
        config = function()
            local actions = require("diffview.config").actions
            require("diffview").setup({
                enhanced_diff_hl = true,
                use_icons = true,
                view = {
                    merge_tool = {
                        layout = "diff3_mixed",
                        disable_diagnostics = true,
                    },
                },
                file_panel = {
                    listing_style = "tree",
                    tree_options = {
                        flatten_dirs = true,
                        folder_statuses = "only_folded",
                    },
                    win_config = {
                        position = "left",
                        width = 35,
                    },
                },
                file_history_panel = {
                    log_options = {
                        git = {
                            single_file = {
                                diff_merges = "combined",
                            },
                            multi_file = {
                                diff_merges = "first-parent",
                            },
                        },
                    },
                    win_config = {
                        position = "bottom",
                        height = 16,
                    },
                },
                key_bindings = {
                    file_panel = {
                        ["s"] = actions.toggle_stage_entry,
                        {
                            "n",
                            "<PageUp>",
                            actions.scroll_view(-0.25),
                            { silent = true, noremap = true, desc = "scroll the view up" },
                        },
                        {
                            "n",
                            "<PageDown>",
                            actions.scroll_view(0.25),
                            { silent = true, noremap = true, desc = "scroll the view Down" },
                        },
                    },
                    file_history_panel = {
                        {
                            "n",
                            "<PageUp>",
                            actions.scroll_view(-0.25),
                            { silent = true, noremap = true, desc = "scroll the view up" },
                        },
                        {
                            "n",
                            "<PageDown>",
                            actions.scroll_view(0.25),
                            { silent = true, noremap = true, desc = "scroll the view Down" },
                        },
                    },
                },
                hooks = {
                    diff_buf_read = function(_)
                        if vim.fn.exists(":IndentBlanklineDisable") > 0 then
                            vim.cmd("IndentBlanklineDisable")
                        end

                        -- disable winbars to prevent the dropbar menu from appearing on one side only
                        vim.opt_local.winbar = nil
                    end,
                    view_closed = function(_)
                        -- BUG: neotree git status watching is broken
                        -- update the tree git status manually after lazygit invocation
                        if package.loaded["neo-tree.sources.git_status"] then
                            require("neo-tree.sources.git_status").refresh()
                        end
                    end,
                },
            })
        end,
    },

    -- fugitive.vim: a Git wrapper so awesome, it should be illegal
    { "tpope/vim-fugitive" },

    -- Git changes in the gutter
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signcolumn = true,
            numhl = false,
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local u = require("utils")
                local opts = { silent = true, nowait = true, noremap = true, buffer = bufnr }
                local expr_opts = vim.tbl_extend("keep", opts, { expr = true })

                -- Navigation
                u.map("n", "]c", function()
                    if vim.wo.diff then
                        return "]c"
                    end
                    vim.schedule(gs.next_hunk)
                    return "<Ignore>"
                end, "Move the the next hunk", expr_opts)

                u.map("n", "[c", function()
                    if vim.wo.diff then
                        return "[c"
                    end
                    vim.schedule(gs.prev_hunk)
                    return "<Ignore>"
                end, "Move to the previous hunk", expr_opts)

                -- Actions
                u.map("nv", "<leader>hs", "<Cmd>Gitsigns stage_hunk<CR>", "Stage hunk", opts)
                u.map("nv", "<leader>hr", "<Cmd>Gitsigns reset_hunk<CR>", "Reset hunk", opts)
                u.map("n", "<leader>hu", gs.undo_stage_hunk, "Unstage hunk", opts)
                u.map("n", "<leader>hS", gs.stage_buffer, "Stage buffer", opts)
                u.map("n", "<leader>hR", gs.reset_buffer, "Reset buffer", opts)
                u.map("n", "<leader>hp", gs.preview_hunk, "Preview hunk", opts)
                u.map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line", opts)
                u.map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle blame line", opts)
                u.map("n", "<leader>tW", gs.toggle_word_diff, "Toggle word diff", opts)
                u.map("n", "<leader>hd", gs.diffthis, "Git diff", opts)
                u.map("n", "<leader>hD", function() gs.diffthis("~") end, "Git diff", opts)
                u.map("n", "<leader>td", function()
                    gs.toggle_linehl()
                    gs.toggle_deleted()
                    gs.toggle_word_diff()
                end, "Toggle diff (inline)", opts)
                u.map("ox", "ih", "<Cmd>Gitsigns select_hunk<CR>", "Select hunk", opts)
            end,
        },
    },

}
