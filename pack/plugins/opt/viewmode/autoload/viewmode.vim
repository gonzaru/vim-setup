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
    D               # scroll forward (half screen) (centered)
    u               # scroll backward (half screen)
    U               # scroll backward (half screen) (centered)
    <Space>         # scroll forward (page)
    <S-Space>       # scroll backward (page)
    y               # scroll backward one line
    Y               # scroll backward one line (centered)
    <CR>            # scroll forward one line [e]
    <S-CR>          # scroll forward one line (centered) [E]
    =               # print the current line number
    s               # do forward incremental search
    r               # do reverse incremental search
    .               # set the mark
    @               # return to the mark
    q               # exit view mode
    Q               # exit view mode and make the buffer editable
  END
  echo join(lines, "\n")
enddef

# enable viewmode keys
export def Enable()
  setlocal nomodifiable readonly
  # move to the beggining of buffer
  nnoremap <buffer> < gg
  # move to the end of buffer
  nnoremap <buffer> > G
  nnoremap <buffer> o G
  nnoremap <buffer> % G
  # scroll forward (half screen)
  nnoremap <buffer> d <C-d>
  # scroll forward (half screen) (centered)
  nnoremap <buffer> D <C-d>zz
  # scroll backward (half screen)
  nnoremap <buffer> u <C-u>
  # scroll backward (half screen) (centerd)
  nnoremap <buffer> U <C-u>zz
  # scroll forward (page)
  nnoremap <buffer> <Space> <C-f>
  # scroll backward (page)
  nnoremap <buffer> <S-Space> <C-b>
  # scroll backward one line
  nnoremap <buffer> y <C-y>
  # scroll backward one line (centered)
  nnoremap <buffer> Y kzz
  # scroll forward one line
  nnoremap <buffer> <CR> <C-e>
  nnoremap <buffer> e <C-e>
  # scroll forward one line (centered)
  nnoremap <buffer> <S-CR> jzz
  nnoremap <buffer> E jzz
  # prints the current line number
  nnoremap <buffer> = <Cmd>echo "Line " .. line('.')<CR>
  # do forward incremental search
  nnoremap <buffer> s /
  # do reverse incremental search
  nnoremap <buffer> r ?
  # TODO check marks
  # set the mark
  nnoremap <buffer> . m'<Cmd>echo 'Mark set'<CR>
  # return to the mark
  nnoremap <buffer> @ `'
  # exit view mode
  nnoremap <buffer> q <ScriptCmd>Disable()<CR>
  # exit view mode and make the buffer editable
  nnoremap <buffer> Q <ScriptCmd>Disable()<CR><Cmd>setlocal modifiable noreadonly<CR>
enddef

# disable viewmode keys
export def Disable()
  silent! nunmap <buffer> <
  silent! nunmap <buffer> >
  silent! nunmap <buffer> o
  silent! nunmap <buffer> %
  silent! nunmap <buffer> d
  silent! nunmap <buffer> D
  silent! nunmap <buffer> u
  silent! nunmap <buffer> U
  silent! nunmap <buffer> <Space>
  silent! nunmap <buffer> <S-Space>
  silent! nunmap <buffer> e
  silent! nunmap <buffer> E
  silent! nunmap <buffer> y
  silent! nunmap <buffer> Y
  silent! nunmap <buffer> <CR>
  silent! nunmap <buffer> <S-CR>
  silent! nunmap <buffer> =
  silent! nunmap <buffer> s
  silent! nunmap <buffer> r
  silent! nunmap <buffer> .
  silent! nunmap <buffer> @
  silent! nunmap <buffer> q
  silent! nunmap <buffer> Q
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
