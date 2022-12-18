local ok, neo_tree = pcall(require, "neo-tree")
if not ok then
    return
end

local u = require("util")

-- Disable legacy commands
vim.g.neo_tree_remove_legacy_commands = 1

-- Disable italic for some highlight groups 
vim.cmd[[highlight! NeoTreeGitConflict guifg=#FF8700 gui=bold]]
vim.cmd[[highlight! NeoTreeGitUnstaged guifg=#FF8700]]

neo_tree.setup({
    close_if_last_window = true,
    enable_diagnostics = false,
    enble_git_status = true,
    sort_case_insensitive = true,
    source_selector = {
        winbar = true,
        content_layout = "center",
    },
    default_component_configs = {
        container = {
            enable_character_fade = true,
        },
        indent = { padding = 0 },
        icon = {
            folder_closed = "",
            folder_open   = "",
            folder_empty  = "ﰊ",
        },
        git_status = {
            symbols = {
              added     = "",
              modified  = "",
              deleted   = "",
              renamed   = "",
              untracked = "",
              ignored   = "◌",
              unstaged  = "",
              staged    = "",
              conflict  = "",
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
            o = "open",
        },
    },
    filesystem = {
        follow_current_file = true,
        hijack_netrw_behavior = "open_current",
        use_libuv_file_watcher = true,
        window = {
            mappings = {
                ["h"] = "toggle_hidden",
                ["ga"] = "git_add_file",
                ["gu"] = "git_unstage_file",
                ["«"] = "prev_source",
                ["»"] = "next_source",
            },
        },
    },
    event_handlers = {
        {
            event = "neo_tree_buffer_enter",
            handler = function(_) vim.opt_local.signcolumn = "auto" end
        },
    },
})

vim.api.nvim_create_autocmd("BufEnter", {
    desc = "Open Neo-Tree on startup with directory",
    group = vim.api.nvim_create_augroup("neotree_start", { clear = true }),
    callback = function()
        local stats = vim.loop.fs_stat(vim.api.nvim_buf_get_name(0))
        if stats and stats.type == "directory" then
            require("neo-tree.setup.netrw").hijack()
        end
    end,
})

u.map_ni("<M-e>", "<Cmd>Neotree focus<CR>", "Toggle Explorer")
u.map_ni("<F5>", "<Cmd>Neotree toggle<CR>", "Toggle Explorer")

