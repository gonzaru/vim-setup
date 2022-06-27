" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" did_ftplugin_go_vim name to avoid collision with another plugins
" do not read the file if is already loaded
if exists("b:did_ftplugin_go_vim")
  finish
endif
let b:did_ftplugin_go_vim = 1

" see $VIMRUNTIME/ftplugin/go.vim
" Go
syntax on
setlocal formatoptions-=t
setlocal signcolumn=auto
setlocal number
setlocal cursorline
setlocal nowrap
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal shiftround
setlocal noexpandtab
setlocal keywordprg=go\ doc
" setlocal makeprg=gofmt\ -e\ %\ >/dev/null
setlocal makeprg=go\ build
nnoremap <buffer><leader>K :call Doc("go")<CR>:echo v:errmsg<CR>
nnoremap <buffer><F6> :call CycleSignsShowDebugInfo('go','cur')<CR>
nnoremap <buffer><leader>ec :call CycleSignsShowDebugInfo('go','cur')<CR>
nnoremap <buffer><F7> :call CycleSignsShowDebugInfo('go','prev')<CR>
nnoremap <buffer><leader>ep :call CycleSignsShowDebugInfo('go','prev')<CR>
nnoremap <buffer><F8> :call CycleSignsShowDebugInfo('go','next')<CR>
nnoremap <buffer><leader>en :call CycleSignsShowDebugInfo('go','next')<CR>
call matchadd('ColorColumn', '\%120v', 10)
