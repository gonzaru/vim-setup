vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_autoendstructs') || !get(g:, 'autoendstructs_enabled')
  finish
endif
g:autoloaded_autoendstructs = true

# allowed file types
const ALLOWED_TYPES = ["sh", "vim", "go"]

# group action struct
const GROUP_ACTION = {
  'sh': {
    'group1': {
      'keys': ['case'],
      'trigger': 'in',
      'add': 'esac'
    },
    'group2': {
      'keys': ['for', 'until', 'while'],
      'trigger': 'do',
      'add': 'done'
    },
    'group3': {
      'keys': ['if'],
      'trigger': 'then',
      'add': 'fi'
    },
  },
  'vim': {
    'group1': {
      'keys': ['if'],
      'trigger': '',
      'add': 'endif'
    },
    'group2': {
      'keys': ['while'],
      'trigger': '',
      'add': 'endwhile'
    },
    'group3': {
      'keys': ['for'],
      'trigger': '',
      'add': 'endfor'
    },
    'group4': {
      'keys': ['try'],
      'trigger': '',
      'add': 'endtry'
    },
    'group5': {
      'keys': ['function', 'function!'],
      'trigger': '',
      'add': 'endfunction'
    },
    'group6': {
      'keys': ['def', 'export def'],
      'trigger': '',
      'add': 'enddef'
    },
    'group7': {
      'keys': ['interface'],
      'trigger': '',
      'add': 'endinterface'
    },
    'group8': {
      'keys': ['class', 'abstract class', 'export class', 'export abstract'],
      'trigger': '',
      'add': 'endclass'
    }
  },
  'go': {
    'group1': {
      'keys': ['if', 'for', 'switch', 'select', 'type', 'func', 'defer func', 'go func'],
      'trigger': '{',
      'add': '}'
    },
    'group2': {
      'keys': ['} else'],
      'trigger': '{',
      'add': '}'
    },
    'group3': {
      'keys': ['import', 'var'],
      'trigger': '(',
      'add': ')'
    }
  }
}

# group action
def GroupAction(lang: string, str: string): dict<string>
  var idx: number
  var grp: dict<string>
  for key in keys(GROUP_ACTION[lang])
    idx = index(GROUP_ACTION[lang][key]['keys'], str)
    if idx >= 0
      grp = {
        'key': GROUP_ACTION[lang][key]['keys'][idx],
        'trigger': GROUP_ACTION[lang][key]['trigger'],
        'add': GROUP_ACTION[lang][key]['add']
      }
      break
    endif
  endfor
  return grp
enddef

# automatic end of structures
export def End(lang: string): string
  var action: string
  var wordf: string
  var words: string
  var wordfs: string
  var wordl: string
  var curline: string
  var curlinelist: list<string>
  var group: dict<string>
  curline = trim(getline('.'))
  if !g:autoendstructs_enabled || pumvisible() || index(ALLOWED_TYPES, lang) == -1
  || empty(curline) || !empty(curline[col('.') - 1])  # current char position
    return "\<CR>"
  endif
  curlinelist = split(curline, " ")
  wordf = curlinelist[0]
  try
    words = curlinelist[1]
  catch /^Vim\%((\a\+)\)\=:E684:/  # E684: List index out of range
    wordfs = ""
  endtry
  wordl = curlinelist[-1]
  wordfs = $"{wordf} {words}"
  group = GroupAction(lang, wordf)
  if empty(group)
    if len(split(wordfs, " ")) == 2
      group = GroupAction(lang, wordfs)
    endif
    if empty(group)
      return "\<CR>"
    endif
  endif
  if lang == 'sh' && wordf == group['key'] && wordl == group['trigger']
    action = $"\<CR>{group['add']}\<ESC>O"
  elseif lang == 'vim' && (wordf == group['key'] || wordfs == group['key'])
    action = $"\<CR>{group['add']}\<ESC>O"
  elseif lang == 'go' && (wordf == group['key'] || wordfs == group['key']) && wordl == group['trigger']
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
