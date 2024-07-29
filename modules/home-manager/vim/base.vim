set nocompatible
set autoindent
set expandtab
set number
set shiftwidth=4
set smartindent
set softtabstop=4
set tabstop=4
set cursorline
set cursorlineopt=number
set noremap
set nowrap

let g:terraform_binary_path='tofu'
let g:terraform_fmt_on_save=1

let mapleader = " "

vnoremap <C-c> :w !pbcopy<CR><CR>
noremap <C-v> :r !pbpaste<CR><CR>
