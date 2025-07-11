-- Python host programs
vim.g.python_host_prog = '/opt/homebrew/bin/python2'
vim.g.python3_host_prog = '/opt/homebrew/bin/python3.10'

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.scrolloff = 5
vim.opt.foldlevel = 9999
vim.opt.foldenable = false
vim.opt.clipboard = 'unnamed'
vim.opt.termguicolors = true
vim.opt.completeopt:append('noinsert')
vim.opt.completeopt:remove('preview')

-- turn backup off, since most stuff is in SCM anyway
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.wb = false

-- search
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- wrap comments at 80 chars with visual `gq`
vim.opt.textwidth = 80
vim.opt.formatoptions:remove("t")
vim.opt.formatoptions:append("q")
vim.opt.formatoptions:append("c")

-- tabs/spaces
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = true

vim.opt.encoding = "utf8"
vim.opt.ffs = "unix,dos,mac"

-- annoying sounds on errors
vim.opt.errorbells = false
vim.opt.visualbell = false
vim.opt.belloff = "all"
vim.opt.tm = 500
