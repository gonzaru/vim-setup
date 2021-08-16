" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" Se simple explorer

" do not read the file if is already loaded
if exists('g:loaded_se') && g:loaded_se == 1
  finish
endif
let g:loaded_se = 1
let g:se_winsize = 20
let g:se_oldcwd = ""

" gets Se buffer id
function! s:SeGetBufId() abort
  for b in getbufinfo()
    if getbufvar(b.bufnr, '&filetype') ==# "se"
      return b.bufnr
    endif
  endfor
  return 0
endfunction

" toggles Se
function! SeToggle() abort
  let l:sb = s:SeGetBufId()
  let l:bufinfo = getbufinfo(l:sb)
  if l:sb && l:bufinfo[0].hidden
    setlocal nosplitright
    execute "vertical sbuffer " . l:sb
    setlocal splitright
    execute "lcd " . g:se_oldcwd
    execute "vertical resize " . g:se_winsize
  elseif l:sb && !l:bufinfo[0].hidden
    if win_getid() != bufwinid(l:sb)
      call win_gotoid(bufwinid(l:sb))
    endif
    if &filetype ==# "se"
      close
    endif
  else
    call SeList()
  endif
endfunction

" populates Se
function! s:SeListPopulate() abort
  let l:lsf = systemlist("cd " . getcwd() . "
  \ && nohidden=$(ls -1 -F) && hidden=$(ls -1 -dF \.?*)
  \ && printf \"${nohidden}\\n${hidden}\" | grep -vE '^(\\.|\\.\\.)/$'")
  call appendbufline('%', 0, l:lsf)
  call deletebufline('%', '$')
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
endfunction

" lists Se
function! SeList() abort
  let l:sb = s:SeGetBufId()
  if !l:sb
    let g:se_oldcwd = fnamemodify(bufname('%'), ":~:h")
    setlocal nosplitright
    vertical new
    silent file se
    setlocal splitright
    setfiletype se
    if g:se_oldcwd && g:se_oldcwd != '.'
      execute "lcd " . g:se_oldcwd
    endif
    call s:SeListPopulate()
    execute ":vertical resize " . g:se_winsize
  else
    if win_getid() != bufwinid(l:sb)
      call win_gotoid(bufwinid(l:sb))
    endif
    if &filetype ==# "se"
      setlocal modifiable
    endif
    silent call deletebufline('%', 1, '$')
    call s:SeListPopulate()
  endif
  let g:se_oldcwd = getcwd()
  setlocal nomodifiable
endfunction

" follows Se file
function! SeFollowFile() abort
  let l:sewinid = win_getid()
  call win_gotoid(win_getid(winnr('#')))
  let l:prevfile = bufname('%')
  let l:prevcwd = fnamemodify(prevfile, ":~:h")
  let l:prevtailfile = fnamemodify(prevfile, ":t")
  call win_gotoid(l:sewinid)
  execute ":lcd " . l:prevcwd
  call SeList()
  if l:prevtailfile != ''
    call search('^' . l:prevtailfile . '.\?$')
  endif
endfunction

" goes to file
function! SeGofile(mode) abort
  let l:curline = substitute(fnameescape(getline('.')), '\\\*$', "", "")
  let l:firstchar = matchstr(l:curline, "^.")
  let l:lastchar = matchstr(l:curline, ".$")
  let l:sb = s:SeGetBufId()
  if a:mode ==# "edit" && l:firstchar == "." && l:lastchar == ']' && isdirectory(split(l:curline, "\\")[0])
    execute "lcd " . getcwd(winnr()) . "/" . split(l:curline, "\\")[0]
    call SeList()
  elseif a:mode ==# "edit" && l:lastchar == '/' && isdirectory(l:curline)
    execute "lcd " . getcwd(winnr()) . "/" . l:curline
    call SeList()
  elseif l:lastchar == '@'
    echohl Warningmsg
    echom "Warning: TODO symlink link"
    echohl None
  else
    let l:mode_list = ["edit", "editk", "pedit", "split"]
    if index(l:mode_list, a:mode) >= 0
      let l:oldcwd = getcwd()
      let l:oldwindid = win_getid()
      call win_gotoid(win_getid(winnr('#')))
      if win_getid() != l:oldwindid
        if a:mode ==# "edit"
          execute "edit " . l:oldcwd . "/" . l:curline
        elseif a:mode ==# "editk"
          execute "edit " . l:oldcwd . "/" . l:curline
          call win_gotoid(bufwinid(l:sb))
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
