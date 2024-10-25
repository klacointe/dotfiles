" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
	silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
  \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	"autocmd VimEnter * PlugInstall
	"autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/autoload/plugged')

" Jump to file
Plug 'ctrlpvim/ctrlp.vim'

" Colors
Plug 'altercation/vim-colors-solarized'
Plug 'chriskempson/base16-vim'

" Code
Plug 'dense-analysis/ale'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Git
Plug 'tpope/vim-fugitive'

"" Completion
" if has('nvim-0.5')
"   Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
" endif

"" language server configurations
" if has('nvim-0.5')
"   Plug 'neovim/nvim-lspconfig'
" endif

"" elixir
Plug 'elixir-editors/vim-elixir'

"" Terraform
Plug 'hashivim/vim-terraform'

"" misc
Plug 'tpope/vim-commentary'
Plug 'bronson/vim-trailing-whitespace'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'jiangmiao/auto-pairs'

call plug#end()
