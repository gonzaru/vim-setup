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

# global variables for popups

# prompt popup
var popPrompt = {
  id: -1,
  prompt: '>',
  query: '',
}

# data popup
var popData = {
  id: -1,
  all: [],
  shown: [],
  cwd: '',
  find_cmd: join(g:searcher_findprg_cmd),
  grep_cmd: join(g:searcher_grepprg_cmd),
  mode: '',
  kind: ''
}

# data pos
var posData = {
  cursor: [0, 0, 0, 0, 0],
  bufnr: -1,
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
  return systemlist($'cd {shellescape(popData.cwd)} && {popData.find_cmd}')
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

# get mappings
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

# update pos
def UpdatePos()
  posData.cursor = getcurpos()
  posData.bufnr = bufnr('%')
enddef

# restore pos
def RestorePos()
  if bufnr('%') == posData.bufnr
    setpos('.', posData.cursor)
  endif
enddef

# popup
export def Popup(kind: string, cwd: string = ''): void
  var kinds = [
    'find', 'grep', 'recent', 'buffers', 'sessions', 'changes', 'jumps', 'marks', 'mappings',
    'quickfix', 'commands', 'completions', 'themes', 'history-ex', 'history-search'
  ]
  if index(kinds, kind) == -1 && kind !~ 'completion-'
    return
  endif
  popData.mode = g:searcher_popup_mode
  popData.kind = kind
  popData.cwd = !empty(cwd) ? cwd : DefaultCwd()
  var files: list<string>
  if popData.kind == 'find'
    files = GetFiles()
  elseif popData.kind == 'recent'
    files = v:oldfiles
  elseif popData.kind == 'buffers'
    files = GetBuffers()
  elseif popData.kind == 'sessions'
    popData.mode = 'source'
    files = GetSessions()
  elseif popData.kind == 'changes'
    files = GetChanges()
  elseif popData.kind == 'jumps'
    files = GetJumps()
  elseif popData.kind == 'marks'
    files = GetMarks()
  elseif popData.kind == 'mappings'
    files = GetMappings()
  elseif popData.kind == 'quickfix'
    files = GetQuickfix()
  elseif popData.kind == 'commands'
    files = GetCompletion('command')
  elseif popData.kind == 'completions'
    files = GetCompletions()
  elseif popData.kind =~ 'completion-'
    files = GetCompletion(substitute(popData.kind, '^completion-', '', ''))
  elseif popData.kind == 'themes'
    popData.mode = 'colorscheme'
    files = GetCompletion('color')
  elseif popData.kind == 'history-ex'
    files = GetHistory('ex')
  elseif popData.kind == 'history-search'
    files = GetHistory('search')
  elseif popData.kind == 'grep'
    files = ['']
  endif
  if popData.kind != 'grep' && empty(files)
    EchoWarningMsg($"Warning: '{popData.kind}' files are empty")
    return
  endif
  popData.all = copy(files)
  popData.shown = copy(files)
  popPrompt.query = ''
  popData.id = popup_menu(
      files, {
      title: '',
      pos: 'center',
      fixed: true,
      posinvert: false,
      minwidth: &columns / 2,
      maxwidth: &columns / 2,
      minheight: &lines / 2,
      maxheight: &lines / 2,
      border: [1, 1, 1, 1],
      padding: [0, 0, 0, 2],
      borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
      scrollbar: false,
      close: 'click',
      mapping: false,
      wrap: false,
      drag: false,
      resize: false,
      cursorline: true,
      filter: function(CompletionFilter),
      callback: function(CompletionPick)
  })
  # popPrompt is on top off popData
  var popDataPos  = popup_getpos(popData.id)
  popPrompt.id = popup_create([popPrompt.prompt], {
    title: PopupTitle(),
    line: popDataPos.line - 3,
    col: popDataPos.col,
    fixed: true,
    minwidth: (&columns / 2) + 2,
    maxwidth: (&columns / 2) + 2,
    minheight: 1,
    maxheight: 1,
    border: [1, 1, 1, 1],
    borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
    scrollbar: false,
    cursorline: false,
    wrap: false,
  })
  # TODO?
  # win_execute(popData.id, 'setlocal colorcolumn=1')
  UpdatePos()
  UpdatePromptCursor()
enddef

# popup title
def PopupTitle(): string
  var counter: string
  var cwd = fnamemodify(popData.cwd, ':~')
  var shown = len(popData.shown)
  if popData.kind == 'grep'
    var maxData = 8  # N chars padding
    if shown == 1 && empty(popData.shown[0])
      counter = $'{repeat(' ', maxData - 1)}0'
    else
      counter = $'{repeat(' ', maxData - len(shown))}{shown}'
    endif
  else
    var maxData = strlen(len(popData.all))
    if shown == 1 && empty(popData.shown[0])
      counter = $'{repeat(' ', maxData - 1)}0/{len(popData.all)}'
    else
      counter = $'{repeat(' ', maxData - len(shown))}{shown}/{len(popData.all)}'
    endif
  endif
  # var fchars = (popData.kind != 'grep' && g:searcher_popup_fuzzy)
  #   ? '+fuzzy'
  #   : '-fuzzy'
  # var title = $' {popData.kind}: {cwd} {counter} {fchars} '
  var title = $' {popData.kind}: {cwd} {counter} '
  return repeat('─', (&columns / 2) - strchars(title) + 2) .. title  # + 2 (see popPrompt maxwidth)
enddef

# update prompt cursor
def UpdatePromptCursor()
  var save = &l:virtualedit
  setlocal virtualedit=all
  var popDataPrompt  = popup_getpos(popPrompt.id)
  var [winRow, _] = win_screenpos(0)
  var info = getwininfo(win_getid())[0]
  # info.textoff (gutter)
  var pline = line('w0') + (popDataPrompt.line - winRow) + 1
  var pcol = (popDataPrompt.col - info.textoff) + strdisplaywidth(popPrompt.query) + 3
  cursor(pline, pcol)
  # restore
  timer_start(0, (_) => {
    &l:virtualedit = save
  })
enddef

# completion filter
def CompletionFilter(id: number, key: string): bool
  # <Esc>
  if key == "\<Esc>"
    popup_close(popPrompt.id, -1)
    popup_close(id, -1)
    RestorePos()
    return true
  endif

  # <Tab> => <CR>
  if key == "\<Tab>"
    return popup_filter_menu(id, "\<CR>")
  endif

  # <C-n> => <Down>
  if key == "\<C-n>" || key == "\<Down>"
    return popup_filter_menu(id, "\<Down>")
  endif

  # <C-p> => <Up>
  if key == "\<C-p>" || key == "\<Up>"
    return popup_filter_menu(id, "\<Up>")
  endif

  # delete a char
  if key == "\<BackSpace>" || key == "\<BS>" || key == "\<C-h>"
    if strchars(popPrompt.query) > 0
      popPrompt.query = strcharpart(popPrompt.query, 0, strchars(popPrompt.query) - 1)
      ApplyFilter(id)
      UpdatePromptCursor()
    endif
    return true
  endif

  # delete all chars
  if key == "\<C-u>"
    popPrompt.query = ''
    ApplyFilter(id)
    UpdatePromptCursor()
    return true
  endif

  # toggle fuzzy (not grep)
  if popData.kind != 'grep' && key == "\<C-f>"
    g:searcher_popup_fuzzy = !g:searcher_popup_fuzzy
    ApplyFilter(id)
    return true
  endif

  # split
  if key == "\<C-s>"
    popData.mode = 'split'
    return popup_filter_menu(id, "\<CR>")
  endif

  # vsplit
  if key == "\<C-v>"
    popData.mode = 'vsplit'
    return popup_filter_menu(id, "\<CR>")
  endif

  # pedit
  if key == "\<C-o>"
    popData.mode = 'pedit'
    return popup_filter_menu(id, "\<CR>")
  endif

  # tabedit
  if key == "\<C-t>"
    popData.mode = 'tabedit'
    return popup_filter_menu(id, "\<CR>")
  endif

  # not <CR>
  if strlen(key) == 1 && key != "\<CR>"
    popPrompt.query ..= key
    ApplyFilter(id)
    UpdatePromptCursor()
    return true
  endif

  return popup_filter_menu(id, key)
enddef

# apply filter
def ApplyFilter(id: number)
  if popData.kind == 'grep'
    if strchars(popPrompt.query) >= g:searcher_popup_grep_minchars  # min N+ chars
      popData.shown = systemlist($'cd {shellescape(popData.cwd)} && {popData.grep_cmd} {shellescape(popPrompt.query)}')
    else
      popData.shown = ['']
    endif
  else
    if empty(popPrompt.query)
      popData.shown = copy(popData.all)
    elseif g:searcher_popup_fuzzy
      popData.shown = matchfuzzy(popData.all, popPrompt.query, { limit: g:searcher_popup_fuzzy_limit })
    else
      var q = tolower(popPrompt.query)
      popData.shown = filter(copy(popData.all), (_, v) => stridx(tolower(v), q) >= 0)
    endif
  endif
  # empty line after prompt
  if empty(popData.shown)
    popData.shown = ['']
  endif
  popup_setoptions(popPrompt.id, { title: PopupTitle() })
  popup_settext(popPrompt.id, [popPrompt.prompt .. ' ' .. popPrompt.query])
  popup_setoptions(id, { firstline: 1, cursorline: 1 })  # reset scroll
  popup_settext(id, popData.shown)
enddef

# completion pick
def CompletionPick(id: number, res: number): void
  var picked: string
  var parts: list<string>

  # do nothing
  if res <= 0 || res > len(popData.shown)
    return
  endif

  # picked
  if popData.kind == 'find'
    picked = $'{popData.cwd}/{popData.shown[res - 1]}'  # -2 instead of -1 (prompt)
  elseif index(['recent', 'buffers', 'sessions'], popData.kind) >= 0
    picked = fnamemodify(popData.shown[res - 1], ':p')
  elseif index(['changes', 'jumps', 'themes', 'commands', 'completions'], popData.kind) >= 0 || popData.kind =~ 'completion-'
    picked = popData.shown[res - 1]
  elseif popData.kind == 'quickfix'
    picked = fnamemodify(split(popData.shown[res - 1], ':')[0], ':p')
    parts = split(popData.shown[res - 1], ':')
  elseif popData.kind == 'marks'
    picked = split(popData.shown[res - 1])[1]
  elseif popData.kind == 'mappings'
    const sep = nr2char(0x1f)  # see GetMappings()
    picked = trim(split(popData.shown[res - 1], sep, 1)[-1], ' ', 1)
    parts = split(popData.shown[res - 1])
  elseif popData.kind == 'history-ex' || popData.kind == 'history-search'
    picked = popData.shown[res - 1]
  elseif popData.kind == 'grep'
    parts = split(popData.shown[res - 1], ':')
    if empty(parts)
      return
    endif
    picked = $'{popData.cwd}/{parts[0]}'
  endif

  # action
  if index(['find', 'grep', 'recent', 'buffers', 'sessions', 'quickfix'], popData.kind) >= 0 && filereadable(picked)
    execute $"{popData.mode} {fnameescape(picked)}"
    # upate cursor
    if popData.kind == 'grep' || popData.kind == 'quickfix'
      cursor(str2nr(parts[1]), str2nr(parts[2]))
    endif
  elseif popData.kind == 'themes'
    execute $"{popData.mode} {picked}"
  elseif popData.kind == 'changes'
    cursor(str2nr(split(picked, ':')[0]), str2nr(split(picked, ':')[1]))
  elseif popData.kind == 'jumps'
    execute $"{popData.mode} {fnamemodify(split(picked, ':')[0], ':p')}"
    cursor(str2nr(split(picked, ':')[1]), str2nr(split(picked, ':')[2]))
  elseif popData.kind == 'marks'
    feedkeys($"{picked}\<CR>", 'n')
  elseif popData.kind == 'mappings'
    # parts[0] (mode = n,i,v,x,c,t,...)
    timer_start(0, (_) => {
      feedkeys(picked, 'm')
    })
  elseif popData.kind == 'commands'
    feedkeys($":{picked}", 'n')
  elseif popData.kind == 'completions'
    timer_start(0, (_) => {
      Popup($'completion-{picked}')
    })
  elseif popData.kind =~ 'completion-'
    # TODO
    # echomsg picked
  elseif popData.kind == 'history-ex'
    timer_start(0, (_) => {
      execute picked
    })
  elseif popData.kind == 'history-search'
    feedkeys($"/{picked}\<CR>", 'n')
  endif

  # close
  popup_close(popPrompt.id)
  popup_close(id)
  RestorePos()
enddef
