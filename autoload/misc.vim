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

# toggle popup
export def PopupToggle(): void
  var id = popup_findinfo()
  if id > 0
    if popup_getpos(id)['visible']
      popup_hide(id)
    else
      popup_show(id)
    endif
  endif
enddef

# complete plugin pack (:ReloadPluginPack)
export def CompleteReloadPluginPack(ArgLead: string, CmdLine: string, _): list<string>
  var kind = (trim(CmdLine) =~ 'MiscReloadPluginStart') ? 'start' : 'opt'
  var plugdir = $"{$HOME}/.vim/pack/plugins/{kind}"
  var plugins = map(sort(globpath(plugdir, "*", 0, 1)), "fnamemodify(v:val, ':t')")
  return filter(plugins, $"v:val =~ '^{ArgLead}'")
enddef

# complete files in the same directory as the file in the active window (:E)
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

# toggle gui menu bar
export def GuiMenuBarToggle(): void
  if !has('gui_running')
    utils.EchoWarningMsg("Warning: only use this function with the gui")
    return
  endif
  if &l:guioptions =~ "m"
    setlocal guioptions-=m
    setlocal guioptions+=M
  else
    setlocal guioptions-=M
    setlocal guioptions+=m
    if !exists('g:did_install_default_menus')
      source $VIMRUNTIME/menu.vim
    endif
  endif
  v:statusmsg = $"guioptions={&l:guioptions}"
enddef

# toggle cmd menu bar
export def CmdMenuBarToggle(): void
  var msg: string
  if pumvisible()
    feedkeys("\<Esc>", "n")
    msg = $"pumvisible={pumvisible()}"
  else
    if !exists('g:did_install_default_menus')
      source $VIMRUNTIME/menu.vim
    endif
    feedkeys($":emenu\<Space>{!empty(&wildcharm) ? nr2char(&wildcharm) : "\<Tab>"}", "nt")
    msg = $"g:did_install_default_menus={g:did_install_default_menus}"
  endif
  v:statusmsg = msg
enddef

# map insert backspace
export def MapInsertBackSpace()
  if !empty(mapcheck("<BS>", "i"))
    iunmap <BS>
  endif
  inoremap <expr> <silent> <BS>
  \ get(g:, 'complementum_enabled')
  \ ? '<Plug>(complementum-backspace)'
  \ : '<BS>'
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

# map insert space
export def MapInsertSpace()
  if !empty(mapcheck("<Space>", "i"))
    iunmap <Space>
  endif
  inoremap <expr> <silent> <Space>
  \ get(g:, 'complementum_enabled')
  \ ? '<Plug>(complementum-space)'
  \ : '<C-]><Space>'  # <C-]> trigger abbreviation
enddef

# map insert tab
export def MapInsertTab()
  if !empty(mapcheck("<Tab>", "i"))
    iunmap <Tab>
  endif
  inoremap <expr> <silent> <Tab>
  \ get(g:, 'complementum_enabled')
  \ ? '<Plug>(complementum-tab)'
  \ : pumvisible()
  \ ? '<C-y>'
  \ : '<Tab>'
enddef

# reload plugin (pack)
export def ReloadPluginPack(plugin: string, kind: string): void
  var dir: string
  var files: list<string>
  var ftplugin: string
  if !get(g:, $"{plugin}_enabled")
     utils.EchoErrorMsg($"Error: the plugin '{plugin}' is not enabled or does not exist")
     return
  endif
  dir = $"{$HOME}/.vim/pack/plugins/{kind}/{plugin}"
  if !isdirectory(dir)
     utils.EchoErrorMsg( $"Error: '{fnamemodify(dir, ':~')}' is not a directory or does not exist")
     return
  endif
  if plugin == "cyclebuffers"
    ftplugin = "cb"
  elseif plugin == "git"
    ftplugin = "gitscm"
  else
    ftplugin = plugin
  endif
  execute $"g:loaded_{plugin} = false"
  execute $"g:autoloaded_{plugin} = false"
  execute $"b:did_ftplugin_{ftplugin} = false"
  files = [
    $"{$HOME}/.vim/pack/plugins/{kind}/{plugin}/plugin/{plugin}.vim",
    $"{$HOME}/.vim/pack/plugins/{kind}/{plugin}/autoload/{plugin}.vim"
  ]
  for file in files
    if filereadable(file)
      execute $"source {file}"
    endif
  endfor
enddef

# set input method options (see help: i_CTRL-^)
export def SetImOptions()
  var deflang = "en"
  var langs = ["ru"]
  if &l:iminsert == 1
    execute $"set dictionary-={$HOME}/.vim/dict/lang/{deflang}"
    if &l:keymap =~ "^russian"
      set dictionary+=${HOME}/.vim/dict/lang/ru
      set spelllang=ru
    endif
  else
    for lang in langs
      execute $"set dictionary-={$HOME}/.vim/dict/lang/{lang}"
    endfor
    execute $"set dictionary+={$HOME}/.vim/dict/lang/{deflang}"
    execute $"set spelllang={deflang}"
  endif
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

# set terminal options
export def SetTerminalOptions()
  if &buftype == "terminal"
    # TODO: laststatus=0
    # highlight! link StatusLineTerm Normal
    # highlight! link StatusLineTermNC Normal
    # setlocal statusline=%#Normal#%{repeat('-',winwidth('.'))}
    setlocal nonumber norelativenumber signcolumn=no statusline=%#Normal#
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

# delete a register
export def RegisterDelete(char: string)
  var exclude = [':', '.', '%', '=', '#']
  var regex = '[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/\-\"\+\*\~]'
  if index(exclude, char) == -1 && char =~ regex && !empty(getreg(char))
    setreg(char, [])
  endif
enddef

# delete all registers
export def RegisterDeleteAll()
  var char: string
  var lines: string
  redir => lines
    execute "silent registers"
  redir END
  for line in split(lines, '\n')[1 : ]
    char = substitute(split(line, ' ')[2], '^"', '', '')
    RegisterDelete(char)
  endfor
enddef

# search the selected text
export def SearchSelectedText(direction: string): void
  var chars = ['.', '*', '^', '$', '/']
  var vsel: string
  var vselesc: string
  vsel = getreg('*')
  if vsel =~ '^\n$'
    utils.EchoWarningMsg($"Warning: the selected text '{vsel}' is empty")
    return
  endif
  # TODO: allow multiple lines
  if len(split(vsel, '\n')) > 1
    utils.EchoErrorMsg($"Error: multiple selected lines are not allowed")
    return
  endif
  vselesc = escape(substitute(vsel, '\', '\\\', 'g'), join(chars))
  if direction == 'forward'
    feedkeys($"/{vselesc}\<CR>")
  else
    feedkeys($"?{vselesc}\<CR>n")
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
