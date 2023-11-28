vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_complementum') || !get(g:, 'complementum_enabled')
  finish
endif
g:autoloaded_complementum = true

# complementum debug info
def DebugInfo()
  echo $"g:complementum_typedchars: {g:complementum_typedchars} "
    .. $"| mode: {mode()} | state: {state()} | pumvisible: {pumvisible()} "
  # .. $"| complete_info: {{pum_visible:{complete_info().pum_visible},mode:{complete_info().mode}"
  # .. $",selected:{complete_info().selected},items:{complete_info().items}}}"
enddef

# complementum enable
export def Enable()
  if empty(mapcheck("<Tab>", "i"))
    inoremap <expr> <Tab> pumvisible() ? '<C-y>' : '<Plug>(complementum-tab)'
  endif
  if empty(mapcheck("<Backspace>", "i"))
    inoremap <expr> <Backspace> pumvisible() ? '<Backspace>' : '<Plug>(complementum-backspace)'
  endif
  if empty(mapcheck("<Space>", "i"))
    inoremap <expr> <Space> pumvisible() ? '<Space>' : '<Plug>(complementum-space)'
  endif
  if empty(mapcheck("<CR>", "i"))
    inoremap <expr> <CR> pumvisible() ? '<CR>' : '<Plug>(complementum-enter)'
  endif
  g:complementum_enabled = true
enddef

# complementum disable
export def Disable()
  # TODO: remove it using g:complementum_keystroke_(tab|backspace|space|enter)
  if !empty(mapcheck("<Tab>", "i"))
    iunmap <Tab>
  endif
  if !empty(mapcheck("<Backspace>", "i"))
    iunmap <Backspace>
  endif
  if !empty(mapcheck("<Space>", "i"))
    iunmap <Space>
  endif
  if !empty(mapcheck("<CR>", "i"))
    iunmap <CR>
  endif
  # misc plugin
  if get(g:, "misc_enabled")
    misc#MapInsertEnter()
    misc#MapInsertTab()
  endif
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

# complete the key
export def CompleteKey(key: string)
  if key == "tab"
    feedkeys(g:complementum_keystroke_tab, "n")
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
  g:complementum_typedchars = 0
  if g:complementum_debuginfo
    DebugInfo()
  endif
enddef

# complete
export def Complete(lang: string): void
  # var prevchar: string
  # prevchar = getline('.')[col('.') - 2]
  # \w word character
  # \k
  var chregex = '\s\|[(){}\|\[\];:",<>/>?`~_\-=+!@#$%^&*]'
  if v:char =~ chregex || v:char == "'" || pumvisible() || state('m') == 'm'
    g:complementum_typedchars = 0
    if g:complementum_debuginfo
      DebugInfo()
    endif
    return
  endif
  # go plugins (vim-go/govim) must be enabled
  if v:char == "."
    if lang == "go"
      GoInsertAutoComplete(lang)
      g:complementum_typedchars = 0
      if g:complementum_debuginfo
        DebugInfo()
      endif
    endif
  else
    ++g:complementum_typedchars
    if g:complementum_typedchars == g:complementum_minchars
      feedkeys(g:complementum_keystroke_default, "i")
      g:complementum_typedchars = 0
    endif
  endif
  if g:complementum_debuginfo
    DebugInfo()
  endif
enddef

# Go (golang) insert autocompletion
def GoInsertAutoComplete(lang: string)
  var curline = getline('.')
  var curcol = col('.')
  if lang == "go"
  && index(["go#complete#Complete", "GOVIM_internal_Complete"], &omnifunc) >= 0
  && strcharpart(curline[curcol - (g:complementum_minchars + 1) : ], 0, 1) =~ '\h\|\d'
    feedkeys(g:complementum_keystroke_go, "i")
  endif
enddef
