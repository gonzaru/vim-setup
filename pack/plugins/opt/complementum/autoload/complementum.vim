vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_complementum') || !get(g:, 'complementum_enabled')
  finish
endif
g:autoloaded_complementum = true

# complementum debug info
def DebugInfo()
  echo $"| mode: {mode()} | state: {state()} | pumvisible: {pumvisible()}"
  # .. $"| complete_info: {{pum_visible:{complete_info().pum_visible},mode:{complete_info().mode}"
  # .. $",selected:{complete_info().selected},items:{complete_info().items}}}"
enddef

# complementum disable
export def Disable()
  # TODO: remove it using g:complementum_keystroke_(tab|backspace|space|enter)
  # if !empty(mapcheck("<Tab>", "i"))
  #   iunmap <Tab>
  # endif
  if !empty(mapcheck(keytrans(g:complementum_keystroke_backspace), "i"))
    execute $'iunmap {keytrans(g:complementum_keystroke_backspace)}'
  endif
  if !empty(mapcheck(keytrans(g:complementum_keystroke_delete_word), "i"))
    execute $'iunmap {keytrans(g:complementum_keystroke_delete_word)}'
  endif
  if !empty(mapcheck(keytrans(g:complementum_keystroke_delete_before_cursor), "i"))
    execute $'iunmap {keytrans(g:complementum_keystroke_delete_before_cursor)}'
  endif
  # if !empty(mapcheck("<Space>", "i"))
  #   iunmap <Space>
  # endif
  # if !empty(mapcheck("<CR>", "i"))
  #   iunmap <CR>
  # endif
  ## misc plugin
  # if get(g:, "misc_enabled")
  #   misc#MapInsertBackSpace()
  #   misc#MapInsertEnter()
  #   misc#MapInsertSpace()
  #   misc#MapInsertTab()
  # endif
  g:complementum_enabled = false
enddef

# complementum toggle
export def Toggle()
  if g:complementum_enabled
    Disable()
  else
    Enable()
  endif
  v:statusmsg = $"complementum={g:complementum_enabled}"
enddef

# toggle default keystroke
export def ToggleDefaultKeystroke(option: string)
  if option == "default_toggle"
    if g:complementum_keystroke_default == g:complementum_keystroke_omni
      g:complementum_keystroke_default = g:complementum_keystroke_default_orig
    elseif g:complementum_keystroke_default != g:complementum_keystroke_default_toggle
      g:complementum_keystroke_default_orig = g:complementum_keystroke_default
      g:complementum_keystroke_default = g:complementum_keystroke_default_toggle
      g:complementum_keystroke_default_toggle = g:complementum_keystroke_default_orig
    endif
  elseif option == "omni"
    if g:complementum_keystroke_default != g:complementum_keystroke_omni
      g:complementum_keystroke_default_orig = g:complementum_keystroke_default
      g:complementum_keystroke_default = g:complementum_keystroke_omni
    endif
  endif
  v:statusmsg = $"g:complementum_keystroke_default={strtrans(g:complementum_keystroke_default)}"
enddef

# complete the key
export def CompleteKey(key: string): void
  if g:complementum_debuginfo
    defer DebugInfo()
  endif
  if key == "tab"
    if pumvisible()
      feedkeys(g:complementum_keystroke_tab_pumvisible, "n")
    else
      feedkeys(g:complementum_keystroke_tab, "n")
    endif
  elseif key == "backspace"
    if pumvisible()
      feedkeys(g:complementum_keystroke_backspace, 'n')
      return
    endif
    var cline = getline('.')
    var ccol = col('.')
    var prev = (ccol > 1) ? matchstr(cline[ : ccol - 2], '.$') : ''
    var prev2 = (ccol > 1) ? matchstr(cline[ : ccol - 3], '.$') : ''
    if (prev =~ '\s' && prev2 != '' && IsTriggerableOmni(&filetype, [prev2]))
      feedkeys(g:complementum_keystroke_backspace .. g:complementum_keystroke_omni, 'n')
    elseif prev2 =~ '\w' && HasTriggerOmniKey('skipwhitespace')
      feedkeys(g:complementum_keystroke_backspace .. g:complementum_keystroke_omni, 'n')
    elseif prev =~ '\s' && prev2 =~ '\w'
      feedkeys(g:complementum_keystroke_backspace .. g:complementum_keystroke_default, 'n')
    else
      feedkeys(g:complementum_keystroke_backspace, 'n')
    endif
  elseif key == "delete-word" || key == "delete-before-cursor"  # <C-w> or <C-u>
    if pumvisible()
      if key == "delete-word"
        feedkeys("\<C-e>" .. g:complementum_keystroke_delete_word, 'n')
      elseif key == "delete-before-cursor"
        feedkeys("\<C-e>" .. g:complementum_keystroke_delete_before_cursor, 'n')
      endif
    else
      if key == "delete-word"
        feedkeys(g:complementum_keystroke_delete_word, 'n')
      elseif key == "delete-before-cursor"
        feedkeys(g:complementum_keystroke_delete_before_cursor, 'n')
      endif
    endif
    timer_start(0, (_) => {
      if !pumvisible() && HasTriggerOmniKey()
        feedkeys(g:complementum_keystroke_omni, 'n')
      endif
    })
  elseif key == "space"
    feedkeys(g:complementum_keystroke_space, "n")
  elseif key == "enter"
    # autoendstructs plugin
    if get(g:, "autoendstructs_enabled") && !pumvisible()
      feedkeys(autoendstructs#End(&filetype), "n")
    else
      feedkeys(g:complementum_keystroke_enter, "n")
    endif
  endif
enddef

# checks if the keystroke is triggerable (default)
def IsTriggerableDefault(ichar: string): bool
  const minchars = g:complementum_minchars
  if pumvisible() || minchars < 1
    return false
  endif
  # non-word
  if minchars == 1 && ichar !~ '^\W$'
    return true
  endif
  var cline = getline('.')
  var ccol = col('.')
  # start of line
  if (ccol - minchars) == 0
    if minchars == 1 || len(trim(cline)) == minchars - 1 && cline[0] =~ '^\w$'
      return true
    endif
  endif
  var num = 0
  while num <= minchars
    var char = cline[ccol - 2 - num]
    if char =~ '^\W$'
      break
    endif
    ++num
  endwhile
  return num == minchars - 1
enddef

# checks if the keystroke is triggerable (omni)
def IsTriggerableOmni(lang: string, chars: list<string>): bool
  if pumvisible() || !has_key(g:complementum_omnichars, lang) || g:complementum_minchars < 1
    return false
  endif
  for char in chars
    if index(g:complementum_omnichars[lang], char) >= 0
      return true
    endif
  endfor
  return false
enddef

# has omni trigger key (word)
def HasTriggerOmniKey(skip: string = ''): bool
  var omni = false
  var cline = getline('.')
  var ccol = col('.')
  var num = ccol
  while num >= 1
    var char = matchstr(cline[ : num - 2], '.$')
    if skip != 'skipwhitespace' && char =~ '\s'
      break
    endif
    if IsTriggerableOmni(&filetype, [char])
      omni = true
      break
    endif
    --num
  endwhile
  return omni
enddef

# complete (default)
export def Complete(lang: string, ichar: string): void
  if g:complementum_debuginfo
    defer DebugInfo()
  endif
  if pumvisible()
    return
  endif
  var prev = matchstr(getline('.')[ : col('.') - 2], '.$')
  if IsTriggerableOmni(lang, [ichar, prev])
    CompleteOmni(lang)
  elseif ichar =~ '^\W$' || state('m') == 'm'
    # do nothing
  elseif IsTriggerableDefault(ichar)
    feedkeys(g:complementum_keystroke_default, "n")
  endif
enddef

# complete (omni)
def CompleteOmni(lang: string): void
  if pumvisible()
    return
  endif
  if !has_key(g:complementum_omnifuncs, lang)
  && !has_key(g:complementum_lspfuncs, lang)
    return
  endif
  # lsp
  # omnni
  # dictionary
  # default
  #  if get(g:, 'lsp_enabled') && get(g:, 'lsp_complementum')
  #  && exists('g:lsp_allowed_types') && index(g:lsp_allowed_types, lang) >= 0
  #    timer_start(0, (_) => {
  #      lsp#Completion()
  #    })
  #    return
  # endif
  if get(g:, 'loaded_lsp') && index(g:complementum_lspfuncs[lang], &omnifunc) >= 0
    # lsp plugin
    if &l:omnifunc == 'lsp#OmniFunc' && (!get(g:, 'lsp_enabled') || !get(g:, 'lsp_complementum'))
      return
    endif
    feedkeys(g:complementum_keystroke_omni, "n")
  elseif index(g:complementum_omnifuncs[lang], &omnifunc) >= 0
    feedkeys(g:complementum_keystroke_omni, "n")
  elseif &dictionary =~ g:complementum_regex_dict
      var iskeyword_save = &l:iskeyword
      setlocal iskeyword+=.
      feedkeys(g:complementum_keystroke_dict, "n")
      timer_start(0, (_) => {
        # restore iskeyword
        execute $"setlocal iskeyword={iskeyword_save}"
      })
      # fallback to function completion
      # timer_start(15, (_) => {
      #   if !pumvisible()
      #    feedkeys(g:complementum_keystroke_func, "n")
      #   endif
      # })
  else
    # fallback to default
    feedkeys(g:complementum_keystroke_default, "n")
  endif
enddef

# complete command-line
export def CmdLineChanged(): void
  var info = cmdcomplete_info()
  var cmd = getcmdline()
  if empty(info) || getcmdcompltype() != 'file'
    return
  endif
  if info.selected != -1
    if getcmdcomplpat() =~ '\/\/$'
      # foo// -> foo/<complete>
      setcmdline(substitute(cmd, '\/\/$', '/', ''))
    endif
  endif
enddef
