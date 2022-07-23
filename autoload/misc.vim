vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# g:  global variables
# b:  local buffer variables
# w:  local window variables
# t:  local tab page variables
# s:  script-local variables
# l:  local function variables
# v:  Vim variables.

# do not read the file if it is already loaded
if exists('g:autoloaded_misc') || !get(g:, 'misc_enabled') || &cp
  finish
endif
g:autoloaded_misc = 1

# toggle background
export def BackgroundToggle()
  execute "set background=" .. (&background == "dark" ? "light" : "dark")
  v:statusmsg = "background=" .. &background
enddef

# toggle diff
export def DiffToggle()
  if &diff
    diffoff
  else
    diffthis
  endif
  v:statusmsg = "diff=" .. &diff
enddef

# generates documentation
export def Doc(atype: string): void
  var curline: string
  var cword: string
  var pfile: string
  var word: string
  if index(["python", "go"], &filetype) == -1
    utils#EchoErrorMsg("Error: running filetype '" .. &filetype .. "' is not supported")
    return
  endif
  if &filetype != atype
    utils#EchoErrorMsg("Error: running type '" .. atype .. "' on filetype '" .. &filetype .. "' is not supported")
    return
  endif
  cword = expand("<cWORD>")
  if empty(cword) || index(["(", ")", "()"], cword) >= 0
    utils#EchoErrorMsg("Error: word is empty or invalid")
    return
  endif
  word = shellescape(trim(split(cword, "(")[0], '"'))
  if empty(word)
    utils#EchoErrorMsg("Error: word is empty")
    return
  endif
  pfile = "(" .. atype .. "doc)" .. word
  if bufexists(pfile)
    silent execute "bw! " .. pfile
  endif
  new
  silent execute "file " .. pfile
  setlocal buftype=nowrite
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  if atype == "python"
    appendbufline('%', 0, systemlist("python3 -m pydoc " .. word))
  elseif atype == "go"
    appendbufline('%', 0, systemlist("go doc " .. word))
  endif
  deletebufline('%', '$')
  cursor(1, 1)
  curline = getline(".")
  if (atype == "python" && curline =~ "No Python documentation found for ")
  || (atype == "go" && (curline =~ "doc: no symbol ") || curline =~ "doc: no buildable Go source files in ")
    bw
    v:errmsg = "Warning: no " .. atype .. " documentation found for " .. word
    utils#EchoWarningMsg("Warning: " .. v:errmsg)
  else
    v:errmsg = ""
  endif
enddef

# edit using a top window
export def EditTop(file: string)
  if filereadable(file)
    execute "new " .. file
    wincmd _
  endif
enddef

# toggle fold column
export def FoldColumnToggle()
  execute "setlocal foldcolumn=" .. (&l:foldcolumn ? 0 : 1)
  v:statusmsg = "foldcolumn=" .. &l:foldcolumn
enddef

# toggle fold
export def FoldToggle()
  if &foldlevel
    execute "normal! zM"
  else
    execute "normal! zR"
  endif
  v:statusmsg = "foldlevel=" .. &foldlevel
enddef

# go to N buffer position
export def GoBufferPos(bnum: number)
  var match = 0
  var pos = 1
  for b in getbufinfo({'buflisted': 1})
    if bnum == pos
      execute "b " .. b.bufnr
      match = 1
      break
    endif
    ++pos
  endfor
  if !match
    utils#EchoErrorMsg("Error: buffer in position " .. bnum .. " does not exist")
  endif
enddef

# toggle gui menu bar
export def GuiMenuBarToggle(): void
  if !has('gui_running')
    utils#EchoWarningMsg("Warning: only use this function with gui")
    return
  endif
  if &l:guioptions =~ "m"
    setlocal guioptions-=m
    setlocal guioptions+=M
  elseif !exists('g:did_install_default_menus')
    source $VIMRUNTIME/menu.vim
    setlocal guioptions-=M
    setlocal guioptions+=m
  endif
  v:statusmsg = "guioptions=" .. &l:guioptions
enddef

# menu spell
export def MenuLanguageSpell(): void
  var langchoice = inputlist(
    [
      'Select:',
      '1.  English',
      '2.  Spanish',
      '3.  Catalan',
      '4.  Russian',
      '5.  Disable spell'
    ]
  )
  if empty(langchoice)
    return
  endif
  if langchoice < 1 || langchoice > 5
    utils#EchoErrorMsg("Error: wrong option " .. langchoice)
    return
  endif
  if langchoice == 5
    setlocal nospell
  else
    setlocal spell
    if langchoice == 1
      setlocal spelllang=en
      # setlocal spellfile=~/.vim/spell/en.utf-8.spl.add
    elseif langchoice == 2
      setlocal spelllang=es
      # setlocal spellfile=~/.vim/spell/es.utf-8.spl.add
    elseif langchoice == 3
      setlocal spelllang=ca
      # setlocal spellfile=~/.vim/spell/ca.utf-8.spl.add
    elseif langchoice == 4
      setlocal spelllang=ru
      # setlocal spellfile=~/.vim/spell/ru.utf-8.spl.add
    endif
  endif
enddef

# menu misc
export def MenuMisc(): void
  var choice = inputlist(
    [
      'Select:',
      '1.  Enable arrow keys',
      '2.  Disable arrow keys',
      '3.  Toggle gui menu bar'
    ]
  )
  if empty(choice)
    return
  endif
  if choice < 1 || choice > 3
    utils#EchoErrorMsg("Error: wrong option " .. choice)
    return
  endif
  if choice == 1
    if !get(g:, 'arrowkeys_enabled')
      utils#EchoErrorMsg("plugin 'arrowkeys' is not enabled")
    else
      arrowkeys#Enable()
    endif
  elseif choice == 2
    if !get(g:, 'arrowkeys_enabled')
      utils#EchoErrorMsg("plugin 'arrowkeys' is not enabled")
    else
      arrowkeys#Disable()
    endif
  elseif choice == 3
    GuiMenuBarToggle()
  endif
enddef

# set maximum foldlevel
export def SetMaxFoldLevel()
  var mfl = max(map(range(1, line('$')), 'foldlevel(v:val)'))
  if mfl > 0
    execute "setlocal foldlevel=" .. mfl
  endif
  v:statusmsg = "foldlevel=" .. &l:foldlevel
enddef

# sh
export def SH(): void
  var guioptions_orig: string
  if !has('gui_running')
    utils#EchoWarningMsg("Warning: only use this function with gui")
    return
  endif
  guioptions_orig = &l:guioptions
  setlocal guioptions+=!
  sh
  execute "setlocal guioptions=" .. guioptions_orig
enddef

# toggle sign column
export def SignColumnToggle()
  execute "setlocal signcolumn=" .. (&l:signcolumn == "yes" ? "no" : "yes")
  v:statusmsg = "signcolumn=" .. &l:signcolumn
enddef

# toggle sytnax
export def SyntaxToggle()
  if !empty(&l:syntax)
    execute "setlocal syntax=" .. (&l:syntax == "on" ? "OFF" : "ON")
    v:statusmsg = "setlocal syntax=" .. &l:syntax
  else
    # global syntax
    # execute "syntax " .. (exists("g:syntax_on") ? "off" : "on")
    # v:statusmsg = "syntax " .. (exists("g:syntax_on") ? "on" : "off")
    # utils#EchoWarningMsg("Warning: filetype '" .. &filetype .. "' does not have ftplugin syntax")
    v:statusmsg = "Warning: filetype '" .. &filetype .. "' does not have ftplugin syntax"
  endif
enddef
