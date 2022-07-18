" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if get(g:, 'autoloaded_commentarium') == 1 || !get(g:, 'commentarium_enabled') || &cp
  finish
endif
let g:autoloaded_commentarium = 1

" prints error message and saves the message in the message-history
function! s:EchoErrorMsg(msg)
  if !empty(a:msg)
    echohl ErrorMsg
    echom  a:msg
    echohl None
  endif
endfunction

" comment by language
function! commentarium#DoComment()
  let l:curline = line('.')
  let l:curcol = col('.')
  if index(["c", "cpp", "java", "sql"], &filetype) >= 0
    execute "normal! I/*\<SPACE>\<ESC>A\<SPACE>*/\<ESC>"
    call cursor(l:curline, l:curcol + 3)
  elseif index(["go", "php", "javascript"], &filetype) >= 0
    execute "normal! I//\<SPACE>"
    call cursor(l:curline, l:curcol + 3)
  elseif &filetype ==# "vim"
    execute "normal! I\"\<SPACE>\<ESC>"
    call cursor(l:curline, l:curcol + 2)
  elseif index(["sh", "perl", "python"], &filetype) >= 0
    execute "normal! I#\<SPACE>\<ESC>"
    call cursor(l:curline, l:curcol + 2)
  elseif index(["html", "xml"], &filetype) >= 0
    execute "normal! I\<!--\<SPACE>\<ESC>A\<SPACE>-->"
    call cursor(l:curline, l:curcol + 5)
  else
    call s:EchoErrorMsg("Error: commenting filetype '" . &filetype . "' is not supported")
  endif
endfunction

" uncomment by language
function! commentarium#UndoComment()
  let l:curline = line('.')
  let l:curcol = col('.')
  if index(["c", "cpp", "java", "sql"], &filetype) >= 0
    execute "normal! ^"
    let l:trimline = trim(getline('.'), " ", 0)
    if l:trimline[0:1] != "/*" || l:trimline[-2:-1] != "*/"
      call cursor(l:curline, l:curcol)
      return
    endif
    let l:num = 2
    if l:trimline[0:2] == "/* " && l:trimline[-3:-1] == " */"
      let l:num = 3
    endif
    execute "normal! ".l:num."x$".(l:num - 1)."h".l:num."x"
    call cursor(l:curline, l:curcol - l:num)
  elseif index(["go", "php", "javascript"], &filetype) >= 0
    execute "normal! ^"
    let l:trimline = trim(getline('.'), " ", 1)
    if l:trimline[0:1] != "//"
      call cursor(l:curline, l:curcol)
      return
    endif
    let l:num = 2
    if l:trimline[0:2] == "// " && l:trimline[3] != " "
      let l:num = 3
    endif
    execute "normal! ".l:num."x"
    call cursor(l:curline, l:curcol - l:num)
  elseif &filetype ==# "vim"
    execute "normal! ^"
    let l:trimline = trim(getline('.'), " ", 1)
    if l:trimline[0] != '"'
      call cursor(l:curline, l:curcol)
      return
    endif
    let l:num = 1
    if l:trimline[0:1] == '" ' || l:trimline[0:2] == '"  '
      let l:num = 2
    endif
    execute "normal! ".l:num."x"
    call cursor(l:curline, l:curcol - l:num)
  elseif index(["sh", "perl", "python"], &filetype) >= 0
    execute "normal! ^"
    let l:trimline = trim(getline('.'), " ", 1)
    if l:trimline[0] != "#"
      call cursor(l:curline, l:curcol)
      return
    endif
    let l:num = 1
    if l:trimline[0:1] == "# " || l:trimline[0:2] == "#  "
      let l:num = 2
    endif
    execute "normal! ".l:num."x"
    call cursor(l:curline, l:curcol - l:num)
  elseif index(["html", "xml"], &filetype) >= 0
    execute "normal! ^"
    let l:trimline = trim(getline('.'), " ", 0)
    if l:trimline[0:4] != "<!-- " || l:trimline[-4:-1] != " -->"
      call cursor(l:curline, l:curcol)
      return
    endif
    let l:num = 5
    execute "normal! ".l:num."x$xxxx"
    call cursor(l:curline, l:curcol - l:num)
  else
    call s:EchoErrorMsg("Error: uncommenting filetype '" . &filetype . "' is not supported")
  endif
endfunction
