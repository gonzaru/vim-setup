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
  # if !empty(mapcheck("<BS>", "i"))
  #   iunmap <BS>
  # endif
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
export def CompleteKey(key: string)
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
    feedkeys(g:complementum_keystroke_backspace, "n")
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
def IsTriggerableDefault(): bool
  var num: number
  var char: string
  var cline: string
  var ccol: number
  if g:complementum_minchars < 1
    return false
  endif
  cline = getline('.')
  ccol = col('.')
  # start of line
  if (ccol - g:complementum_minchars) == 0
    if g:complementum_minchars == 1 || len(trim(cline)) == g:complementum_minchars - 1 && cline[0] =~ '^\w$'
      return true
    endif
  endif
  num = 0
  while num <= g:complementum_minchars
    char = cline[ccol - 2 - num]
    if char =~ '^\W$' # non-word character
      break
    endif
    ++num
  endwhile
  return num == g:complementum_minchars - 1
enddef

# checks if the keystroke is triggerable (omni)
def IsTriggerableOmni(lang: string, ichar: string): bool
  if !has_key(g:complementum_omnichars, lang)
    return false
  endif
  var cline = getline('.')
  var ccol = col('.')
  var omni = false
  if index(g:complementum_omnichars[lang], ichar) >= 0
    omni = true
  elseif g:complementum_minchars == 1 && index(g:complementum_omnichars[lang], cline[ccol - 2]) >= 0
    omni = true
  elseif g:complementum_minchars < 1 || cline[ccol - 2] !~ '^\w$' || ichar =~ '^\W$'
    omni = false
  elseif cline[ccol - 2 - g:complementum_minchars] =~ '^\w$'
    && index(g:complementum_omnichars[lang], cline[ccol - 1 - g:complementum_minchars]) >= 0
    omni = true
  endif
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
  if IsTriggerableOmni(lang, ichar)
    CompleteOmni(lang)
  elseif ichar =~ '^\W$' || state('m') == 'm'
    # do nothing
  elseif IsTriggerableDefault()
    feedkeys(g:complementum_keystroke_default, "i")
  endif
enddef

# complete (omni)
def CompleteOmni(lang: string): void
  if !has_key(g:complementum_omnifuncs, lang)
  && !has_key(g:complementum_lspfuncs, lang)
    return
  endif
  # lsp
  # omnni
  # dictionary
  # default
  if get(g:, 'lsp_enabled') && get(g:, 'lsp_complementum')
  && exists('g:lsp_allowed_types') && index(g:lsp_allowed_types, lang) >= 0
    # TODO: omnifunc function
    timer_start(0, (_) => {
      lsp#Completion()
    })
  elseif get(g:, 'loaded_lsp') && index(g:complementum_lspfuncs[lang], &omnifunc) >= 0
    feedkeys(g:complementum_keystroke_omni, "i")
  elseif index(g:complementum_omnifuncs[lang], &omnifunc) >= 0
    feedkeys(g:complementum_keystroke_omni, "i")
  elseif &dictionary =~ g:complementum_regex_dict
      var iskeyword_orig = &l:iskeyword
      setlocal iskeyword+=.
      feedkeys(g:complementum_keystroke_dict, "i")
      timer_start(0, (_) => {
        # restore iskeyword
        execute $"setlocal iskeyword={iskeyword_orig}"
      })
      # fallback to function completion
      # timer_start(15, (_) => {
      #   if !pumvisible()
      #    feedkeys(g:complementum_keystroke_func, 'i')
      #   endif
      # })
  else
    # fallback to default
    feedkeys(g:complementum_keystroke_default, "i")
  endif
enddef
