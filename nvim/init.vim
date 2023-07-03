" coq_nvim
let g:coq_settings = { 'auto_start': 'shut-up' }

" Plugins
source $HOME/.config/nvim/vim-plug/plugins.vim

" LSP
if has('nvim-0.5')
  source $HOME/.config/nvim/lua/lsp_config.lua
endif

" common
set autoread            " Auto-reload modified files (with no local changes)
set encoding=utf-8
set fileformat=unix
set noswapfile
set hlsearch
set pastetoggle=<F10>
let c_space_errors = 1

" mouse
set mouse=

" show line numbers
set nu

" indentation / tab as space
set autoindent
set tabstop=2
set shiftwidth=2
set expandtab

" keep selection when indent
vnoremap < <gv
vnoremap > >gv

" ctrlp.vim
let g:ctrlp_map = '<c-p>'
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

" base16-vim
colorscheme base16-tomorrow-night
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif

" commentary
xmap <C-c>  <Plug>Commentary
nmap <C-c>  <Plug>Commentary
omap <C-c>  <Plug>Commentary

" auto-pairs
let g:AutoPairsShortcutToggle = '<M-">'

" ale

map <C-x> :ALEFix<CR>
let g:ale_completion_enabled = 1
let g:ale_elixir_elixir_ls_release = expand("~/elixir-ls/release")
let g:ale_elixir_elixir_ls_config = {'elixirLS': {'dialyzerEnabled': v:false}}
nnoremap <C-]> :ALEGoToDefinition<CR>
nnoremap <C-\> :ALEFindReferences<CR>
nnoremap <C-k> :ALEHover<CR>

highlight clear ALEErrorSign
highlight clear ALEWarningSign
let g:ale_set_highlights = 0
" highlight ALEWarning ctermbg=DarkMagenta
" highlight ALEError ctermbg=DarkRed


" filetypes
au BufNewFile,BufRead *.tsx setlocal filetype=typescript.tsx

" fixers
let g:ale_fixers = {}

""" Global
let g:ale_fixers['*'] = ['remove_trailing_lines', 'trim_whitespace']

""" Elixir
let g:ale_fixers['elixir'] = ['mix_format']

""" Ruby
" let g:ale_fixers['ruby'] = ['rubocop', 'standardrb']
let g:ale_fixers['ruby'] = ['standardrb']

""" Javascript
let g:ale_fixers['typescript'] = ['eslint', 'prettier']
let g:ale_fixers['typescript.jsx'] = ['eslint', 'prettier']
let g:ale_fixers['typescriptreact'] = ['eslint', 'prettier']
let g:ale_fixers['javascript'] = ['eslint', 'prettier']

""" Golang
let g:ale_fixers['go'] = ['gofmt']

"" Linters
let g:ale_linters = {}

""" Elixir
let g:ale_linters['elixir'] = ['credo', 'elixir-ls']

""" Ruby
" let g:ale_linters['ruby'] = ['rubocop', 'standardrb']
let g:ale_linters['ruby'] = ['standardrb']

""" Javascript
let g:ale_linters['javascript'] = ['prettier', 'eslint']
let g:ale_linters['typescript'] = ['prettier', 'eslint', 'tsserver']
let g:ale_linters['typescript.jsx'] = ['prettier', 'eslint', 'tsserver']
let g:ale_linters['typescriptreact'] = ['prettier', 'eslint', 'tsserver']

""" Golang
let g:ale_linters['go'] = ['gofmt']
