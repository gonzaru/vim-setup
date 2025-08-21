vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_format') || !get(g:, 'format_enabled')
  finish
endif
g:loaded_format = true

# global variables
if !exists('g:format_sh_command')
  g:format_sh_command = ['shfmt', '-i', &l:shiftwidth, '-']
endif
if !exists('g:format_sh_on_write')
  g:format_sh_on_write = false
endif
if !exists('g:format_bash_command')
  g:format_bash_command = g:format_sh_command
endif
if !exists('g:format_python_command')
  g:format_python_command = ['black', '-q', '-S', '-l', '88', '-']
endif
if !exists('g:format_python_on_write')
  g:format_python_on_write = false
endif
if !exists('g:format_go_command')
  g:format_go_command = ['gofmt']
endif
if !exists('g:format_go_on_write')
  g:format_go_on_write = false
endif

# autoload
import autoload '../autoload/format.vim'

# see checker plugin
# autocmd
# augroup format_go
#   autocmd!
#   autocmd FileType sh,python,go {
#     autocmd BufWritePre <buffer>
#     \ if index(["sh", "python", "go"], &filetype) >= 0 && get(g:, $"format_{&filetype}_on_write") |
#     \   execute "normal \<Plug>(format-language)" |
#     \ endif
#   }
# augroup END

# define mappings
nnoremap <silent> <script> <Plug>(format-language)
\ <ScriptCmd>format.Language(&filetype, expand('%:p'))<CR>

# set mappings
if get(g:, 'format_no_mappings') == 0
  if empty(mapcheck("<leader>fm", "n"))
    nnoremap <leader>fm <Plug>(format-language)
  endif
endif

# set commands
if get(g:, 'format_no_commands') == 0
  command! FormatLanguage execute "normal \<Plug>(format-language)"
endif
