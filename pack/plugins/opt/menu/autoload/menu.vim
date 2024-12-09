vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_menu') || !get(g:, 'menu_enabled')
  finish
endif
g:autoloaded_menu = true

# prints the error message and saves the message in the message-history
export def EchoErrorMsg(msg: string)
  if !empty(msg)
    echohl ErrorMsg
    echom msg
    echohl None
  endif
enddef

# menu spell
export def LanguageSpell(): void
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
    EchoErrorMsg($"Error: wrong option '{choice}'")
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
export def Misc(): void
  var choice = inputlist(
    [
      'Select:',
      '1. Enable arrow keys',
      '2. Disable arrow keys',
      '3. Toggle cmd menu bar',
      '4. Toggle gui menu bar'
    ]
  )
  if empty(choice)
    return
  endif
  if choice < 1 || choice > 4
    EchoErrorMsg($"Error: wrong option '{choice}'")
    return
  endif
  if choice == 1 || choice == 2
    if !get(g:, 'arrowkeys_enabled')
      EchoErrorMsg("Error: the plugin 'arrowkeys' is not enabled")
      return
    endif
    if choice == 1
      arrowkeys#Enable()
    else
      arrowkeys#Disable()
    endif
  elseif choice == 3 || choice == 4
    if !get(g:, 'misc_enabled')
      EchoErrorMsg("Error: the plugin 'misc' is not enabled")
      return
    endif
    if choice == 3
      misc#CmdMenuBarToggle()
    else
      misc#GuiMenuBarToggle()
    endif
  endif
enddef

# menu extra
export def MenuExtra()
  # remove menu extra
  try
    aunmenu &Extra
  catch
  endtry

  # menu extra
  anoremenu 1000.1000 &Extra.&Smile<Tab>:smile :smile<CR>
  anoremenu 1000.1000.1000.1 &Extra.&Plugins.-SEP1- <Nop>

  # arrowkeys
  anoremenu 1000.1000.1001.1 &Extra.&Plugins.&ArrowKeys.&Enable<Tab><leader>ae <Plug>(arrowkeys-enable)
  anoremenu 1000.1000.1001.2 &Extra.&Plugins.&ArrowKeys.&Disable<Tab><leader>ad <Plug>(arrowkeys-disable)
  anoremenu 1000.1000.1001.3 &Extra.&Plugins.&ArrowKeys.&Toggle<Tab><leader>at <Plug>(arrowkeys-toggle)

  # autoclosechars
  anoremenu 1000.1000.1002.1 &Extra.&Plugins.&AutoCloseChars.&Toggle<Tab><leader>tga <Plug>(autoclosechars-toggle)
  anoremenu 1000.1000.1002.2 &Extra.&Plugins.&AutoCloseChars.&BracketLeft<Tab>[ <Plug>(autoclosechars-bracketleft)
  anoremenu 1000.1000.1002.3 &Extra.&Plugins.&AutoCloseChars.&ParenLeft<Tab>( <Plug>(autoclosechars-parenleft)
  anoremenu 1000.1000.1002.4 &Extra.&Plugins.&AutoCloseChars.&BraceLeft<Tab>{ <Plug>(autoclosechars-braceleft)

  # autoendstrucs
  anoremenu 1000.1000.1003.1 &Extra.&Plugins.&AutoEndStructs.&Toggle<Tab><leader>tge <Plug>(autoendstructs-toggle)

  # bufferonly
  anoremenu 1000.1000.1004.1 &Extra.&Plugins.&BufferOnly.&Delete<Tab><leader>bo <Plug>(bufferonly-delete)
  anoremenu 1000.1000.1004.2 &Extra.&Plugins.&BufferOnly.&Delete!<Tab><leader>bO <Plug>(bufferonly-delete!)
  anoremenu 1000.1000.1004.3 &Extra.&Plugins.&BufferOnly.&Wipe<Tab><leader>Bo <Plug>(bufferonly-wipe)
  anoremenu 1000.1000.1004.4 &Extra.&Plugins.&BufferOnly.&Wipe!<Tab><leader>BO <Plug>(bufferonly-wipe!)

  # checker
  anoremenu 1000.1000.1005.1 &Extra.&Plugins.&Checker.&Toggle<Tab><leader>tgk <Plug>(checker-toggle)
  anoremenu 1000.1000.1005.2 &Extra.&Plugins.&Checker.&SignsDebugCur<Tab><leader>ec\ \|\ F6 <Plug>(checker-signsdebug-cur)
  anoremenu 1000.1000.1005.3 &Extra.&Plugins.&Checker.&SignsDebugPrev<Tab><leader>ep\ \|\ F7 <Plug>(checker-signsdebug-prev)
  anoremenu 1000.1000.1005.4 &Extra.&Plugins.&Checker.&SignsDebugNext<Tab><leader>en\ \|\ F8 <Plug>(checker-signsdebug-next)

  # commentarium
  anoremenu 1000.1000.1006.1 &Extra.&Plugins.&Commentarium.&Do<Tab><leader>/\ \ (normal) <Plug>(commentarium-do)
  anoremenu 1000.1000.1006.2 &Extra.&Plugins.&Commentarium.&DoRange<Tab><leader>/\ \ (visual) <Plug>(commentarium-do-range)
  anoremenu 1000.1000.1006.3 &Extra.&Plugins.&Commentarium.&Undo<Tab><leader>?\ \ (normal) <Plug>(commentarium-undo)
  anoremenu 1000.1000.1006.4 &Extra.&Plugins.&Commentarium.&UndoRange<Tab><leader>?\ \ (visual) <Plug>(commentarium-undo-range)
  anoremenu 1000.1000.1006.5 &Extra.&Plugins.&Commentarium.&+<Tab><leader>+\ \/*\ abc\ */\ \(normal\ \|\ visual) :<CR>
  anoremenu 1000.1000.1006.7 &Extra.&Plugins.&Commentarium.&<<Tab><leader><\ \<!--\ abc\ -->\ \(normal\ \|\ visual) :<CR>

  # complementum
  anoremenu 1000.1000.1007.1 &Extra.&Plugins.&Complementum.&Enable <Plug>(complementum-enable)
  anoremenu 1000.1000.1007.2 &Extra.&Plugins.&Complementum.&Disable <Plug>(complementum-disable)
  anoremenu 1000.1000.1007.3 &Extra.&Plugins.&Complementum.&Toggle<Tab><leader>tgc <Plug>(complementum-toggle)
  anoremenu 1000.1000.1007.4 &Extra.&Plugins.&Complementum.&ToggleDefaultKeystroke
    \<Tab><leader>tgC <Plug>(complementum-toggle-default-keystroke)

  # cycleBuffers
  anoremenu 1000.1000.1008.1 &Extra.&Plugins.&CycleBuffers.&Cycle<Tab><leader><Space> <Plug>(cyclebuffers-cycle)

  # documentare
  anoremenu 1000.1000.1009.1 &Extra.&Plugins.&Documentare.&Doc<Tab><Leader>K <Plug>(documentare-doc)
  anoremenu 1000.1000.1009.2 &Extra.&Plugins.&Documentare.&Close <Plug>(documentare-close)

  # esckey
  anoremenu 1000.1000.1010.1 &Extra.&Plugins.&EscKey.&Enable<Tab><Leader>je <Plug>(esckey-enable)
  anoremenu 1000.1000.1010.2 &Extra.&Plugins.&EscKey.&Disable<Tab><Leader>jd <Plug>(esckey-disable)
  anoremenu 1000.1000.1010.3 &Extra.&Plugins.&EscKey.&Toggle<Tab><Leader>jt <Plug>(esckey-toggle)

  # format
  anoremenu 1000.1000.1011.1 &Extra.&Plugins.&Format.&Language<Tab><Leader>fm <Plug>(format-language)

  # git
  anoremenu 1000.1000.1012.1 &Extra.&Plugins.&Git.&Branch<Tab><Leader>vb <Plug>(git-branch)
  anoremenu 1000.1000.1012.2 &Extra.&Plugins.&Git.&BranchAll<Tab><Leader>vB <Plug>(git-branch-all)
  anoremenu 1000.1000.1012.3 &Extra.&Plugins.&Git.&BranchRemotes<Tab><Leader>VB <Plug>(git-branch-remotes)
  anoremenu 1000.1000.1012.4 &Extra.&Plugins.&Git.&Close<Tab><Leader>vc <Plug>(git-close)
  anoremenu 1000.1000.1012.5 &Extra.&Plugins.&Git.&Diff<Tab><Leader>vd <Plug>(git-diff)
  anoremenu 1000.1000.1012.6 &Extra.&Plugins.&Git.&StashList<Tab><Leader>vh <Plug>(git-stash-list)
  anoremenu 1000.1000.1012.7 &Extra.&Plugins.&Git.&Log<Tab><Leader>vl <Plug>(git-log)
  anoremenu 1000.1000.1012.8 &Extra.&Plugins.&Git.&LogOnline<Tab><Leader>vL <Plug>(git-log-online)
  anoremenu 1000.1000.1012.9 &Extra.&Plugins.&Git.&Pull<Tab><Leader>vp <Plug>(git-pull)
  anoremenu 1000.1000.1012.10 &Extra.&Plugins.&Git.&Status<Tab><Leader>vs <Plug>(git-status)
  anoremenu 1000.1000.1012.11 &Extra.&Plugins.&Git.&Show<Tab><Leader>vS <Plug>(git-show)
  anoremenu 1000.1000.1012.12 &Extra.&Plugins.&Git.&TagList<Tab><Leader>vt <Plug>(git-tag-list)
  anoremenu 1000.1000.1012.13 &Extra.&Plugins.&Git.&TagListRemote<Tab><Leader>vT <Plug>(git-tag-list-remote)

  # habit
  anoremenu 1000.1000.1013.1 &Extra.&Plugins.&Habit.&Enable<Tab><Leader>he <Plug>(habit-enable)
  anoremenu 1000.1000.1013.2 &Extra.&Plugins.&Habit.&Disable<Tab><Leader>hd <Plug>(habit-disable)
  anoremenu 1000.1000.1013.3 &Extra.&Plugins.&Habit.&Toggle<Tab><Leader>ht <Plug>(habit-toggle)

  # menu
  anoremenu 1000.1000.1014.1 &Extra.&Plugins.&Menu.&LanguageSpell<Tab><Leader>ms <Plug>(menu-language-spell)
  anoremenu 1000.1000.1014.2 &Extra.&Plugins.&Menu.&Misc<Tab><Leader>mm <Plug>(menu-misc)
  anoremenu 1000.1000.1014.3 &Extra.&Plugins.&Menu.&MenuExtra<Tab><Leader>me <Plug>(menu-menu-extra)

  # runprg
  anoremenu 1000.1000.1015.1 &Extra.&Plugins.&Runprg.&Run<Tab><Leader>ru <Plug>(runprg-run)
  anoremenu 1000.1000.1015.2 &Extra.&Plugins.&Runprg.&Window<Tab><Leader>rU <Plug>(runprg-window)
  anoremenu 1000.1000.1015.3 &Extra.&Plugins.&Runprg.&Close<Tab><Leader>RU <Plug>(runprg-close)

  # statusline
  anoremenu 1000.1000.1016.1 &Extra.&Plugins.&StatusLine.&GitToggle<Tab><Leader>tgg <Plug>(statusline-git-toggle)

  # xkb
  anoremenu 1000.1000.1017.1 &Extra.&Plugins.&Xkb.&XkbLayoutFirst <Plug>(xkb-layout-first)
  anoremenu 1000.1000.1017.2 &Extra.&Plugins.&Xkb.&XkbLayoutNext <Plug>(xkb-layout-next)
  anoremenu 1000.1000.1017.3 &Extra.&Plugins.&Xkb.&XkbToggleLayout<Tab><Leader>xt <Plug>(xkb-toggle-layout)

enddef
