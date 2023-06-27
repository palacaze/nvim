return {

    -- mini file manager
    {
        "echasnovski/mini.files",
        version = false,
        opts = {
            windows = {
                preview = true,
            },
            options = {
                use_as_default_explorer = false,
            },
            mappings = {
                go_in = "<Right>",
                go_in_plus = "<C-Right>",
                go_out = "<Left>",
                go_out_plus = "<C-Left>",
            },
        },
        keys = {
            {
                "<leader>m",
                function()
                    require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
                end,
                desc = "Open mini.files (directory of current file)",
            },
            {
                "<leader>M",
                function()
                    require("mini.files").open(vim.loop.cwd(), true)
                end,
                desc = "Open mini.files (cwd)",
            },
        },
        config = function(_, opts)
            require("mini.files").setup(opts)

            local show_dotfiles = true
            local filter_show = function(_) return true end
            local filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, ".") end

            local toggle_dotfiles = function()
                show_dotfiles = not show_dotfiles
                local new_filter = show_dotfiles and filter_show or filter_hide
                require("mini.files").refresh({ content = { filter = new_filter } })
            end

            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesBufferCreate",
                callback = function(args)
                    local buf_id = args.data.buf_id
                    -- Tweak left-hand side of mapping to your liking
                    vim.keymap.set("n", "h", toggle_dotfiles, { buffer = buf_id })

                    -- Remove some keymaps
                    vim.keymap.set({"n", "i"}, "<S-Left>", "<Left>", { buffer = buf_id })
                    vim.keymap.set({"n", "i"}, "<S-Right>", "<Right>", { buffer = buf_id })
                    vim.keymap.set({"n", "i"}, "<S-Up>", "<Up>", { buffer = buf_id })
                    vim.keymap.set({"n", "i"}, "<S-Down>", "<Down>", { buffer = buf_id })
                end,
            })
        end,
    },

    -- Neo-tree file explorer   
    {
        "nvim-neo-tree/neo-tree.nvim",
        cmd = "Neotree",
        keys = {
            { "<M-e>", "<Cmd>Neotree focus<CR>", desc = "Focus File Explorer", mode = { "n", "i" } },
            { "<F5>", "<Cmd>Neotree toggle<CR>", desc = "Toggle File Explorer", mode = { "n", "i" } },
        },
        deactivate = function()
            vim.cmd([[Neotree close]])
        end,
        init = function()
            vim.g.neo_tree_remove_legacy_commands = 1
            -- open neo-tree if vim was set to open a directory
            if vim.fn.argc() == 1 then
                local stat = vim.loop.fs_stat(vim.fn.argv(0))
                if stat and stat.type == "directory" then
                    require("neo-tree")
                end
            end
        end,
        opts = {
            sources = {
                "filesystem",
                "buffers",
                "git_status",
            },
            close_if_last_window = true,
            enable_diagnostics = false,
            enble_git_status = true,
            sort_case_insensitive = true,
            use_popups_for_input = false,
            source_selector = {
                winbar = false,
                content_layout = "center",
            },
            event_handlers = {
                {
                    event = "file_opened",
                    handler = function()
                        vim.cmd([[Neotree close]])
                    end
                },
            },
            default_component_configs = {
                container = {
                    enable_character_fade = true,
                },
                indent = {
                    padding = 0,
                    with_markers = false,
                },
                icon = {
                    folder_closed = require("config.icons").doc.Folder,
                    folder_open   = require("config.icons").doc.OpenFolder,
                    folder_empty  = require("config.icons").doc.EmptyFolder,
                },
                name = {
                    trailing_slash = true,
                    use_git_status_colors = true,
                },
                git_status = {
                    symbols = {
                        added     = "",
                        modified  = "",
                        deleted   = require("config.icons").git.Deleted,
                        renamed   = require("config.icons").git.Renamed,
                        untracked = require("config.icons").git.Untracked,
                        ignored   = require("config.icons").git.Ignored,
                        unstaged  = require("config.icons").git.Unstaged,
                        staged    = require("config.icons").git.Staged,
                        conflict  = require("config.icons").git.Conflict,
                    },
                },
            },
            window = {
                width = 30,
                mappings = {
                    ["<space>"] = {
                        "toggle_node",
                        nowait = false,
                    },
                    ["o"] = "open",
                    ["<C-Left>"] = "prev_source",
                    ["<C-Right>"] = "next_source",
                    ["<C-s>"] = "open_split",
                    ["<C-v>"] = "open_vsplit",
                    ["<C-t>"] = "open_tabnew",
                    ["Z"] = "expand_all_nodes",
                    ["<tab>"] = function (state)
                        local node = state.tree:get_node()
                        if require("neo-tree.utils").is_expandable(node) then
                            state.commands["toggle_node"](state)
                        else
                            state.commands["open"](state)
                            vim.cmd("Neotree reveal")
                        end
                    end,
                },
            },
            filesystem = {
                find_args = {
                    fd = {
                        "--exclude", ".git",
                        "--exclude", "cmake/vcpkg",
                    }
                },
                follow_current_file = true,
                hijack_netrw_behavior = "open_current",
                use_libuv_file_watcher = true,
                window = {
                    mappings = {
                        ["h"] = "toggle_hidden",
                        ["ga"] = "git_add_file",
                        ["gu"] = "git_unstage_file",
                    },
                },
            },
        },
    },

}
