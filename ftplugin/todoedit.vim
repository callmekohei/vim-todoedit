" --------------------------------------------------------
" FILE    : ftplugin/todoedit.vim
" AUTHOR  : callmekohei <callmekohei at gmail.com>
" LICENSE : MIT License
" --------------------------------------------------------

" Save context {{{

  let s:save_cpo = &cpo
  set cpo&vim

" }}}
" ------------------------------------------------------

" Set params {{{
function! s:init() abort

  if ! exists( 'g:FoldMarkerPrefix' )
    let g:FoldMarkerPrefix = 'Folder'
  endif

  " folding options
  let &l:foldmethod = 'expr'
  let &l:foldexpr   = get(funcref('s:myFoldLevel'), 'name') . '(v:lnum)'
  let &l:foldtext   = get(funcref('s:myFoldText' ), 'name') . '()'

  " sort and fold by +folder at first time
  call todoedit#sortByFoldMarker( g:FoldMarkerPrefix )

  " vim-partedit
  let b:partedit_opener      = ':split'
  let b:partedit_filetype    = 'todoedit'
  let b:Partedit_prefix      = ''
  let b:partedit_auto_prefix = v:false

endfunction " }}}
"Key mappings {{{

function! s:keymaps () abort

  " snipet
  inoreabbrev <expr> due: { -> 'due:' . strftime("%Y-%m-%d") }()

  " quick q
  nnoremap <silent><buffer><nowait> q :<C-u>call todoedit#comfirmEmptyBuffer()<CR>

  " folding by marks, taskBody and tag
  nnoremap <silent><buffer><localleader>sx :<C-u>call todoedit#sortByFoldMarker( 'Completion'   )<CR>
  nnoremap <silent><buffer><localleader>sp :<C-u>call todoedit#sortByFoldMarker( 'Priority'     )<CR>
  nnoremap <silent><buffer><localleader>s  :<C-u>call todoedit#sortByFoldMarker( 'PreviousSort' )<CR>
  nnoremap <silent><buffer><localleader>sf :<C-u>call todoedit#sortByFoldMarker( 'Folder'       )<CR>
  nnoremap <silent><buffer><localleader>ss :<C-u>call todoedit#sortByFoldMarker( 'SubFolder'    )<CR>
  nnoremap <silent><buffer><localleader>sc :<C-u>call todoedit#sortByFoldMarker( 'Context'      )<CR>
  nnoremap <silent><buffer><localleader>sd :<C-u>call todoedit#sortByFoldMarker( 'DueDate'      )<CR>

  " toggle done task
  nnoremap <silent><buffer><localleader>x :call todoedit#toggleDoneTask()<CR>
  vnoremap <silent><buffer><localleader>x :call todoedit#toggleDoneTask()<CR>

  " swipe done task
  nnoremap <silent><buffer><localleader>X :call todoedit#swipeDoneTask()<CR>
  vnoremap <silent><buffer><localleader>X :call todoedit#swipeDoneTask()<CR>

  " partEdit
  nnoremap <silent><buffer><localleader><localleader> :call todoedit#partEdit()<CR>
  vnoremap <silent><buffer><localleader><localleader> :call todoedit#partEdit()<CR>

endfunction" }}}
" folding's func {{{

function! s:myFoldLevel(lnum) abort "{{{

  " compare foldMarker to previous line's foldMarker

  let l:dic = {
    \   'Completion' : '\v\C^x\s\d{4}-\d{2}-\d{2}\ze\s'
    \ , 'Priority'   : '\v^\([A-Z]\)\ze\s'
    \ , 'Folder'     : '\v(^|\s)\zs\+\S+'
    \ , 'SubFolder'  : '\v(^|\s)\zs\+\+\S+'
    \ , 'Context'    : '\v(^|\s)\zs\@\S+'
    \ , 'DueDate'    : '\v(^|\s)\zsdue:\d{4}-\d{2}-\d{2}\ze($|\s)'
    \ }

  let l:foldMarkerPattern = l:dic[ g:FoldMarkerPrefix ]

  if g:FoldMarkerPrefix ==# 'Completion'
    let l:preFoldMarker = match(getline(a:lnum - 1), l:foldMarkerPattern )
    let l:foldMarker    = match(getline(a:lnum)    , l:foldMarkerPattern )
  else
    let l:preFoldMarker = matchstr(getline(a:lnum - 1), l:foldMarkerPattern )
    let l:foldMarker    = matchstr(getline(a:lnum)    , l:foldMarkerPattern )
  endif

  if l:foldMarker ==# l:preFoldMarker
    return 1     " stay same fold level
  else
    return ">1"  " set fold start
  endif

endfunction "}}}
function! s:myFoldText() abort "{{{

  let l:dic = {
    \   'Completion' : '\v\C^x\s\d{4}-\d{2}-\d{2}\ze\s'
    \ , 'Priority'   : '\v^\([A-Z]\)\ze\s'
    \ , 'Folder'     : '\v(^|\s)\zs\+\S+'
    \ , 'SubFolder'  : '\v(^|\s)\zs\+\+\S+'
    \ , 'Context'    : '\v(^|\s)\zs\@\S+'
    \ , 'DueDate'    : '\v(^|\s)\zsdue:\d{4}-\d{2}-\d{2}\ze($|\s)'
    \ }

  " Number of lines
  let l:nLines = printf("%003d", v:foldend - v:foldstart + 1)

  " headline
  if g:FoldMarkerPrefix ==# 'Completion'
    if stridx(getline(v:foldstart),'x ') ==# 0
      let l:headline = 'Completed tasks'
    else
      let l:headline = ''
    endif
  else
    let l:foldMarkerPattern = l:dic[ g:FoldMarkerPrefix ]
    let l:headline = matchstr(getline(v:foldstart) , l:foldMarkerPattern )
  endif

  return join([ '+' . v:folddashes , l:nLines, l:headline ])

endfunction "}}}

" }}}
" initialize {{{

  call <SID>init()
  call <SID>keymaps()

" }}}

" ------------------------------------------------------
" Restore context {{{

  let &cpo = s:save_cpo
  unlet s:save_cpo

" }}}
" Modeline "{{{1
  " vim: expandtab softtabstop=2 shiftwidth=2
  " vim: foldmethod=marker
  " vim: foldcolumn=5
