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
# TODO:
### global ###
# setlocal mousemodel=popup_setpos  # <RightMouse>, <2-RightMouse>
# setlocal mousetime=500
# setlocal noconfirm
###  end   ###
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
  # <LeftRelease> (one click)
  nnoremap <buffer> <2-LeftMouse> <Plug>(se-gofile-edit)
  # nnoremap <buffer> <nowait> <Space> <Plug>(se-gofile-editk)
  nnoremap <buffer> <nowait> <Space> <Plug>(se-gofile-editkorbase)
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
  nnoremap <buffer> <nowait> <BackSpace> <Plug>(se-godir-parent)
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
  nnoremap <buffer> <nowait> <F1> <Plug>(se-help)
  nnoremap <buffer> <nowait> w <Plug>(se-godir-git)
  nnoremap <buffer> <nowait> W <Plug>(se-godir-root)
  nnoremap <buffer> <nowait> z <Plug>(se-set-rootdir)
  nnoremap <buffer> <nowait> Z <Plug>(se-unset-rootdir)

  # searcher plugin (popup)
  def Searcher(kind: string): void
    var bpname: string
    var newwid: number
    var sewid = win_getid()
    var top = fnamemodify(getline(1), ':p')
    var cwd = line('.') == 1 ? top : top .. trim(se#RemoveFileIndicators(se#RemoveDirSep(getline(line('.')))))
    if !isdirectory(cwd)
      return
    endif
    if winnr('$') >= 2
      var wnr = (g:se_position == "right") ? winnr('h') : winnr('l')
      bpname = bufname(winbufnr(wnr))
      win_gotoid(win_getid(wnr))
    else
      if get(g:, 'se_position') == 'right'
        vnew
      else
        rightbelow vnew
      endif
      newwid = win_getid()
      win_execute(sewid, 'se#Resize(g:se_resizemaxcol ? "maxcol" : "default")')
    endif
    searcher#Popup(kind, cwd)
    timer_start(0, (_) => {
      var pid = get(popup_list(), 0, 0)
      if pid <= 0
        return
      endif
      timer_start(100, (tid: number) => {
        # popup still exist
        if index(popup_list(), pid) != -1
          return
        endif
        if empty(bufname()) && win_getid() == newwid
          close
          win_gotoid(sewid)
        elseif bufname() == bpname
          win_gotoid(sewid)
        endif
        timer_stop(tid)
      }, { repeat: -1 })
    })
  enddef

  # searcher plugin (find or grep)
  def SearcherFindOrGrep()
    var res = input('find (f) or grep (g) (f,g): ', '')
    if res == 'f' || res == 'find'
      #feedkeys(":SearcherFind '-i', '', '-p', '" .. fnamemodify(trim(se#RemoveFileIndicators(se#RemoveDirSep(getline(line('.'))))), ':p:~') .. "'\<S-Left>\<S-Left>\<S-Left>\<Right>")
      Searcher('find')
    elseif res == 'g' || res == 'grep'
      #feedkeys(":SearcherGrep '-i', '', '" .. fnamemodify(trim(se#RemoveFileIndicators(se#RemoveDirSep(getline(line('.'))))), ':p:~') .. "'\<S-Left>\<S-Left>\<Right>")
      Searcher('grep')
    else
      redraw!
    endif
  enddef

  #nnoremap <buffer> <nowait> <C-f> <ScriptCmd>feedkeys(":SearcherFind '-i', '', '-p', '" .. fnamemodify(trim(se#RemoveFileIndicators(se#RemoveDirSep(getline(line('.'))))), ':p:~') .. "'<S-Left><S-Left><S-Left><Right>")<CR>
  nnoremap <buffer> <nowait> <C-f> <ScriptCmd>Searcher('find')<CR>
  #nnoremap <buffer> <nowait> <C-g> <ScriptCmd>feedkeys(":SearcherGrep '-i', '', '" .. fnamemodify(trim(se#RemoveFileIndicators(se#RemoveDirSep(getline(line('.'))))), ':p:~') .. "'<S-Left><S-Left><Right>")<CR>
  nnoremap <buffer> <nowait> <C-g> <ScriptCmd>Searcher('grep')<CR>
  #nnoremap <buffer> <2-rightmouse> <scriptcmd>feedkeys(":searcherfind '-i', '', '-p', '" .. fnamemodify(trim(se#removefileindicators(se#removedirsep(getline(line('.'))))), ':p:~') .. "'<s-left><s-left><s-left><right>")<cr>
  nnoremap <buffer> <RightMouse> <ScriptCmd>SearcherFindOrGrep()<CR>
endif

# undo
b:undo_ftplugin = 'setlocal syntax< statusline< winfixheight< winfixwidth< winfixbuf< number< relativenumber< signcolumn< cursorline< cursorcolumn< wrap< spell< list< splitright< swapfile< buflisted< buftype< bufhidden<'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> q'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> <Esc>'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> <CR>'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> <2-LeftMouse>'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> <Space>'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> e'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> E'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> p'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> P'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> s'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> S'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> v'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> V'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> t'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> T'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> -'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> <BackSpace>'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> b'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> ~'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> d'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> a'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> i'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> y'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> Y'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> r'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> f'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> F'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> h'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> l'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> ='
b:undo_ftplugin ..= ' | silent! nunmap <buffer> +'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> c'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> C'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> o'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> u'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> m'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> M'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> .'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> H'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> K'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> <F1>'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> w'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> W'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> z'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> Z'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> <C-f>'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> <C-g>'
b:undo_ftplugin ..= ' | silent! nunmap <buffer> <RightMouse>'
