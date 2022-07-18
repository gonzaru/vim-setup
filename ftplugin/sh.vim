" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" see $VIMRUNTIME/ftplugin/sh.vim
" sh
" :help ft-posix-syntax
if getline(1) =~# "bash"
  let g:is_bash = 1
else
  let g:is_posix = 1
endif
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
if get(g:, "checker_enabled")
  nnoremap <buffer><F6> :call checker#CycleSignsShowDebugInfo('sh','cur')<CR>
  nnoremap <buffer><leader>ec :call checker#CycleSignsShowDebugInfo('sh','cur')<CR>
  nnoremap <buffer><F7> :call checker#CycleSignsShowDebugInfo('sh','prev')<CR>
  nnoremap <buffer><leader>ep :call checker#CycleSignsShowDebugInfo('sh','prev')<CR>
  nnoremap <buffer><F8> :call checker#CycleSignsShowDebugInfo('sh','next')<CR>
  nnoremap <buffer><leader>en :call checker#CycleSignsShowDebugInfo('sh','next')<CR>
endif
if get(g:, "autoendstructs_enabled")
  inoremap <buffer><CR> <Plug>(autoendstructs-end)
endif
call matchadd('ColorColumn', '\%120v', 10)
