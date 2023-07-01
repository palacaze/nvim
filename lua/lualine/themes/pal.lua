local colors = {}

if vim.o.background == "dark" then
    colors.green   = "#98BB6C"
    colors.orange  = "#FFA066"
    colors.blue    = "#7E9CD8"
    colors.violet  = "#957FB8"
    colors.yellow  = "#C0A36E"
    colors.bg      = "#16161D"
    colors.bg_dim  = "#2A2A37"
    colors.fg      = "#DCD7BA"
    colors.fg_dim  = "#C8C093"
    colors.warning = "#FF9E3B"
else
    colors.green   = "#6f894e"
    colors.orange  = "#cc6d00"
    colors.blue    = "#4d699b"
    colors.violet  = "#624c83"
    colors.yellow  = "#836f4a"
    colors.bg      = "#dcd5ac"
    colors.bg_dim  = "#e7dba0"
    colors.fg      = "#545464"
    colors.fg_dim  = "#43436c"
    colors.warning = "#E98A00"
end

return {
    normal = {
        a = { bg = colors.bg, fg = colors.fg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.blue },
        c = { bg = colors.bg, fg = colors.fg },
        z = { bg = colors.blue, fg = colors.bg, gui = "bold" },
    },
    insert = {
        a = { bg = colors.bg, fg = colors.fg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.green },
        c = { bg = colors.bg, fg = colors.fg },
        z = { bg = colors.green, fg = colors.bg, gui = "bold" },
    },
    command = {
        a = { bg = colors.bg, fg = colors.fg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.yellow },
        c = { bg = colors.bg, fg = colors.fg },
        z = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
    },
    visual = {
        a = { bg = colors.bg, fg = colors.fg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.violet },
        c = { bg = colors.bg, fg = colors.fg },
        z = { bg = colors.violet, fg = colors.bg, gui = "bold" },
    },
    replace = {
        a = { bg = colors.bg, fg = colors.fg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.orange },
        c = { bg = colors.bg, fg = colors.fg },
        z = { bg = colors.orange, fg = colors.bg, gui = "bold" },
    },
    inactive = {
        a = { bg = colors.bg_dim, fg = colors.fg_dim, gui = "bold" },
        b = { bg = colors.bg_dim, fg = colors.fg_dim },
        c = { bg = colors.bg_dim, fg = colors.fg_dim },
    }
}
