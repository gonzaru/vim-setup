" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" see $VIMRUNTIME/ftplugin/python.vim
" Python
syntax on
syntax region Comment start=/'''/ end=/'''/
syntax region Comment start=/"""/ end=/"""/
setlocal signcolumn=yes
setlocal number
setlocal cursorline
setlocal matchpairs-=<:>
setlocal suffixesadd=.py
setlocal wildignore+=*.pyc
setlocal nowrap
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal shiftround
setlocal expandtab
setlocal smartindent
setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class
setlocal omnifunc=python3complete#Complete
setlocal keywordprg=python3\ -m\ pydoc
setlocal makeprg=pep8\ %
nnoremap <buffer><leader>K :call Doc("python")<CR>:echo v:errmsg<CR>
nnoremap <buffer><F6> :call CycleSignsShowDebugInfo('py','cur')<CR>
nnoremap <buffer><F7> :call CycleSignsShowDebugInfo('py','prev')<CR>
nnoremap <buffer><F8> :call CycleSignsShowDebugInfo('py','next')<CR>
call matchadd('ColorColumn', '\%79v', 10)
