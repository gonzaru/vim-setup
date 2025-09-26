vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_session') || !get(g:, 'session_enabled')
  finish
endif
g:autoloaded_session = true

# script local variables
const sessionDir = g:session_directory
const sessionExt = g:session_file_extension

# prints the warning message and saves the message in the message-history
def EchoWarningMsg(msg: string)
  if !empty(msg)
    echohl WarningMsg
    echomsg msg
    echohl None
  endif
enddef

# complete load
export def CompleteLoad(argLead: string, _, _): list<string>
  var sessions = mapnew(sort(globpath(sessionDir, $'*.{sessionExt}', 0, 1)), "fnamemodify(v:val, ':t')")
  return filter(sessions, $"v:val =~ '^{argLead}'")
enddef

# close
export def Close(force: bool = false): void
  var res: string
  if empty(v:this_session) && !force
    EchoWarningMsg("Warning: no session found, 'v:this_session' is empty")
    return
  endif
  if !force
    res = input($"Are you sure to close session '{fnamemodify(v:this_session, ':t:r')}'? (y/N): ")
    redraw!
    if res != 'y' && res != 'yes'
      return
    endif
  endif
  silent! only
  silent! tabonly
  # silent! bufdo bwipeout
  for b in getbufinfo({'buflisted': 1})
    # TODO confirm() ?
    var name = empty(b.name) ? '[No Name]' : fnamemodify(b.name, ':t')
    if getbufvar(b.bufnr, '&buftype') ==# 'terminal'
      res = input($"terminal '{name}': kill job and close? (y/N): ")
      if res != 'y' && res != 'yes'
        continue
      endif
    endif
    if b.changed
      res = input($"buffer '{name}' was modified, Discard changes and close? (y/N): ")
      if res != 'y' && res != 'yes'
        continue
      endif
    endif
    execute $'silent! bwipeout! {b.bufnr}'
  endfor
  if &buftype != ''
    enew
  endif
  v:this_session = ''
  setlocal buftype=
  nohlsearch
  if exists(':ReloadVimrc') == 2
    silent! ReloadVimrc
  endif
  redraw!
enddef

# delete
export def Delete(dir: string, file: string, force: bool = false)
  var baseFile = $'{dir}/{file}'
  var dstFile = file =~ $'\.{sessionExt}$' ? baseFile : $'{baseFile}.{sessionExt}'
  var name = fnamemodify(dstFile, ':t:r')
  var res: string
  if !force
    res = input($"Are you sure to delete session '{name}'? (y/N): ")
    redraw!
  endif
  if res == 'y' || res == 'yes' || force
    if filereadable(dstFile)
      if delete(dstFile) == 0
        echomsg $"session '{name}' was removed"
        if name == fnamemodify(v:this_session, ':t:r')
          Close(true)
        endif
      else
        echoerr $"failed to delete session '{name}'"
      endif
    else
      echoerr $"session '{name}' is not readable"
    endif
  endif
enddef

# load
export def Load(dir: string, file: string)
  Close(true)
  execute $'source {dir}/{file}'
  echomsg $"session {fnamemodify(v:this_session, ':t:r')} loaded"
  if exists(':ReloadVimrc') == 2
    silent! ReloadVimrc
  endif
  redraw!
enddef

# write
export def Write(dir: string, file: string, force: bool = false): void
  if empty(file)
    feedkeys(":SessionWrite\<Space>", 'n')
    return
  endif
  var tailFile = fnamemodify(file, ':p:t')
  var baseFile = $'{dir}/{tailFile}'
  var dstFile = tailFile =~ $'\.{sessionExt}$' ? baseFile : $'{baseFile}.{sessionExt}'
  var name = fnamemodify(dstFile, ':t:r')
  var res: string
  if !force
    res = input($"Are you sure to write session '{name}'? (y/N): ")
    redraw!
  endif
  if res == 'y' || res == 'yes' || force
    execute $'mksession! {dstFile}'
    if filereadable(dstFile)
      echomsg $"session '{name}' was written"
    else
      echoerr $"session '{name}' is not readable"
    endif
  endif
enddef

# rename
export def Rename(dir: string): void
  if empty(v:this_session)
    EchoWarningMsg("Warning: no session found, 'v:this_session' is empty")
    return
  endif
  var src = fnamemodify(v:this_session, ':t')
  var res = trim(input($"Rename session '{src}' to?: "))
  redraw!
  if empty(res)
    return
  endif
  var dst = res =~ $'\.{sessionExt}$' ? res : $'{res}.{sessionExt}'
  Write(dir, dst, true)
  if filereadable($'{dir}/{dst}')
    Delete(dir, src, true)
  endif
  if !filereadable($'{dir}/{src}') && filereadable($'{dir}/{dst}')
    echomsg $"session '{fnamemodify(src, ':t:r')}' was renamed to '{fnamemodify(dst, ':t:r')}'"
  endif
enddef
