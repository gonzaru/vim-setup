vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_session') || !get(g:, 'session_enabled')
  finish
endif
g:loaded_session = true

# global variables
if !exists('g:session_directory')
  g:session_directory = $'{$HOME}/.vim/sessions'
  if !isdirectory(g:session_directory)
    mkdir(g:session_directory, 'p')
  endif
endif
if !exists('g:session_file_extension')
  g:session_file_extension = 'vim'
endif
if !exists('g:session_save_colorscheme')
  g:session_save_colorscheme = false
endif
if !exists('g:session_save_menubar')
  g:session_save_menubar = false
endif

# autoload
import autoload '../autoload/session.vim'

# automcd
# TODO

# define mappings
nnoremap <silent> <script> <Plug>(session-load) :SessionLoad<Space>
nnoremap <silent> <script> <Plug>(session-delete) :SessionDelete<Space>
nnoremap <silent> <script> <Plug>(session-write) <ScriptCmd>session.Write(g:session_directory, v:this_session)<CR>
nnoremap <silent> <script> <Plug>(session-rename) <ScriptCmd>session.Rename(g:session_directory)<CR>
nnoremap <silent> <script> <Plug>(session-close) <ScriptCmd>session.Close()<CR>
nnoremap <silent> <script> <Plug>(session-close!) <ScriptCmd>session.Close(true)<CR>

# set mappings
if get(g:, 'session_no_mappings') == 0
  if empty(mapcheck('<leader>pw', 'n'))
    nnoremap <silent><leader>pw <Plug>(session-write)
  endif
  if empty(mapcheck('<leader>pl', 'n'))
    nnoremap <silent><leader>pl <Plug>(session-load)
  endif
  if empty(mapcheck('<leader>pd', 'n'))
    nnoremap <silent><leader>pd <Plug>(session-delete)
  endif
  if empty(mapcheck('<leader>pr', 'n'))
    nnoremap <silent><leader>pr <Plug>(session-rename)
  endif
  if empty(mapcheck('<leader>pq', 'n'))
    nnoremap <silent><leader>pq <Plug>(session-close)
  endif
  if empty(mapcheck('<leader>pQ', 'n'))
    nnoremap <silent><leader>pQ <Plug>(session-close!)
  endif
endif

# set commands
if get(g:, 'session_no_commands') == 0
  command! -nargs=0 -bang SessionClose session.Close(!empty('<bang>'))
  command! -nargs=0 SessionRename execute "normal \<Plug>(session-rename)"
  command! -nargs=1 -complete=customlist,session.CompleteLoad SessionLoad session.Load(g:session_directory, '<args>')
  command! -nargs=1 -complete=customlist,session.CompleteLoad SessionWrite session.Write(g:session_directory, '<args>')
  command! -nargs=1 -complete=customlist,session.CompleteLoad SessionDelete session.Delete(g:session_directory, '<args>')
endif
