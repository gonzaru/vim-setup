vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# g: global variables
# b: local buffer variables
# w: local window variables
# t: local tab page variables
# s: script-local variables
# l: local function variables
# v: Vim variables.

# do not read the file if it is already loaded
if get(g:, 'autoloaded_misc') || !get(g:, 'misc_enabled')
  finish
endif
g:autoloaded_misc = true

# autoload
import autoload './utils.vim'
import autoload '../pack/plugins/opt/arrowkeys/autoload/arrowkeys.vim'

# toggle background
export def BackgroundToggle()
  execute "set background=" .. (&background == "dark" ? "light" : "dark")
  v:statusmsg = $"background={&background}"
enddef

# toggle diff
export def DiffToggle()
  if &diff
    diffoff
  else
    diffthis
  endif
  v:statusmsg = $"diff={&diff}"
enddef

# complete files in the same directory as the file in the active window (:E command)
export def CompleteSameDir(_, _, _): list<string>
  var cwddir = expand('%:p:h')
  var hidden = map(sort(globpath(cwddir, ".*", 0, 1)), "fnamemodify(v:val, ':~') .. utils.FileIndicator(v:val)")
  var nohidden = map(sort(globpath(cwddir, "*", 0, 1)), "fnamemodify(v:val, ':~') .. utils.FileIndicator(v:val)")
  return extend(nohidden, hidden)
enddef

# edit using a top window
export def EditTop(file: string)
  if filereadable(file)
    execute $"new {file}"
    wincmd _
  endif
enddef

# toggle fold column
export def FoldColumnToggle()
  execute "setlocal foldcolumn=" .. (&l:foldcolumn ? 0 : 1)
  v:statusmsg = $"foldcolumn={&l:foldcolumn}"
enddef

# toggle fold
export def FoldToggle()
  if &foldlevel
    execute "normal! zM"
  else
    execute "normal! zR"
  endif
  v:statusmsg = $"foldlevel={&foldlevel}"
enddef

# go to N buffer position
export def GoBufferPos(bnum: number)
  var match = 0
  var pos = 1
  for b in getbufinfo({'buflisted': 1})
    if bnum == pos
      execute $"b {b.bufnr}"
      match = 1
      break
    endif
    ++pos
  endfor
  if !match
    utils.EchoErrorMsg($"Error: the buffer in the position '{bnum}' does not exist")
  endif
enddef

# go to last edit cursor position
export def GoLastEditCursorPos()
  var lastcursorline = line("'\"")
  if lastcursorline >= 1 && lastcursorline <= line("$") && &filetype !~ "commit"
    execute "normal! g`\""
  endif
enddef

# toggle gui menu bar
export def GuiMenuBarToggle(): void
  if !has('gui_running')
    utils.EchoWarningMsg("Warning: only use this function with the gui")
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
  v:statusmsg = $"guioptions={&l:guioptions}"
enddef

# map insert enter
export def MapInsertEnter()
  if !empty(mapcheck("<CR>", "i"))
    iunmap <CR>
  endif
  inoremap <expr> <CR>
  \ get(g:, 'complementum_enabled')
  \ ? '<Plug>(complementum-enter)'
  \ : get(g:, "autoendstructs_enabled")
  \ ? '<Plug>(autoendstructs-end)'
  \ : '<CR>'
enddef

# map insert tab
export def MapInsertTab()
  if !empty(mapcheck("<Tab>", "i"))
    iunmap <Tab>
  endif
  inoremap <silent><expr> <Tab>
  \ get(g:, 'complementum_enabled')
  \ ? '<Plug>(complementum-tab)'
  \ : pumvisible()
  \ ? '<C-y>'
  \ : '<Tab>'
enddef

# menu spell
export def MenuLanguageSpell(): void
  var choice = inputlist(
    [
      'Select:',
      '1. English',
      '2. Spanish',
      '3. Catalan',
      '4. Russian',
      '5. Disable spell'
    ]
  )
  if empty(choice)
    return
  endif
  if choice < 1 || choice > 5
    utils.EchoErrorMsg($"Error: wrong option '{choice}'")
    return
  endif
  if choice >= 1 && choice <= 4
    setlocal spell
  endif
  if choice == 1
    setlocal spelllang=en
    # setlocal spellfile=~/.vim/spell/en.utf-8.spl.add
  elseif choice == 2
    setlocal spelllang=es
    # setlocal spellfile=~/.vim/spell/es.utf-8.spl.add
  elseif choice == 3
    setlocal spelllang=ca
    # setlocal spellfile=~/.vim/spell/ca.utf-8.spl.add
  elseif choice == 4
    setlocal spelllang=ru
    # setlocal spellfile=~/.vim/spell/ru.utf-8.spl.add
  elseif choice == 5
    setlocal nospell
  endif
enddef

# menu misc
export def MenuMisc(): void
  var choice = inputlist(
    [
      'Select:',
      '1. Enable arrow keys',
      '2. Disable arrow keys',
      '3. Toggle gui menu bar'
    ]
  )
  if empty(choice)
    return
  endif
  if choice < 1 || choice > 3
    utils.EchoErrorMsg($"Error: wrong option '{choice}'")
    return
  endif
  if choice == 1 || choice == 2
    if !get(g:, 'arrowkeys_enabled')
      utils.EchoErrorMsg("Error: the plugin 'arrowkeys' is not enabled")
      return
    endif
    if choice == 1
      arrowkeys.Enable()
    else
      arrowkeys.Disable()
    endif
  elseif choice == 3
    GuiMenuBarToggle()
  endif
enddef

# reload plugin (pack)
export def ReloadPluginPack(plugin: string, type: string): void
  var dir: string
  var files: list<string>
  if !get(g:, $"{plugin}_enabled")
     utils.EchoErrorMsg($"Error: the plugin '{plugin}' is not enabled or does not exist")
     return
  endif
  dir = $"{$HOME}/.vim/pack/plugins/{type}/{plugin}"
  if !isdirectory(dir)
     utils.EchoErrorMsg( $"Error: '{fnamemodify(dir, ':~')}' is not a directory or does not exist")
     return
  endif
  execute $"g:loaded_{plugin} = false"
  execute $"g:autoloaded_{plugin} = false"
  files = [
    $"{$HOME}/.vim/pack/plugins/{type}/{plugin}/plugin/{plugin}.vim",
    $"{$HOME}/.vim/pack/plugins/{type}/{plugin}/autoload/{plugin}.vim"
  ]
  for file in files
    if filereadable(file)
      execute $"source {file}"
    endif
  endfor
enddef

# set maximum foldlevel
export def SetMaxFoldLevel()
  var mfl = max(map(range(1, line('$')), 'foldlevel(v:val)'))
  if mfl > 0
    execute $"setlocal foldlevel={mfl}"
  endif
  v:statusmsg = $"foldlevel={&l:foldlevel}"
enddef

# set python3 with dynamic support
export def SetPythonDynamic()
  var homepython: string
  var libpython: string
  if has("python3_dynamic")
    if has('mac')
      homepython = "/Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/Current"
      libpython = $"{homepython}/Python3"
    elseif has('linux')
      homepython = "/usr"
      try
        libpython = sort(
          globpath($"{homepython}/lib/x86_64-linux-gnu", "libpython3*.so.1", 0, 1),
          (s1: string, s2: string): number => str2nr(split(s1, "\\.")[1]) - str2nr(split(s2, "\\.")[1])
        )[-1]
      catch /^Vim\%((\a\+)\)\=:E684:/  # E684: List index out of range: libpython3*.so.1 was not found
      endtry
    endif
    if isdirectory(homepython) && filereadable(libpython)
      execute $"set pythonthreehome={homepython}"
      execute $"set pythonthreedll={libpython}"
    endif
  endif
enddef

# sh
export def SH(): void
  var guioptions_orig: string
  if !has('gui_running')
    utils.EchoWarningMsg("Warning: only use this function with the gui")
    return
  endif
  guioptions_orig = &l:guioptions
  setlocal guioptions+=!
  sh
  execute $"setlocal guioptions={guioptions_orig}"
enddef

# check trailing spaces
export def CheckTrailingSpaces()
  var nline: number
  nline = search('\s\+$', 'n')
  if nline > 0
    utils.EchoWarningMsg($"Warning: there are trailing spaces in the line '{nline}'")
  endif
enddef

# toggle sign column
export def SignColumnToggle()
  execute "setlocal signcolumn=" .. (&l:signcolumn == "yes" ? "no" : "yes")
  v:statusmsg = $"signcolumn={&l:signcolumn}"
enddef

# toggle sytnax
export def SyntaxToggle()
  if !empty(&l:syntax)
    execute "setlocal syntax=" .. (&l:syntax == "on" ? "OFF" : "ON")
    v:statusmsg = $"setlocal syntax={&l:syntax}"
  else
    # global syntax
    # execute "syntax " .. (exists("g:syntax_on") ? "off" : "on")
    # v:statusmsg = "syntax " .. (exists("g:syntax_on") ? "on" : "off")
    # utils.EchoWarningMsg($"Warning: filetype '{&filetype}' does not have ftplugin syntax")
    v:statusmsg = $"Warning: filetype '{&filetype}' does not have ftplugin syntax"
  endif
enddef
