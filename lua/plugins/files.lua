return {

    {
        "stevearc/oil.nvim",
        cmds = { "Oil" },
        lazy = false,
        keys = {
            { "-", function() require("oil").toggle_float() end, mode = "n", desc = "Open parent directory" },
            { "<Leader>m", function() require("oil").toggle_float() end, mode = "n", desc = "Open parent directory" },
        },
        opts = {
            float = { padding = 2, win_options = { winblend = 0 }, },
            default_file_explorer = true,
            skip_confirm_for_simple_edits = true,
            delete_to_trash = true,
            lsp_file_methods = {
                enabled = true,
                timeout_ms = 5000,
            },
            keymaps = {
                ["q"] = {
                    "actions.close",
                    opts = { exit_if_last_buf = true },
                    desc = "Close oil",
                },
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
        dependencies = { { "echasnovski/mini.icons" } },
    },

    -- Neo-tree file explorer
    {
        "nvim-neo-tree/neo-tree.nvim",
        version = "v3.x",
        cmd = "Neotree",
        keys = {
            { "<F5>", "<Cmd>Neotree toggle<CR>", desc = "Toggle File Explorer", mode = { "n", "i" } },
        },
        deactivate = function()
            vim.cmd([[Neotree close]])
        end,
        init = function()
            vim.g.neo_tree_remove_legacy_commands = 1
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
            open_files_do_not_replace_types = { "terminal", "trouble", "qf", "DiffViewFiles" },
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
                follow_current_file = {
                    enabled = true,
                    leave_dirs_open = true,
                },
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
