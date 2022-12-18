local ok, telescope = pcall(require, "telescope")
if not ok then
    return
end

local actions = require("telescope.actions")
local u = require("util")

telescope.setup({
    defaults = {
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
        },
        prompt_prefix = "   ",
        selection_caret = "x ",
        entry_prefix = " ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
            horizontal = {
                prompt_position = "top",
                preview_width = 0.55,
                results_width = 0.8,
            },
            vertical = {
                mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
        },
        path_display = { "smart" },
        winblend = 0,
        border = {},
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        color_devicons = true,
        mappings = {
            n = {
                ["q"] = actions.close
            },
            i = {
                ["<esc>"] = actions.close
            },
        },
    },
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
        fzy_native = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
    },
})

-- load extensions
require("telescope").load_extension("fzf")

-- mappings
u.map_ni("<F6>", "<Cmd>Telescope find_files<CR>", "Find files")
u.map_ni("<F7>", "<Cmd>Telescope live_grep<CR>", "Search in files")
u.map_n("<Leader>ff", "<Cmd>Telescope find_files<CR>", "Search in files")
u.map_n("<Leader>fg", "<Cmd>Telescope live_grep<CR>", "Search in files")
u.map_n("<Leader>fb", "<Cmd>Telescope buffers<CR>", "Find buffers")
u.map_n("<Leader>gc", "<Cmd>Telescope git_commits<CR>", "Display git commits")
u.map_n("<Leader>gb", "<Cmd>Telescope git_branches<CR>", "Display git branches")
u.map_n("<Leader>gs", "<Cmd>Telescope git_status<CR>", "Display git status")
u.map_n(
    "<Leader>fv",
    [[<cmd>lua require("telescope.builtin").find_files{cwd = vim.fn.stdpath('config')}<CR>]],
    "Find files in vim config"
)
u.map_n(
    "<Leader>fs",
    [[<cmd>lua require("telescope.builtin").find_files{cwd = "~/travail/SURFO/indu"}<CR>]],
    "Find files in SURFO"
)
