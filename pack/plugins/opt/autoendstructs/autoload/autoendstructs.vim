vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_autoendstructs') || !get(g:, 'autoendstructs_enabled')
  finish
endif
g:autoloaded_autoendstructs = true

# group action struct
const GROUP_ACTION = {
  'sh': [
    {
      'keys': ['case'],
      'trigger': 'in',
      'add': 'esac'
    },
    {
      'keys': ['for', 'until', 'while'],
      'trigger': 'do',
      'add': 'done'
    },
    {
      'keys': ['if'],
      'trigger': 'then',
      'add': 'fi'
    },
  ],
  'vim': [
    {
      'keys': ['if'],
      'trigger': '',
      'add': 'endif'
    },
    {
      'keys': ['while'],
      'trigger': '',
      'add': 'endwhile'
    },
    {
      'keys': ['for'],
      'trigger': '',
      'add': 'endfor'
    },
    {
      'keys': ['try'],
      'trigger': '',
      'add': 'endtry'
    },
    {
      'keys': ['function', 'function!'],
      'trigger': '',
      'add': 'endfunction'
    },
    {
      'keys': ['def', 'export def'],
      'trigger': '',
      'add': 'enddef'
    },
    {
      'keys': ['interface'],
      'trigger': '',
      'add': 'endinterface'
    },
    {
      'keys': ['class', 'abstract class', 'export class', 'export abstract'],
      'trigger': '',
      'add': 'endclass'
    }
  ],
  'go': [
    {
      'keys': ['if', 'for', 'switch', 'select', 'type', 'func', 'defer func', 'go func'],
      'trigger': '{',
      'add': '}'
    },
    {
      'keys': ['} else'],
      'trigger': '{',
      'add': '}'
    },
    {
      'keys': ['import', 'var'],
      'trigger': '(',
      'add': ')'
    }
  ]
}

# group action
def GroupAction(lang: string, str: string): dict<string>
  var idx: number
  var gaction: dict<string>
  for grp in GROUP_ACTION[lang]
    idx = index(grp['keys'], str)
    if idx >= 0
      gaction = {
        'key': grp['keys'][idx],
        'trigger': grp['trigger'],
        'add': grp['add']
      }
      break
    endif
  endfor
  return gaction
enddef

# automatic end of structures
export def End(lang: string): string
  var action: string
  var curline: string
  var curlinelist: list<string>
  var group: dict<string>
  var wfirst: string
  var wsecond: string
  var wfirsec: string
  var wlast: string
  if !g:autoendstructs_enabled || pumvisible()
    return "\<CR>"
  endif
  curline = trim(getline('.'))
  if empty(curline) || !empty(curline[col('.') - 1])  # current char position
    return "\<CR>"
  endif
  curlinelist = split(curline)
  wfirst = curlinelist[0]
  wsecond = len(curlinelist) >= 2 ? curlinelist[1] : ""
  wfirsec = !empty(wsecond) ? $"{wfirst} {wsecond}" : ""
  wlast = curlinelist[-1]
  group = GroupAction(lang, wfirst)
  if empty(group) && !empty(wfirsec)
    group = GroupAction(lang, wfirsec)
  endif
  if empty(group)
     return "\<CR>"
  endif
  if lang == 'sh' && wfirst == group['key'] && wlast == group['trigger']
    action = $"\<CR>{group['add']}\<ESC>O"
  elseif lang == 'vim' && (wfirst == group['key'] || wfirsec == group['key'])
    action = $"\<CR>{group['add']}\<ESC>O"
  elseif lang == 'go' && (wfirst == group['key'] || wfirsec == group['key']) && wlast == group['trigger']
    action = $"\<CR>{group['add']}\<ESC>O"
  else
    action = "\<CR>"
  endif
  return action
enddef

# toggle automatic end of structures
export def Toggle()
  g:autoendstructs_enabled = !g:autoendstructs_enabled
  v:statusmsg = $"autoendstructs={g:autoendstructs_enabled}"
enddef
