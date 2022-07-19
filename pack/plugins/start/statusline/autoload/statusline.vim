" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists('g:autoloaded_statusline') || !get(g:, 'statusline_enabled') || &cp
  finish
endif
let g:autoloaded_statusline = 1

" my statusline
function! statusline#MyStatusLine()
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
  if get(g:, "checker_enabled") && get(g:, "autoloaded_checker")
    if &filetype ==# "sh" && (executable("sh") || executable("bash")) && executable("shellcheck")
      let l:output = statusline#Checker("sh")
    elseif &filetype ==# "python" && executable("python3") && executable("pep8")
      let l:output = statusline#Checker("python")
    elseif &filetype ==# "go" && executable("go") && executable("gofmt")
      let l:output = statusline#Checker("go")
    endif
  endif
  if !empty(l:output)
    let l:output = " " . l:output
  endif
  return l:sname . '$' . l:output
endfunction

" statusline checker plugin output
function! statusline#Checker(type) abort
  let l:allowed_types = ["sh", "python", "go"]
  if index(l:allowed_types, a:type) == -1
    return ""
  endif
  if a:type ==# "sh"
    if get(g:, "checker_sh_error")
      let l:output = "[SH=".g:checker_sh_error."]{SC}"
    elseif get(g:, "checker_sc_error")
      let l:output = "[SH][SC=".g:checker_sc_error."]"
    else
      let l:output = "[SH][SC]"
    endif
  elseif a:type ==# "python"
    if get(g:, "checker_py_error")
      let l:output = "[PY=".g:checker_py_error."]{P8}"
    elseif get(g:, "checker_pep8_error")
      let l:output = "[PY][P8=".g:checker_pep8_error."]"
    else
      let l:output = "[PY][P8]"
    endif
  elseif a:type ==# "go"
    if get(g:, "checker_go_error")
      let l:output = "[GO=".g:checker_go_error."]{GV}"
    elseif get(g:, "checker_gv_error")
      let l:output = "[GO][GV=".g:checker_gv_error."]"
    else
      let l:output = "[GO][GV]"
    endif
  endif
  return l:output
endfunction
