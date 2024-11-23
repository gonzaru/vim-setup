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
export def ToggleDefaultKeystroke()
  if g:complementum_keystroke_default != g:complementum_keystroke_default_toggle
    g:complementum_keystroke_default_orig = g:complementum_keystroke_default
    g:complementum_keystroke_default = g:complementum_keystroke_default_toggle
  else
    g:complementum_keystroke_default = g:complementum_keystroke_default_orig
  endif
  v:statusmsg = $"g:complementum_keystroke_default={strtrans(g:complementum_keystroke_default)}"
enddef

# complete the key
export def CompleteKey(key: string)
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
  if g:complementum_debuginfo
    DebugInfo()
  endif
enddef

# checks if the keystroke is triggerable (default)
def IsTriggerable(): bool
  var num: number
  var char: string
  var cline = getline('.')
  var ccol = col('.')
  if g:complementum_minchars < 1
    return false
  endif
  # start of line
  if (ccol - g:complementum_minchars) == 0
    if g:complementum_minchars == 1 || len(trim(cline)) == g:complementum_minchars - 1 && cline[0] =~ '^\w$'
      return true
    endif
  endif
  num = 0
  while num <= g:complementum_minchars
    char = cline[ccol - num - 1]
    if char =~ '^\W$' # non-word character
      break
    endif
    ++num
  endwhile
  return num == g:complementum_minchars
enddef

# complete
export def Complete(lang: string): void
  # \W non-word character
  if v:char =~ '^\W$' || pumvisible() || state('m') == 'm'
    if g:complementum_debuginfo
      DebugInfo()
    endif
    return
  endif
  # go plugins (vim-go/govim) must be enabled
  if v:char == "."
    if lang == "go"
      GoInsertAutoComplete(lang)
      if g:complementum_debuginfo
        DebugInfo()
      endif
    endif
  elseif !pumvisible() && IsTriggerable()
    feedkeys(g:complementum_keystroke_default, "i")
  endif
  if g:complementum_debuginfo
    DebugInfo()
  endif
enddef

# Go (golang) insert autocompletion
def GoInsertAutoComplete(lang: string)
  var curline = getline('.')
  var curcol = col('.')
  if g:complementum_minchars < 1
    return
  endif
  if lang == "go"
  && index(["go#complete#Complete", "GOVIM_internal_Complete"], &omnifunc) >= 0
  && strcharpart(curline[curcol - (g:complementum_minchars + 1) : ], 0, 1) =~ '\h\|\d'
    feedkeys(g:complementum_keystroke_omni, "i")
  endif
enddef
