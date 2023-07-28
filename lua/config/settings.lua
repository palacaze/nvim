local opt = vim.opt
local g = vim.g

local cachedir = vim.fn.stdpath("data") .. "/cache"
local backdir = cachedir .. "/backup//"
local swapdir = cachedir .. "/swap//"
local undodir = cachedir .. "/undo//"
vim.fn.mkdir(backdir, "p", "0700")
vim.fn.mkdir(swapdir, "p", "0700")
vim.fn.mkdir(undodir, "p", "0700")

-- disable unused default vim plugins
g.loaded_node_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0

g.mapleader = " "
g.maplocalleader = " "

-- opt.shellslash = true
opt.background = "dark"
opt.backup = true
opt.backupdir = backdir
opt.backupskip = { "/tmp/*", "$TMPDIR/*", "$TMP/*", "$TEMP/*" }
opt.cindent = true
opt.cinoptions = "g0N0"
opt.clipboard = "unnamedplus"
opt.completeopt = "menu,menuone,noinsert,noselect"
opt.conceallevel = 3
opt.cursorline = false
opt.diffopt:append("linematch:60")
opt.directory = swapdir
opt.emoji = true
opt.encoding = "utf8"
opt.errorbells = false
opt.expandtab = true
opt.fillchars = {
    fold = " ",
    foldopen = "▾",
    foldsep = "│",
    foldclose = "▸",
    horiz = "━",
    horizup = "┻",
    horizdown = "┳",
    stlnc = " ",
    vert = "┃",
    vertleft = "┫",
    vertright = "┣",
    verthoriz = "╋",
    eob = " ",
    diff = "",
}
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
-- opt.foldmethod = "marker"
opt.formatoptions = "lcqtrnj2"
if vim.fn.executable("rg") then
    opt.grepformat:append("%f:%l:%c:%m")
    opt.grepprg = "rg --vimgrep --smart-case --trim"
end
opt.guicursor = {
    "n-v:block-Cursor/lCursor-blinkon0",
    "i-c-ci-ve:ver25-Cursor/lCursor",
    "r-cr:hor20-Cursor/lCursor",
    "o:hor50",
}
opt.hidden = true
opt.history = 1000
opt.hlsearch = true
opt.ignorecase = true
opt.inccommand = "nosplit"
opt.incsearch = true
opt.iskeyword:append({ "_", "$", "@", "%", "#", "-" })
opt.laststatus = 1
opt.lazyredraw = false
opt.linebreak = true
opt.list = false
opt.listchars = {
    eol = "↲",
    tab = "▶ ",
    trail = "•",
    precedes = "«",
    extends = "»",
    nbsp = "␣",
    space = ".",
}
opt.modeline = true
opt.modelineexpr = false
opt.modelines = 5
opt.mouse = "a"
opt.mousemoveevent = true
opt.number = true
opt.numberwidth = 2
opt.pumblend = 15
opt.pumheight = 15
opt.relativenumber = false
opt.ruler = false
opt.scrolloff = 3
opt.shada = "'1000,:1000,/1000"
opt.shiftround = true
opt.shiftwidth = 4
opt.shortmess = "atIF"
opt.showcmd = false
opt.showfulltag = true
opt.showmatch = true
opt.showmode = false
opt.sidescrolloff = 8
opt.smartcase = true
opt.smartindent = true
opt.smarttab = true
opt.spelllang = { "en" }
opt.softtabstop = 4
opt.splitkeep = "topline"
opt.splitbelow = true
opt.splitright = true
opt.swapfile = true
opt.synmaxcol = 200
opt.tabstop = 4
opt.termguicolors = true
opt.timeout = true
opt.timeoutlen = 500
opt.ttimeoutlen = 10
opt.undodir = undodir
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.virtualedit = "block,onemore"
opt.whichwrap:append("<>[]")
opt.wildignore = {
    ".git",
    ".hg",
    ".svn",
    "*.pyc",
    "*.o",
    "*.bak",
    "*.out",
    "*.jpg",
    "*.jpeg",
    "*.png",
    "*.gif",
    "*.zip",
    "*.pdf",
}
opt.wildignorecase = true
opt.wildmode = "longest:full,full"
opt.wrap = false
opt.writebackup = true

-- plugins

g["pandoc#command#latex_engine"] = "lualatex"
g["pandoc#filetypes#handled"] = { "pandoc" }
g["pandoc#filetypes#pandoc_markdown"] = 0

g.editorconfig = true

g.gruvbox_plugin_hi_groups = 1

g.markdown_recommended_style = 0

g.puml_server = "http://localhost:8080"
