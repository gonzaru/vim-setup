" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" Se simple explorer

" See also ../../ftplugin/se.vim

" do not read the file if it is already loaded or se is not enabled
if exists('g:autoloaded_se') || !get(g:, 'se_enabled') || &cp
  finish
endif
let g:autoloaded_se = 1
let s:se_winsize = get(g:, 'se_winsize', 20)
let s:se_oldcwd = ""

" prints error message and saves the message in the message-history
function! s:EchoErrorMsg(msg)
  if !empty(a:msg)
    echohl ErrorMsg
    echom  a:msg
    echohl None
  endif
endfunction

" prints warning message and saves the message in the message-history
function! s:EchoWarningMsg(msg)
  if !empty(a:msg)
    echohl WarningMsg
    echom  a:msg
    echohl None
  endif
endfunction

" returns an indicator that identifies a file (*/=@|)
function! s:FileIndicator(file)
  let l:ftype = getftype(a:file)
  if l:ftype == "dir"
    let l:symbol = "/"
  elseif l:ftype == "file" && executable(a:file)
    let l:symbol = "*"
  elseif l:ftype == "link"
    let l:symbol = "@"
  elseif l:ftype == "fifo"
    let l:symbol = "|"
  elseif l:ftype == "socket"
    let l:symbol = "="
  else
    let l:symbol = ""
  endif
  return l:symbol
endfunction

" gets Se buffer id
function! s:GetBufId() abort
  for l:b in getbufinfo()
    if getbufvar(l:b.bufnr, '&filetype') ==# "se"
      return l:b.bufnr
    endif
  endfor
  return 0
endfunction

" toggles Se
function! se#Toggle() abort
  let l:sb = s:GetBufId()
  if l:sb
    let l:bufinfo = getbufinfo(l:sb)
    if l:bufinfo[0].hidden
      setlocal nosplitright
      execute "vertical sbuffer " . l:sb
      setlocal splitright
      execute "lcd " . fnameescape(s:se_oldcwd)
      execute "vertical resize " . s:se_winsize
    else
      if win_getid() != bufwinid(l:sb)
        call win_gotoid(bufwinid(l:sb))
      endif
      if &filetype ==# "se"
        close
      endif
    endif
  else
    call se#List()
  endif
endfunction

" populates Se
function! s:ListPopulate() abort
  let l:nohidden = map(sort(globpath(getcwd(), "*", 0, 1)), 'split(v:val, "/")[-1] . s:FileIndicator(v:val)')
  let l:hidden = map(sort(globpath(getcwd(), ".*", 0, 1)), 'split(v:val, "/")[-1] . s:FileIndicator(v:val)')[2:]
  let l:lsf = extend(l:nohidden, l:hidden)
  if len(l:lsf)
    call appendbufline('%', 0, l:lsf)
    call deletebufline('%', '$')
  endif
  call cursor(1, 1)
  try
    let l:parent2cwd = split(getcwd(), "/")[-2]
  catch
    let l:parent2cwd = '/'
  endtry
  call appendbufline('%', 0, ['../ [' . l:parent2cwd . ']'])
  try
    let l:parentcwd = split(getcwd(), "/")[-1]
  catch
    let l:parentcwd = '/'
  endtry
  call appendbufline('%', 1, ['./ [' . l:parentcwd . ']'])
  if !len(l:lsf)
    call deletebufline('%', '$')
    call cursor(1, 1)
    call s:EchoWarningMsg("Warning: directory is empty")
  endif
endfunction

" lists Se
function! se#List() abort
  let l:sb = s:GetBufId()
  if !l:sb
    let s:se_oldcwd = fnamemodify(bufname('%'), ":~:h")
    setlocal nosplitright
    vertical new
    silent file se
    setlocal splitright
    setlocal filetype=se
    if s:se_oldcwd && s:se_oldcwd != '.'
      execute "lcd " . fnameescape(s:se_oldcwd)
    endif
    call s:ListPopulate()
    execute ":vertical resize " . s:se_winsize
  else
    if win_getid() != bufwinid(l:sb)
      call win_gotoid(bufwinid(l:sb))
    endif
    if &filetype ==# "se"
      setlocal modifiable
    endif
    silent call deletebufline('%', 1, '$')
    call s:ListPopulate()
  endif
  let s:se_oldcwd = getcwd()
  setlocal nomodifiable
endfunction

" follows Se file
function! se#FollowFile() abort
  let l:sewinid = win_getid()
  call win_gotoid(win_getid(winnr('#')))
  let l:prevfile = bufname('%')
  let l:prevcwd = fnamemodify(prevfile, ":~:h")
  let l:prevtailfile = fnamemodify(prevfile, ":t")
  call win_gotoid(l:sewinid)
  execute ":lcd " . fnameescape(l:prevcwd)
  call se#List()
  call s:SearchFile(l:prevtailfile)
endfunction

" search Se file
function! s:SearchFile(file) abort
  if !empty(a:file)
    call search('^' . a:file . '.\?$')
  endif
endfunction

" refresh Se list
function! se#RefreshList() abort
  let l:se_prevline = substitute(fnameescape(getline('.')), '*$', "", "")
  call cursor(2, 1)
  call se#List()
  call s:SearchFile(l:se_prevline)
endfunction

" goes to file
function! se#Gofile(mode) abort
  let l:curline = substitute(getline('.'), '*$', "", "")
  let l:firstchar = matchstr(l:curline, "^.")
  let l:lastchar = matchstr(l:curline, ".$")
  let l:sb = s:GetBufId()
  if a:mode ==# "edit" && l:firstchar == "." && l:lastchar == ']' && isdirectory(split(l:curline, " ")[0])
    try
      let l:oldcwd = split(getcwd(), "/")[-1] . "/"
    catch
      let l:oldcwd = "/"
    endtry
    execute "lcd " . getcwd(winnr()) . "/" . fnameescape(split(l:curline, " ")[0])
    call se#List()
    call s:SearchFile(l:oldcwd)
  elseif a:mode ==# "edit" && l:lastchar == '/' && isdirectory(l:curline)
    execute "lcd " . getcwd(winnr()) . "/" . fnameescape(l:curline)
    call se#List()
  elseif a:mode ==# "edit" && l:lastchar == '@' && isdirectory(resolve(substitute(l:curline, '@$', "", "")))
    execute "lcd " . fnameescape(resolve(substitute(l:curline, '@$', "", "")))
    call se#List()
  else
    if l:lastchar == '@'
      let l:curline = resolve(substitute(l:curline, '@$', "", ""))
      if !filereadable(l:curline)
        call s:EchoErrorMsg("Error: symlink is broken")
        return
      endif
    endif
    if !filereadable(l:curline)
      call s:EchoErrorMsg("Error: file is no longer available")
      return
    endif
    let l:mode_list = ["edit", "editk", "pedit", "split"]
    if index(l:mode_list, a:mode) >= 0
      let l:oldcwd = getcwd()
      let l:oldwindid = win_getid()
      call win_gotoid(win_getid(winnr('#')))
      if win_getid() != l:oldwindid
        if a:mode ==# "edit" || a:mode ==# "editk"
          execute "edit " . l:oldcwd . "/" . l:curline
          if a:mode ==# "editk"
            call win_gotoid(bufwinid(l:sb))
          endif
        elseif a:mode ==# "pedit"
          execute "pedit " . l:oldcwd . "/" . l:curline
          call win_gotoid(bufwinid(l:sb))
        elseif a:mode ==# "split"
          execute "split " . l:oldcwd . "/" . l:curline
        endif
      else
        " vsplit as default if is the same Se window
        execute "vsplit " . l:oldcwd . "/" . l:curline
        if a:mode ==# "editk" || a:mode ==# "pedit"
          call win_gotoid(bufwinid(l:sb))
        endif
      endif
    elseif a:mode ==#  "vsplit"
      execute "vsplit " . l:curline
    elseif a:mode ==#  "tabedit"
      execute "tabedit " . l:curline
    endif
  endif
endfunction
