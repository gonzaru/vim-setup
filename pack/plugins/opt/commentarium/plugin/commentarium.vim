vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:loaded_commentarium') || !get(g:, 'commentarium_enabled') || &cp
  finish
endif
g:loaded_commentarium = 1

# autoload
import autoload '../autoload/commentarium.vim'

# define mappings
nnoremap <silent> <unique> <script> <Plug>(commentarium-do) <ScriptCmd>commentarium.DoComment()<CR>
nnoremap <silent> <unique> <script> <Plug>(commentarium-undo) <ScriptCmd>commentarium.UndoComment()<CR>

# set mappings
if get(g:, 'commentarium_no_mappings') == 0
  if empty(mapcheck("<leader>/", "n"))
    nnoremap <leader>/ <Plug>(commentarium-do)
  endif
  if empty(mapcheck("<leader>?", "n"))
    nnoremap <leader>? <Plug>(commentarium-undo)
  endif
  command! CommentariumComment commentarium.DoComment()
  command! CommentariumUncomment commentarium.UndoComment()
endif
