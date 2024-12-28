vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded or se is not enabled
if get(b:, "did_ftplugin_runprg") || !get(g:, "runprg_enabled")
  finish
endif
b:did_ftplugin_runprg = true

# runprg
setlocal statusline=%<\ %=b%{bufnr()},w%{win_getid()}\ %{&filetype}\ %{&fileencoding}[%{&fileformat}]\ %-15.(%l,%c%V%)\ %P
setlocal signcolumn=no
setlocal nonumber
setlocal norelativenumber
setlocal cursorline
setlocal nocursorcolumn
setlocal nowrap
setlocal nospell
setlocal nolist
setlocal winfixheight
setlocal winfixwidth
setlocal noswapfile
setlocal nobuflisted
setlocal nomodifiable
setlocal buftype=nowrite
setlocal bufhidden=wipe
