vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_autoendstructs') || !get(g:, 'autoendstructs_enabled') || &cp
  finish
endif
g:autoloaded_autoendstructs = 1

# allowed file types
const AUTOENDSTRUCTS_ALLOWED_TYPES = ["sh", "vim"]

# automatic end of structures
export def End(): string
  var curcharpos: string
  var dend: dict<dict<string>>
  var firstword: string
  var lastword: string
  var line: string
  var linelist: list<string>
  if !get(g:, "autoendstructs_enabled") || index(AUTOENDSTRUCTS_ALLOWED_TYPES, &filetype) == -1
    return "\<CR>"
  endif
  dend = {
    'sh': {
      'if': 'fi',
      'while': 'done',
      'for': 'done',
      'until': 'done',
      'case': 'esac'
    },
    'vim': {
      'if': 'endif',
      'while': 'endwhile',
      'for': 'endfor',
      'try': 'endtry',
      'function': 'endfunction',
      'function!': 'endfunction',
      'def': 'enddef'
    }
  }
  line = getline('.')
  if empty(trim(line))
    return "\<CR>"
  endif
  curcharpos = line[col('.') - 1]
  linelist = split(line, " ")
  firstword = linelist[0]
  lastword = linelist[-1]
  if &ft == 'sh' && has_key(dend['sh'], firstword) && index(['then', 'do', 'in'], lastword) >= 0 && empty(curcharpos)
    return "\<CR>" .. dend['sh'][firstword] .. "\<ESC>O"
  elseif &ft == 'vim' && has_key(dend['vim'], firstword) && empty(curcharpos)
    return "\<CR>" .. dend['vim'][firstword] .. "\<ESC>O"
  endif
  return "\<CR>"
enddef

# toggle automatic end of structures
export def Toggle()
  g:autoendstructs_enabled = !get(g:, "autoendstructs_enabled")
  v:statusmsg = "autoendstructs=" .. g:autoendstructs_enabled
enddef
