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
if exists('g:autoloaded_misc') || !get(g:, 'misc_enabled') || &cp
  finish
endif
let g:autoloaded_misc = 1

" toggle background
function! misc#BackgroundToggle()
  let l:new_background = &background ==# "dark" ? "light" : "dark"
  execute "setlocal background=" . l:new_background
  let v:statusmsg = "background=" . &background
endfunction

" tells if buffer is empty
function! misc#BufferIsEmpty()
  return line('$') == 1 && empty(getline(1))
endfunction

" toggle diff
function! misc#DiffToggle()
  if &diff
    diffoff
  else
    diffthis
  endif
  let v:statusmsg = "diff=" . &diff
endfunction

" checks if directory is empty
function! misc#DirIsEmpty(path)
    if getftype(a:path) != "dir")
      call misc#EchoErrorMsg("Error: " . a:path . " is not a directory")
      return
    endif
    let l:nohidden = globpath(a:path, "*", 0, 1)
    let l:hidden = globpath(a:path, ".*", 0, 1)[2:]
    return !len(extend(l:nohidden, l:hidden))
endfunction

" generates documentation
function! misc#Doc(type)
  if index(["python", "go"], &filetype) == -1
    call misc#EchoErrorMsg("Error: running filetype '" . &filetype . "' is not supported")
    return
  endif
  if &filetype !=# a:type
    call misc#EchoErrorMsg("Error: running type '" . a:type . "' on filetype '" . &filetype . "' is not supported")
    return
  endif
  let l:cword = expand("<cWORD>")
  if empty(l:cword) || index(["(", ")", "()"], l:cword) >= 0
    call misc#EchoErrorMsg("Error: word is empty or invalid")
    return
  endif
  let l:word = shellescape(trim(split(l:cword, "(")[0], '"'))
  if empty(l:word)
    call misc#EchoErrorMsg("Error: word is empty")
    return
  endif
  let l:pfile = "(".a:type."doc)". l:word
  if bufexists(l:pfile)
    silent execute "bw! " . l:pfile
  endif
  new
  silent execute "file " . l:pfile
  setlocal buftype=nowrite
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  if a:type ==# "python"
    call appendbufline('%', 0, systemlist("python3 -m pydoc " . l:word))
  elseif a:type ==# "go"
    call appendbufline('%', 0, systemlist("go doc " . l:word))
  endif
  call deletebufline('%', '$')
  call cursor(1, 1)
  let l:curline = getline(".")
  if (a:type ==# "python" && l:curline =~# "No Python documentation found for ")
  \|| (a:type ==# "go" && (l:curline =~# "doc: no symbol ") || l:curline =~# "doc: no buildable Go source files in ")
    bw
    let v:errmsg = "Warning: no " . a:type . " documentation found for " . l:word
    call misc#EchoWarningMsg("Warning: " . v:errmsg)
  else
    let v:errmsg = ""
  endif
endfunction

" prints error message and saves the message in the message-history
function! misc#EchoErrorMsg(msg)
  if !empty(a:msg)
    echohl ErrorMsg
    echom  a:msg
    echohl None
  endif
endfunction

" prints warning message and saves the message in the message-history
function! misc#EchoWarningMsg(msg)
  if !empty(a:msg)
    echohl WarningMsg
    echom  a:msg
    echohl None
  endif
endfunction

" edit using a top window
function! misc#EditTop(file)
  if filereadable(a:file)
    new a:file
    wincmd _
  endif
endfunction

" checks if file is empty
function! misc#FileIsEmpty(file)
  if getftype(a:file) != "file")
    call misc#EchoErrorMsg("Error: " . a:file . " is not a normal file")
    return
  endif
  if !filereadable(a:file)
    call misc#EchoErrorMsg("Error: " . a:file . " is not readable")
    return
  endif
  return !getfsize(a:file)
endfunction

" toggle fold column
function! misc#FoldColumnToggle()
  let l:new_foldcolumn = &foldcolumn ? 0 : 1
  execute "setlocal foldcolumn=" . l:new_foldcolumn
  let v:statusmsg = "foldcolumn=" . &foldcolumn
endfunction

" toggle fold
function! misc#FoldToggle()
  if &foldlevel
    execute "normal zM"
  else
    execute "normal zR"
  endif
  let v:statusmsg = "foldlevel=" . &foldlevel
endfunction

" format language
function! misc#FormatLanguage()
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
    call misc#EchoErrorMsg("Error: formatting filetype '" . &filetype . "' is not supported")
  endif
endfunction

" go to N buffer position
function! misc#GoBufferPos(bnum)
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
    call misc#EchoErrorMsg("Error: buffer in position " . a:bnum . " does not exist")
  endif
endfunction

" toggle gui menu bar
function! misc#GuiMenuBarToggle()
  if !has('gui_running')
    call misc#EchoWarningMsg("Warning: only use this function with gui")
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
function! misc#MenuLanguageSpell()
  let l:langchoice = inputlist(['Select:',
                    \'1.  English',
                    \'2.  Spanish',
                    \'3.  Catalan',
                    \'4.  Russian',
                    \'5.  Disable spell'])
  if !empty(l:langchoice)
    if l:langchoice < 1 || l:langchoice > 5
      call misc#EchoErrorMsg("Error: wrong option " . l:langchoice)
      return
    endif
    if l:langchoice == 5
      setlocal nospell
    else
      setlocal spell
      if l:langchoice == 1
        setlocal spelllang=en
        " setlocal spellfile=~/.vim/spell/en.utf-8.spl.add
      elseif l:langchoice == 2
        setlocal spelllang=es
        " setlocal spellfile=~/.vim/spell/es.utf-8.spl.add
      elseif l:langchoice == 3
        setlocal spelllang=ca
        " setlocal spellfile=~/.vim/spell/ca.utf-8.spl.add
      elseif l:langchoice == 4
        setlocal spelllang=ru
        " setlocal spellfile=~/.vim/spell/ru.utf-8.spl.add
      endif
    endif
  endif
endfunction

" menu misc
function! misc#MenuMisc()
  let l:choice = inputlist(['Select:',
                      \'1.  Enable arrow keys',
                      \'2.  Disable arrow keys',
                      \'3.  Toggle gui menu bar'])
  if !empty(l:choice)
    if l:choice < 1 || l:choice > 3
      call misc#EchoErrorMsg("Error: wrong option " . l:choice)
      return
    endif
    if l:choice == 1
      execute ":normal! \<Plug>(arrowkeys-enable)"
    elseif l:choice == 2
      execute ":normal! \<Plug>(arrowkeys-disable)"
    elseif l:choice == 3
      call misc#GuiMenuBarToggle()
    endif
  endif
endfunction

" set foldlevel
function! misc#SetMaxFoldLevel()
  let l:mfl = max(map(range(1, line('$')), 'foldlevel(v:val)'))
  if l:mfl > 0
    execute "setlocal foldlevel=" . l:mfl
  endif
  let v:statusmsg = "foldlevel=" . l:mfl
endfunction

" sh
function! misc#SH()
  if !has('gui_running')
    call misc#EchoWarningMsg("Warning: only use this function with gui")
    return
  endif
  let l:guioptions_orig=&guioptions
  setlocal guioptions+=!
  sh
  execute "setlocal guioptions=" . l:guioptions_orig
endfunction

" toggle sign column
function! misc#SignColumnToggle()
  let l:new_signcolumn = &signcolumn ==# "yes" ? "no" : "yes"
  execute "setlocal signcolumn=" . l:new_signcolumn
  let v:statusmsg = "signcolumn=" . &signcolumn
endfunction

" detects if the shell is sh or bash using shebang
function! misc#SHShellType()
  if &filetype !=# "sh"
    call misc#EchoErrorMsg("Error: filetype '" . &filetype . "' is not supported")
    return
  endif
  return getline(1) =~# "bash$" ? "bash" : "sh"
endfunction

" toggle sytnax
function! misc#SyntaxToggle()
  let l:new_syntax = exists("g:syntax_on") ? "off" : "on"
  execute "syntax " . l:new_syntax
  let v:statusmsg = "syntax " . l:new_syntax . ", background=" . &background
endfunction
