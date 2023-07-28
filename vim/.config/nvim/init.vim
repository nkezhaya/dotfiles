" Python 3 location
let g:python_host_prog = '/opt/homebrew/bin/python2'
let g:python3_host_prog = '/opt/homebrew/bin/python3.10'

call plug#begin()

" Sensible defaults
Plug 'tpope/vim-sensible'

Plug 'Shougo/defx.nvim'
Plug 'mattn/emmet-vim'
Plug 'mileszs/ack.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-surround'

" Telescope
Plug 'nvim-lua/plenary.nvim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" lint
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'amiralies/coc-elixir', {'do': 'yarn install && yarn prepack'}
Plug 'clangd/coc-clangd'

" snippets
"Plug 'garbas/vim-snipmate'
"let g:snipMate = { 'snippet_version' : 1 }
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

Plug 'tomtom/tlib_vim'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'honza/vim-snippets'

" lang-specific
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'elixir-editors/vim-elixir'
Plug 'mhinz/vim-mix-format'
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'udalov/kotlin-vim'
Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' }
Plug 'iamcco/coc-tailwindcss',  {'do': 'yarn install --frozen-lockfile && yarn run build'}
Plug 'chrisbra/csv.vim'

" colors
Plug 'arcticicestudio/nord-vim'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'Rigellute/rigel'
Plug 'cocopon/iceberg.vim'
Plug 'flrnd/candid.vim'
Plug 'morhetz/gruvbox'
Plug 'joshdick/onedark.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'embark-theme/vim', { 'as': 'embark' }
Plug 'sainnhe/sonokai'
Plug 'ghifarit53/tokyonight-vim'
Plug 'sainnhe/everforest'
Plug 'ayu-theme/ayu-vim'
call plug#end()

" Leader key
let mapleader = ","

""" Ack

" Ack should use rg
let g:ackprg = 'rg --vimgrep --type-not sql --smart-case'

" Auto close the Quickfix list after pressing '<enter>' on a list item
let g:ack_autoclose = 1

" Any empty ack search will search for the work the cursor is on
let g:ack_use_cword_for_empty_search = 1

" Maps <leader>/ so we're ready to type the search keyword
nnoremap <Leader>/ :Ack!<Space>

" Don't jump to first match
cnoreabbrev Ack Ack!

" mix format
let g:mix_format_elixir_bin_path = trim(system('asdf where elixir')) . '/bin'
let g:mix_format_on_save = 1

""" TreeSitter

lua <<EOF
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = {},

  highlight = {
    -- false will disable the whole extension
    enable = true,

    disable = { "elixir" },

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true,
  },
  indent = {
    enable = true,
    disable = { "elixir" },
  },
}
EOF

""" CoC

" Escape to close floating windows
nmap <Esc> :call coc#float#close_all() <CR>

" Go to definition in a new tab with "gf"
nmap <silent> gf <Plug>(coc-definition)

" Go to definition in the current tab with "gs"
nmap <silent> gs :call CocAction('jumpDefinition', 'edit')<CR>

" Enter to autocomplete
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" ,<Tab>
imap <C-j> <Plug>snipMateNextOrTrigger

" FZF
let $FZF_DEFAULT_COMMAND = 'ag -g "" --ignore "node_modules"'
nnoremap <leader>j :Files<CR>

" Emmet
" To autocomplete in insert mode: <C-y>,
let g:user_emmet_settings = {
  \  'javascript.jsx' : {
    \      'extends' : 'jsx',
    \  },
  \}

let g:user_emmet_install_global = 0
autocmd FileType html,css,eelixir EmmetInstall

" Cadence files are basically Kotlin
au BufRead,BufNewFile *.cdc set filetype=kotlin

set number
set scrolloff=5
set foldlevel=9999
set nofoldenable
set clipboard=unnamed
set nohlsearch
set termguicolors
set completeopt+=noinsert
set completeopt-=preview

" EEx highlighting in Elixir modules
syntax region elixirTemplateSigil matchgroup=elixirSigilDelimiter keepend start=+\~E\z("""\)+ end=+^\s*\z1+ skip=+\\"+ contains=@HTML fold

" EEx highlighting in .heex files
autocmd BufNewFile,BufRead *.html.heex set syntax=eelixir

" pgFormatter for SQL
au FileType sql setl formatprg=/usr/local/bin/pg_format\ -
vmap <C-f> <ESC>:'<,'>! pg_format --no-space-function --function-case 2<CR>

" Defx options
autocmd FileType defx call s:defx_my_settings()
function! s:defx_my_settings() abort
  " Define mappings
  nnoremap <silent><buffer><expr> <CR>
  \ defx#do_action('open')
  nnoremap <silent><buffer><expr> c
  \ defx#do_action('copy')
  nnoremap <silent><buffer><expr> m
  \ defx#do_action('move')
  nnoremap <silent><buffer><expr> p
  \ defx#do_action('paste')
  nnoremap <silent><buffer><expr> l
  \ defx#do_action('open')
  nnoremap <silent><buffer><expr> E
  \ defx#do_action('open', 'vsplit')
  nnoremap <silent><buffer><expr> P
  \ defx#do_action('preview')
  nnoremap <silent><buffer><expr> o
  \ defx#do_action('open_tree', 'toggle')
  nnoremap <silent><buffer><expr> K
  \ defx#do_action('new_directory')
  nnoremap <silent><buffer><expr> N
  \ defx#do_action('new_file')
  nnoremap <silent><buffer><expr> M
  \ defx#do_action('new_multiple_files')
  nnoremap <silent><buffer><expr> C
  \ defx#do_action('toggle_columns',
  \                'mark:indent:icon:filename:type:size:time')
  nnoremap <silent><buffer><expr> S
  \ defx#do_action('toggle_sort', 'time')
  nnoremap <silent><buffer><expr> d
  \ defx#do_action('remove')
  nnoremap <silent><buffer><expr> r
  \ defx#do_action('rename')
  nnoremap <silent><buffer><expr> !
  \ defx#do_action('execute_command')
  nnoremap <silent><buffer><expr> x
  \ defx#do_action('execute_system')
  nnoremap <silent><buffer><expr> yy
  \ defx#do_action('yank_path')
  nnoremap <silent><buffer><expr> .
  \ defx#do_action('toggle_ignored_files')
  nnoremap <silent><buffer><expr> ;
  \ defx#do_action('repeat')
  nnoremap <silent><buffer><expr> h
  \ defx#do_action('cd', ['..'])
  nnoremap <silent><buffer><expr> ~
  \ defx#do_action('cd')
  nnoremap <silent><buffer><expr> q
  \ defx#do_action('quit')
  nnoremap <silent><buffer><expr> <Space>
  \ defx#do_action('toggle_select') . 'j'
  nnoremap <silent><buffer><expr> *
  \ defx#do_action('toggle_select_all')
  nnoremap <silent><buffer><expr> j
  \ line('.') == line('$') ? 'gg' : 'j'
  nnoremap <silent><buffer><expr> k
  \ line('.') == 1 ? 'G' : 'k'
  nnoremap <silent><buffer><expr> <C-l>
  \ defx#do_action('redraw')
  nnoremap <silent><buffer><expr> <C-g>
  \ defx#do_action('print')
  nnoremap <silent><buffer><expr> cd
  \ defx#do_action('change_vim_cwd')
endfunction

" I want to open defx window like explorer.
nnoremap <leader>df :Defx `expand('%:p:h')` -split=vertical -winwidth=50 -direction=topleft -search=`expand('%:p')`<CR>

" Ctrl-\ for netrw replacement
nnoremap <C-\> :Defx `expand('%:p:h')` -search=`expand('%:p')`<CR>

" Turn backup off, since most stuff is in an SCM anyway
set nobackup
set nowb
set noswapfile

" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 2 spaces
set shiftwidth=2
set tabstop=2

" Auto indent, smart indent, wrap lines
set ai
set si
set wrap

" Set UTF-8 as standard encoding
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

" Don't redraw while executing macros (good performance config)
set lazyredraw 

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Wrap comments at 80 chars with visual `gq`
set textwidth=80
set formatoptions-=t
set formatoptions+=q
set formatoptions+=c

" Jump to the last position when opening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

nnoremap <leader>\| :vsplit<CR>
nnoremap <leader>- :split<CR>
nnoremap <leader>t :tab split<CR>

colorscheme dracula

" :evimrc for editing the vim rc
command Evimrc edit $MYVIMRC
