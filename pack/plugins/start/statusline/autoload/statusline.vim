" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists('g:autoloaded_statusline') || !get(g:, 'statusline_enabled') || &cp
  finish
endif
let g:autoloaded_statusline = 1

" global variables
let g:statusline_showgitbranch = get(g:, 'statusline_showgitbranch', 1)

" script local variables
let s:statusline_full = ''

" draw statusline
function! statusline#Draw()
  return get(s:, 'statusline_full', '')
endfunction

" show git branch
function! statusline#GitBranch()
  let l:branch = ""
  let l:filepath = resolve(expand('%:p'))
  " file or directory does not exist
  if !empty(l:filepath) && empty(getftype(l:filepath))
    return ''
  endif
  " empty file or directory
  if empty(l:filepath) && empty(&filetype)
    let l:filepath = resolve(getcwd())
  endif
  let l:ftype = getftype(l:filepath)
  let l:filehead = l:filepath
  if l:ftype ==# "file"
    let l:filehead = fnamemodify(l:filepath, ':h')
  endif
  if getftype(l:filehead) !=# "dir"
    return 'DEBUG_UNSUPPORTED_FILE: ' . l:filehead
  endif
  let l:gitroot = l:filehead
  " s:GitValidRepo(l:gitroot)
  let l:ret = systemlist("cd " . l:gitroot . " && git rev-parse --abbrev-ref HEAD")
  if !v:shell_error && !empty(l:ret)
    let l:branch = l:ret[0]
  endif
  return l:branch
endfunction

" checks if it is a valid git repo
function! s:GitValidRepo(dir)
  call system("cd " . a:dir . " && git -C . rev-parse 2>/dev/null")
  return v:shell_error == 0 ? 1 : 0
endfunction

" my statusline
function! statusline#MyStatusLine(file)
  let l:gitbranch = ""
  let l:filehead = fnamemodify(a:file, ":h")
  let l:cwddirname = fnamemodify(getcwd(), ":~")
  let l:dirname = fnamemodify(!empty(l:filehead) ? l:filehead : l:cwddirname, ":~")
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
  if get(g:, 'statusline_showgitbranch')
    let l:gitbranch = statusline#GitBranch()
    if !empty(l:gitbranch)
      let l:gitbranch = "[" .l:gitbranch. "] "
    endif
  endif
  let s:statusline_full = l:gitbranch . l:cwddirname . "$ " . l:sname . '%'
  return s:statusline_full
endfunction
