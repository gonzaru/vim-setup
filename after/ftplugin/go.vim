vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# see $VIMRUNTIME/ftplugin/go.vim
#^ already done previously

# Go
setlocal syntax=ON
#^ setlocal formatoptions-=t
# setlocal signcolumn=auto
# setlocal number
# setlocal cursorline
setlocal nowrap
setlocal showbreak=NONE
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal shiftround
setlocal noexpandtab
#setlocal keywordprg=go\ doc
setlocal keywordprg=:GoKeywordPrg
# setlocal makeprg=gofmt\ -e\ %\ >/dev/null
setlocal makeprg=go\ build
# see :help gq (gqip, gggqG, ...). Also :help 'equalprg' (gg=G, ...)
setlocal formatprg=gofmt
if get(g:, "complementum_enabled")
  # inoremap <buffer> <nowait> <silent> . .<Plug>(complementum-insertautocomplete)
  var gofileproj = trim(system("dirname $(go env GOMOD)")) .. "/go-project.dict"
  if filereadable(gofileproj)
    execute $"setlocal dictionary^={gofileproj}"
  endif
  if filereadable(expand("$HOME/.vim/dict/go/go-stdlib.dict"))
    setlocal dictionary^=$HOME/.vim/dict/go/go-stdlib.dict
  endif
  if filereadable(expand("$HOME/.vim/tags/go/go-stdlib.tags"))
    setlocal tags+=$HOME/.vim/tags/go/go-stdlib.tags
  endif
endif
if get(g:, "lsp_enabled")
  setlocal omnifunc=lsp#OmniFunc
  # setlocal complete^=o^10
  if &autocomplete && !get(g:, "complementum_enabled")
    # inoremap <buffer> <nowait> <silent> <expr> . ".\<C-x>\<C-o>"
    inoremap <buffer> <nowait> <silent> <expr> . (getline('.')[col('.') - 2] =~ '\k') ? ".\<C-x>\<C-o>" : "."
  endif
endif
if get(g:, "autoendstructs_enabled")
  inoremap <buffer> <nowait> <CR> <Plug>(autoendstructs-end)
endif
# setlocal colorcolumn=120
# matchadd('ColorColumn', '\%120v', 10)
if g:misc_enabled
  misc#MatchAdd({'group': 'ColorColumn', 'pattern': '\%120v', 'priority': 10})
endif

# undo
b:undo_ftplugin = 'setlocal syntax< nowrap< tabstop< softtabstop< shiftwidth< shiftround< expandtab< keywordprg< makeprg< formatprg< dictionary< tags< omnifunc< complete< showbreak<'
b:undo_ftplugin ..= ' | silent! iunmap <buffer> <CR>'
