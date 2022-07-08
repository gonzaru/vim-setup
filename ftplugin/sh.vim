" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" see $VIMRUNTIME/ftplugin/sh.vim
" sh
" :help ft-posix-syntax
let g:is_posix = 1
syntax on
" setlocal signcolumn=auto
setlocal number
setlocal cursorline
setlocal matchpairs-=<:>
setlocal nowrap
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal shiftround
setlocal expandtab
setlocal makeprg=sh\ -n\ %
nnoremap <buffer><F6> :call CycleSignsShowDebugInfo('sh','cur')<CR>
nnoremap <buffer><leader>ec :call CycleSignsShowDebugInfo('sh','cur')<CR>
nnoremap <buffer><F7> :call CycleSignsShowDebugInfo('sh','prev')<CR>
nnoremap <buffer><leader>ep :call CycleSignsShowDebugInfo('sh','prev')<CR>
nnoremap <buffer><F8> :call CycleSignsShowDebugInfo('sh','next')<CR>
nnoremap <buffer><leader>en :call CycleSignsShowDebugInfo('sh','next')<CR>
call matchadd('ColorColumn', '\%120v', 10)
