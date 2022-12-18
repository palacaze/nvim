local ok, toggleterm = pcall(require, "toggleterm")
if not ok then
    return
end

local u = require("util")

toggleterm.setup({
    open_mapping = "<F1>",
})

-- Custom terminals
local Terminal = require("toggleterm.terminal").Terminal

local lazygit = Terminal:new({
    cmd = "lazygit",
    direction = "float",
    close_on_exit = true,
    float_opts = {
        border = "single",
        winblend = 5,
    },
})

local python = Terminal:new({
    cmd = "ipython",
    direction = "horizontal",
    close_on_exit = true,
    on_open = function(term)
        vim.notify("Run ipython", vim.log.levels.INFO)
    end,
})

local toggle_lazygit = function()
    lazygit:toggle()
end

local toggle_python = function()
    python:toggle()
end

u.map_n("<Leader>tg", toggle_lazygit, "Run lazygit in a floating terminal")
u.map_n("<Leader>tp", toggle_python, "Run python3 in a terminal")
u.map_ni("<F10>", "<Cmd>ToggleTermSendCurrentLine<CR>", "Send current line to terminal")
u.map_v("<F10>", "<Cmd>ToggleTermSendVisualSelection<CR>", "Send selection to terminal")
