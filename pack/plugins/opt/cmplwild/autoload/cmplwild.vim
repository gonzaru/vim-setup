vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_cmplwild') || !get(g:, 'cmplwild_enabled')
  finish
endif
g:autoloaded_cmplwild = true

# cmplwild enable
export def Enable()
  g:cmplwild_enabled = true
enddef

# cmplwild disable
export def Disable()
  g:cmplwild_enabled = false
enddef

# cmplwild toggle
export def Toggle()
  g:cmplwild_enabled = !g:cmplwild_enabled
  v:statusmsg = $"cmplwild={g:cmplwild_enabled}"
enddef

# complete command-line
export def CmdLineChanged(): void
  var cmd: string
  var info = cmdcomplete_info()
  if empty(info) || getcmdcompltype() != 'file'
    return
  endif
  cmd = getcmdline()
  if info.selected != -1
    if getcmdcomplpat() =~ '\/\/$'
      # foo// -> foo/<complete>
      setcmdline(substitute(cmd, '\/\/$', '/', ''))
    endif
  endif
enddef
