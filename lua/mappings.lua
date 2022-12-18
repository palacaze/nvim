local u = require("util")

-- Change annoying behaviours
u.map_n("q:", ":q", "Quit")
u.map_n("Y", "y$", "copy to the end of the line")

-- For bépo keyboard
u.map_nv("<C-»>", "<C-]>", "Jump to tag")
u.map_nv("<C-«>", "<C-t>", "Jump back from tag")
u.map_n("«", "<", "Decrease indentation")
u.map_n("»", ">", "Increase indentation")
u.map_v("«", "<gv", "Decrease indentation")
u.map_v("»", ">gv", "Increase indentation")

-- Change directory to that of current file
u.map_n("<Leader>cd", "<Cmd>:cd %:p:h<CR>:pwd<CR>", "CD to the directory of the current file")

-- Copy to clipboard
u.map_nv("<Leader>y", '"+y', "Copy to clipboard")
u.map_n("<Leader>yy", '"+yy', "Copy line to clipboard")
u.map_v("<Leader>Y", '"+y$', "Copy to the end of the line to clipboard")

-- Paste from clipboard
u.map_nv("<Leader>p", '"+p', "Paste from to clipboard")
u.map_nv("<Leader>P", '"+P', "Paste before from to clipboard")

-- Text formating
u.map_n("Q", "gwip", "Reformat paragraph")
u.map_n("<Leader>Q", "ggVGgq", "Reformat the full file")

-- Folding
u.map_n("z1", function() vim.opt_local.foldlevel = 0 end, "Unfold 1 level")
u.map_n("z2", function() vim.opt_local.foldlevel = 1 end, "Unfold 2 levels")
u.map_n("z3", function() vim.opt_local.foldlevel = 2 end, "Unfold 3 levels")
u.map_n("z4", function() vim.opt_local.foldlevel = 3 end, "Unfold 4 levels")
u.map_n("z5", function() vim.opt_local.foldlevel = 4 end, "Unfold 5 levels")
u.map_n("z6", function() vim.opt_local.foldlevel = 6 end, "Unfold 6 levels")
u.map_n("z0", function() vim.opt_local.foldlevel = 9999 end, "Unfold all")
u.map_n("à", "za", "Toggle fold", { remap = true })

-- Use ALT-s for saving and ALT-q to close
u.map_nvi("<M-s>", "<Cmd>update<CR>", "Save")
u.map_nvi("<M-q>", "<Cmd>quit<CR>", "Quit")

-- Comment out lines of code (toggles) using Alt-x
local comment_api_ok, comment_api = pcall(require, "Comment.api")
if comment_api_ok then
    u.map_ni("<M-x>", comment_api.toggle.linewise.current, "Toggle comment")

    -- Toggle selection (linewise)
    u.map_v("<M-x>", function()
        vim.api.nvim_feedkeys(u.esc, "nx", false)
        comment_api.toggle.linewise(vim.fn.visualmode())
    end)

    -- Toggle selection (blockwise)
    u.map_v("<M-y>", function()
        vim.api.nvim_feedkeys(u.esc, "nx", false)
        comment_api.toggle.blockwise(vim.fn.visualmode())
    end)
end

-- Align stuff with Tabular
u.map_nv("<A-a>=", "<Cmd>Tabularize /=<CR>", "Align on =")
u.map_nv("<A-a>,", "<Cmd>Tabularize /,<CR>", "Align on ,")
u.map_nv("<A-a><Bar>", "<Cmd>Tabularize /<Bar><CR>", "Align on |")

-- Tab navigation
u.map_ni("<C-PageUp>", "<Cmd>tabp<CR>", "Go to previous tab")
u.map_ni("<C-PageDown>", "<Cmd>tabn<CR>", "Go to next tab")
u.map_ni("<C-t>", "<Cmd>tabnew<CR>", "Create a new tab")

-- Window control: moving between windows and resizing
u.map_n("<C-k>", "C-w>c", "Close current window")

-- Navigation
local smart_ok, smart_splits = pcall(require, "smart-splits")
if smart_ok then
    -- Move between splits
    u.map_ni("<S-Left>",  smart_splits.move_cursor_left, "Move to left split")
    u.map_ni("<S-Down>",  smart_splits.move_cursor_down, "Move to below split")
    u.map_ni("<S-Up>",    smart_splits.move_cursor_up, "Move to above split")
    u.map_ni("<S-Right>", smart_splits.move_cursor_right, "Move to right split")

    -- Resize with arrows
    u.map_ni("<M-Up>",   smart_splits.resize_up, "Resize split up")
    u.map_ni("<M-Down>", smart_splits.resize_down, "Resize split down")
    u.map_ni("<M-Left>", smart_splits.resize_left, "Resize split left")
    u.map_ni("<M-Right>",smart_splits.resize_right, "Resize split right")
else
    u.map_ni("<S-Left>",  "<C-w>h", "Move to left split")
    u.map_ni("<S-Down>",  "<C-w>j",  "Move to below split")
    u.map_ni("<S-Up>",    "<C-w>k",  "Move to above split")
    u.map_ni("<S-Right>", "<C-w>l", "Move to right split")
    u.map_ni("<M-Up>",    "<Cmd>resize -2<CR>", "Resize split up")
    u.map_ni("<M-Down>",  "<Cmd>resize +2<CR>", "Resize split down")
    u.map_ni("<M-Left>",  "<Cmd>vertical resize -2<CR>", "Resize split left")
    u.map_ni("<M-Right>", "<Cmd>vertical resize +2<CR>", "Resize split right")
end

-- Buffers navigation
if pcall(require, "bufferline") then
    u.map_n("<Leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>", "Jump to buffer 1")
    u.map_n("<Leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>", "Jump to buffer 2")
    u.map_n("<Leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>", "Jump to buffer 3")
    u.map_n("<Leader>4", "<Cmd>BufferLineGoToBuffer 4<CR>", "Jump to buffer 4")
    u.map_n("<Leader>5", "<Cmd>BufferLineGoToBuffer 5<CR>", "Jump to buffer 5")
    u.map_n("<Leader>6", "<Cmd>BufferLineGoToBuffer 6<CR>", "Jump to buffer 6")
    u.map_n("<Leader>7", "<Cmd>BufferLineGoToBuffer 7<CR>", "Jump to buffer 7")
    u.map_n("<Leader>8", "<Cmd>BufferLineGoToBuffer 8<CR>", "Jump to buffer 8")
    u.map_n("<Leader>9", "<Cmd>BufferLineGoToBuffer 9<CR>", "Jump to buffer 9")
    u.map_ni("<C-Up>",   "<Cmd>BufferLineCycleNext<CR>", "Go to previous buffer")
    u.map_ni("<C-Down>", "<Cmd>BufferLineCyclePrev<CR>", "Go to next buffer")
else
    u.map_ni("<C-Up>", "<Cmd>bprevious<CR>", "Go to previous buffer")
    u.map_ni("<C-Down>", "<Cmd>bnext<CR>", "Go to next buffer")
end

-- Terminal navigation
u.map_t("<Esc>", [[<C-\><C-n>]], "Return to Normal mode")
u.map_t("<S-Left>", [[<C-\><C-n><C-W>h]], "Move to the window on the left")
u.map_t("<S-Up>", [[<C-\><C-n><C-W>j]], "Move to the window up")
u.map_t("<S-Down>", [[<C-\><C-n><C-W>k]], "Move to the window down")
u.map_t("<S-Right>", [[<C-\><C-n><C-W>l]], "Move to the window on the right")

-- F keys

-- F1 = ToggleTerm
-- S-F2 = Previous error in lsp
-- S-F3 = Next error in lsp

-- folding
u.map_nvi("<F2>", "<Cmd>foldclose<CR>", "Fold")
u.map_nvi("<F3>", "<Cmd>foldopen<CR>", "Unfold")

u.map_ni("<F4>", "<Cmd>ClangdSwitchSourceHeader<CR>", "Switch between header and source file")
-- F5 = Neo Tree toggle
-- F6 = Telescope find_files
-- F7 = Telescope live_grep
u.map_ni("<F8>", "<Cmd>nohlsearch<CR>", "Hide search highlighting")
u.map_ni("<F9>", "<Cmd>set list!<CR>", "Toggle display of special chars")
-- F10 = ToggleTerm sends data to terminal

-- A function to trim trailing spaces
local function strip_trailing_spaces()
    local save = vim.fn.winsaveview()
    vim.api.nvim_exec("keepjumps keeppatterns silent! %s/\\s\\+$//e", false)
    vim.fn.winrestview(save)
end

u.map_nvi("<F11>", strip_trailing_spaces, "Strip Trailing spaces")

