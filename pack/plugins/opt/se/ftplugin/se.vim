vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded or se is not enabled
if get(b:, "did_ftplugin_se") || !get(g:, "se_enabled")
  finish
endif
b:did_ftplugin_se = true

# Se
setlocal syntax=ON
setlocal statusline=%y:%<%{getcwd()->fnamemodify(':~')}%=b%n,w%{win_getid()}
setlocal winfixheight
setlocal winfixwidth
setlocal winfixbuf
setlocal noconfirm
setlocal nonumber
setlocal norelativenumber
setlocal signcolumn=no
setlocal cursorline
setlocal nocursorcolumn
setlocal nowrap
setlocal nospell
setlocal nolist
setlocal nosplitright
setlocal noswapfile
setlocal nobuflisted
setlocal buftype=nofile
setlocal bufhidden=hide
if get(g:, 'se_no_mappings') == 0
  nnoremap <buffer> <nowait> q <Plug>(se-close)
  nnoremap <buffer> <nowait> <ESC> <Plug>(se-close)
  nnoremap <buffer> <nowait> <CR> <Plug>(se-gofile-edit)
  nnoremap <buffer> <nowait> <Space> <Plug>(se-gofile-editk)
  nnoremap <buffer> <nowait> e <Plug>(se-gofile-edit)
  nnoremap <buffer> <nowait> E <Plug>(se-gofile-edit)<Plug>(se-toggle)
  nnoremap <buffer> <nowait> p <Plug>(se-gofile-pedit)
  nnoremap <buffer> <nowait> P :pclose<CR>
  nnoremap <buffer> <nowait> s <Plug>(se-gofile-split)
  nnoremap <buffer> <nowait> S <Plug>(se-gofile-split)<Plug>(se-toggle)
  nnoremap <buffer> <nowait> v <Plug>(se-gofile-vsplit)
  nnoremap <buffer> <nowait> V <Plug>(se-gofile-vsplit)<Plug>(se-toggle)
  nnoremap <buffer> <nowait> t <Plug>(se-gofile-tabedit)
  nnoremap <buffer> <nowait> T <Plug>(se-gofile-tabedit)<Plug>(se-toggle)
  nnoremap <buffer> <nowait> - <Plug>(se-godir-parent)
  nnoremap <buffer> <nowait> b <Plug>(se-godir-parent)
  nnoremap <buffer> <nowait> ~ <Plug>(se-godir-home)
  nnoremap <buffer> <nowait> d <Plug>(se-godir-home)
  nnoremap <buffer> <nowait> a <Plug>(se-godir-prompt)
  nnoremap <buffer> <nowait> i <Plug>(se-toggle-dirsfirst-show)
  nnoremap <buffer> <nowait> y <Plug>(se-toggle-onlydirs-show)
  nnoremap <buffer> <nowait> Y <Plug>(se-toggle-onlyfiles-show)
  nnoremap <buffer> <nowait> r <Plug>(se-refresh)
  nnoremap <buffer> <nowait> f <Plug>(se-godir-prev)
  nnoremap <buffer> <nowait> F <Plug>(se-followfile)
  nnoremap <buffer> <nowait> h <Plug>(se-resize-left)
  nnoremap <buffer> <nowait> l <Plug>(se-resize-right)
  nnoremap <buffer> <nowait> = <Plug>(se-resize-restore)
  nnoremap <buffer> <nowait> + <Plug>(se-resize-maxcol)
  nnoremap <buffer> <nowait> c <Plug>(se-open-with-custom)
  nnoremap <buffer> <nowait> C <Plug>(se-open-with-default)
  nnoremap <buffer> <nowait> o <Plug>(se-toggle-hidden-position)
  nnoremap <buffer> <nowait> u <Plug>(se-toggle-perms-show)
  nnoremap <buffer> <nowait> m <Plug>(se-check-mime)
  nnoremap <buffer> <nowait> M <Plug>(se-set-mime)
  nnoremap <buffer> <nowait> . <Plug>(se-toggle-hidden-show)
  nnoremap <buffer> <nowait> H <Plug>(se-help)
  nnoremap <buffer> <nowait> K <Plug>(se-help)
  nnoremap <buffer> <nowait> w <Plug>(se-godir-git)
  nnoremap <buffer> <nowait> W <Plug>(se-godir-root)
  nnoremap <buffer> <nowait> z <Plug>(se-set-rootdir)
  nnoremap <buffer> <nowait> Z <Plug>(se-unset-rootdir)
endif
