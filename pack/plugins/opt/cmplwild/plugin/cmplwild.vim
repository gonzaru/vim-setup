vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_cmplwild') || !get(g:, 'cmplwild_enabled')
  finish
endif
g:loaded_cmplwild = true

# global variables
if !exists('g:cmplwild_fuzzy')
  g:cmplwild_fuzzy = false
endif
if !exists('g:cmplwild_delay')
  g:cmplwild_delay = 0  # ms
endif
if !exists('g:cmplwild_minchars')
  g:cmplwild_minchars = 1
endif

# autoload
import autoload '../autoload/cmplwild.vim'

# autocmd
# command-line mode
# help cmdline-autocompletion
augroup cmplwild_cmdline
  autocmd!
  # [:/\?]
  autocmd CmdlineEnter [:/\?] {
    if &wildmenu && g:cmplwild_enabled
      g:cmplwild_incsearch_save = &incsearch
      g:cmplwild_wildmode_save = &wildmode
      g:cmplwild_wildoptions_save = &wildoptions
      set noincsearch  # TODO: blinks popup
      set wildmode=noselect:lastused,full
      # set wildmode=noselect,longest,full
      if g:cmplwild_fuzzy
        set wildoptions=pum,fuzzy
      else
        set wildoptions=pum
      endif
    endif
  }
  # [:/\?]
  autocmd CmdlineLeave [:/\?] {
    if &wildmenu && g:cmplwild_enabled
      &incsearch = g:cmplwild_incsearch_save
      &wildmode = g:cmplwild_wildmode_save
      &wildoptions = g:cmplwild_wildoptions_save
    endif
  }
  # [:/\?]
  autocmd CmdlineChanged [:/\?] CmplTrigger()
  var _timer = -1
  def CmplTrigger(): void
    if !&wildmenu || !g:cmplwild_enabled
      return
    endif
    if _timer != -1
      timer_stop(_timer)
    endif
    _timer = timer_start(g:cmplwild_delay, (_) => {
      if g:cmplwild_enabled
        cmplwild.CmdLineChanged()
        var cmd = getcmdline()
        if !empty(cmd) && strlen(cmd) >= g:cmplwild_minchars
          wildtrigger()
        endif
      endif
      _timer = -1
    })
  enddef
augroup END

# define mappings
nnoremap <silent> <script> <Plug>(cmplwild-enable) <ScriptCmd>cmplwild.Enable()<CR>
nnoremap <silent> <script> <Plug>(cmplwild-disable) <ScriptCmd>cmplwild.Disable()<CR>
nnoremap <silent> <script> <Plug>(cmplwild-toggle) <ScriptCmd>cmplwild.Toggle()<CR>

# set mappings
if !get(g:, 'cmplwild_no_mappings')
  if empty(mapcheck("<Left>", "c"))
    cnoremap <expr> <Left> wildmenumode() ? "\<C-e>\<Left>" : "\<Left>"
  endif
  if empty(mapcheck("<Right>", "c"))
    cnoremap <expr> <Right> wildmenumode() ? "\<C-e>\<Right>" : "\<Right>"
  endif
  # if empty(mapcheck("<Up>", "c"))
  #   cnoremap <expr> <Up> wildmenumode() ? "\<C-e>\<Up>" : "\<Up>"
  # endif
  # if empty(mapcheck("<Down>", "c"))
  #   cnoremap <expr> <Down> wildmenumode() ? "\<C-e>\<Down>" : "\<Down>"
  # endif
endif

# set commands
if !get(g:, 'cmplwild_no_commands')
  command! CmplWildEnable execute "normal \<Plug>(cmplwild-enable)"
  command! CmplWildDisable execute "normal \<Plug>(cmplwild-disable)"
  command! CmplWildToggle execute "normal \<Plug>(cmplwild-toggle)"
endif
