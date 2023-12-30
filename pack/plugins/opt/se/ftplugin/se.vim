vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded or se is not enabled
if get(b:, "did_ftplugin_se") || !get(g:, "se_enabled")
  finish
endif
b:did_ftplugin_se = true

# Se
setlocal statusline=%y:%<%{getcwd()->fnamemodify(':~')}%=b%n,w%{win_getid()}
setlocal winfixheight
setlocal winfixwidth
setlocal noconfirm
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
  nnoremap <buffer> <nowait> ~ <Plug>(se-godir-home)
  nnoremap <buffer> <nowait> r <Plug>(se-refresh)
  nnoremap <buffer> <nowait> f <Plug>(se-followfile)
  nnoremap <buffer> <nowait> l :execute "vertical resize "  .. (g:se_position == 'right' ? '-1' : '+1')<CR>
  nnoremap <buffer> <nowait> h :execute "vertical resize "  .. (g:se_position == 'right' ? '+1' : '-1')<CR>
  nnoremap <buffer> <nowait> o <Plug>(se-toggle-hidden)
  nnoremap <buffer> <nowait> <BS> :execute ":vertical resize " .. g:se_winsize<CR><ScriptCmd>cursor(line('.'), 1)<CR>
  nnoremap <buffer> <nowait> = :execute ":vertical resize " .. g:se_winsize<CR><ScriptCmd>cursor(line('.'), 1)<CR>
  nnoremap <buffer> <nowait> H <Plug>(se-help)
  nnoremap <buffer> <nowait> K <Plug>(se-help)
endif
