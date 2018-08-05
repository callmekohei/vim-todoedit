" --------------------------------------------------------
" FILE    : ftdetect/todoedit.vim
" AUTHOR  : callmekohei <callmekohei at gmail.com>
" LICENSE : MIT License
" --------------------------------------------------------

augroup autodoedit
  autocmd!
  autocmd BufNewFile,BufRead todo.txt setlocal filetype=todoedit
augroup END

