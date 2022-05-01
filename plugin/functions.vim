" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" g:  global variables
" b:  local buffer variables
" w:  local window variables
" t:  local tab page variables
" s:  script-local variables
" l:  local function variables
" v:  Vim variables.

" do not read the file if is already loaded
if exists('g:loaded_functions') && g:loaded_functions == 1
  finish
endif
let g:loaded_functions = 1

" toggle background
function! BackgroundToggle()
  if &background ==# "dark"
    setlocal background=light
  else
    setlocal background=dark
  endif
  let v:statusmsg = "background=" . &background
endfunction

" tells if buffer is empty
function! BufferIsEmpty()
  return line('$') == 1 && empty(getline(1))
endfunction

" remove all buffers except the current one
function! BufferRemoveAllExceptCurrent(mode)
  let l:curbufid = winbufnr(winnr())
  if a:mode ==# 'delete' || a:mode ==# 'wipe'
    let l:bufinfo = getbufinfo({'buflisted':1})
  elseif a:mode ==# 'wipe!'
    let l:bufinfo = getbufinfo()
  endif
  for l:b in l:bufinfo
    if l:b.bufnr == l:curbufid
      continue
    endif
    if getbufvar(l:b.bufnr, '&buftype') ==# 'terminal' && term_getstatus(b.bufnr) ==# 'running,normal'
      if a:mode ==# "delete"
        execute "bd! " . l:b.bufnr
      elseif a:mode ==# "wipe" || a:mode ==# "wipe!"
        execute "bw! " . l:b.bufnr
      endif
    else
      if a:mode ==# "delete"
        execute "bd " . l:b.bufnr
      elseif a:mode ==# "wipe" || a:mode ==# "wipe!"
        execute "bw " . l:b.bufnr
      endif
    endif
  endfor
endfunction

" comment by language
function! CommentByLanguage()
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
    call EchoErrorMsg("Error: commenting filetype '" . &filetype . "' is not supported")
  endif
endfunction

" cycle between buffers
function! CycleBuffers()
  let l:curbuf = substitute(bufname("%"), $HOME . "/" . $USER . "/", "~/", "")
  let l:bufinfo = getbufinfo({'buflisted':1})
  if len(l:bufinfo) == 1
    call EchoWarningMsg("Warning: already using only one buffer")
    return
  endif
  let l:buflist = []
  for l:buf in l:bufinfo
    let l:bul = split(substitute(l:buf.name, $HOME . "/" . $USER . "/", "~/", ""))
    call extend(l:buflist, l:bul)
  endfor
  topleft new
  call appendbufline('%', 0, l:buflist)
  call deletebufline('%', '$')
  execute "resize " . line('$')
  setlocal filetype=cb
  for l:i in range(1, line('$'))
    if l:curbuf ==# getline(l:i)
      call cursor(l:i, 1)
      break
    endif
  endfor
endfunction

" shows debug information
function! CycleSignsShowDebugInfo(type, mode)
  let l:curbuf = winbufnr(winnr())
  let l:curline = line('.')
  let l:curcycleline = 0
  let l:nextcycleline = 0
  let l:prevcycleline = 0
  let l:signameline = ""
  if index(["sh", "py", "go"], a:type) == -1
    call EchoErrorMsg("Error: debug information for filetype '" . &filetype . "' is not supported")
    return
  endif
  let l:signs = sign_getplaced(l:curbuf)[0].signs
  if empty(l:signs)
    call EchoWarningMsg("Warning: signs not found in the current buffer")
    return
  endif
  for l:sign in l:signs
    let l:cycleline = l:sign.lnum
    if a:mode ==# 'cur'
      let l:curcycleline = l:curline
      let l:signameline = l:sign.name
      break
    elseif a:mode ==# 'next'
      if l:curline < l:cycleline
        let l:nextcycleline = l:cycleline
        let l:signameline = l:sign.name
        break
      endif
    elseif a:mode ==# 'prev'
      if l:curline > l:cycleline
        let l:prevcycleline = l:cycleline
        let l:signameline = l:sign.name
      endif
    endif
  endfor
  if l:curcycleline || l:nextcycleline || l:prevcycleline
    if l:curcycleline
      try
        call sign_jump(l:curcycleline, '', l:curbuf)
      catch
        call EchoWarningMsg("Warning: sign id not found in line " . l:curcycleline)
        return
      endtry
    elseif l:nextcycleline
      try
        call sign_jump(l:nextcycleline, '', l:curbuf)
      catch
        call EchoWarningMsg("Warning: sign id not found in line " . l:nextcycleline)
        return
      endtry
    elseif l:prevcycleline
      try
        call sign_jump(l:prevcycleline, '', l:curbuf)
      catch
        call EchoWarningMsg("Warning: sign id not found in line " . l:prevcycleline)
        return
      endtry
    else
      call EchoErrorMsg("Error: sign jump line not found")
      return
    endif
    if a:type ==# "sh"
      call ShowSHDebugInfo(l:signameline)
    elseif a:type ==# "py"
      call ShowPY3DebugInfo(l:signameline)
    elseif a:type ==# "go"
      call ShowGODebugInfo(l:signameline)
    endif
  endif
endfunction

" toggle diff
function! DiffToggle()
  if &diff
    diffoff
  else
    diffthis
  endif
endfunction

" checks if directory is empty
function! DirIsEmpty(file)
    let l:dirHasFiles = systemlist("[ \"$(ls -A ".fnameescape(a:file).")\" ] && echo 1 || echo 0")
    return !l:dirHasFiles[0]
endfunction

" disable arrow keys
function! DisableArrowKeys()
  silent execute "nnoremap <up> <nop>"
  silent execute "nnoremap <down> <nop>"
  silent execute "nnoremap <left> <nop>"
  silent execute "nnoremap <right> <nop>"
  silent execute "inoremap <up> <nop>"
  silent execute "inoremap <down> <nop>"
  silent execute "inoremap <left> <nop>"
  silent execute "inoremap <right> <nop>"
  silent execute "vnoremap <up> <nop>"
  silent execute "vnoremap <down> <nop>"
  silent execute "vnoremap <left> <nop>"
  silent execute "vnoremap <right> <nop>"
endfunction

" prints error message and saves the message in the message-history
function! EchoErrorMsg(msg)
  if !empty(a:msg)
    echohl ErrorMsg
    echom  a:msg
    echohl None
  endif
endfunction

" prints warning message and saves the message in the message-history
function! EchoWarningMsg(msg)
  if !empty(a:msg)
    echohl WarningMsg
    echom  a:msg
    echohl None
  endif
endfunction

" edit using a top window
function! EditTop(file)
  if filereadable(a:file)
    execute "new " . a:file
    execute "normal! \<C-W>_"
  endif
endfunction

" enable arrow keys
function! EnableArrowKeys()
  silent execute "nnoremap <up> <up>"
  silent execute "nnoremap <down> <down>"
  silent execute "nnoremap <left> <left>"
  silent execute "nnoremap <right> <right>"
  silent execute "inoremap <up> <up>"
  silent execute "inoremap <down> <down>"
  silent execute "inoremap <left> <left>"
  silent execute "inoremap <right> <right>"
  silent execute "vnoremap <up> <up>"
  silent execute "vnoremap <down> <down>"
  silent execute "vnoremap <left> <left>"
  silent execute "vnoremap <right> <right>"
endfunction

" checks if file is empty
function! FileIsEmpty(file)
  return filereadable(a:file) && !getfsize(a:file)
endfunction

" toggle fold column
function! FoldColumnToggle()
  if &foldcolumn
    setlocal foldcolumn=0
  else
    setlocal foldcolumn=1
  endif
  let v:statusmsg = "foldcolumn=" . &foldcolumn
endfunction

" toggle fold
function! FoldToggle()
  if &foldlevel
    execute "normal zM"
  else
    execute "normal zR"
  endif
endfunction

" format language
function! FormatLanguage()
  let l:curfile = expand('%:p')
  if &filetype ==# "python"
    " -l 79 to keep pep8 in all projects
    let l:out = systemlist("black -S -l 79 " . l:curfile)
    checktime
    if empty(l:out) || index(l:out, "1 file left unchanged.") >= 0
      echo "Info: file was not modified (black)"
    endif
  elseif &filetype ==# "go"
    let l:out = systemlist("go fmt " . l:curfile)
    checktime
    if empty(l:out)
      echo "Info: file was not modified (go fmt)"
    endif
  else
    call EchoErrorMsg("Error: formatting filetype '" . &filetype . "' is not supported")
  endif
endfunction

" go to N buffer position
function! GoBufferPos(bnum)
  let l:match = 0
  let l:i = 1
  for l:b in getbufinfo({'buflisted':1})
    if a:bnum == l:i
      execute "b " . l:b.bufnr
      let l:match = 1
      break
    endif
    let l:i += 1
  endfor
  if !l:match
    call EchoErrorMsg("Error: buffer in position " . a:bnum . " does not exist")
  endif
endfunction

" go to last edit cursor position
function! GoLastEditCursorPos()
  let l:lastcursorline = line("'\"")
  if l:lastcursorline >= 1 && l:lastcursorline <= line("$")
    execute "normal! g`\""
  endif
endfunction

" toggle gui menu bar
function! GuiMenuBarToggle()
  if !has('gui_running')
    call EchoWarningMsg("Warning: only use this function with gui")
    return
  endif
  if &guioptions =~# "m"
    setlocal guioptions-=m
    setlocal guioptions+=M
  else
    if !exists('g:did_install_default_menus')
      source $VIMRUNTIME/menu.vim
    endif
    setlocal guioptions-=M
    setlocal guioptions+=m
  endif
  let v:statusmsg = "guioptions=" . &guioptions
endfunction

" menu spell
function! MenuLanguageSpell()
  let l:langchoice = inputlist(['Select:',
                    \'1.  English',
                    \'2.  Spanish',
                    \'3.  Catalan',
                    \'4.  Russian',
                    \'5.  Disable spell'])
  if !empty(l:langchoice)
    if l:langchoice < 1 || l:langchoice > 5
      call EchoErrorMsg("Error: wrong option " . l:langchoice)
      return
    endif
    if l:langchoice == 5
      setlocal nospell
    else
      setlocal spell
      if l:langchoice == 1
        setlocal spelllang=en
        " setlocal spellfile="$HOME/.vim/spell/language.utf-8.spl"
      elseif l:langchoice == 2
        setlocal spelllang=es
        setlocal spellfile="$HOME/.vim/spell/es.".&encoding.".spl"
      elseif l:langchoice == 3
        setlocal spelllang=ca
        setlocal spellfile="$HOME/.vim/spell/ca.".&encoding.".spl"
      elseif l:langchoice == 4
        setlocal spelllang=ru
        setlocal spellfile="$HOME/.vim/spell/ru.".&encoding.".spl"
      endif
    endif
  endif
endfunction

" menu misc
function! MenuMisc()
  let l:choice = inputlist(['Select:',
                      \'1.  Enable arrow keys',
                      \'2.  Disable arrow keys',
                      \'3.  Toggle gui menu bar'])
  if !empty(l:choice)
    if l:choice < 1 || l:choice > 3
      call EchoErrorMsg("Error: wrong option " . l:choice)
      return
    endif
    if l:choice == 1
      call EnableArrowKeys()
    elseif l:choice == 2
      call DisableArrowKeys()
    elseif l:choice == 3
      call GuiMenuBarToggle()
    endif
  endif
endfunction

" my tablabel
function! MyTabLabel(arg)
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
function! MyTabLine()
  let l:s = ''
  for l:i in range(tabpagenr('$'))
    if l:i + 1 == tabpagenr()
      let l:s .= '%#TabLineSel#'
    else
      let l:s .= '%#TabLine#'
    endif
    let l:s .= '%' . (l:i + 1) . 'T'
    let l:s .= ' %{MyTabLabel(' . (l:i + 1) . ')} '
  endfor
  let l:s .= '%#TabLineFill#%T'
  return l:s
endfunction

" my statusline
function! MyStatusLine()
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
  if &filetype ==# "sh" && (executable("sh") || executable("bash")) && executable("shellcheck")
    let l:output = SHStatusLine()
  elseif &filetype ==# "python" && executable("python3") && executable("pep8")
    let l:output = PY3StatusLine()
  elseif &filetype ==# "go" && executable("go") && executable("gofmt")
    let l:output = GOStatusLine()
  endif
  if !empty(l:output)
    let l:output = " " . l:output
  endif
  return l:sname . '$' . l:output
endfunction

" remove signs
function! RemoveSignsName(buf, name)
  let l:signs = sign_getplaced(a:buf)[0].signs
  if empty(l:signs)
    return
  endif
  for l:sign in l:signs
    if l:sign.name ==# a:name
      call sign_unplace('', {'buffer' : a:buf, 'id' : l:sign.id})
    endif
  endfor
endfunction

" run
function! Run()
  let l:curfile = expand('%:p')
  if &filetype ==# "python"
    echo system("python3 " . l:curfile)
  elseif &filetype ==# "go"
    echo system("go run " . l:curfile)
  else
    call EchoErrorMsg("Error: running filetype '" . &filetype . "' is not supported")
  endif
endfunction

" run using a window
function! RunInWindow()
  let l:bufname = "runoutput"
  let l:curfile = expand('%:p')
  let l:curwinid = win_getid()
  let l:prevwinid = bufwinid(l:bufname)
  if l:curwinid == l:prevwinid
    call EchoWarningMsg("Warning: already using the same window " . l:bufname)
    return
  endif
  if &filetype ==# "python"
    let l:out = systemlist("python3 " . l:curfile)
    if empty(l:out)
      call EchoWarningMsg("Warning: empty output")
      return
    endif
  elseif &filetype ==# "go"
    let l:out = systemlist("go run " . l:curfile)
    if empty(l:out)
      call EchoWarningMsg("Warning: empty output")
      return
    endif
  else
    call EchoErrorMsg("Error: formatting filetype '" . &filetype . "' is not supported")
    return
  endif
  if l:prevwinid > 0
    call win_gotoid(l:prevwinid)
  else
    if !empty(bufname(l:bufname))
      silent execute "bw! " . l:bufname
    endif
    below new
    setlocal winfixheight
    setlocal winfixwidth
    setlocal buftype=nowrite
    setlocal noswapfile
    setlocal buflisted
    execute "file " . l:bufname
  endif
  call appendbufline('%', 0, l:out)
  call deletebufline('%', '$')
  call cursor(1, 1)
  execute "resize " . len(l:out)
  call win_gotoid(l:curwinid)
endfunction

" set foldlevel
function! SetMaxFoldLevel()
  let l:mfl = max(map(range(1, line('$')), 'foldlevel(v:val)'))
  if l:mfl > 0
    execute "setlocal foldlevel=" . l:mfl
  endif
  let v:statusmsg = "foldlevel=" . l:mfl
endfunction

" sh
function! SH()
  if !has('gui_running')
    call EchoWarningMsg("Warning: only use this function with gui")
    return
  endif
  let l:guioptions_orig=&guioptions
  setlocal guioptions+=!
  sh
  execute "setlocal guioptions=" . l:guioptions_orig
endfunction

" toggle sign column
function! SignColumnToggle()
  if &signcolumn ==# 'yes'
    setlocal signcolumn=no
  else
    setlocal signcolumn=yes
  endif
  let v:statusmsg = "signcolumn=" . &signcolumn
endfunction

" scratch buffer
function! ScratchBuffer()
  let l:curbufn = winbufnr(winnr())
  let l:scnum = 0
  let l:match = 0
  for l:b in getbufinfo()
    " :help special-buffers
    if empty(b.name)
    \ && getbufvar(l:b.bufnr, '&buftype') ==# 'nofile'
    \ && getbufvar(l:b.bufnr, '&bufhidden') ==# 'hide'
    \ && getbufvar(l:b.bufnr, '&swapfile') == 0
      let l:scnum = l:b.bufnr
      let l:match = 1
      break
    endif
  endfor
  if l:match == 1
    if l:curbufn == l:scnum
      " return to previous buffer if whe are in the scratch
      if !empty(getreg('#'))
        execute "b #"
      endif
    else
      execute "b " . l:scnum
    endif
  else
    enew
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
  endif
endfunction

" toggle sytnax
function! SyntaxToggle()
  if exists("g:syntax_on")
    syntax off
    let v:statusmsg = "syntax off, background=" . &background
  else
    syntax on
    if exists("g:mytheme") && g:mytheme ==# "plan9" && &background != "light"
      setlocal background=light
    endif
    let v:statusmsg = "syntax on, background=" . &background
  endif
endfunction

" uncomment by language
function! UncommentByLanguage()
  let l:curline = line('.')
  let l:curcol = col('.')
  if index(["c", "cpp", "java", "sql"], &filetype) >= 0
    execute "normal! ^"
    let l:trimline = trim(getline('.'), 0)
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
    let l:trimline = trim(getline('.'), 1)
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
    let l:trimline = trim(getline('.'), 1)
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
    let l:trimline = trim(getline('.'), 1)
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
    let l:trimline = trim(getline('.'), 0)
    if l:trimline[0:4] != "<!-- " || l:trimline[-4:-1] != " -->"
      call cursor(l:curline, l:curcol)
      return
    endif
    let l:num = 5
    execute "normal! ".l:num."x$xxxx"
    call cursor(l:curline, l:curcol - l:num)
  else
    call EchoErrorMsg("Error: uncommenting filetype '" . &filetype . "' is not supported")
  endif
endfunction

" user tmp
function! UserTempDir()
  let l:tmp = "/tmp"
  if !empty($TMPDIR)
    if $TMPDIR == "/"
      let l:tmp = $TMPDIR
    else
      let l:tmp = substitute($TMPDIR, "/$", "", "")
    endif
  endif
  return l:tmp
endfunction
