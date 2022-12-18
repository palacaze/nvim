local ok, trouble = pcall(require, "trouble")
if not ok then
    return
end

local u = require("util")

trouble.setup({
    -- action_keys = {
    --     previous = "<F2>",
    --     next = "<F3>"
    -- },
    use_diagnostics_signs = true,
})

u.map_n("<leader>xx", "<Cmd>TroubleToggle<CR>", "Toggle the list of diagnostics")
u.map_n("<leader>xw", "<Cmd>TroubleToggle workspace_diagnostics<CR>", "Toggle the list of diagnostics for this workspace")
u.map_n("<leader>xd", "<Cmd>TroubleToggle document_diagnostics<CR>", "Toggle the list of diagnostics for this document")
u.map_n("<leader>xl", "<Cmd>TroubleToggle loclist<CR>", "Toggle the location list")
u.map_n("<leader>xq", "<Cmd>TroubleToggle quickfix<CR>", "Toggle the quickfix list")
u.map_n("<leader>xr", "<Cmd>TroubleToggle lsp_references<CR>", "Toggle the list of LSP References")

