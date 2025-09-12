vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(b:, "did_ftplugin_after")
  finish
endif
b:did_ftplugin_after = true

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
endif
if get(g:, "autoendstructs_enabled")
  inoremap <buffer> <nowait> <CR> <Plug>(autoendstructs-end)
endif
# setlocal colorcolumn=120
# matchadd('ColorColumn', '\%120v', 10)
if g:misc_enabled
  misc#MatchAdd({'group': 'ColorColumn', 'pattern': '\%120v', 'priority': 10})
endif
