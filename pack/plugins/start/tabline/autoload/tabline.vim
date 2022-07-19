" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists('g:autoloaded_tabline') || !get(g:, 'tabline_enabled') || &cp
  finish
endif
let g:autoloaded_tabline = 1

" my tabline
function! tabline#MyTabLine()
  let l:s = ''
  for l:i in range(tabpagenr('$'))
    if l:i + 1 == tabpagenr()
      let l:s .= '%#TabLineSel#'
    else
      let l:s .= '%#TabLine#'
    endif
    let l:s .= '%' . (l:i + 1) . 'T'
    let l:s .= ' %{tabline#MyTabLabel(' . (l:i + 1) . ')} '
  endfor
  let l:s .= '%#TabLineFill#%T'
  return l:s
endfunction

" my tablabel
function! tabline#MyTabLabel(arg)
  let l:buflist = tabpagebuflist(a:arg)
  let l:winnr = tabpagewinnr(a:arg)
  let l:name = fnamemodify(bufname(buflist[l:winnr - 1]), ":~")
  let l:tname = fnamemodify(l:name, ":t")
  let l:cname = ''
  let l:cchars = ''
  " exception [No Name]
  if empty(l:name)
    let l:cchars = "[No Name]"
    if getbufvar(l:buflist[l:winnr -1], "&modified")
      if len(l:buflist) > 1
        let l:cname = len(l:buflist) . "+" . " " . l:cchars
      else
        let l:cname = "+" . " " . l:cchars
      endif
    else
      if len(l:buflist) > 1
        let l:cname = len(l:buflist) . " " . l:cchars
      else
        let l:cname = l:cchars
      endif
    endif
    return l:cname
  endif
  let l:name_len = len(split(l:name, "/"))
  let l:i = 0
  for l:n in split(l:name, "/")
    if l:i < l:name_len - 1
      if l:n[0] == '.'
        let l:cchars .= l:n[0:1] . "/"
      else
        let l:cchars .= l:n[0] . "/"
      endif
    endif
    let l:i += 1
  endfor
  if getbufvar(l:buflist[l:winnr -1], "&modified")
    if len(l:buflist) > 1
      if l:name[0] == "/"
        let l:cname = len(l:buflist) . "+" . " " . "/" . l:cchars . l:tname
      else
        let l:cname = len(l:buflist) . "+" . " " . l:cchars . l:tname
      endif
    else
      if l:name[0] == "/"
        let l:cname = "+" . " " . "/" . l:cchars . l:tname
      else
        let l:cname = "+" . " " . l:cchars . l:tname
      endif
    endif
  else
    if len(l:buflist) > 1
      if l:name[0] == "/"
        let l:cname = len(l:buflist) . " " . "/" . l:cchars . l:tname
      else
        let l:cname = len(l:buflist) . " " . l:cchars . l:tname
      endif
    else
      if l:name[0] == "/"
        let l:cname = "/" . l:cchars . l:tname
      else
        let l:cname = l:cchars . l:tname
      endif
    endif
  endif
  return l:cname
endfunction
