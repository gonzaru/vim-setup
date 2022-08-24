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
nnoremap <silent> <unique> <script> <Plug>(commentarium-do) <ScriptCmd>commentarium.DoComment(line('.'), col('.'))<CR>
vnoremap <silent> <unique> <script> <Plug>(commentarium-do-range)
  \ <ESC><ScriptCmd>commentarium.DoCommentRange(line("'<"), line("'>"), getpos("v"))<CR>gv=
nnoremap <silent> <unique> <script> <Plug>(commentarium-undo) <ScriptCmd>commentarium.UndoComment(line('.'), col('.'))<CR>
vnoremap <silent> <unique> <script> <Plug>(commentarium-undo-range)
  \ <ESC><ScriptCmd>commentarium.UndoCommentRange(line("'<"), line("'>"), getpos("v"))<CR>gv=

# set mappings
if get(g:, 'commentarium_no_mappings') == 0
  if empty(mapcheck("<leader>/", "n"))
    nnoremap <leader>/ <Plug>(commentarium-do)
  endif
  if empty(mapcheck("<leader>/", "v"))
    vnoremap <leader>/ <Plug>(commentarium-do-range)
  endif
  if empty(mapcheck("<leader>?", "n"))
    nnoremap <leader>? <Plug>(commentarium-undo)
  endif
  if empty(mapcheck("<leader>?", "v"))
    vnoremap <leader>? <Plug>(commentarium-undo-range)
  endif
  if empty(mapcheck("<leader>*", "v"))
    vnoremap <leader>* <ESC>'<<ESC>O/*<ESC>'><ESC>o*/<ESC>
  endif
  if empty(mapcheck("<leader><", "v"))
    vnoremap <leader>< <ESC>'<<ESC>O<!--<ESC>'><ESC>o--><ESC>
  endif
endif

# TODO: undo
# // comment1
# // comment2
# // ...
# vnoremap <leader>\ <ESC>:'<,'>s/\/\///g<ESC>gv=

# set commands
if get(g:, 'commentarium_no_commands') == 0
  command! CommentariumComment commentarium.DoComment(line('.'), col('.'))
  command! -range CommentariumCommentRange {
    commentarium.DoCommentRange(<line1>, <line2>, getpos('.'))
    normal! <line1>G=<line2>G
  }
  command! CommentariumUncomment commentarium.UndoComment(line('.'), col('.'))
  command! -range CommentariumUncommentRange {
    commentarium.UndoCommentRange(<line1>, <line2>, getpos('.'))
    normal! <line1>G=<line2>G
  }
endif
