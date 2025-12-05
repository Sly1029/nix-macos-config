{ pkgs, config, ... }:

{
  # Vimrc for VSCode vim extension and other vim-compatible tools
  ".vimrc".text = ''
    " Leader key
    let mapleader=" "
    let maplocalleader=" "

    " Basic options
    set number
    set relativenumber
    set ignorecase
    set smartcase
    set hlsearch
    set incsearch

    " Delete without yanking (leader prefix)
    nnoremap <leader>d "_d
    vnoremap <leader>d "_d
    nnoremap <leader>D "_D
    vnoremap <leader>D "_D
    nnoremap <leader>c "_c
    vnoremap <leader>c "_c
    nnoremap <leader>x "_x

    " Window navigation
    nnoremap <C-h> <C-w>h
    nnoremap <C-j> <C-w>j
    nnoremap <C-k> <C-w>k
    nnoremap <C-l> <C-w>l

    " Yank to end of line
    nnoremap Y y$

    " Move by display lines
    nnoremap j gj
    nnoremap k gk

    " Quit window
    nnoremap <leader>q :q<CR>

    " Clipboard operations
    nnoremap <leader>p "+gP
    xnoremap <leader>y "+y
  '';
}
