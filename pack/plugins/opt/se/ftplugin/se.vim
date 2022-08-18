vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded or se is not enabled
if exists("b:did_ftplugin_se") || get(g:, "se_enabled") == 0
  finish
endif
b:did_ftplugin_se = 1

# Se
setlocal statusline=b%n,w%{win_getid()}%h%=[SE]
setlocal winfixheight
setlocal winfixwidth
setlocal noconfirm
setlocal nocursorline
setlocal nocursorcolumn
setlocal nowrap
setlocal nospell
setlocal nolist
setlocal nosplitright
setlocal noswapfile
setlocal nobuflisted
setlocal buftype=nowrite
setlocal bufhidden=hide
if get(g:, 'se_no_mappings') == 0
  if empty(mapcheck("<ESC>", "n"))
    nnoremap <buffer><ESC> <Plug>(se-close)
  endif
  if empty(mapcheck("<CR>", "n"))
    nnoremap <buffer><CR> <Plug>(se-gofile-edit)
  endif
  if empty(mapcheck("<Space>", "n"))
    nnoremap <buffer><Space> <Plug>(se-gofile-editk)
  endif
  if empty(mapcheck("e", "n"))
    nnoremap <buffer>e <Plug>(se-gofile-edit)
  endif
  if empty(mapcheck("E", "n"))
    nnoremap <buffer>E <Plug>(se-gofile-edit)<Plug>(se-toggle)
  endif
  if empty(mapcheck("p", "n"))
    nnoremap <buffer>p <Plug>(se-gofile-pedit)
  endif
  if empty(mapcheck("P", "n"))
    nnoremap <buffer>P :pclose<CR>
  endif
  if empty(mapcheck("s", "n"))
    nnoremap <buffer>s <Plug>(se-gofile-split)
  endif
  if empty(mapcheck("S", "n"))
    nnoremap <buffer>S <Plug>(se-gofile-split)<Plug>(se-toggle)
  endif
  if empty(mapcheck("v", "n"))
    nnoremap <buffer>v <Plug>(se-gofile-vsplit)
  endif
  if empty(mapcheck("V", "n"))
    nnoremap <buffer>V <Plug>(se-gofile-vsplit)<Plug>(se-toggle)
  endif
  if empty(mapcheck("t", "n"))
    nnoremap <buffer>t <Plug>(se-gofile-tabedit)
  endif
  if empty(mapcheck("-", "n"))
    nnoremap <buffer>- <ScriptCmd>cursor(1, 1)<CR><Plug>(se-gofile-edit)
  endif
  if empty(mapcheck("r", "n"))
    nnoremap <buffer>r <Plug>(se-refresh)
  endif
  if empty(mapcheck("f", "n"))
    nnoremap <buffer>f <Plug>(se-followfile)
  endif
  if empty(mapcheck("<BS>", "n"))
    nnoremap <buffer><BS> :execute ":vertical resize " .. g:se_winsize<CR><ScriptCmd>cursor(line('.'), 1)<CR>
  endif
  if empty(mapcheck("=", "n"))
    nnoremap <buffer>= :execute ":vertical resize " .. g:se_winsize<CR><ScriptCmd>cursor(line('.'), 1)<CR>
  endif
  if empty(mapcheck("h", "n"))
    nnoremap <buffer>h <Plug>(se-help)
  endif
  if empty(mapcheck("K", "n"))
    nnoremap <buffer>K <Plug>(se-help)
  endif
endif
