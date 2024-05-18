return {

    -- mini file manager
    {
        "echasnovski/mini.files",
        version = false,
        opts = {
            windows = {
                preview = false,
            },
            options = {
                use_as_default_explorer = false,
                permanent_delete = false,
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
                    require("mini.files").open(vim.uv.cwd(), true)
                end,
                desc = "Open mini.files (cwd)",
            },
        },
        config = function(_, opts)
            local minifiles = require("mini.files")
            minifiles.setup(opts)

            local show_dotfiles = true
            local filter_show = function(_) return true end
            local filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, ".") end

            local toggle_dotfiles = function()
                show_dotfiles = not show_dotfiles
                local new_filter = show_dotfiles and filter_show or filter_hide
                minifiles.refresh({ content = { filter = new_filter } })
            end

            -- Make new window and set it as target
            local open_split = function(direction)
                return function()
                    local new_target_window
                    vim.api.nvim_win_call(minifiles.get_target_window(), function()
                        vim.cmd(direction .. " split")
                        new_target_window = vim.api.nvim_get_current_win()
                    end)
                    minifiles.set_target_window(new_target_window)
                    local fs_entry = minifiles.get_fs_entry()
                    local is_at_file = fs_entry ~= nil and fs_entry.fs_type == 'file'
                    if is_at_file then
                        minifiles.go_in()
                        minifiles.close()
                    end
                end
            end

            -- Change the cwd
            local files_set_cwd = function()
                -- Works only if cursor is on the valid file system entry
                local cur_entry_path = minifiles.get_fs_entry().path
                local cur_directory = vim.fs.dirname(cur_entry_path)
                vim.fn.chdir(cur_directory)
            end

            -- Add some mappings to MiniFiles buffers
            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesBufferCreate",
                callback = function(args)
                    local buf = args.data.buf_id
                    local u = require("utils")

                    -- Tweak left-hand side of mapping to your liking
                    u.bufmap(buf, "n", "h", toggle_dotfiles, "Toggle show hidden files")

                    -- Open in split
                    u.bufmap(buf, "n", "gs", open_split("belowright horizontal"), "Horizontal Split")
                    u.bufmap(buf, "n", "gv", open_split("belowright vertical"), "Vertical Split")

                    -- Open with <Enter>
                    u.bufmap(buf, "n", "<CR>", function()
                        local fs_entry = minifiles.get_fs_entry()
                        local is_at_file = fs_entry ~= nil and fs_entry.fs_type == 'file'
                        if is_at_file then
                            minifiles.go_in()
                            minifiles.close()
                        end
                    end, "Open file")

                    -- Change CWD
                    u.bufmap(buf, "n", "g~", files_set_cwd, "Set CWD")

                    -- Quit with escape
                    u.bufmap(buf, "n", "<Esc>", minifiles.close, "Close Window")

                    -- Remove some keymaps
                    u.bufmap(buf, "ni", "<S-Left>", "<Ignore>", "")
                    u.bufmap(buf, "ni", "<S-Right>", "<Ignore>", "")
                    u.bufmap(buf, "ni", "<S-Up>", "<Ignore>", "")
                    u.bufmap(buf, "ni", "<S-Down>", "<Ignore>", "")
                end,
            })
        end,
    },

    -- Neo-tree file explorer
    {
        "nvim-neo-tree/neo-tree.nvim",
        version = "v3.x",
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
                local stat = vim.uv.fs_stat(vim.fn.argv(0))
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
