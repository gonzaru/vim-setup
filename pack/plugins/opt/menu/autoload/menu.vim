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
      '3. Add cmd/gui menu extra',
      '4. Del cmd/gui menu extra',
      '5. Toggle cmd menu bar',
      '6. Toggle gui menu bar'
    ]
  )
  if empty(choice)
    return
  endif
  if choice < 1 || choice > 6
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
  elseif choice == 3
    AddMenuExtra()
  elseif choice == 4
    DelMenuExtra()
  elseif choice == 5 || choice == 6
    if !get(g:, 'misc_enabled')
      EchoErrorMsg("Error: the plugin 'misc' is not enabled")
      return
    endif
    if choice == 5
      misc#CmdMenuBarToggle()
    else
      misc#GuiMenuBarToggle()
    endif
    if g:menu_add_menu_extra
      AddMenuExtra()
    endif
  endif
enddef

# delete menu extra
export def DelMenuExtra()
  try
    aunmenu &Extra
  catch
  endtry
enddef

# add menu extra
export def AddMenuExtra()

  # delete menu extra
  DelMenuExtra()

  # menu extra
  anoremenu 1000.1000 &Extra.&Smile<Tab>:smile :smile<CR>
  anoremenu 1000.1000.1000.1 &Extra.&Plugins.-SEP1- <Nop>

  # arrowkeys
  if get(g:, 'arrowkeys_enabled')
    anoremenu 1000.1000.1001.1 &Extra.&Plugins.&ArrowKeys.&Enable<Tab><leader>ae <Plug>(arrowkeys-enable)
    anoremenu 1000.1000.1001.2 &Extra.&Plugins.&ArrowKeys.&Disable<Tab><leader>ad <Plug>(arrowkeys-disable)
    anoremenu 1000.1000.1001.3 &Extra.&Plugins.&ArrowKeys.&Toggle<Tab><leader>at <Plug>(arrowkeys-toggle)
  endif

  # autoclosechars
  if get(g:, 'autoclosechars_enabled')
    anoremenu 1000.1000.1002.1 &Extra.&Plugins.&AutoCloseChars.&Toggle<Tab><leader>tga <Plug>(autoclosechars-toggle)
    anoremenu 1000.1000.1002.2 &Extra.&Plugins.&AutoCloseChars.&BracketLeft<Tab>[ <Plug>(autoclosechars-bracketleft)
    anoremenu 1000.1000.1002.3 &Extra.&Plugins.&AutoCloseChars.&ParenLeft<Tab>( <Plug>(autoclosechars-parenleft)
    anoremenu 1000.1000.1002.4 &Extra.&Plugins.&AutoCloseChars.&BraceLeft<Tab>{ <Plug>(autoclosechars-braceleft)
  endif

  # autoendstructs
  if get(g:, 'autoendstructs_enabled')
    anoremenu 1000.1000.1003.1 &Extra.&Plugins.&AutoEndStructs.&Toggle<Tab><leader>tge <Plug>(autoendstructs-toggle)
  endif

  # bufferonly
  if get(g:, 'bufferonly_enabled')
    anoremenu 1000.1000.1004.1 &Extra.&Plugins.&BufferOnly.&Delete<Tab><leader>bo <Plug>(bufferonly-delete)
    anoremenu 1000.1000.1004.2 &Extra.&Plugins.&BufferOnly.&Delete!<Tab><leader>bO <Plug>(bufferonly-delete!)
    anoremenu 1000.1000.1004.3 &Extra.&Plugins.&BufferOnly.&Wipe<Tab><leader>Bo <Plug>(bufferonly-wipe)
    anoremenu 1000.1000.1004.4 &Extra.&Plugins.&BufferOnly.&Wipe!<Tab><leader>BO <Plug>(bufferonly-wipe!)
  endif

  # checker
  if get(g:, 'checker_enabled')
    anoremenu 1000.1000.1005.1 &Extra.&Plugins.&Checker.&Toggle<Tab><leader>tgk <Plug>(checker-toggle)
    anoremenu 1000.1000.1005.2 &Extra.&Plugins.&Checker.&SignsDebugCur<Tab><leader>ec\ \|\ F6 <Plug>(checker-signsdebug-cur)
    anoremenu 1000.1000.1005.3 &Extra.&Plugins.&Checker.&SignsDebugPrev<Tab><leader>ep\ \|\ F7 <Plug>(checker-signsdebug-prev)
    anoremenu 1000.1000.1005.4 &Extra.&Plugins.&Checker.&SignsDebugNext<Tab><leader>en\ \|\ F8 <Plug>(checker-signsdebug-next)
  endif

  # commentarium
  if get(g:, 'commentarium_enabled')
    anoremenu 1000.1000.1006.1 &Extra.&Plugins.&Commentarium.&Do<Tab><leader>/\ \ (normal) <Plug>(commentarium-do)
    anoremenu 1000.1000.1006.2 &Extra.&Plugins.&Commentarium.&DoRange<Tab><leader>/\ \ (visual) <Plug>(commentarium-do-range)
    anoremenu 1000.1000.1006.3 &Extra.&Plugins.&Commentarium.&Undo<Tab><leader>?\ \ (normal) <Plug>(commentarium-undo)
    anoremenu 1000.1000.1006.4 &Extra.&Plugins.&Commentarium.&UndoRange<Tab><leader>?\ \ (visual) <Plug>(commentarium-undo-range)
    anoremenu 1000.1000.1006.5 &Extra.&Plugins.&Commentarium.&+<Tab><leader>#\ \/*\ abc\ */\ \(normal\ \|\ visual) :<CR>
    anoremenu 1000.1000.1006.7 &Extra.&Plugins.&Commentarium.&<<Tab><leader><\ \<!--\ abc\ -->\ \(normal\ \|\ visual) :<CR>
  endif

  # complementum
  if get(g:, 'complementum_enabled')
    anoremenu 1000.1000.1007.1 &Extra.&Plugins.&Complementum.&Enable <Plug>(complementum-enable)
    anoremenu 1000.1000.1007.2 &Extra.&Plugins.&Complementum.&Disable <Plug>(complementum-disable)
    anoremenu 1000.1000.1007.3 &Extra.&Plugins.&Complementum.&Toggle<Tab><leader>tgc <Plug>(complementum-toggle)
    anoremenu 1000.1000.1007.4 &Extra.&Plugins.&Complementum.&ToggleDefaultKeystroke
      \<Tab><leader>tgC <Plug>(complementum-toggle-default-keystroke)
    anoremenu 1000.1000.1007.5 &Extra.&Plugins.&Complementum.&ToggleDefaultOmniKeystroke
      \<Tab><leader>tGC <Plug>(complementum-toggle-default-omni-keystroke)
  endif

  # cycleBuffers
  if get(g:, 'cyclebuffers_enabled')
    anoremenu 1000.1000.1008.1 &Extra.&Plugins.&CycleBuffers.&Cycle<Tab><leader><Space> <Plug>(cyclebuffers-cycle)
    anoremenu 1000.1000.1008.2 &Extra.&Plugins.&CycleBuffers.&OldFiles <Plug>(cyclebuffers-oldfiles)
    anoremenu 1000.1000.1008.3 &Extra.&Plugins.&CycleBuffers.&Help <Plug>(cyclebuffers-help)
  endif

  # documentare
  if get(g:, 'documentare_enabled')
    anoremenu 1000.1000.1009.1 &Extra.&Plugins.&Documentare.&Doc<Tab><Leader>K <Plug>(documentare-doc)
    anoremenu 1000.1000.1009.2 &Extra.&Plugins.&Documentare.&Close <Plug>(documentare-close)
  endif

  # esckey
  if get(g:, 'esckey_enabled')
    anoremenu 1000.1000.1010.1 &Extra.&Plugins.&EscKey.&Enable<Tab><Leader>je <Plug>(esckey-enable)
    anoremenu 1000.1000.1010.2 &Extra.&Plugins.&EscKey.&Disable<Tab><Leader>jd <Plug>(esckey-disable)
    anoremenu 1000.1000.1010.3 &Extra.&Plugins.&EscKey.&Toggle<Tab><Leader>jt <Plug>(esckey-toggle)
  endif

  # format
  if get(g:, 'format_enabled')
    anoremenu 1000.1000.1011.1 &Extra.&Plugins.&Format.&Language<Tab><Leader>fm <Plug>(format-language)
  endif

  # git
  if get(g:, 'git_enabled')
    anoremenu 1000.1000.1012.1  &Extra.&Plugins.&Git.&AddFile <Plug>(git-add-file)
    anoremenu 1000.1000.1012.2  &Extra.&Plugins.&Git.&Blame <Plug>(git-blame)
    anoremenu 1000.1000.1012.3  &Extra.&Plugins.&Git.&BlameShort <Plug>(git-blame-short)
    anoremenu 1000.1000.1012.4  &Extra.&Plugins.&Git.&Branch<Tab><Leader>vb <Plug>(git-branch)
    anoremenu 1000.1000.1012.5  &Extra.&Plugins.&Git.&BranchAll<Tab><Leader>vB <Plug>(git-branch-all)
    anoremenu 1000.1000.1012.6  &Extra.&Plugins.&Git.&BranchRemotes<Tab><Leader>VB <Plug>(git-branch-remotes)
    anoremenu 1000.1000.1012.7  &Extra.&Plugins.&Git.&CheckOutFile <Plug>(git-checkout-file)
    anoremenu 1000.1000.1012.8  &Extra.&Plugins.&Git.&Close<Tab><Leader>vc <Plug>(git-close)
    anoremenu 1000.1000.1012.9  &Extra.&Plugins.&Git.&Diff<Tab><Leader>vd <Plug>(git-diff)
    anoremenu 1000.1000.1012.10 &Extra.&Plugins.&Git.&DiffFile <Plug>(Outgit-diff-file)
    anoremenu 1000.1000.1012.11 &Extra.&Plugins.&Git.&DoAction <Plug>(git-do-action)
    anoremenu 1000.1000.1012.12 &Extra.&Plugins.&Git.&Help <Plug>(git-help)
    anoremenu 1000.1000.1012.13 &Extra.&Plugins.&Git.&StashList<Tab><Leader>vh <Plug>(git-stash-list)
    anoremenu 1000.1000.1012.14 &Extra.&Plugins.&Git.&Log<Tab><Leader>vl <Plug>(git-log)
    anoremenu 1000.1000.1012.15 &Extra.&Plugins.&Git.&LogFile <Plug>(git-log-file)
    anoremenu 1000.1000.1012.16 &Extra.&Plugins.&Git.&LogOneFile <Plug>(git-log-one-file)
    anoremenu 1000.1000.1012.17 &Extra.&Plugins.&Git.&LogOneLine<Tab><Leader>vL <Plug>(git-log-oneline)
    anoremenu 1000.1000.1012.18 &Extra.&Plugins.&Git.&Pull<Tab><Leader>vp <Plug>(git-pull)
    anoremenu 1000.1000.1012.19 &Extra.&Plugins.&Git.&RestoreStagedFile <Plug>(git-restore-staged-file)
    anoremenu 1000.1000.1012.20 &Extra.&Plugins.&Git.&Status<Tab><Leader>vs <Plug>(git-status)
    anoremenu 1000.1000.1012.21 &Extra.&Plugins.&Git.&StatusFile <Plug>(git-status-file)
    anoremenu 1000.1000.1012.22 &Extra.&Plugins.&Git.&Show<Tab><Leader>vS <Plug>(git-show)
    anoremenu 1000.1000.1012.23 &Extra.&Plugins.&Git.&ShowFile <Plug>(git-show-file)
    anoremenu 1000.1000.1012.24 &Extra.&Plugins.&Git.&TagList<Tab><Leader>vt <Plug>(git-tag-list)
    anoremenu 1000.1000.1012.25 &Extra.&Plugins.&Git.&TagListRemote<Tab><Leader>vT <Plug>(git-tag-list-remote)
  endif

  # habit
  if get(g:, 'habit_enabled')
    anoremenu 1000.1000.1013.1 &Extra.&Plugins.&Habit.&Enable<Tab><Leader>he <Plug>(habit-enable)
    anoremenu 1000.1000.1013.2 &Extra.&Plugins.&Habit.&Disable<Tab><Leader>hd <Plug>(habit-disable)
    anoremenu 1000.1000.1013.3 &Extra.&Plugins.&Habit.&Toggle<Tab><Leader>ht <Plug>(habit-toggle)
  endif

  # lsp
  if get(g:, 'lsp_enabled')
    anoremenu 1000.1000.1014.1  &Extra.&Plugins.&LSP.&Definition<Tab><Leader>gd\ \|\ <C-]> <Plug>(lsp-definition)
    anoremenu 1000.1000.1014.2  &Extra.&Plugins.&LSP.&DocumentSymbol<Tab><Leader>GS <Plug>(lsp-document-symbol)
    anoremenu 1000.1000.1014.3  &Extra.&Plugins.&LSP.&Hover<Tab><Leader>gi <Plug>(lsp-hover)
    anoremenu 1000.1000.1014.4  &Extra.&Plugins.&LSP.&References<Tab><Leader>gs <Plug>(lsp-references)
    anoremenu 1000.1000.1014.5  &Extra.&Plugins.&LSP.&Rename<Tab><Leader>gs <Plug>(lsp-rename)
    anoremenu 1000.1000.1014.6  &Extra.&Plugins.&LSP.&Signature<Tab><Leader>gS <Plug>(lsp-signature)
    anoremenu 1000.1000.1014.7  &Extra.&Plugins.&LSP.&Start <Plug>(lsp-start)
    anoremenu 1000.1000.1014.8  &Extra.&Plugins.&LSP.&Stop <Plug>(lsp-stop)
    anoremenu 1000.1000.1014.9  &Extra.&Plugins.&LSP.&StopAll <Plug>(lsp-stop-all)
    anoremenu 1000.1000.1014.10 &Extra.&Plugins.&LSP.&Restart <Plug>(lsp-restart)
    anoremenu 1000.1000.1014.11 &Extra.&Plugins.&LSP.&Enable <Plug>(lsp-enable)
    anoremenu 1000.1000.1014.12 &Extra.&Plugins.&LSP.&Disable <Plug>(lsp-disable)
    anoremenu 1000.1000.1014.13 &Extra.&Plugins.&LSP.&Info <Plug>(lsp-info)
    anoremenu 1000.1000.1014.14 &Extra.&Plugins.&LSP.&Ready <Plug>(lsp-ready)
    anoremenu 1000.1000.1014.15 &Extra.&Plugins.&LSP.&Running <Plug>(lsp-running)
  endif

  # menu
  if get(g:, 'menu_enabled')
    anoremenu 1000.1000.1015.1 &Extra.&Plugins.&Menu.&LanguageSpell<Tab><Leader>ms <Plug>(menu-language-spell)
    anoremenu 1000.1000.1015.2 &Extra.&Plugins.&Menu.&Misc<Tab><Leader>mm <Plug>(menu-misc)
    anoremenu 1000.1000.1015.3 &Extra.&Plugins.&Menu.&AddMenuExtra<Tab><Leader>me <Plug>(menu-menu-add-extra)
    anoremenu 1000.1000.1015.4 &Extra.&Plugins.&Menu.&DelMenuExtra<Tab><Leader>mE <Plug>(menu-menu-del-extra)
  endif

  # runprg
  if get(g:, 'runprg_enabled')
    anoremenu 1000.1000.1016.1 &Extra.&Plugins.&Runprg.&Run<Tab><Leader>ru <Plug>(runprg-run)
    anoremenu 1000.1000.1016.2 &Extra.&Plugins.&Runprg.&Window<Tab><Leader>rU <Plug>(runprg-window)
    anoremenu 1000.1000.1016.3 &Extra.&Plugins.&Runprg.&Close<Tab><Leader>RU <Plug>(runprg-close)
  endif

  # scratch
  if get(g:, 'scratch_enabled')
    anoremenu 1000.1000.1017.1  &Extra.&Plugins.&Scratch.&Buffer<Tab><Leader>sb\ \|\ s<BS> <Plug>(scratch-buffer)
    anoremenu 1000.1000.1017.2  &Extra.&Plugins.&Scratch.&Terminal<Tab><Leader>sz\ \|\ s<CR> <Plug>(scratch-terminal)
  endif

  # se
  if get(g:, 'se_enabled')
    anoremenu 1000.1000.1018.1  &Extra.&Plugins.&Se.&Togle<Tab><Leader>se <Plug>(se-toggle)
    anoremenu 1000.1000.1018.2  &Extra.&Plugins.&Se.&Help <Plug>(se-help)
    anoremenu 1000.1000.1018.3  &Extra.&Plugins.&Se.&Close <Plug>(se-close)
  endif

  # searcher
  if get(g:, 'searcher_enabled')
    anoremenu 1000.1000.1019.1  &Extra.&Plugins.&Searcher.&Find<Tab><Leader>sf <Plug>(searcher-find)
    anoremenu 1000.1000.1019.2  &Extra.&Plugins.&Searcher.&FindRoot<Tab><Leader>sF <Plug>(searcher-find-root)
    anoremenu 1000.1000.1019.3  &Extra.&Plugins.&Searcher.&FindLFind <Plug>(searcher-lfind)
    anoremenu 1000.1000.1019.4  &Extra.&Plugins.&Searcher.&FindWord <Plug>(searcher-find-word)
    anoremenu 1000.1000.1019.5  &Extra.&Plugins.&Searcher.&LFindWord <Plug>(searcher-lfind-word)
    anoremenu 1000.1000.1019.6  &Extra.&Plugins.&Searcher.&Grep<Tab><Leader>sg <Plug>(searcher-grep)
    anoremenu 1000.1000.1019.7  &Extra.&Plugins.&Searcher.&GrepRoot<Tab><Leader>sG <Plug>(searcher-grep-root)
    anoremenu 1000.1000.1019.8  &Extra.&Plugins.&Searcher.&LGrep <Plug>(searcher-lgrep)
    anoremenu 1000.1000.1019.9  &Extra.&Plugins.&Searcher.&GrepWord<Tab><Leader>sw <Plug>(searcher-grep-word)
    anoremenu 1000.1000.1019.10 &Extra.&Plugins.&Searcher.&GrepWordRoot<Tab><Leader>sW <Plug>(searcher-grep-word-root)
    anoremenu 1000.1000.1019.11 &Extra.&Plugins.&Searcher.&LGrepWord <Plug>(searcher-lgrep-word)
    anoremenu 1000.1000.1019.12 &Extra.&Plugins.&Searcher.&Git<Tab><Leader>sk <Plug>(searcher-git)
    anoremenu 1000.1000.1019.13 &Extra.&Plugins.&Searcher.&GitRoot<Tab><Leader>sK <Plug>(searcher-git-root)
    anoremenu 1000.1000.1019.14 &Extra.&Plugins.&Searcher.&GitWord <Plug>(searcher-git-word)
    anoremenu 1000.1000.1019.15 &Extra.&Plugins.&Searcher.&LGitWord <Plug>(searcher-lgit-word)
    anoremenu 1000.1000.1019.16 &Extra.&Plugins.&Searcher.&PopupFind<Tab><Leader>ff <Plug>(searcher-popup-find)
    anoremenu 1000.1000.1019.17 &Extra.&Plugins.&Searcher.&PopupGrep<Tab><Leader>fg <Plug>(searcher-popup-grep)
    anoremenu 1000.1000.1019.18 &Extra.&Plugins.&Searcher.&PopupRecent<Tab><Leader>fo <Plug>(searcher-popup-recent)
    anoremenu 1000.1000.1019.19 &Extra.&Plugins.&Searcher.&PopupBuffers<Tab>Leader>fb <Plug>(searcher-popup-buffers)
    anoremenu 1000.1000.1019.20 &Extra.&Plugins.&Searcher.&PopupSessions<Tab>Leader>fs <Plug>(searcher-popup-sessions)
    anoremenu 1000.1000.1019.21 &Extra.&Plugins.&Searcher.&PopupChanges<Tab>Leader>fc <Plug>(searcher-popup-changes)
    anoremenu 1000.1000.1019.22 &Extra.&Plugins.&Searcher.&PopupJumps<Tab>Leader>fj <Plug>(searcher-popup-jumps)
    anoremenu 1000.1000.1019.23 &Extra.&Plugins.&Searcher.&PopupQuickfix<Tab>Leader>fq <Plug>(searcher-popup-quickfix)
    anoremenu 1000.1000.1019.24 &Extra.&Plugins.&Searcher.&PopupCommands<Tab>Leader>fk <Plug>(searcher-popup-commands)
    anoremenu 1000.1000.1019.25 &Extra.&Plugins.&Searcher.&PopupThemes<Tab>Leader>ft <Plug>(searcher-popup-themes)
    anoremenu 1000.1000.1019.26 &Extra.&Plugins.&Searcher.&PopupCompletions<Tab>Leader>f* <Plug>(searcher-popup-completions)
    anoremenu 1000.1000.1019.27 &Extra.&Plugins.&Searcher.&PopupMappings<Tab>Leader>f_ <Plug>(searcher-popup-mappings)
    anoremenu 1000.1000.1019.28 &Extra.&Plugins.&Searcher.&PopupMarks<Tab>Leader>f' <Plug>(searcher-popup-marks)
    anoremenu 1000.1000.1019.29 &Extra.&Plugins.&Searcher.&PopupHistoryEx<Tab>Leader>f: <Plug>(searcher-popup-history-ex)
    anoremenu 1000.1000.1019.30 &Extra.&Plugins.&Searcher.&PopupHistorySearch<Tab>Leader>f/ <Plug>(searcher-popup-history-search)
  endif

  # statusline
  if get(g:, 'statusline_enabled')
    anoremenu 1000.1000.1020.1 &Extra.&Plugins.&StatusLine.&GitToggle<Tab><Leader>tgg <Plug>(statusline-git-toggle)
    anoremenu 1000.1000.1020.2 &Extra.&Plugins.&StatusLine.&GitEnable <Plug>(statusline-git-enable)
    anoremenu 1000.1000.1020.3 &Extra.&Plugins.&StatusLine.&GitDisable <Plug>(statusline-git-disable)
  endif

  # tabline

  # xkb
  if get(g:, 'xkb_enabled')
    anoremenu 1000.1000.1021.1 &Extra.&Plugins.&Xkb.&XkbLayoutFirst <Plug>(xkb-layout-first)
    anoremenu 1000.1000.1021.2 &Extra.&Plugins.&Xkb.&XkbLayoutNext <Plug>(xkb-layout-next)
    anoremenu 1000.1000.1021.3 &Extra.&Plugins.&Xkb.&XkbToggleLayout<Tab><Leader>xt <Plug>(xkb-toggle-layout)
  endif

enddef
