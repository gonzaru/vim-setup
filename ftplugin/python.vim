" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" see $VIMRUNTIME/ftplugin/python.vim
" Python
syntax on
syntax region Comment start=/'''/ end=/'''/
syntax region Comment start=/"""/ end=/"""/
" setlocal signcolumn=auto
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
if get(g:, "checker_enabled")
  nnoremap <buffer><leader>K :call misc#Doc("python")<CR>:echo v:errmsg<CR>
  nnoremap <buffer><F6> :call checker#CycleSignsShowDebugInfo('python','cur')<CR>
  nnoremap <buffer><leader>ec :call checker#CycleSignsShowDebugInfo('python','cur')<CR>
  nnoremap <buffer><F7> :call checker#CycleSignsShowDebugInfo('python','prev')<CR>
  nnoremap <buffer><leader>ep :call checker#CycleSignsShowDebugInfo('python','prev')<CR>
  nnoremap <buffer><F8> :call checker#CycleSignsShowDebugInfo('python','next')<CR>
  nnoremap <buffer><leader>en :call checker#CycleSignsShowDebugInfo('python','next')<CR>
endif
call matchadd('ColorColumn', '\%79v', 10)
