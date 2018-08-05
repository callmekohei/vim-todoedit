" --------------------------------------------------------
" FILE    : syntax/todoedit.vim
" AUTHOR  : callmekohei <callmekohei at gmail.com>
" LICENSE : MIT License
" --------------------------------------------------------

if exists("b:current_syntax")
  finish
endif

" ------------------------------------------------------

function! s:tag() abort "{{{

  " foo:bar
  call matchadd( 'Type', '\v(^|\W)\S+:' )

endfunction "}}}
function! s:project() abort "{{{

  " +foo, ++bar
  call matchadd( 'Statement', '\v(^|\W)\+\S+'  )

endfunction "}}}
function! s:contexts() abort "{{{

  " @09-12
  call matchadd( 'Identifier', '\v(^|\W)\@\S+'  )

endfunction "}}}
function! s:priority() abort " {{{

  " (A)
  call matchadd( 'Function', '\v^\([A-Z]\)\ze\s' )

endfunction " }}}
function! s:date() abort "{{{

  " date formats: YYYY-MM-DD

  " due:
  call matchadd( 'Type', '\v(^|\W)due:' )

  " invalide date formats
  " due:a, due:1, due:2018a-08-05, due:2018-08a-05
  call matchadd( 'Error', '\v(^|\W)due:\zs' . '(\S*)' . '\ze(\s|$)' )

  " valid date formats
  for l:n in range(1,365*2)
    let l:now = localtime()
    let l:second = (60 * 60 * 24 * l:n)
    " past
    call matchadd( 'Constant', strftime( "%Y-%m-%d", l:now - l:second ))
    " today
    call matchadd( 'String', strftime( "%Y-%m-%d", l:now))
    " future
    call matchadd( 'Comment', strftime( "%Y-%m-%d", l:now + l:second ))
  endfor

  " invalide date formats
  " due:2018-08-05a
  call matchadd( 'Error', '\v(^|\W)due:\zs' . '\d{4}-\d{2}-\d{2}\S+' . '\ze(\s|$)' )

endfunction "}}}
function! s:rec() abort "{{{

  " rec formats: rec:[+][count][d|w|m|y]

  " rec:
  call matchadd( 'Type', '\v(^|\W)rec:' )

  " invalide rec formats
  " rec:w1 , rec:aw , rec:+w1 , rec:+aw
  call matchadd( 'Error', '\v(^|\W)rec:\zs' . '(\+\D|\D)[^[:blank:]]+' )
  " rec:1ww , +1ww
  call matchadd( 'Error', '\v(^|\W)rec:\zs' . '\S*(d|w|m|y)\S')
  " rec:1a , rec:+1a
  call matchadd( 'Error', '\v(^|\W)rec:\zs' . '(\+\d{1,}|\d{1,})\S')
  " rec:11a11w , rec:+11a11w
  call matchadd( 'Error', '\v(^|\W)rec:\zs' . '(\+\d{1,}|\d{1,})\w{1,}(d|w|m|y)\ze(\s|$)')

  " valid rec formats
  " rec:1w , rec:+1w
  call matchadd( 'Tag',  '\v(^|\W)rec:\zs' . '(\+\d{1,}|\d{1,})(d|w|m|y)\ze(\s|$)')

endfunction "}}}
function! s:done() abort "{{{

  call matchadd( 'Comment', '\v^x\s.+$' )

endfunction "}}}
" initialize {{{

  call s:tag()
  call s:project()
  call s:contexts()
  call s:priority()
  call s:date()
  call s:rec()
  call s:done()
  let b:current_syntax = "todoedit"

"}}}

" ------------------------------------------------------

" Modeline "{{{1
  " vim: expandtab softtabstop=2 shiftwidth=2
  " vim: foldmethod=marker
  " vim: foldcolumn=5
