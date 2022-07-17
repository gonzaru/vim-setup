" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" g:  global variables
" b:  local buffer variables
" w:  local window variables
" t:  local tab page variables
" s:  script-local variables
" l:  local function variables
" v:  Vim variables.

" do not read the file if it is already loaded
if get(g:, 'loaded_misc') == 1 || get(g:, 'misc_enabled') == 0 || &cp
  finish
endif
let g:loaded_misc = 1

" see ../autoload/misc.vim

" go to last edit cursor position
function! s:GoLastEditCursorPos()
  let l:lastcursorline = line("'\"")
  if l:lastcursorline >= 1 && l:lastcursorline <= line("$")
    execute "normal! g`\""
  endif
endfunction

" my statusline
function! g:MiscMyStatusLine()
  let l:output = ""
  let l:dirname = fnamemodify(getcwd(), ":~")
  let l:tname = fnamemodify(l:dirname, ":t")
  let l:cchars = ""
  let l:name_len = len(split(l:dirname, "/"))
  let l:i = 0
  for l:d in split(l:dirname, "/")
    if l:i < l:name_len - 1
      if l:d[0] == '.'
        let l:cchars .= l:d[0:1] . "/"
      else
        let l:cchars .= l:d[0] . "/"
      endif
    endif
    let l:i += 1
  endfor
  if l:dirname[0] == "/"
    let l:sname = "/" . l:cchars . l:tname
  else
    let l:sname = l:cchars . l:tname
  endif
  if get(g:, "checker_enabled")
    if &filetype ==# "sh" && (executable("sh") || executable("bash")) && executable("shellcheck")
      let l:output = checker#StatusLine("sh")
    elseif &filetype ==# "python" && executable("python3") && executable("pep8")
      let l:output = checker#StatusLine("python")
    elseif &filetype ==# "go" && executable("go") && executable("gofmt")
      let l:output = checker#StatusLine("go")
    endif
  endif
  if !empty(l:output)
    let l:output = " " . l:output
  endif
  return l:sname . '$' . l:output
endfunction

" my tablabel
function! g:MyTabLabel(arg)
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

" my tabline
function! g:MiscMyTabLine()
  let l:s = ''
  for l:i in range(tabpagenr('$'))
    if l:i + 1 == tabpagenr()
      let l:s .= '%#TabLineSel#'
    else
      let l:s .= '%#TabLine#'
    endif
    let l:s .= '%' . (l:i + 1) . 'T'
    let l:s .= ' %{g:MyTabLabel(' . (l:i + 1) . ')} '
  endfor
  let l:s .= '%#TabLineFill#%T'
  return l:s
endfunction

" mappings
nnoremap <silent> <unique> <script> <Plug>(misc-golasteditcursor) :<C-u>call <SID>GoLastEditCursorPos()<CR>
nnoremap <silent> <unique> <script> <Plug>(misc-mystatusline) :<C-u>call <SID>MiscMyStatusLine()<CR>
nnoremap <silent> <unique> <script> <Plug>(misc-mytabline) :<C-u>call <SID>MiscMyTabLine<CR>
