vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_echords') || !get(g:, 'echords_enabled')
  finish
endif
g:autoloaded_echords = true

# some references:
# https://www.gnu.org/software/emacs/refcards/pdf/refcard.pdf

# enable echords keys
export def Enable()

  # TODO: check all C-S-* for terminal

  # TODO: the M-key works well with gui, but does not in terminal

  # TODO: terminal maps

  # TODO: nnoremap?

  # TODO: vnoremap?

  # TODO: onoremap?

  # TODO: more maps
  # https://www.gnu.org/software/emacs/manual/html_node/emacs/Shift-Selection.html
  # when Shift modifier, it triggers a built-in feature called shift-select-mode

  # TODO: delete all spaces and tabs at point
  # M-\

  # go to functions
  # M-?  (xref-find-references)

  # TODO:
  # C-M-b move backward sexp
  # C-M-f move forward sexp
  # C-M-u
  # C-M-p
  # C-M-n

  # TODO: set-fill-column
  # C-x f

  # TODO: bookmarks
  # C-x r m              bookmark-set
  # C-x r b              bookmark-jump
  # C-x r SPC            point-to-register
  # C-x r j              jump-to-register

  # TODO: help commands
  # <C-h>i
  # <C-h>f
  # <C-h>v

  # TODO: evaluate expression
  # <C-x><C-e>
  # <M-:> # see the file

  # TODO: show all lines in the current buffer containing a match
  # <M-s>o

  # TODO: add more search
  # M-s w
  # M-s _
  # M-s .
  # M-s M-.

  # TODO: mark defun (put mark at end of this defun, point at beginning)
  # <C-H-h>

  # TODO: check all :help popupmenu-keys

  # go to line beginning
  # collision: i_CTRL-A insert previously inserted text
  # inoremap <C-a> <C-o>0
  # inoremap <C-a> <C-o>^
  # inoremap <C-a> <Home>
  inoremap <C-a> <ScriptCmd>MoveBeginningOfLine()<CR>
  if g:echords_visual_mappings
    # collision: v_CTRL-A add [count] to the number
    vnoremap <C-a> ^
  endif
  if g:echords_normal_mappings
    # collision: CTRL-A add [count] to the number
    nnoremap <C-a> ^
  endif
  # go to line beginning + select
  if has('gui_running')
    inoremap <C-S-a> <C-o>v0
  else
    # <F13> is mapped to <C-S-a>
    inoremap <F13> <C-o>v0
  endif
  # use <C-x><C-a> to use the builtin <C-a>
  inoremap <C-x><C-a> <C-a>
  if g:echords_command_mappings
    # collision: c_CTRL-A all names that match the pattern in front of the cursor are inserted (default: <C-b>)
    cnoremap <C-a> <Home>
    # use <C-x><C-a> to use the builtin <C-a>
    cnoremap <C-x><C-a> <C-a>
  endif

  # go to line end
  # collision: i_CTRL-E insert the character which is below the cursor
  # inoremap <C-e> <C-o>$
  # inoremap <expr> <C-e> pumvisible() ? "\<C-e>" : "\<C-o>$"
  # see complementum map with <C-e>
  # if !get(g:, 'complementum_enabled')
  #   inoremap <expr> <C-e> pumvisible() <bar><bar> preinserted() ? "\<C-e>" : "\<End>"
  # endif
  # inoremap <C-e> <End>
  inoremap <expr> <C-e> pumvisible() ? "\<C-e>" : "\<End>"
  if g:echords_visual_mappings
    vnoremap <C-e> $
  endif
  if g:echords_normal_mappings
    # collision: CTRL-E scroll window [count] lines downwards
    # TODO: alternative key for scroll
    nnoremap <C-e> $
  endif

  # go to line end + select
  if has('gui_running')
    inoremap <C-S-e> <C-o>v$
  else
    # <F14> is mapped to <C-S-e>
    inoremap <F14> <C-o>v$
  endif
  # it goes by default
  if g:echords_command_mappings
    cnoremap <C-e> <End>
  endif

  # collision: i_CTRL-Q (same as i_CTRL-V, insert next non-digit literally)
  inoremap <C-q> <C-o>
  # add new line below
  inoremap <C-o> <C-o>o
  # add new line above
  if has('gui_running')
    inoremap <C-S-o> <C-o>O
  endif

  # mark set
  if has('gui_running')
    inoremap <C-Space> <C-o>v
    if g:echords_normal_mappings
      nnoremap <C-Space> v
    endif
  else
    inoremap <C-@> <C-o>v
    if g:echords_normal_mappings
      nnoremap <C-@> v
    endif
  endif
  if has('gui_running')
    # collision: i_CTRL-@ insert previously inserted text and stop insert
    inoremap <C-S-@> <C-o>v
  endif

  # mark entire buffer
  inoremap <C-x>h <Cmd>normal! ggVG<CR>

  # go to last edit position
  if has('gui_running')
    inoremap <C-u><C-Space> <C-o>g;
  else
    inoremap <C-u><C-@> <C-o>g;
  endif

  # exchange point and mark (implies vnoremap)
  if g:echords_visual_mappings
    vnoremap <C-x><C-x> o
  endif

  # set mark args words away M-@ (M-S-@)
  inoremap <M-@> <C-o>ve

  # interactive replace a text string (current line to end of the buffer)
  # inoremap <M-%> <C-o>:.,$///gc<Left><Left><Left><Left>
  inoremap <M-%> <ScriptCmd>QueryReplace()<CR>

  # check spelling of current word
  inoremap <M-$> <ScriptCmd>SpellWord()<CR>

  # fill paragraph
  inoremap <M-q> <Cmd>normal! gwap<CR>
  if g:echords_visual_mappings
    vnoremap <M-q> gw
  endif

  # go to line beginning (non-blank)
  inoremap <M-m> <C-o>^
   if g:echords_normal_mappings
    nnoremap <M-m> ^
  endif
  # go to line beginning (non-blank) + select
  inoremap <M-S-m> <C-o>v^

  # go to sentence backward
  inoremap <M-a> <C-o>(
  if g:echords_normal_mappings
    nnoremap <M-a> (
  endif
  # go to sentence backward + select
  inoremap <M-S-a> <C-o>v(

  # go to sentence forward
  inoremap <M-e> <C-o>)
  if g:echords_normal_mappings
    nnoremap <M-e> )
  endif
  # go to sentence forward + select
  inoremap <M-S-e> <C-o>v)

  # kill to start of sentence
  inoremap <C-x><BackSpace> <C-o>d(

  # kill to end of sentence
  inoremap <M-k> <C-o>d)

  # go to paragraph backward
  inoremap <M-{> <C-o>{
  inoremap <C-Up> <C-o>{
  if g:echords_normal_mappings
    nnoremap <M-{> {
    nnoremap <C-Up> {
  endif
  # go to paragraph backward + select
  if has('gui_running')
    inoremap <C-S-Up> <C-o>v{
  else
    inoremap <F18> <C-o>v{
  endif

  # go to paragraph forward
  inoremap <M-}> <C-o>}
  inoremap <C-Down> <C-o>}
  if g:echords_normal_mappings
    nnoremap <M-}> }
    nnoremap <C-Down> }
  endif
  # go to paragraph forward + select
  if has('gui_running')
    inoremap <C-S-Down> <C-o>v}
  else
    inoremap <F19> <C-o>v}
  endif

  # TODO: recheck method up/down
  # method up
  inoremap <C-M-a> <C-o>[m
  inoremap <C-M-Home> <C-o>[m
  if g:echords_normal_mappings
    nnoremap <C-M-a> [m
    nnoremap <C-M-Home> [m
  endif
  # method down
  inoremap <C-M-e> <C-o>]m
  inoremap <C-M-End> <C-o>]m
  if g:echords_normal_mappings
    nnoremap <C-M-e> ]m
    nnoremap <C-M-End> ]m
  endif

  # goto previous line
  # collision: i_CTRL-P completion find the previous match
  # TODO: is ignored with omni (C-x C-o)
  # inoremap <C-p> <Up>
  # inoremap <expr> <C-p> pumvisible() <bar><bar> preinserted() ? "\<C-p>" : "\<Up>"
  # inoremap <expr> <C-p> pumvisible() ? "\<C-e>\<Up>" : "\<Up>"
  inoremap <expr> <C-p> pumvisible() ? "\<C-p>" : "\<Up>"
  # inoremap <expr> <C-p>
  # \ pumvisible() && get(g:, 'loaded_complementum')
  # \ ? "\<Up>"
  # \ : pumvisible()
  # \ ? "\<C-p>"
  # \ : "\<Up>"
  if g:echords_normal_mappings
    nnoremap <C-p> k
  endif

  # goto previous line + select
  if has('gui_running')
    # inoremap <C-S-p> <C-o>v0k
    inoremap <expr> <C-S-p> pumvisible() ? "\<C-e>\<C-o>k" : "\<C-o>v0k"
  else
    # inoremap <F22> <C-o>v0k
    inoremap <expr> <F22> pumvisible() ? "\<C-e>\<C-o>k" : "\<C-o>v0k"
  endif
  # select previous line
  if g:echords_visual_mappings
    vnoremap <C-p> k
  endif

  # goto next line
  # collision: i_CTRL-N completion find the next match
  # TODO: is ignored with omni (C-x C-o)
  # inoremap <C-n> <Down>
  # inoremap <expr> <C-n> pumvisible() <bar><bar> preinserted() ? "\<C-n>" : "\<Down>"
  # inoremap <C-n> <Down>
  # inoremap <expr> <C-n> pumvisible() ? "\<C-e>\<Down>" : "\<Down>"
  inoremap <expr> <C-n> pumvisible() ? "\<C-n>" : "\<Down>"
  # inoremap <expr> <C-n>
  # \ pumvisible() && get(g:, 'loaded_complementum')
  # \ ? "\<Down>"
  # \ : pumvisible()
  # \ ? "\<C-n>"
  # \ : "\<Down>"
  if g:echords_normal_mappings
    nnoremap <C-n> j
  endif

  # goto next line + select
  if has('gui_running')
    # inoremap <C-S-n> <C-o>v$j
    inoremap <expr> <C-S-n> pumvisible() ? "\<C-e>\<C-o>j" : "\<C-o>v$j"
  else
    # inoremap <F21> <C-o>v$j
    inoremap <expr> <F21> pumvisible() ? "\<C-e>\<C-o>j" : "\<C-o>v$j"
  endif
  # select next line
  if g:echords_visual_mappings
    vnoremap <C-n> j
  endif

  # isearch forward
  # collision with <leader> <C-s>
  inoremap <C-s><C-s> <C-\><C-n>/
  if g:echords_normal_mappings
    nnoremap <C-s><C-s> /
  endif

  # search the current word or char forward
  inoremap <C-s><C-w> <C-\><C-n>*

  # isearch backward
  # collision with i_CTRL-R_CTRL-R insert the contents of a register. (like i_CTLR-R, but inserted literally)
  inoremap <C-r><C-r> <C-\><C-n>?
  if g:echords_normal_mappings
    # collision with CTRL-R_CTRL-R insert the contents of a register. (like CTLR-R, but inserted literally)
    nnoremap <C-r><C-r> ?
  endif

  # search the current word or char backward
  inoremap <C-r><C-w> <C-\><C-n>#

  # write
  # collision with i_CTRL_X_s and i_CTRL_X i_CTRL_X_s locate the word in front of the cursor and first the first spell suggestion for it
  # save-some-buffers, this saves all the buffers
  inoremap <C-x>s <Cmd>wall<CR>
  # save-buffer, this saves only the current buffer
  inoremap <C-x><C-s> <Cmd>update<CR>

  # revert the buffer quick
  inoremap <C-x>xg <Cmd>e!<CR>

  # go to directory
  inoremap <C-x>d <C-\><C-n><ScriptCmd>feedkeys(":edit " .. expand('%:p:~:h') .. $"{expand('%:p:h') == '/' ? '' : '/'}")<CR>

  # find file
  # collision with i_CTRL_X_CTRL-F search for the first file name that starts with the same characters as before the cursor
  inoremap <C-x><C-f> <C-\><C-n>:edit<Space>

  # save buffers and kill terminal (exit)
  # inoremap <C-x><C-c> <Cmd>confirm qa<CR>

  # edit the current directory
  inoremap <C-x><C-j> <C-\><C-n><Cmd>edit .<CR>
  if g:echords_extra_mappings
    inoremap <C-x>j <C-\><C-n><Cmd>edit .<CR>
  endif

  # write file
  inoremap <C-x><C-w> <C-\><C-n><ScriptCmd>feedkeys(":write " .. expand('%:p:~:h') .. $"{expand('%:p:h') == '/' ? '' : '/'}")<CR>

  # transpose characters
  # collision: i_CTRL-T insert one shiftwidth of indent at the start of the current line
  # TODO: looks a little different
  # TODO: builtin <C-t> it's very useful
  inoremap <C-t> <Cmd>normal! xp<CR>

  # transpose words
  inoremap <M-t> <C-o>dw<C-o>e<Right><Space><C-o>p<Left>

  # transpose lines
  # collision: i_CTRL-X i_CTRL-T like completion thesaurus dictionary
  inoremap <C-x><C-t> <Cmd>normal! ddp<CR>

  # TODO: transpose sexps
  # inoremap <C-M-t>

  # character backward
  inoremap <C-b> <Left>
  # TODO: problem with plugin cmplwild (when popup menu)
  # collision: c_CTRL-B cursor to beginning of command-line <Home>
  if g:echords_command_mappings
    cnoremap <C-b> <Left>
  endif
  if g:echords_visual_mappings
    vnoremap <expr> <C-b> col('.') == 1 ? "k$" : "h"
  endif
  if g:echords_normal_mappings
    # collison: CTRL-F scroll window [count] pages backwards (backwards) <PageUp>
    nnoremap <C-b> h
  endif

  # character forward
  # collision: i_CTRL-F characters that can precede each key
  inoremap <C-f> <Right>
  if g:echords_command_mappings
    # collision: c_CTRL-F open the command-line window
    cnoremap <C-f> <Right>
    # use <C-x><C-f> to use the vim builtin <C-f>
    cnoremap <C-x><C-f> <C-f>
  endif
  if g:echords_visual_mappings
    vnoremap <expr> <C-f> col('.') >= col('$') - 1 ? "j0" : "l"
  endif
  if g:echords_normal_mappings
    # collison: CTRL-F scroll window [count] pages forwards (downwards) <PageDown>
    nnoremap <C-f> l
  endif

  # word backward
  # inoremap <M-b> <S-Left>
  inoremap <M-b> <C-o>b
  inoremap <M-Left> <C-o>b
  inoremap <C-Left> <C-o>b
  if g:echords_command_mappings
    cnoremap <M-b> <S-Left>
  endif
  if g:echords_visual_mappings
    vnoremap <M-b> b
  endif
  if g:echords_normal_mappings
    nnoremap <M-b> b
  endif

  # word forward
  # inoremap <M-f> <S-Right>
  inoremap <M-f> <C-o>e<Right>
  inoremap <M-Right> <C-o>e<Right>
  inoremap <C-Right> <C-o>e<Right>
  if g:echords_command_mappings
    cnoremap <M-f> <S-Right>
  endif
  if g:echords_visual_mappings
    vnoremap <M-f> e
  endif
  if g:echords_normal_mappings
    nnoremap <M-f> e
  endif

  # delete character backward
  # same as vim <DEL> = <BackSpace>
  # delete character forward
  # collision: i_CTRL_D delete one shiftwidth of indent at the start of the current line
  # inoremap <C-d> <C-o>x
  inoremap <C-d> <Del>
  if g:echords_command_mappings
    # collision: c_CTRL-D list names that match the pattern in front of the cursor
    cnoremap <C-d> <Del>
    cnoremap <M-d> <S-Right><C-w>
  endif

  # delete word backward
  inoremap <M-BackSpace> <C-w>
  inoremap <C-BackSpace> <C-w>
  if g:echords_command_mappings
    cnoremap <M-BackSpace> <C-w>
    cnoremap <C-BackSpace> <C-w>
  endif

  # delete the whole line
  if has('gui_running')
    # inoremap <C-S-BackSpace> <C-o>0<C-o>dd
    inoremap <C-S-BackSpace> <Cmd>normal! 0d$<CR>
  endif

  # TODO: check
  # delete word forward
  inoremap <M-d> <C-o>dw
  inoremap <C-Delete> <C-o>dw

  # delete line backward
  # default <C-u> already does it
  # TODO: map to <M-0> fails
  # inoremap <M-0><C-k> <C-u>
  # inoremap <M--><C-k> <C-u>
  # inoremap <C-0><C-k> <C-u>

  # delete line forward
  # collision: i_CTRL_K enter digraph
  # inoremap <C-k> <C-o>d$
  inoremap <expr> <C-k> col('.') == col('$') ? "\<Cmd>normal! gJ\<CR>" : "\<Cmd>normal! d$\<CR>"
  if has('gui_running')
    inoremap <expr> <C-S-k> empty(trim(getline('.'))) ? "\<Cmd>normal! dd\<CR>" : "\<Cmd>normal! d$\<CR>"
  endif
  if g:echords_command_mappings
    # collision: c_CTRL-K enter diagraph
    # cnoremap <C-k> <ScriptCmd>setcmdline("")<CR>
    cnoremap <C-k> <ScriptCmd>DeleteCmdLine()<CR>
  endif

  # yank
  # recheck alternative to == (formating)
  # collision: i_CTRL_Y insert the character which is above the cursor
  # inoremap <C-y> <C-o>p<C-o>==
  inoremap <expr> <C-y> pumvisible() <bar><bar> preinserted() ? "\<C-y>" : "\<C-r>\<C-p>\""
  if g:echords_command_mappings
    # collision: c_CTRL-Y when there is a modeless selection, copy the selection into the clipboard
    # cnoremap <C-y> <C-r>*
    # cnoremap <C-y> <C-r>+
    cnoremap <C-y> <C-r>"
  endif

  # paste interactive (yank-pop)
  inoremap <M-y> <C-x><C-r>

  # kill ring save (copy selection)
  if g:echords_visual_mappings
    vnoremap <M-w> y
  endif

  # kill region (cut selection)
  if g:echords_visual_mappings
    vnoremap <C-w> d
  endif

  # indent region
  if g:echords_visual_mappings
    vnoremap <C-M-\> =
  endif

  # undo
  # inoremap <C-/> <C-o>u
  # inoremap <C-x>u <C-o>u
  # inoremap <C-S-_> <C-e>
  inoremap <C-/> <Cmd>undo<CR>
  inoremap <C-x>u <Cmd>undo<CR>
  inoremap <Undo> <Cmd>undo<CR>
  # collision: i_CTRL-_ switch between languages
  if has('gui_running')
   inoremap <C-S-_> <Cmd>undo<CR>
  else
   inoremap <F15> <Cmd>undo<CR>
  endif

  # redo (undo-redo)
  # inoremap <C-M-S-_> <C-o><C-r>
  if has('gui_running')
    inoremap <C-M-S-_> <Cmd>redo<CR>
  else
    inoremap <F17> <Cmd>redo<CR>
  endif
  if has('gui_running')
    inoremap <C-S-?> <Cmd>redo<CR>
  else
    inoremap <F16> <Cmd>redo<CR>
  endif

  # select another buffer
  # TODO: list etc
  # inoremap <C-x>b <C-o>:bprevious
  # inoremap <C-x>b <C-\><C-n>:b<Space>
  inoremap <C-x>b <C-\><C-n><ScriptCmd>feedkeys(":buffer " .. fnamemodify(bufname('#'), ":~"))<CR>

  # list all buffers
  inoremap <C-x><C-b> <Cmd>ls<CR>

  # delete a buffer
  inoremap <C-x>k <C-o>:bdelete<Space>

  # go to mini buffer M-x
  inoremap <M-x> <C-\><C-n>:

  # eval expression
  # inoremap <M-:> <C-\><C-n>:

  # tags
  # find a tag (xref-find-definitions)
  inoremap <M-.> <C-o><C-]>
  # find a tag (a definition) in other window
  inoremap <C-x>4. <Cmd>wincmd }<CR>
  if g:echords_normal_mappings
    nnoremap <M-.> <C-]>
    nnoremap <C-x>4. <C-w>}
  endif

  # go back (xref-go-back)
  inoremap <M-,> <C-o><C-t>
  if g:echords_normal_mappings
    nnoremap <M-,> <C-t>
  endif

  # shells / terminal
  # execute a shell command
  inoremap <M-!> <C-o>:!
  # execute a shell command asynchronously
  inoremap <M-&> <ScriptCmd>AsyncShellCmd()<CR>

  # M-num numeric arguments (C-u num)
  inoremap <M-1> <C-o>1
  inoremap <M-2> <C-o>2
  inoremap <M-3> <C-o>3
  inoremap <M-4> <C-o>4
  inoremap <M-5> <C-o>5
  inoremap <M-6> <C-o>6
  inoremap <M-7> <C-o>7
  inoremap <M-8> <C-o>8
  inoremap <M-9> <C-o>9
  # C-num numeric arguments (C-u num)
  if has('gui_running')
    inoremap <C-1> <C-o>1
    inoremap <C-2> <C-o>2
    inoremap <C-3> <C-o>3
    inoremap <C-4> <C-o>4
    inoremap <C-5> <C-o>5
    inoremap <C-6> <C-o>6
    inoremap <C-7> <C-o>7
    inoremap <C-8> <C-o>8
    inoremap <C-9> <C-o>9
  endif

  # TODO: map to this? (undefined by default)
  ### inoremap <M-p> <Up>
  ### inoremap <M-n> <Down>
  if g:echords_command_mappings
    cnoremap <M-p> <Up>
    cnoremap <M-n> <Down>
  endif

  # scroll down
  # collision: i_CTRL_V insert non-digit literally
  # inoremap <C-v> <C-o><C-d>
  inoremap <C-v> <PageDown>
  if g:echords_normal_mappings
    # collision: CTRL-V start visual mode blockwise
    nnoremap <C-v> <PageDown>
    # add leader as alternative
    nnoremap <leader><C-v> <C-v>
  endif

  # scroll up
  # inoremap <M-v> <C-o><C-u>
  inoremap <M-v> <PageUp>
  if g:echords_normal_mappings
    nnoremap <M-v> <PageUp>
  endif

  # scroll current line top, center, bottom  (zz, zb, zt)
  # collision: i_CTRL_L when 'insertmode' is set, go to noremal mode
  # inoremap <C-l> <ScriptCmd>ScrollTo()<CR>
  inoremap <expr> <C-l> pumvisible() ? "\<C-l>" : "\<ScriptCmd>ScrollTo()\<CR>"
  if g:echords_normal_mappings
    # collision: CTRL-L clear and redraw the screen
    nnoremap <C-l> <ScriptCmd>ScrollTo()<CR>
  endif

  # move between top, middle, bottom of window
  inoremap <M-r> <ScriptCmd>CursorTo()<CR>
  if g:echords_normal_mappings
    nnoremap <M-r> <ScriptCmd>CursorTo()<CR>
  endif

  # TODO
  # scroll left, right

  # kill through next occurence of char (zap to char)
  inoremap <M-z> <ScriptCmd>ZapToChar()<CR>

  # uppercase word
  inoremap <M-u> <C-o>gUw

  # lowercase word
  inoremap <M-l> <C-o>guw

  # TODO: first non blank "_" or up/down "+" "-"
  # capitalize word
  inoremap <M-c> <C-o>~

  # set the buffer in read only (toggle)
  inoremap <C-x><C-q> <Cmd>setlocal ro!<CR>

  # goto line
  # TODO: add message "Goto line: "
  inoremap <M-g>g <C-o>:
  inoremap <M-g><M-g> <C-o>:
  if g:echords_normal_mappings
    nnoremap <M-g>g :
    nnoremap <M-g><M-g> :
  endif

  # TODO: errors
  # go to next error
  # <M-g>n
  # go to previous error
  # <M-g>p

  # go to buffer beginning
  inoremap <M-<> <Cmd>normal! 1G0<CR>
  inoremap <C-Home> <Cmd>normal! 1G0<CR>
  if g:echords_normal_mappings
    nnoremap <M-<> gg
    nnoremap <C-Home> gg
  endif

  # go to buffer end
  inoremap <M->> <Cmd>normal! G$<CR>
  inoremap <C-End> <Cmd>normal! G$<CR>
  if g:echords_normal_mappings
    nnoremap <M->> G
    nnoremap <C-End> G
  endif

  # abbreviations (all buffers)
  # expand previous word
  # inoremap <M-/> <C-p>
  # TODO: check if <C-n> or <C-o>
  inoremap <expr> <M-/> pumvisible() <bar><bar> preinserted() ? "\<C-e>\<C-p>" : "\<C-p>"

  # abbreviations (current buffer)
  # expand previous word
  # inoremap <C-M-/> <C-x><C-p>
  # inoremap <expr> <C-M-/> pumvisible() ? "\<C-e>\<C-x>\<C-p>" : "\<C-x>\<C-p>"

  # windows

  # close this window
  inoremap <C-x>0 <Cmd>close<CR>
  if g:echords_normal_mappings
    nnoremap <C-x>0 <C-w>c
  endif

  # delete all other windows (only)
  inoremap <C-x>1 <Cmd>only<CR>
  if g:echords_normal_mappings
    nnoremap <C-x>1 <C-w>o
  endif

  # split window horizontal
  inoremap <C-x>2 <Cmd>split<CR>
  if g:echords_normal_mappings
    nnoremap <C-x>2 <C-w>s
  endif

  # split window vertical
  inoremap <C-x>3 <Cmd>vsplit<CR>
  if g:echords_normal_mappings
    nnoremap <C-x>3 <C-w>v
  endif

  # switch cursor to another window forward
  inoremap <C-x>o <Cmd>wincmd w<CR>
  if g:echords_normal_mappings
    nnoremap <C-x>o <C-w>w
  endif

  # switch cursor to another window backward
  inoremap <C-x>O <Cmd>wincmd W<CR>
  if g:echords_normal_mappings
    nnoremap <C-x>O <C-w>W
  endif

  # resize vertical equal window
  inoremap <C-x>+ <Cmd>wincmd =<CR>
  if g:echords_normal_mappings
    nnoremap <C-x>+ <C-w>=
  endif

  # shrink window narrower
  inoremap <C-x>{ <Cmd>wincmd <<CR>
  if g:echords_normal_mappings
    nnoremap <C-x>{ <C-w><
  endif

  # grow window wider
  inoremap <C-x>} <Cmd>wincmd ><CR>
  if g:echords_normal_mappings
    nnoremap <C-x>} <C-w>>
  endif

  # TODO: shrink window if larger than buffer
  # C-x -

  # TODO: recheck
  # grow window taller
  inoremap <C-x>^ <Cmd>wincmd +<CR>
  if g:echords_normal_mappings
    nnoremap <C-x>^ <C-w>+
  endif

  # scroll other window forward
  inoremap <C-M-v> <Cmd>wincmd w<CR><PageDown><Cmd>wincmd W<CR>
  if g:echords_normal_mappings
    nnoremap <C-M-v> <C-w>w<PageDown><C-w>W
  endif

  # scroll other window backward
  if has('gui_running')
    inoremap <C-M-S-v> <Cmd>wincmd w<CR><PageUp><Cmd>wincmd W<CR>
    if g:echords_normal_mappings
      nnoremap <C-M-S-v> <C-w>w<PageUp><C-w>W
    endif
  else
    inoremap <F20> <Cmd>wincmd w<CR><PageUp><Cmd>wincmd W<CR>
    if g:echords_normal_mappings
      nnoremap <F20> <C-w>w<PageUp><C-w>W
    endif
  endif

  # TODO: recheck
  # find file other window
  inoremap <C-x>4<C-f> <C-o>:split<Space>

  # formatting
  # delete indentation
  # inoremap <M-^> <Up><End><C-o>J
  inoremap <M-^> <Cmd>normal! gJ<CR>

  # TODO? add command?

  # TODO
  # folds

  # macros
  # recording 'z' as a tmp macro register
  inoremap <C-x>( <ScriptCmd>setreg('z', 'a')<CR><C-\><C-n>qZa
  inoremap <C-x>) <C-o>q
  # collision: i_CTRL-e insert the character which is below the cursor
  inoremap <C-x>e <C-\><C-n>@z

  # abort
  # collision: i_CTRL_G don't start a new undo block with the next left/right cursor movement
  # inoremap <C-g> <C-c>
  # inoremap <C-g> <C-\><C-n>
  inoremap <expr> <C-g> pumvisible() <bar><bar> preinserted() ? "\<C-e>" : "\<C-\>\<C-n>"
  if g:echords_command_mappings
    # collision: c_CTRL-g when 'incsearch' is set, entering a search pattern for '/' or '?' move to the next match
    cnoremap <C-g> <C-c><Esc>
  endif
  # collision: v_CTRL-g (several options)
  if g:echords_visual_mappings
    vnoremap <C-g> <Esc>gV
  endif
  if g:echords_operator_mappings
    onoremap <C-g> <Esc>
  endif
  if g:echords_normal_mappings
    nnoremap <C-g> <Esc>
  endif

  # TODO: add more
  # extras
  if g:echords_extra_mappings

    # leader
    # imap: recursive map for <leader>
    imap <C-x><C-x> <C-\><C-n><leader>

    # M-x
    inoremap <C-x><CR> <C-\><C-n>:
    inoremap <C-x><C-m> <C-\><C-n>:

    if g:echords_normal_mappings
        nnoremap <M-x> :
    endif

    # go to alternate buffer
    # collision: i_CTRL_^ toggle to use of typing language characters
    inoremap <C-^> <Cmd>buffer#<CR>

    # delete current buffer
    inoremap <C-x>K <Cmd>bdelete<CR>

    # begin a new line below the cursor
    inoremap <M-o> <C-o>o

    # begin a new line above the cursor
    inoremap <M-S-o> <C-o>O

    # duplicate line
    inoremap <leader>ed <Cmd>normal! ^yyp<CR>

    # copy line
    inoremap <leader>ew <Cmd>normal! ^yy<CR>

    # copy from above
    inoremap <leader>eP <Cmd>normal! k^yyp<CR>

    # join line
    inoremap <leader>eJ <C-o>J

    # prints the current file name and the cursor position
    inoremap <C-x>= <Cmd>file<CR>

    # count words
    inoremap <leader>e= <Cmd>echo wordcount()<CR>

    # zap up to char
    inoremap <leader>ez <ScriptCmd>ZapUpToChar()<CR>
  endif

  # TODO: recheck terminal maps to disable section
  # terminal

  if g:echords_terminal_mappings
    # word backward
    tnoremap <M-b> <Esc>b

    # word forward
    tnoremap <M-f> <Esc>f

    # delete character backward
    tnoremap <C-d> <Del>

    # delete word forward
    tnoremap <M-d> <Esc>d

    # move
    tnoremap <M-p> <Up>
    tnoremap <M-n> <Down>

    # delete word backward
    tnoremap <M-BackSpace> <Esc>b<Esc>d
    tnoremap <C-BackSpace> <Esc>b<Esc>d

    # TODO: bash?
    tnoremap <C-M-h> <Esc>b<Esc>d

    # delete the whole line
    if has('gui_running')
      tnoremap <C-S-BackSpace> <C-a><C-k>
    endif
  endif
enddef

# disable echords keys
export def Disable()
  silent! iunmap <C-a>
  if g:echords_visual_mappings
    silent! vunmap <C-a>
  endif
  if g:echords_normal_mappings
    silent! nunmap <C-a>
  endif
  if has('gui_running')
    silent! iunmap <C-S-a>
  else
    silent! iunmap <F13>
  endif
  silent! iunmap <C-x><C-a>
  if g:echords_command_mappings
    silent! cunmap <C-a>
    silent! cunmap <C-x><C-a>
  endif
  silent! iunmap <C-e>
  if g:echords_visual_mappings
    silent! vunmap <C-e>
  endif
  if g:echords_normal_mappings
    silent! nunmap <C-e>
  endif
  if g:echords_command_mappings
    silent! cunmap <C-e>
  endif
  if has('gui_running')
    silent! iunmap <C-S-e>
  else
    silent! iunmap <F14>
  endif
  silent! iunmap <C-q>
  silent! iunmap <C-o>
  if has('gui_running')
    silent! iunmap <C-S-o>
  endif
  if has('gui_running')
    silent! iunmap <C-Space>
    if g:echords_normal_mappings
      silent! nunmap <C-Space>
    endif
  else
    silent! iunmap <C-@>
    if g:echords_normal_mappings
      silent! nunmap <C-@>
    endif
  endif
  if has('gui_running')
    silent! iunmap <C-S-@>
  endif
  silent! iunmap <C-x>h
  if has('gui_running')
    silent! iunmap <C-u><C-Space>
  else
    silent! iunmap <C-u><C-@>
  endif
  if g:echords_visual_mappings
    silent! vunmap <C-x><C-x>
  endif
  silent! iunmap <M-@>
  silent! iunmap <M-%>
  silent! iunmap <M-$>
  silent! iunmap <M-q>
  if g:echords_visual_mappings
    silent! vunmap <M-q>
  endif
  silent! iunmap <M-m>
  if g:echords_normal_mappings
    silent! nunmap <M-m>
  endif
  silent! iunmap <M-S-m>
  silent! iunmap <M-a>
  if g:echords_normal_mappings
    silent! nunmap <M-a>
  endif
  silent! iunmap <M-S-a>
  silent! iunmap <M-e>
  if g:echords_normal_mappings
    silent! nunmap <M-e>
  endif
  silent! iunmap <M-S-e>
  silent! iunmap <C-x><BackSpace>
  silent! iunmap <M-k>
  silent! iunmap <M-{>
  silent! iunmap <C-Up>
  if g:echords_normal_mappings
    silent! nunmap <M-{>
    silent! nunmap <C-Up>
  endif
  if has('gui_running')
    silent! iunmap <C-S-Up>
  else
    silent! iunmap <F18>
  endif
  silent! iunmap <M-}>
  silent! iunmap <C-Down>
  if g:echords_normal_mappings
    silent! nunmap <M-}>
    silent! nunmap <C-Down>
  endif
  if has('gui_running')
    silent! iunmap <C-S-Down>
  else
    silent! iunmap <F19>
  endif
  silent! iunmap <C-M-a>
  silent! iunmap <C-M-Home>
  if g:echords_normal_mappings
    silent! nunmap <C-M-a>
    silent! nunmap <C-M-Home>
  endif
  silent! iunmap <C-M-e>
  silent! iunmap <C-M-End>
  if g:echords_normal_mappings
    silent! nunmap <C-M-e>
    silent! nunmap <C-M-End>
  endif
  silent! iunmap <C-p>
  if g:echords_normal_mappings
    silent! nunmap <C-p>
  endif
  if has('gui_running')
    silent! iunmap <C-S-p>
  else
    silent! iunmap <F22>
  endif
  if g:echords_visual_mappings
    silent! vunmap <C-p>
  endif
  silent! iunmap <C-n>
  if g:echords_normal_mappings
    silent! nunmap <C-n>
  endif
  silent! iunmap <C-s><C-s>
  silent! iunmap <C-s><C-w>
  silent! iunmap <C-r><C-r>
  silent! iunmap <C-r><C-w>
  if has('gui_running')
    silent! iunmap <C-S-n>
  else
    silent! iunmap <F21>
  endif
  if g:echords_visual_mappings
    silent! vunmap <C-n>
  endif
  silent! iunmap <C-x>s
  silent! iunmap <C-x><C-s>
  silent! iunmap <C-x>xg
  silent! iunmap <C-x>d
  silent! iunmap <C-x><C-f>
  # silent! iunmap <C-x><C-c>
  silent! iunmap <C-x><C-j>
  if g:echords_extra_mappings
    silent! iunmap <C-x>j
  endif
  silent! iunmap <C-x><C-w>
  silent! iunmap <C-t>
  silent! iunmap <M-t>
  silent! iunmap <C-x><C-t>
  silent! iunmap <C-b>
  if g:echords_command_mappings
    silent! cunmap <C-b>
  endif
  if g:echords_visual_mappings
    silent! vunmap <C-b>
  endif
  if g:echords_normal_mappings
    silent! nunmap <C-b>
  endif
  silent! iunmap <C-f>
  if g:echords_command_mappings
    silent! cunmap <C-f>
    silent! cunmap <C-x><C-f>
  endif
  if g:echords_visual_mappings
    silent! vunmap <C-f>
  endif
  if g:echords_normal_mappings
    silent! nunmap <C-f>
  endif
  silent! iunmap <M-b>
  silent! iunmap <M-Left>
  silent! iunmap <C-Left>
  if g:echords_command_mappings
    silent! cunmap <M-b>
  endif
  if g:echords_visual_mappings
    silent! vunmap <M-b>
  endif
  if g:echords_normal_mappings
    silent! nunmap <M-b>
  endif
  silent! iunmap <M-f>
  silent! iunmap <M-Right>
  silent! iunmap <C-Right>
  if g:echords_command_mappings
    silent! cunmap <M-f>
  endif
  if g:echords_visual_mappings
    silent! vunmap <M-f>
  endif
  if g:echords_normal_mappings
    silent! nunmap <M-f>
  endif
  silent! iunmap <C-d>
  if g:echords_command_mappings
    silent! cunmap <C-d>
    silent! cunmap <M-d>
  endif
  silent! iunmap <M-BackSpace>
  silent! iunmap <C-BackSpace>
  if g:echords_command_mappings
    silent! cunmap <M-BackSpace>
    silent! cunmap <C-BackSpace>
  endif
  if has('gui_running')
    silent! iunmap <C-S-BackSpace>
  endif
  silent! iunmap <M-d>
  silent! iunmap <C-Delete>
  silent! iunmap <C-k>
  if has('gui_running')
    silent! iunmap <C-S-k>
  endif
  silent! iunmap <C-y>
  if g:echords_command_mappings
    silent! cunmap <C-k>
    silent! cunmap <C-y>
  endif
  silent! iunmap <M-y>
  if g:echords_visual_mappings
    silent! vunmap <M-w>
  endif
  if g:echords_visual_mappings
    silent! vunmap <C-w>
  endif
  if g:echords_visual_mappings
    silent! vunmap <C-M-\>
  endif
  silent! iunmap <C-/>
  silent! iunmap <C-x>u
  silent! iunmap <Undo>
  if has('gui_running')
    silent! iunmap <C-S-_>
  else
    silent! iunmap <F15>
  endif
  if has('gui_running')
    silent! iunmap <C-M-S-_>
  else
    silent! iunmap <F17>
  endif
  if has('gui_running')
    silent! iunmap <C-S-?>
  else
    silent! iunmap <F16>
  endif
  silent! iunmap <C-x>b
  silent! iunmap <C-x><C-b>
  silent! iunmap <C-x>k
  silent! iunmap <M-x>
  # silent! iunmap <M-:>
  silent! iunmap <M-.>
  silent! iunmap <C-x>4.
  silent! iunmap <M-,>
  if g:echords_normal_mappings
    silent! nunmap <M-.>
    silent! nunmap <C-x>4.
    silent! nunmap <M-,>
  endif
  silent! iunmap <M-!>
  silent! iunmap <M-&>
  silent! iunmap <M-1>
  silent! iunmap <M-2>
  silent! iunmap <M-3>
  silent! iunmap <M-4>
  silent! iunmap <M-5>
  silent! iunmap <M-6>
  silent! iunmap <M-7>
  silent! iunmap <M-8>
  silent! iunmap <M-9>
  if has('gui_running')
    silent! iunmap <C-1>
    silent! iunmap <C-2>
    silent! iunmap <C-3>
    silent! iunmap <C-4>
    silent! iunmap <C-5>
    silent! iunmap <C-6>
    silent! iunmap <C-7>
    silent! iunmap <C-8>
    silent! iunmap <C-9>
  endif
  ### silent! iunmap <M-p>
  ### silent! iunmap <M-n>
  if g:echords_command_mappings
    silent! cunmap <M-p>
    silent! cunmap <M-n>
  endif
  silent! iunmap <C-v>
  silent! iunmap <M-v>
  if g:echords_normal_mappings
    silent! nunmap <C-v>
    silent! nunmap <M-v>
    silent! nunmap <leader><C-v>
  endif
  silent! iunmap <C-l>
  if g:echords_normal_mappings
    silent! nunmap <C-l>
  endif
  silent! iunmap <M-r>
  if g:echords_normal_mappings
    silent! nunmap <M-r>
  endif
  silent! iunmap <M-z>
  silent! iunmap <M-u>
  silent! iunmap <M-l>
  silent! iunmap <M-c>
  silent! iunmap <C-x><C-q>
  silent! iunmap <M-g>g
  silent! iunmap <M-g><M-g>
  if g:echords_normal_mappings
    silent! nunmap <M-g>g
    silent! nunmap <M-g><M-g>
  endif
  silent! iunmap <M-<>
  silent! iunmap <C-Home>
  if g:echords_normal_mappings
    silent! nunmap <M-<>
    silent! nunmap <C-Home>
  endif
  silent! iunmap <M->>
  silent! iunmap <C-End>
  if g:echords_normal_mappings
    silent! nunmap <M->>
    silent! nunmap <C-End>
  endif
  silent! iunmap <M-/>
  silent! iunmap <C-M-/>
  silent! iunmap <C-x>0
  if g:echords_normal_mappings
    silent! nunmap <C-x>0
  endif
  silent! iunmap <C-x>1
  if g:echords_normal_mappings
    silent! nunmap <C-x>1
  endif
  silent! iunmap <C-x>2
  if g:echords_normal_mappings
    silent! nunmap <C-x>2
  endif
  silent! iunmap <C-x>3
  if g:echords_normal_mappings
    silent! nunmap <C-x>3
  endif
  silent! iunmap <C-x>o
  if g:echords_normal_mappings
    silent! nunmap <C-x>o
  endif
  silent! iunmap <C-x>O
  if g:echords_normal_mappings
    silent! nunmap <C-x>O
  endif
  silent! iunmap <C-x>+
  if g:echords_normal_mappings
    silent! nunmap <C-x>+
  endif
  silent! iunmap <C-x>{
  if g:echords_normal_mappings
    silent! nunmap <C-x>{
  endif
  silent! iunmap <C-x>}
  if g:echords_normal_mappings
    silent! nunmap <C-x>}
  endif
  silent! iunmap <C-x>^
  if g:echords_normal_mappings
    silent! nunmap <C-x>^
  endif
  silent! iunmap <C-M-v>
  if g:echords_normal_mappings
    silent! nunmap <C-M-v>
  endif
  if has('gui_running')
    silent! iunmap <C-M-S-v>
    if g:echords_normal_mappings
      silent! nunmap <C-M-S-v>
    endif
  else
    silent! iunmap <F20>
    if g:echords_normal_mappings
      silent! nunmap <F20>
    endif
  endif
  silent! iunmap <C-x>4<C-f>
  silent! iunmap <C-x>(
  silent! iunmap <C-x>)
  silent! iunmap <C-x>e
  silent! iunmap <M-^>
  silent! iunmap <C-g>
  if g:echords_command_mappings
    silent! cunmap <C-g>
  endif
  if g:echords_visual_mappings
    silent! vunmap <C-g>
  endif
  if g:echords_operator_mappings
    silent! ounmap <C-g>
  endif
  if g:echords_normal_mappings
    silent! nunmap <C-g>
  endif

  if g:echords_extra_mappings
    silent! iunmap <C-x><C-x>
    silent! iunmap <C-^>
    silent! iunmap <C-x>K
    silent! iunmap <C-x><CR>
    silent! iunmap <M-o>
    silent! iunmap <M-S-o>
    silent! iunmap <leader>ed
    silent! iunmap <leader>ew
    silent! iunmap <leader>eP
    silent! iunmap <leader>eJ
    silent! iunmap <C-x>=
    silent! iunmap <C-x><C-m>
    if g:echords_normal_mappings
      silent! nunmap <M-x>
    endif
    silent! iunmap <leader>e=
    silent! iunmap <leader>ez
  endif

  if g:echords_terminal_mappings
    # TODO: recheck terminal maps to disable section
    # terminal
    silent! tunmap <M-b>
    silent! tunmap <M-f>
    silent! tunmap <C-d>
    silent! tunmap <M-d>
    silent! tunmap <M-p>
    silent! tunmap <M-n>
    silent! tunmap <M-BackSpace>
    silent! tunmap <C-BackSpace>
    if has('gui_running')
      silent! tunmap <C-S-BackSpace>
    endif
    # TODO: bash?
    silent! tunmap <C-M-h>
  endif
enddef

# toggle echords keys
export def Toggle()
  if g:echords_enabled
    Disable()
  else
    Enable()
  endif
  g:echords_enabled = !g:echords_enabled
  v:statusmsg = $"echords={g:echords_enabled}"
enddef

# async shell command
def AsyncShellCmd(): void
  var cmd = input("Async shell command: ")
  if empty(cmd)
    redraw!
    return
  endif
  var winid = win_getid()
  execute $"below terminal ++noclose ++norestore {cmd}"
  win_gotoid(winid)
enddef

# query replace
def QueryReplace(): void
  var old = input("Query Replace: ")
  if old == ""
    redraw!
    return
  endif
  var new = input($"Query replace {old} with: ")
  if new == ""
    redraw!
    return
  endif
  feedkeys($"\<C-o>:.,$s/{old}/{new}/gc\<CR>", "n")
enddef

# move beginning of line
def MoveBeginningOfLine()
  if indent(line('.')) != virtcol('.') - 1
    normal! ^
  else
    normal! 0
  endif
enddef

# spell word
def SpellWord()
  var lspell = &l:spell
  if !lspell
    setlocal spell
  endif
  var cword: string
  try
    cword = expand('<cword>')
  catch /^Vim\%((\a\+)\)\=:E348:/  # E348: No string under cursor
  endtry
  var bad = spellbadword(cword)
  if !empty(cword)
    # correct ['', '']
    # incorrect ['word', 'bad'] # bad, rare, local, caps
    if bad[1] == ""
      echo $"{toupper(cword)} is correct"
    else
      normal! z=
    endif
  endif
  if !lspell
    setlocal nospell
  endif
enddef

# zap to char
def ZapToChar()
  echo "Zap to char: "
  var char = getcharstr()
  if !empty(char)
    execute $"normal! df{char}"
  endif
enddef

# zap up to char
def ZapUpToChar()
  echo "Zap up to char: "
  var char = getcharstr()
  if !empty(char)
    execute $"normal! dt{char}"
  endif
enddef

# scroll current line to top, center, bottom  (zz, zb, zt)
var scrlkey: string = ""
def ScrollTo()
  if scrlkey == "" || scrlkey == "zb"
    normal! zt
    scrlkey = "zt"
  elseif scrlkey == "zt"
    normal! zz
    scrlkey = "zz"
  elseif scrlkey == "zz"
    normal! zb
    scrlkey = "zb"
  endif
enddef

# cursor line to top, center, bottom  (H, M, L)
var crskey: string = ""
def CursorTo()
  if crskey == "" || crskey == "L"
    normal! H
    crskey = "H"
  elseif crskey == "H"
    normal! M
    crskey = "M"
  elseif crskey == "M"
    normal! L
    crskey = "L"
  endif
enddef

# delete cmd line <C-k>
def DeleteCmdLine(): void
  var pos = getcmdpos()
  if pos <= 1
    setcmdline("")
    setcmdpos(1)
    return
  endif
  var line = getcmdline()
  var new = line[: pos - 2]
  setcmdline(new)
  setcmdpos(strlen(new) + 1)
  # TODO: custom collision with <C-Space> (see vimrc.local)
enddef
