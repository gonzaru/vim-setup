vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_runprg') || !get(g:, 'runprg_enabled')
  finish
endif
g:loaded_runprg = true

# autoload
import autoload '../autoload/runprg.vim'

# get run commands
def GetRunCommand(lang: string): string
  var cmds = {
    'sh': getline(1) =~ "bash" ? 'bash' : 'sh',
    'bash': 'bash',
    'python': 'python3',
    'go': 'go run'
  }
  if !has_key(cmds, lang)
    throw $"Error: the lang '{lang}' is not supported"
  endif
  return cmds[lang]
enddef

# define mappings
nnoremap <silent> <script> <Plug>(runprg-run)
  \ <ScriptCmd>runprg.Run(GetRunCommand(&filetype), expand('%:p'))<CR>
nnoremap <silent> <script> <Plug>(runprg-window)
  \ <ScriptCmd>runprg.RunWindow(GetRunCommand(&filetype), expand('%:p'), 'below', false)<CR>
nnoremap <silent> <script> <Plug>(runprg-close) <ScriptCmd>runprg.Close()<CR>

# set mappings
if get(g:, 'runprg_no_mappings') == 0
  if empty(mapcheck("<leader>ru", "n"))
    nnoremap <leader>ru <Plug>(runprg-run)
  endif
  if empty(mapcheck("<leader>rU", "n"))
    nnoremap <leader>rU <Plug>(runprg-window)
  endif
  if empty(mapcheck("<leader>RU", "n"))
    nnoremap <leader>RU <Plug>(runprg-close)
  endif
endif

# set commands
if get(g:, 'runprg_no_commands') == 0
  command! Run execute "normal \<Plug>(runprg-run)"
  command! RunWindow execute "normal \<Plug>(runprg-window)"
  command! RunClose execute "normal \<Plug>(runprg-close)"
endif
