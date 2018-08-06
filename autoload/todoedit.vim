" --------------------------------------------------------
" FILE    : autoload/todoedit.vim
" AUTHOR  : callmekohei <callmekohei at gmail.com>
" LICENSE : MIT License
" --------------------------------------------------------

" Save context {{{

  let s:save_cpo = &cpo
  set cpo&vim

" }}}
" ------------------------------------------------------

function! todoedit#partEdit() range "{{{

  if call('foldclosed',[line('.')]) !=# -1

    normal!v
    normal!:
    normal!`<
    let l:fstline = line(".")
    normal!`>
    let l:lstline = line(".")

    set foldmethod=indent " Partedit needs fixed original buffer.
    execute l:fstline .',' . l:lstline . 'Partedit'

  else

    set foldmethod=indent " Partedit needs fixed original buffer.
    execute a:firstline .',' . a:lastline . 'Partedit'

  endif

endfunction "}}}
function! todoedit#swipeDoneTask() range "{{{

  " check valid file path to done.txt
  if exists( 'g:doneTaskFile' )
    if ! filereadable( g:doneTaskFile )
      echo 'File path to done.txt is invalid!'
      echo g:doneTaskFile
      return
    endif
  endif

  " trim head and tail spaces
  call todoedit#trim()

  " select all folding items if cursor is on foldclosed line.
  if call('foldclosed',[line('.')]) !=# -1 && a:firstline ==# a:lastline
    normal!v
    normal!:
    normal!`<
    let l:fstline = line(".")
    normal!`>
    let l:lstline = line(".")
  else
    let l:fstline = a:firstline
    let l:lstline = a:lastline
  endif

  let l:lst_doneTasks = []
  let l:lst_RowNumber = []

  for l:lnum in range(l:fstline,l:lstline)

    let l:line = getline(lnum)

    " do not action for empty line
    if l:line =~# '\v(^$|^\s+$)'
      return
    endif

    " do done task format and add list
    if l:line =~# '\v^x\s\d{4}-\d{2}-\d{2}\s'
      :call add( l:lst_doneTasks, l:line )
    else
      :call add( l:lst_doneTasks, 'x ' . strftime("%Y-%m-%d") .' ' . l:line )
    endif

    :call add( l:lst_RowNumber , l:lnum )

  endfor

  if exists( 'g:doneTaskFile' )
      :call writefile( l:lst_doneTasks, g:doneTaskFile, "a" )
  endif

  :execute l:lst_RowNumber[0] ',' l:lst_RowNumber[-1] 'delete'

endfunction "}}}
function! todoedit#toggleDoneTask() range "{{{

  " trim head and tail spaces
  :call todoedit#trim()

  " select all folding items if cursor is on foldclosed line.
  if call('foldclosed',[line('.')]) !=# -1 && a:firstline ==# a:lastline
    normal!v
    normal!:
    normal!`<
    let l:fstline = line(".")
    normal!`>
    let l:lstline = line(".")
  else
    let l:fstline = a:firstline
    let l:lstline = a:lastline
  endif

  for l:lnum in range(l:fstline,l:lstline)

    let l:line = getline(l:lnum)

    " do not action for empty line
    if l:line =~# '\v(^$|^\s+$)'
      return
    endif

    let l:pattern_rec = '\v(^|\s)\zsrec:\zs(\+\d{1,}|\d{1,})[dwmy]'

    if l:line !~# '\v^x\s\d{4}-\d{2}-\d{2}\s'
      \ && matchstr( l:line, l:pattern_rec ) !=# ''
      :call setline( l:lnum , todoedit#recur(l:line) )
    else
      if l:line =~# '\v^x\s\d{4}-\d{2}-\d{2}\s'
        :call setline( l:lnum , substitute( l:line ,'\v^x\s\d{4}-\d{2}-\d{2}\s','',"" ) )
      else
        :call setline( l:lnum , 'x ' . strftime("%Y-%m-%d") . ' ' . l:line )
      endif
    endif

  endfor

endfunction "}}}
function! todoedit#sortByFoldMarker(foldMarkerPrefix) abort "{{{

  if &l:foldmethod !=# 'expr'
    let &l:foldmethod = 'expr'
  endif

  " trim head and tail spaces
  :call todoedit#trim()

  " clear empty line
  if getline('.') !~# '\v(^$|^\s+$)'
    :normal! ma
    :silent :vglobal/\S/d
    :normal! `a
  else
    :silent :vglobal/\S/d
  endif

  let l:dic = {
    \   'PreviousSort' : ''
    \ , 'Completion'   : '\v\C^x\s\d{4}-\d{2}-\d{2}\s'
    \ , 'Priority'     : '\v^\([A-Z]\)\ze\s'
    \ , 'Folder'       : '\v(^|\s)\zs\+\S+'
    \ , 'SubFolder'    : '\v(^|\s)\zs\+\+\S+'
    \ , 'Context'      : '\v(^|\s)\zs\@\S+'
    \ , 'DueDate'      : '\v(^|\s)\zsdue:\d{4}-\d{2}-\d{2}\ze($|\s)'
    \ }

  " do sort with folding
  if a:foldMarkerPrefix ==# 'PreviousSort'

    :execute 'sort u'
    :execute 'sort /' . l:dic[ g:FoldMarkerPrefix ] . '/ r'
    :normal! zX
    :normal! zM

  else

    let g:FoldMarkerPrefix = a:foldMarkerPrefix

    " do sort with folding
    :execute 'sort u'
    :execute 'sort /' . l:dic[ a:foldMarkerPrefix ] . '/ r'
    :normal! zX
    :normal! zM

  endif

endfunction "}}}
function! todoedit#trim() abort "{{{

  :normal! ma

  let l:range = '%'

  " Replace unicode spaces to normal space
  let l:unicodeSpaces = '\v%u180E|%u2028|%u2029|%u00A0|%u2000|%u2001|%u2002|%u2003|%u2004|%u2005|%u2006|%u2007|%u2008|%u2009|%u200A|%u202F|%u205F|%u3000'
  :execute l:range 'substitute' '/' . l:unicodeSpaces . '/ /ge'

  " trim head spaces
  let headSpaces = '^\s+\ze\S'
  :execute l:range 'substitute' '/\v' . l:headSpaces . '//ge'

  " trim tail spaces
  let tailSpaces = '\s+$'
  :execute l:range 'substitute' '/\v' . l:tailSpaces . '//ge'

  :normal! `a

endfunction "}}}
function! todoedit#comfirmEmptyBuffer() abort "{{{
  if line('$') ==# 1 && getline('$') ==# ''
    :q
  else
    :wq
  endif
endfunction "}}}

" reccurence tasks {{{

function! todoedit#timeZoneOffsetFromUTC() abort "{{{

  " %z is +hhmm , -hhmm
  " %Z is Time zone name
  " see(win): https://msdn.microsoft.com/en-us/library/fe06s4ak.aspx
  " see(osx): man strftime

  let tz = matchstr( strftime('%z'),'\v(\+|-)\d{4}')
  if tz ==# ''
    return 0
  else
    return str2nr(substitute( tz , '0' , '' , 'g'))
  endif

endfunction "}}}
function! todoedit#epochTime(year, month, day, hour, minute, second) "{{{

  " code from : nanasi.jp
  " author    : @taku_o ( Github )
  " url       : http://nanasi.jp/articles/code/date/localtime.html

  " days from 0000/01/01
  let l:year  = a:month < 3 ? a:year - 1   : a:year
  let l:month = a:month < 3 ? 12 + a:month : a:month
  let l:days = 365*l:year + l:year/4 - l:year/100 + l:year/400 + 306*(l:month+1)/10 + a:day - 428

  " days from 0000/01/01 to 1970/01/01
  " 1970/01/01 == 1969/13/01
  let l:ybase = 1969
  let l:mbase = 13
  let l:dbase = 1
  let l:basedays = 365*l:ybase + l:ybase/4 - l:ybase/100 + l:ybase/400 + 306*(l:mbase+1)/10 + l:dbase - 428

  " seconds from 1970/01/01 ( epoch time )
  let l:offset = todoedit#timeZoneOffsetFromUTC()
  return (l:days-l:basedays)*86400 + (a:hour-l:offset)*3600 + a:minute*60 + a:second

endfunction "}}}
function! todoedit#getYaerMonthDayFromDueDate(s) abort "{{{

  let dueDateStr = matchstr(a:s,'\vdue:\zs\d{4}-\d{2}-\d{2}')

  if dueDateStr ==# ''
    let l:today = strftime( "%Y-%m-%d", localtime() )
    return map( split(l:today,'-') , { i,s -> str2nr(s) } )
  else
    return map( split(dueDateStr,'-') , { i,s -> str2nr(s) } )
  endif

endfunction "}}}
function! todoedit#getDaysInMonth(year, month) "{{{

  " code from : dbeniamine/todo.txt-vim
  " author    : @dbeniamine ( GitLab )
  " url       : https://gitlab.com/dbeniamine/todo.txt-vim

  if index([1, 3, 5, 7, 8, 10, 12], a:month) >= 0
    return 31
  elseif index([4, 6, 9, 11], a:month) >= 0
    return 30
  else
    " February, leap year fun.
    if a:year % 4 != 0
      return 28
    elseif a:year % 100 != 0
      return 29
    elseif a:year % 400 != 0
      return 28
    else
      return 29
    endif
  endif

endfunction "}}}
function! todoedit#getDays(s) abort "{{{

  let l:pattern_rec = '\v(^|\s)\zsrec:\zs(\+\d{1,}|\d{1,})[dwmy]'
  let l:rec = matchstr(a:s, l:pattern_rec )
  let l:timespan = split( l:rec, '\zs' )[-1]

  if l:timespan ==# 'd'
    return str2nr( l:rec )
  elseif l:timespan ==# 'w'
    return str2nr( l:rec ) * 7
  elseif l:timespan ==# 'y'
    return str2nr( l:rec ) * 365
  elseif l:timespan ==# 'm'

    let l:ymd    = todoedit#getYaerMonthDayFromDueDate(a:s)
    let l:year   = l:ymd[0]
    let l:month  = l:ymd[1]
    let l:days   = 0
    let l:repeat = str2nr(l:rec)

    for n in range( 1, l:repeat )

      let l:days += todoedit#getDaysInMonth(l:year, l:month )

      let l:month += 1

      if l:month > 12
        let l:year = l:year + 1
        let l:month = 1
      endif

    endfor

    return l:days

  endif

endfunction "}}}
function! todoedit#createDueDateFromToday(s) abort "{{{

  let l:second = (60 * 60 * 24 * todoedit#getDays(a:s) )
  let l:localTime = localtime()
  return 'due:' . strftime( "%Y-%m-%d", l:localTime + l:second )

endfunction "}}}
function! todoedit#createDueDateFromDueDate(s) abort "{{{

  let l:ymd     = todoedit#getYaerMonthDayFromDueDate(a:s)

  let l:second  = (60 * 60 * 24 * todoedit#getDays(a:s) )
  let epochTime = todoedit#epochTime(l:ymd[0],l:ymd[1],l:ymd[2],0,0,0)
  return 'due:' . strftime( "%Y-%m-%d", epochTime + l:second )

endfunction "}}}
function! todoedit#recur(s) abort "{{{

  let l:pattern_rec = '\v(^|\s)\zsrec:\zs(\+\d{1,}|\d{1,})[dwmy]'
  let l:pattern_due = '\v(^|\W)\zsdue:\d{4}-\d{2}-\d{2}\ze(\s|$)'

  let rec = matchstr( a:s, l:pattern_rec )

  if match(a:s, l:pattern_due ) ==# -1
    return a:s . ' ' . todoedit#createDueDateFromToday(a:s)
  endif

  if stridx( rec, '+') ==# 0
    return substitute( a:s, l:pattern_due , todoedit#createDueDateFromDueDate(a:s) , 'g' )
  else
    return substitute( a:s, l:pattern_due , todoedit#createDueDateFromToday(a:s) , 'g' )
  endif

endfunction "}}}

"}}}

" ------------------------------------------------------
" Restore context {{{

  let &cpo = s:save_cpo
  unlet s:save_cpo

" }}}
" Modeline "{{{1
  " vim: expandtab softtabstop=2 shiftwidth=2
  " vim: foldmethod=marker
  " vim: foldcolumn=5
