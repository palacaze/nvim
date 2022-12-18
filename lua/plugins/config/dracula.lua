local ok, dracula = pcall(require, "dracula")
if not ok then
    return
end

dracula.setup({
    show_end_of_buffer = false, -- default false
    transparent_bg = true, -- default false
    -- set custom lualine background color
    -- lualine_bg_color = "#44475a", -- default nil
    -- set italic comment
    -- italic_comment = true, -- default false
    -- overrides the default highlights see `:h synIDattr`
    overrides = {
        Comment = { fg = "#888888" }
        -- Examples
        -- NonText = { fg = dracula.colors().white }, -- set NonText fg to white
        -- NvimTreeIndentMarker = { link = "NonText" }, -- link to NonText highlight
        -- Nothing = {} -- clear highlight of Nothing
    }
})

