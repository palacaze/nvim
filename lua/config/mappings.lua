local u = require("utils")

-- Change annoying behaviours
u.map("n", "q:", ":q", "Quit")
u.map("n", "Y", "y$", "copy to the end of the line")

-- For bépo keyboard
u.map("n", "<C-«>", "<C-]>", "Jump to tag")
u.map("n", "<C-«>", "<Cmd>pop<CR>", "Jump back from tag")
u.map("n", "«", "<<", "Decrease indentation")
u.map("n", "»", ">>", "Increase indentation")
u.map("v", "«", "<gv", "Decrease indentation")
u.map("v", "»", ">gv", "Increase indentation")

-- Change directory to that of current file
u.map("n", "<Leader>~", "<Cmd>:cd %:p:h<CR>:pwd<CR>", "CD to the directory of the current file")

-- Open or create file under cursor
local function open_or_create_file_under_cursor()
    local link = vim.fn.expand("<cfile>")
    local file = vim.loop.fs_realpath(link) or link
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    vim.cmd(":e " .. file)
end

u.map("n", "<M-CR>", open_or_create_file_under_cursor, "Create file under cursor")

-- Copy to clipboard
u.map("nv", "<Leader>y", '"+y', "Copy to clipboard")
u.map("n", "<Leader>yy", '"+yy', "Copy line to clipboard")
u.map("v", "<Leader>Y", '"+y$', "Copy to the end of the line to clipboard")

-- Paste from clipboard
u.map("nv", "<Leader>p", '"+p', "Paste from to clipboard")
u.map("nv", "<Leader>P", '"+P', "Paste before from to clipboard")

-- Text formating
u.map("nv", "Q", "gwip", "Reformat paragraph")
u.map("n", "<Leader>Q", "ggVGgq", "Reformat the full file")

-- Allow moving up and down in wrapped lines.
u.map("nvx", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "Move up", { silent = true, noremap = true, nowait = true, expr = true })
u.map("i", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "<Up>" : "<C-o>gk"', "Move up", { silent = true, noremap = true, nowait = true, expr = true })
u.map("nvx", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "Move down", { silent = true, noremap = true, nowait = true, expr = true })
u.map("i", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "<Down>" : "<C-o>gj"', "Move down", { silent = true, noremap = true, nowait = true, expr = true })

-- Folding
if not u.has_mapping("z1") then
    u.map("n", "z1", function() vim.opt_local.foldlevel = 0 end, "Unfold 1 level")
    u.map("n", "z2", function() vim.opt_local.foldlevel = 1 end, "Unfold 2 levels")
    u.map("n", "z3", function() vim.opt_local.foldlevel = 2 end, "Unfold 3 levels")
    u.map("n", "z4", function() vim.opt_local.foldlevel = 3 end, "Unfold 4 levels")
    u.map("n", "z5", function() vim.opt_local.foldlevel = 4 end, "Unfold 5 levels")
    u.map("n", "z6", function() vim.opt_local.foldlevel = 6 end, "Unfold 6 levels")
    u.map("n", "z0", function() vim.opt_local.foldlevel = 9999 end, "Unfold all")
    u.map("n", "à", "za", "Toggle fold", { remap = true, silent = true, nowait = true })
end

-- Use ALT-s for saving and ALT-q to close
u.map("nvi", "<M-s>", "<Cmd>silent update<CR>", "Save")
u.map("nvi", "<M-q>", "<Cmd>quit<CR>", "Quit")

u.map("n", "<Leader>tw", "<Cmd>set wrap!<CR>", "Toggle wrap")
u.map("n", "<Leader>ts", "<Cmd>set spell!<CR>", "Toggle spell")
u.map("n", "<Leader>tl", "<Cmd>set list!<CR>", "Toggle display of special chars")

-- Tab navigation
u.map("nit", "<A-Up>", "<Cmd>tabp<CR>", "Go to previous tab")
u.map("nit", "<A-Down>", "<Cmd>tabn<CR>", "Go to next tab")
u.map("nit", "<A-t>", "<Cmd>tabnew<CR>", "Create a new tab")

-- Window control: moving between windows and resizing
u.map("n", "<C-k>", "<C-w>c", "Close current window")

-- Navigation if smart-splits has not already set those
if not u.has_mapping("<S-Left>") then
    u.map("nit", "<S-Left>",  "<Cmd>wincmd h<CR>", "Move to left split")
    u.map("nit", "<S-Down>",  "<Cmd>wincmd j<CR>",  "Move to below split")
    u.map("nit", "<S-Up>",    "<Cmd>wincmd k<CR>",  "Move to above split")
    u.map("nit", "<S-Right>", "<Cmd>wincmd l<CR>", "Move to right split")
    u.map("nit", "<C-S-Up>",    "<Cmd>resize -2<CR>", "Resize split up")
    u.map("nit", "<C-S-Down>",  "<Cmd>resize +2<CR>", "Resize split down")
    u.map("nit", "<C-S-Left>",  "<Cmd>vertical resize -2<CR>", "Resize split left")
    u.map("nit", "<C-S-Right>", "<Cmd>vertical resize +2<CR>", "Resize split right")
end

-- Buffers navigation, if not already provided by a plugin
if not u.has_mapping("<A-Left", "n") then
    u.map("ni", "<A-Left>", "<Cmd>bprevious<CR>", "Go to previous buffer")
    u.map("ni", "<A-Right>", "<Cmd>bnext<CR>", "Go to next buffer")
end

-- Terminal navigation
u.map("t", "<M-Esc>",   [[<C-\><C-n>]], "Return to Normal mode")

-- Search word under cursor in Devdocs
u.map("nv", "<Leader>#", function() vim.cmd.Devdocs(u.get_selection()) end, "Search word or selection in Devdocs")

-- F keys

-- F1 = ToggleTerm all terms
-- S-F1 = ToggleTerm sends data to terminal
-- F2 = Open/Toggle first term
-- S-F2 = Previous error in lsp
-- F3 = Resume last search (fzf / telescope)
-- S-F3 = Next error in lsp

u.map("ni", "<F4>", "<Cmd>ClangdSwitchSourceHeader<CR>", "Switch between header and source file")
-- S-F4 = Undotree toggle
-- F5 = Neo Tree toggle
-- S-F5 = Telescope file_browser
u.map("ni", "<M-h>", "<Cmd>nohlsearch<CR>", "Hide search highlighting")
u.map("ni", "<F8>", "<Cmd>nohlsearch<CR>", "Hide search highlighting")
u.map("ni", "<F9>", "<Cmd>set list!<CR>", "Toggle display of special chars")

-- Strip trailing spaces
local function strip_trailing_spaces()
    local save = vim.fn.winsaveview()
    vim.api.nvim_exec2("keepjumps keeppatterns silent! %s/\\s\\+$//e", {})
    vim.fn.winrestview(save)
    vim.cmd("silent update")
end

u.map("ni", "<F10>", strip_trailing_spaces, "Strip Trailing spaces")

-- F11 = DiffView
-- F12 = LazyGit
