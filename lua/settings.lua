local opt = vim.opt
local g = vim.g
local fn = vim.fn

local cachedir = fn.stdpath("data") .. "/cache"
local backdir = cachedir .. "/backup//"
local swapdir = cachedir .. "/swap//"
local undodir = cachedir .. "/undo//"
fn.mkdir(backdir, "p", "0700")
fn.mkdir(swapdir, "p", "0700")
fn.mkdir(undodir, "p", "0700")

-- disable unused default vim plugins
g.loaded_gzip = 1
g.loaded_tar = 1
g.loaded_tarPlugin = 1
g.loaded_zip = 1
g.loaded_zipPlugin = 1
g.loaded_getscript = 1
g.loaded_getscriptPlugin = 1
g.loaded_vimball = 1
g.loaded_vimballPlugin = 1
g.loaded_matchit = 1
g.loaded_matchparen = 1
g.loaded_2html_plugin = 1
g.loaded_logiPat = 1
g.loaded_rrhelper = 1
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.loaded_netrwSettings = 1
g.loaded_netrwFileHandlers = 1

opt.history = 1000
opt.shada = "'1000,:1000,/1000"
opt.backupdir = backdir
opt.directory = swapdir
opt.undodir = undodir
opt.backup = true
opt.writebackup = true
opt.swapfile = true
opt.undofile = true
opt.backupskip = "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*"

-- broken
-- g.do_filetype_lua = 1
-- g.did_load_filetypes = 0

opt.background = "dark"
opt.termguicolors = true
opt.modelines = 5
opt.modelineexpr = false
opt.modeline = true
-- opt.shellslash = true
g.mapleader = " "
g.maplocalleader = " "
opt.number = true
opt.numberwidth = 2
opt.ruler = false
opt.showcmd = false
opt.hidden = true
opt.showmatch = true
opt.laststatus = 2
opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 3
opt.sidescrolloff = 2
opt.emoji = false
opt.errorbells = false
opt.listchars = { eol = "↲", tab = "▶ ", trail = "•", precedes = "«", extends = "»", nbsp = "␣", space = "." }
opt.fillchars = {
    fold = " ",
    foldopen = "▾",
    foldsep = "│",
    foldclose = "▸",
    horiz = "━",
    horizup = "┻",
    horizdown = "┳",
    stlnc = "»",
    vert = "┃",
    vertleft = "┫",
    vertright = "┣",
    verthoriz = "╋",
    eob = " ",
}
opt.list = false
opt.wildmenu = false
-- opt.wildignore = ".git,.hg,.svn,*.pyc,*.o,*.bak,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip"
-- opt.wildignorecase = true
-- opt.wildmode = "longest:full,full"
opt.conceallevel = 2
opt.showmode = false
opt.timeoutlen = 500
opt.ttimeoutlen = 10
opt.updatetime = 250
opt.lazyredraw = true
opt.shortmess = "atIF"
opt.wrap = false
opt.whichwrap:append("<>[]")
opt.linebreak = true
opt.iskeyword:append({ "_", "$", "@", "%", "#", "-" })
opt.incsearch = true
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.smarttab = true
opt.smartindent = true
opt.expandtab = true
opt.softtabstop = 4
opt.tabstop = 4
opt.shiftwidth = 4
opt.shiftround = true
opt.mouse = "a"
opt.mousehide = true
opt.clipboard = "unnamed"
opt.synmaxcol = 200
opt.completeopt = "menu,menuone,noselect"
opt.showfulltag = true
opt.encoding = "utf8"
vim.cmd([[syntax enable]])
opt.foldcolumn = '0'
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
-- opt.foldmethod = "syntax"
-- opt.foldnestmax = 2
opt.pumheight = 15
-- opt.pumblend = 15
opt.virtualedit = "block,onemore"
opt.formatoptions = "lcqrnj"

if fn.executable("rg") then
    opt.grepprg = "rg --vimgrep --no-heading --smart-case"
    opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

opt.guicursor = {
    "n-v:block-Cursor/lCursor-blinkon0",
    "i-c-ci-ve:ver25-Cursor/lCursor",
    "r-cr:hor20-Cursor/lCursor",
    "o:hor50",
}

g["pandoc#command#latex_engine"] = "lualatex"
g["pandoc#filetypes#handled"] = { "pandoc" }
g["pandoc#filetypes#pandoc_markdown"] = 0

g.vim_markdown_auto_insert_bullets = 1
g.vim_markdown_new_list_item_indent = 1
g.vim_markdown_emphasis_multiline = 1
g.vim_markdown_conceal = 2
g.vim_markdown_conceal_code_blocks = 0
g.vim_markdown_math = 1
g.vim_markdown_toml_frontmatter = 1
g.vim_markdown_frontmatter = 1
g.vim_markdown_strikethrough = 1
g.vim_markdown_autowrite = 1
g.vim_markdown_edit_url_in = "tab"
g.vim_markdown_follow_anchor = 1

