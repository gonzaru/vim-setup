vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_autoendstructs') || !get(g:, 'autoendstructs_enabled') || &cp
  finish
endif
g:autoloaded_autoendstructs = 1

# allowed file types
const ALLOWED_TYPES = ["sh", "vim"]

# automatic end of structures
export def End(): string
  var action: string
  var curcharpos: string
  var firstword: string
  var lastword: string
  var curline: string
  var curlinelist: list<string>
  const dend = {
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
  curline = getline('.')
  if !g:autoendstructs_enabled || index(ALLOWED_TYPES, &filetype) == -1 || empty(trim(curline))
    return "\<CR>"
  endif
  curcharpos = curline[col('.') - 1]
  curlinelist = split(curline, " ")
  firstword = curlinelist[0]
  lastword = curlinelist[-1]
  if &ft == 'sh' && has_key(dend['sh'], firstword) && index(['then', 'do', 'in'], lastword) >= 0 && empty(curcharpos)
    action = "\<CR>" .. dend['sh'][firstword] .. "\<ESC>O"
  elseif &ft == 'vim' && has_key(dend['vim'], firstword) && empty(curcharpos)
    action = "\<CR>" .. dend['vim'][firstword] .. "\<ESC>O"
  else
    action = "\<CR>"
  endif
  return action
enddef

# toggle automatic end of structures
export def Toggle()
  g:autoendstructs_enabled = !g:autoendstructs_enabled
  v:statusmsg = "autoendstructs=" .. g:autoendstructs_enabled
enddef
