au BufRead,BufNewFile *.tpp set filetype=cpp

"set cursorline
set number
"set relativenumber
set hlsearch

nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz      
nnoremap <C-f> <C-f>zz      
nnoremap <C-b> <C-b>zz      

" tabe size
set tabstop =4
set softtabstop =4
set shiftwidth =4

" tab functionality
set noexpandtab
set autoindent
set smartindent 

" folding configuration
"set foldmethod=syntax
"autocmd BufWinEnter * silent! %foldopen!

"colorscheme desert
"set background=dark
"hi Normal ctermbg=NONE guibg=NONE
"hi Normal guibg=#000000
syntax on


