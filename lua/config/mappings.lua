local u = require("config.utils")

-- Change annoying behaviours
u.map_n("q:", ":q", "Quit")
u.map_n("Y", "y$", "copy to the end of the line")

-- For bépo keyboard
u.map_n("<C-«>", "<C-]>", "Jump to tag")
u.map_n("<C-«>", "<Cmd>pop<CR>", "Jump back from tag")
u.map_n("«", "<<", "Decrease indentation")
u.map_n("»", ">>", "Increase indentation")
u.map_v("«", "<gv", "Decrease indentation")
u.map_v("»", ">gv", "Increase indentation")

-- Change directory to that of current file
u.map_n("<Leader>~", "<Cmd>:cd %:p:h<CR>:pwd<CR>", "CD to the directory of the current file")

u.map_n("<M-CR>", u.open_or_create_file_under_cursor, "Create file under cursor")

-- Copy to clipboard
u.map_nv("<Leader>y", '"+y', "Copy to clipboard")
u.map_n("<Leader>yy", '"+yy', "Copy line to clipboard")
u.map_v("<Leader>Y", '"+y$', "Copy to the end of the line to clipboard")

-- Paste from clipboard
u.map_nv("<Leader>p", '"+p', "Paste from to clipboard")
u.map_nv("<Leader>P", '"+P', "Paste before from to clipboard")

-- Text formating
u.map_nv("Q", "gwip", "Reformat paragraph")
u.map_n("<Leader>Q", "ggVGgq", "Reformat the full file")

-- Allow moving up and down in wrapped lines.
u.map({"n", "v", "x"}, "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "Move up", { silent = true, noremap = true, nowait = true, expr = true })
u.map("i", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "<Up>" : "<C-o>gk"', "Move up", { silent = true, noremap = true, nowait = true, expr = true })
u.map({"n", "v", "x"}, "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "Move down", { silent = true, noremap = true, nowait = true, expr = true })
u.map("i", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "<Down>" : "<C-o>gj"', "Move down", { silent = true, noremap = true, nowait = true, expr = true })

-- Folding
u.map_n("z1", function() vim.opt_local.foldlevel = 0; end, "Unfold 1 level")
u.map_n("z2", function() vim.opt_local.foldlevel = 1 end, "Unfold 2 levels")
u.map_n("z3", function() vim.opt_local.foldlevel = 2 end, "Unfold 3 levels")
u.map_n("z4", function() vim.opt_local.foldlevel = 3 end, "Unfold 4 levels")
u.map_n("z5", function() vim.opt_local.foldlevel = 4 end, "Unfold 5 levels")
u.map_n("z6", function() vim.opt_local.foldlevel = 6 end, "Unfold 6 levels")
u.map_n("z0", function() vim.opt_local.foldlevel = 9999 end, "Unfold all")
u.map_n("à", "za", "Toggle fold", { remap = true, silent = true, nowait = true })

-- Use ALT-s for saving and ALT-q to close
u.map_nvi("<M-s>", "<Cmd>silent update<CR>", "Save")
u.map_nvi("<M-q>", "<Cmd>quit<CR>", "Quit")

-- Tab navigation
u.map({"n", "i", "t"}, "<A-Up>", "<Cmd>tabp<CR>", "Go to previous tab")
u.map({"n", "i", "t"}, "<A-Down>", "<Cmd>tabn<CR>", "Go to next tab")
u.map({"n", "i", "t"}, "<A-t>", "<Cmd>tabnew<CR>", "Create a new tab")

-- Window control: moving between windows and resizing
u.map_n("<C-k>", "<C-w>c", "Close current window")

-- Navigation if smart-splits has not already set those
if not u.has_mapping("<S-Left>") then
    u.map({"n", "i", "t"}, "<S-Left>",  "<Cmd>wincmd h<CR>", "Move to left split")
    u.map({"n", "i", "t"}, "<S-Down>",  "<Cmd>wincmd j<CR>",  "Move to below split")
    u.map({"n", "i", "t"}, "<S-Up>",    "<Cmd>wincmd k<CR>",  "Move to above split")
    u.map({"n", "i", "t"}, "<S-Right>", "<Cmd>wincmd l<CR>", "Move to right split")
    u.map({"n", "i", "t"}, "<C-S-Up>",    "<Cmd>resize -2<CR>", "Resize split up")
    u.map({"n", "i", "t"}, "<C-S-Down>",  "<Cmd>resize +2<CR>", "Resize split down")
    u.map({"n", "i", "t"}, "<C-S-Left>",  "<Cmd>vertical resize -2<CR>", "Resize split left")
    u.map({"n", "i", "t"}, "<C-S-Right>", "<Cmd>vertical resize +2<CR>", "Resize split right")
end

-- Buffers navigation, if not already provided by a plugin
if not u.has_mapping("<A-Left", "n") then
    u.map_ni("<A-Left>", "<Cmd>bprevious<CR>", "Go to previous buffer")
    u.map_ni("<A-Right>", "<Cmd>bnext<CR>", "Go to next buffer")
end

-- Terminal navigation
u.map_t("<M-Esc>",   [[<C-\><C-n>]], "Return to Normal mode")

-- F keys

-- F1 = ToggleTerm all terms
-- S-F1 = ToggleTerm sends data to terminal
-- F2 = Open/Toggle first term
-- S-F2 = Previous error in lsp
-- F3 = Resume last search (fzf / telescope)
-- S-F3 = Next error in lsp

u.map_ni("<F4>", "<Cmd>ClangdSwitchSourceHeader<CR>", "Switch between header and source file")
-- S-F4 = Undotree toggle
-- F5 = Neo Tree toggle
-- S-F5 = Telescope file_browser
-- F6 = Telescope find_files
-- F7 = Telescope live_grep
u.map_ni("<F8>", "<Cmd>nohlsearch<CR>", "Hide search highlighting")
u.map_ni("<F9>", "<Cmd>set list!<CR>", "Toggle display of special chars")

-- strip trailing spaces
u.map_nvi("<F10>", u.strip_trailing_spaces, "Strip Trailing spaces")

-- F11 = DiffView
-- F12 = LazyGit
