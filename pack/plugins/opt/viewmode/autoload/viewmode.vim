vim9script noclear
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_viewmode') || !get(g:, 'viewmode_enabled')
  finish
endif
g:autoloaded_viewmode = true

# help information
export def Help()
  var lines =<< trim END
    --              view mode (help)
    <               # move to the beggining of buffer
    >               # move to the end of buffer [o,%]
    d               # scroll forward (half screen)
    u               # scroll backward (half screen)
    <Space>         # scroll forward (page)
    <S-Space>       # scroll backward (page)
    y               # scroll backward one line
    <CR>            # scroll forward one line
    =               # print the current line number
    s               # do forward incremental search
    r               # do reverse incremental search
    .               # set the mark
    @               # return to the mark
    e               # exit view mode
    E               # exit view mode and make the buffer editable
  END
  echo join(lines, "\n")
enddef

# enable viewmode keys
export def Enable()
  # move to the beggining of buffer
  nnoremap < gg
  # move to the end of buffer
  nnoremap > G
  nnoremap o G
  nnoremap % G
  # scroll forward (half screen)
  nnoremap d <C-d>
  # scroll backward (half screen)
  nnoremap u <C-u>
  # scroll forward (page)
  nnoremap <Space> <C-f>
  # scroll backward (page)
  nnoremap <S-Space> <C-b>
  # scroll backward one line
  nnoremap y <C-y>
  # scroll forward one line
  nnoremap <CR> <C-e>
  # prints the current line number
  nnoremap = <Cmd>echo "Line " .. line('.')<CR>
  # do forward incremental search
  nnoremap s /
  # do reverse incremental search
  nnoremap r ?
  # TODO check marks
  # set the mark
  nnoremap . m'<Cmd>echo 'Mark set'<CR>
  # return to the mark
  nnoremap @ `'
  # exit view mode
  nnoremap e <ScriptCmd>Disable()<CR>
  # exit view mode and make the buffer editable
  nnoremap E <ScriptCmd>Disable()<CR><Cmd>setlocal noreadonly<CR>
enddef

# disable viewmode keys
export def Disable()
  nnoremap < <
  nnoremap > >
  nnoremap o o
  nnoremap % %
  nnoremap d d
  nnoremap u u
  nnoremap <Space> <Space>
  nnoremap <S-Space> <S-Space>
  nnoremap y y
  nnoremap <CR> <CR>
  nnoremap = =
  nnoremap s s
  nnoremap r r
  nnoremap . .
  nnoremap @ @
  nnoremap e e
  nnoremap E E
enddef

# toggle viewmode keys
export def Toggle()
  if g:viewmode_enabled
    Disable()
  else
    Enable()
  endif
  g:viewmode_enabled = !g:viewmode_enabled
  v:statusmsg = $"viewmode={g:viewmode_enabled}"
enddef
