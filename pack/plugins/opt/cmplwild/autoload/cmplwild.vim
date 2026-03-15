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
  var cmpltypes = ['file', 'dir_in_path', 'command']
  var info = cmdcomplete_info()
  if empty(info) || mode() != 'c' || index(cmpltypes, getcmdcompltype()) == -1
    return
  endif
  cmd = getcmdline()
  if info.selected != -1
    if info.pum_visible == 0 && getcmdcomplpat() =~ '\/\/$'
      # foo// -> foo/<complete>
      setcmdline(substitute(cmd, '\/\/$', '/', ''))
    endif
  endif
enddef
