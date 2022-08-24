vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists("b:did_ftplugin_after")
  finish
endif
b:did_ftplugin_after = 1

# see $VIMRUNTIME/ftplugin/go.vim
#^ already done previously

# Go
setlocal syntax=on
#^ setlocal formatoptions-=t
# setlocal signcolumn=auto
setlocal number
setlocal cursorline
setlocal nowrap
setlocal showbreak=NONE
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal shiftround
setlocal noexpandtab
setlocal keywordprg=go\ doc
# setlocal makeprg=gofmt\ -e\ %\ >/dev/null
setlocal makeprg=go\ build
if get(g:, "documentare_enabled")
  if empty(mapcheck("<leader>K", "n"))
    nnoremap <buffer><leader>K <Plug>(documentare-doc)
  endif
endif
if get(g:, "complementum_enabled")
  if empty(mapcheck(".", "i"))
    inoremap <silent><buffer>. .<Plug>(complementum-goinsertautocomplete)
  endif
endif
matchadd('ColorColumn', '\%120v', 10)
