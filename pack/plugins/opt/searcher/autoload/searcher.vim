vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_searcher') || !get(g:, 'searcher_enabled')
  finish
endif
g:autoloaded_searcher = true

# searcher commands
const COMMANDS = {
  'findprg': {
    'cmd': join(g:searcher_findprg_cmd)
  },
  'grepprg': {
    'cmd': join(g:searcher_grepprg_cmd)
  },
  'gitprg': {
    'cmd': join(g:searcher_gitprg_cmd)
  }
}

# prints the warning message and saves the message in the message-history
def EchoWarningMsg(msg: string)
  if !empty(msg)
    echohl WarningMsg
    echom msg
    echohl None
  endif
enddef

# find files, grep and git grep searching
export def Search(...args: list<string>): void
  var cmd: string
  var idx: number
  var kind = args[-2]
  var mode = args[-1]
  var nargs = args
  var prg = COMMANDS[kind]['cmd']
  var str: string
  if index(nargs, '') >= 0
    throw $"Error: the args '{args}' have empty values"
  endif
  idx = index(nargs, '-i')
  if kind == 'findprg'
    prg ..= ' ' .. (idx >= 0 ? join(g:searcher_findprg_insensitive) : join(g:searcher_findprg_sensitive))
  elseif kind == 'grepprg'
    prg ..= ' ' .. (idx >= 0 ? join(g:searcher_grepprg_insensitive) : join(g:searcher_grepprg_sensitive))
  elseif kind == 'gitprg'
    prg ..= ' ' .. (idx >= 0 ? join(g:searcher_gitprg_insensitive) : join(g:searcher_gitprg_sensitive))
  endif
  remove(nargs, -2, -1)
  if idx >= 0
    nargs[1] = $"'{nargs[1]}'"
    remove(nargs, idx)
  else
    nargs[0] = $"'{nargs[0]}'"
  endif
  nargs[-1] = $"'{fnamemodify(nargs[-1], ":p")}'"
  if kind == 'findprg'
    cmd = prg .. ' ' .. join(nargs) .. ' | tr "\n" "\0" | xargs -0 file | sed "s/:/:1:/"'
  elseif kind == 'grepprg'
    cmd = prg .. ' ' .. join(nargs)
  elseif kind == 'gitprg'
    cmd = prg .. ' ' .. join(nargs)
  endif
  Run(cmd, mode)
enddef

# run
def Run(cmd: string, mode: string)
  if mode == "quickfix"
    cgetexp systemlist(cmd)
    cwindow
  elseif mode == "locationlist"
    lgetexp systemlist(cmd)
    lwindow
  endif
  # TODO: use ftplugin?
  if &filetype == "qf"
    setlocal number
  endif
enddef

# get listed buffers
def GetBuffers(): list<string>
  var buffs: list<string>
  for b in getbufinfo({'buflisted': 1})
    if !empty(b.name)
      add(buffs, fnamemodify(b.name, ':p:~'))
    endif
  endfor
  return buffs
enddef

# get changes
def GetChanges(): list<string>
  var [changes, idx] = getchangelist(bufnr('%'))
  return map(reverse(changes), (_, val) => $'{val.lnum}:{val.col + 1} {getline(val.lnum)}')
enddef

# get files
def GetFiles(): list<string>
  return systemlist($'cd {shellescape(pop.cwd)} && {pop.find_cmd}')
enddef

# get history
def GetHistory(type: string): list<string>
  var files = []
  if type == 'ex'
    files = map(range(-1, -g:searcher_popup_history_ex_limit, -1), (_, val) => histget(':', val))
  elseif type == 'search'
    files = map(range(-1, -g:searcher_popup_history_search_limit, -1), (_, val) => histget('/', val))
  endif
  return files
enddef

# get jumps
def GetJumps(): list<string>
  var [jumps, idx] = getjumplist()
  return map(reverse(jumps), (_, val) => {
    return $'{fnamemodify(bufname(val.bufnr), ':p:~')}:{val.lnum}:{val.col + 1} {bufloaded(val.bufnr) ? getline(val.lnum) : ''}'
  })
enddef

# get marks
def GetMarks(): list<string>
  var localMarks = map(getmarklist(bufnr('%')), (_, val) => $'L {val.mark} {val.pos[1] + 1}')
  var globalMarks = map(getmarklist(), (_, val) => $'G {val.mark} {val.file}:{val.pos[1] + 1}')
  return extend(localMarks, globalMarks)
enddef

# def mappings
def GetMappings(abbr: bool = false): list<string>
  const sep = nr2char(0x1f)
  return map(maplist(abbr), (_, val)  => $'{val.mode} {val.lhs} {val.rhs} {sep} {val.lhsraw}')
enddef

# get quickfix
def GetQuickfix(): list<string>
  return map(getqflist(), (_, val) => $'{fnamemodify(bufname(val.bufnr), ':p:~')}:{val.lnum}:{val.col + 1}')
enddef

# get sessions
def GetSessions(): list<string>
  var sessiondir = $"{$HOME}/.vim/sessions"
  var sessions = sort(globpath(sessiondir, "*", 0, 1))
  return mapnew(sessions, (_, val) => fnamemodify(val, ':p:~'))
enddef

# get completions
def GetCompletions(): list<string>
  return [
    'arglist', 'augroup', 'buffer', 'behave', 'breakpoint', 'color', 'command', 'cmdline', 'compiler',
    'cscope', 'custom', 'customlist', 'diff_buffer', 'dir', 'dir_in_path', 'environment', 'event',
    'expression', 'file', 'file_in_path', 'filetype', 'filetypecmd', 'function', 'help', 'highlight',
    'history', 'keymap', 'locale', 'mapclear', 'mapping', 'menu', 'messages', 'option',
    'packadd', 'retab', 'runtime', 'scriptnames', 'shellcmd', 'shellcmdline', 'sign', 'syntax',
    'syntime', 'tag', 'tag_listfiles', 'user', 'var'
  ]
enddef

# get completion
def GetCompletion(type: string, pat: string = ''): list<string>
  # pat = '' (default, all matches)
  return getcompletion(pat, type)
enddef

# get the default search directory
def DefaultCwd(): string
  var groot = systemlist("git rev-parse --show-toplevel")[0]
  return isdirectory(groot) ? groot : getcwd()
enddef

# global variables for popup
var pop = {
  all: [],
  shown: [],
  query: '',
  cwd: '',
  find_cmd: join(g:searcher_findprg_cmd),
  grep_cmd: join(g:searcher_grepprg_cmd),
  mode: '',
  kind: ''
}

# popup
export def Popup(kind: string, cwd: string = ''): void
  var kinds = [
    'find', 'grep', 'recent', 'buffers', 'sessions', 'changes', 'jumps', 'marks', 'mappings',
    'quickfix', 'commands', 'completions', 'themes', 'history-ex', 'history-search'
  ]
  if index(kinds, kind) == -1 && kind !~ 'completion-'
    return
  endif
  pop.mode = g:searcher_popup_mode
  pop.kind = kind
  pop.cwd = !empty(cwd) ? cwd : DefaultCwd()
  var files: list<string>
  if pop.kind == 'find'
    files = GetFiles()
  elseif pop.kind == 'recent'
    files = v:oldfiles
  elseif pop.kind == 'buffers'
    files = GetBuffers()
  elseif pop.kind == 'sessions'
    pop.mode = 'source'
    files = GetSessions()
  elseif pop.kind == 'changes'
    files = GetChanges()
  elseif pop.kind == 'jumps'
    files = GetJumps()
  elseif pop.kind == 'marks'
    files = GetMarks()
  elseif pop.kind == 'mappings'
    files = GetMappings()
  elseif pop.kind == 'quickfix'
    files = GetQuickfix()
  elseif pop.kind == 'commands'
    files = GetCompletion('command')
  elseif pop.kind == 'completions'
    files = GetCompletions()
  elseif pop.kind =~ 'completion-'
    files = GetCompletion(substitute(pop.kind, '^completion-', '', ''))
  elseif pop.kind == 'themes'
    pop.mode = 'colorscheme'
    files = GetCompletion('color')
  elseif pop.kind == 'history-ex'
    files = GetHistory('ex')
  elseif pop.kind == 'history-search'
    files = GetHistory('search')
  elseif pop.kind == 'grep'
    files = ['']
  endif
  if pop.kind != 'grep' && empty(files)
    EchoWarningMsg($"Warning: '{pop.kind}' files are empty")
    return
  endif
  pop.all = copy(files)
  pop.shown = copy(files)
  pop.query = ''
  var prompt = '> '
  var id = popup_menu(
    [prompt] + files, {
      title: PopupTitle(),
      pos: 'center',
      fixed: true,
      posinvert: false,
      minwidth: 60,
      maxwidth: 60,
      minheight: 12,
      maxheight: 12,
      border: [1, 1, 1, 1],
      borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
      scrollbar: true,
      close: 'click',
      mapping: false,
      wrap: false,
      drag: false,
      resize: false,
      cursorline: true,
      filter: function(CompletionFilter),
      callback: function(CompletionPick)
  })
  # select next line (prompt)
  if line('.', id) == 1
    popup_filter_menu(id, "\<Down>")
  endif
enddef

# popup title
def PopupTitle(): string
  var counter: string
  var cwd = fnamemodify(pop.cwd, ':~')
  if pop.kind == 'grep'
    var n = len(pop.shown)
    counter = $'[{n == 1 && empty(pop.shown[0]) ? 0 : n}]'
  else
    var n = len(pop.shown)
    counter = $'[{n == 1 && empty(pop.shown[0]) ? 0 : n}/{len(pop.all)}]'
  endif
  var fchars = (pop.kind != 'grep' && g:searcher_popup_fuzzy)
    ? '+fuzzy'
    : '-fuzzy'
  var title = $' {pop.kind}: {cwd} {counter} {fchars} '
  return title
enddef

# completion filter
def CompletionFilter(id: number, key: string): bool
  # <Esc>
  if key == "\<Esc>"
    popup_close(id, -1)
    return true
  endif

  # <Tab> => <CR>
  if key == "\<Tab>"
    return popup_filter_menu(id, "\<CR>")
  endif

  # <C-n> => <Down>
  if key == "\<C-n>"
    return popup_filter_menu(id, "\<Down>")
  endif

  # <C-p> => <Up>
  if key == "\<C-p>"
    return popup_filter_menu(id, "\<Up>")
  endif

  # delete a char
  if key == "\<BackSpace>" || key == "\<BS>" || key == "\<C-h>"
    if strchars(pop.query) > 0
      pop.query = strcharpart(pop.query, 0, strchars(pop.query) - 1)
      ApplyFilter(id)
    endif
    return true
  endif

  # delete all chars
  if key == "\<C-u>"
    pop.query = ''
    ApplyFilter(id)
    return true
  endif

  # toggle fuzzy (only find)
  if pop.kind != 'grep' && key == "\<C-f>"
    g:searcher_popup_fuzzy = !g:searcher_popup_fuzzy
    ApplyFilter(id)
    return true
  endif

  # split
  if key == "\<C-s>"
    pop.mode = 'split'
    return popup_filter_menu(id, "\<CR>")
  endif

  # vsplit
  if key == "\<C-v>"
    pop.mode = 'vsplit'
    return popup_filter_menu(id, "\<CR>")
  endif

  # pedit
  if key == "\<C-o>"
    pop.mode = 'pedit'
    return popup_filter_menu(id, "\<CR>")
  endif

  # tabedit
  if key == "\<C-t>"
    pop.mode = 'tabedit'
    return popup_filter_menu(id, "\<CR>")
  endif

  # not <CR>
  if strlen(key) == 1 && key != "\<CR>"
    pop.query ..= key
    ApplyFilter(id)
    return true
  endif

  return popup_filter_menu(id, key)
enddef

# apply filter
def ApplyFilter(id: number)
  var query = pop.query
  if pop.kind == 'grep'
    if strlen(query) >= g:searcher_popup_grep_minchars  # min n+ chars
      pop.shown = systemlist($'cd {shellescape(pop.cwd)} && {pop.grep_cmd} {shellescape(query)}')
    else
      pop.shown = ['']
    endif
  else
    if empty(query)
      pop.shown = copy(pop.all)
    elseif g:searcher_popup_fuzzy
      pop.shown = matchfuzzy(pop.all, pop.query, { limit: g:searcher_popup_fuzzy_limit })
    else
      var q = tolower(query)
      pop.shown = filter(copy(pop.all), (_, v) => stridx(tolower(v), q) >= 0)
    endif
  endif
  # empty line after prompt
  if empty(pop.shown)
    pop.shown = ['']
  endif
  var prompt = '> ' .. pop.query
  popup_settext(id, [prompt] + pop.shown)
  popup_setoptions(id, { title: PopupTitle() })
enddef

# completion pick
def CompletionPick(id: number, res: number): void
  var picked: string
  var parts: list<string>

  # 1 prompt line, +1 also for pop.shown
  if res <= 1 || res > len(pop.shown) + 1
    return
  endif

  # picked
  if pop.kind == 'find'
    picked = $'{pop.cwd}/{pop.shown[res - 2]}'  # -2 instead of -1 (prompt)
  elseif index(['recent', 'buffers', 'sessions'], pop.kind) >= 0
    picked = fnamemodify(pop.shown[res - 2], ':p')
  elseif index(['changes', 'jumps', 'themes', 'commands', 'completions'], pop.kind) >= 0 || pop.kind =~ 'completion-'
    picked = pop.shown[res - 2]
  elseif pop.kind == 'quickfix'
    picked = fnamemodify(split(pop.shown[res - 2], ':')[0], ':p')
    parts = split(pop.shown[res - 2], ':')
  elseif pop.kind == 'marks'
    picked = split(pop.shown[res - 2])[1]
  elseif pop.kind == 'mappings'
    const sep = nr2char(0x1f)  # see GetMappings()
    picked = trim(split(pop.shown[res - 2], sep, 1)[-1], ' ', 1)
    parts = split(pop.shown[res - 2])
  elseif pop.kind == 'history-ex' || pop.kind == 'history-search'
    picked = pop.shown[res - 2]
  elseif pop.kind == 'grep'
    parts = split(pop.shown[res - 2], ':')
    if empty(parts)
      return
    endif
    picked = $'{pop.cwd}/{parts[0]}'
  endif

  # action
  if index(['find', 'grep', 'recent', 'buffers', 'sessions', 'quickfix'], pop.kind) >= 0 && filereadable(picked)
    execute $"{pop.mode} {fnameescape(picked)}"
    # upate cursor
    if pop.kind == 'grep' || pop.kind == 'quickfix'
      cursor(str2nr(parts[1]), str2nr(parts[2]))
    endif
  elseif pop.kind == 'themes'
    execute $"{pop.mode} {picked}"
  elseif pop.kind == 'changes'
    cursor(str2nr(split(picked, ':')[0]), str2nr(split(picked, ':')[1]))
  elseif pop.kind == 'jumps'
    execute $"{pop.mode} {fnamemodify(split(picked, ':')[0], ':p')}"
    cursor(str2nr(split(picked, ':')[1]), str2nr(split(picked, ':')[2]))
  elseif pop.kind == 'marks'
    feedkeys($"{picked}\<CR>", 'n')
  elseif pop.kind == 'mappings'
    # parts[0] (mode = n,i,v,x,c,t,...)
    timer_start(0, (_) => {
      feedkeys(picked, 'm')
    })
  elseif pop.kind == 'commands'
    feedkeys($":{picked}", 'n')
  elseif pop.kind == 'completions'
    timer_start(0, (_) => {
      Popup($'completion-{picked}')
    })
  elseif pop.kind =~ 'completion-'
    # TODO
    # echomsg picked
  elseif pop.kind == 'history-ex'
    timer_start(0, (_) => {
      execute picked
    })
  elseif pop.kind == 'history-search'
    feedkeys($"/{picked}\<CR>", 'n')
  endif

  # close
  popup_close(id)
enddef
