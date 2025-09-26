vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_searcher') || !get(g:, 'searcher_enabled')
  finish
endif
g:autoloaded_searcher = true

# job queue
final JOB_QUEUE = []

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
  prompt: '',
  query: '',
  message: '',
  shape: '█',  # '▮', '┃',
  ready: false,
  timer: -1
}

# data popup
var popData = {
  id: -1,
  all: {
    raw: [],
    lower: [],
    idx: []
  },
  shown: [],
  prev: {
    query: '',
    idx: []
  },
  cache: {
    idx: {},
    key: {}
  },
  cwd: '',
  findCmd: join(g:searcher_findprg_cmd),
  grepCmd: join(g:searcher_grepprg_cmd),
  mode: '',
  kind: ''
}

# data pos
var posData = {
  cursor: [0, 0, 0, 0, 0],
  bufnr: -1,
  winid: -1
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
  return systemlist($'cd {shellescape(popData.cwd)} && {popData.findCmd}')
enddef

# get command async
def GetCommandAsync(cmd: string): void
  if !empty(JOB_QUEUE)
    return
  endif
  # win_execute(popPrompt.id, 'setlocal wincolor=Search')
  var newJob: job
  newJob = job_start(cmd, {
    'out_cb': function(OutHandler),
    'close_cb': function(CloseHandler),
    'exit_cb': function(ExitHandler),
    'out_io': 'pipe',
    'out_mode': 'nl',
    'out_msg': 0,
    'out_modifiable': 0,
    'err_io': 'out',
    'cwd': popData.cwd
  })
  if job_status(newJob) == 'run'
    popPrompt.ready = false
    timer_start(50, (tid: number) => {
      if popPrompt.id > 0 && !popPrompt.ready
        var msg = ' waiting for results... '
        popup_setoptions(popPrompt.id, { title: msg })
      endif
    })
    add(JOB_QUEUE, job_info(newJob)['process'])
  endif
enddef

# out handler
def OutHandler(channel: channel, message: string)
  if !empty(message)
    add(popData.all.raw, trim(message, "\r", 2))
  endif
enddef

# close handler
def CloseHandler(channel: channel): void
  if empty(popData.all.raw)
    popup_close(popPrompt.id, -1)
    popup_close(popData.id, -1)
    EchoWarningMsg($"Warning: '{popData.kind}' data is empty")
    return
  endif
  popData.all.lower = mapnew(popData.all.raw, (_, v) => tolower(v))
  popData.all.idx = range(len(popData.all.lower))
  popData.prev.idx = copy(popData.all.idx)
  popData.prev.query = ''
  popData.cache.idx = {}
  popData.cache.key = {}
  popData.cache.idx[0] = copy(popData.all.idx)
  popData.cache.key[0] = ''
  popData.shown = copy(popData.all.raw)
  popPrompt.message = ''
  popup_setoptions(popPrompt.id, { title: PopupTitle() })
  popup_settext(popPrompt.id, [popPrompt.prompt .. popPrompt.query .. popPrompt.shape])
  popup_settext(popData.id, popData.shown)
  # unlock
  # win_execute(popPrompt.id, 'setlocal wincolor=Pmenu')
  popPrompt.ready = true
enddef

# exit handler for when the job ends
def ExitHandler(job: job, status: number)
  var idx = index(JOB_QUEUE, job_info(job)['process'])
  if idx >= 0
    remove(JOB_QUEUE, idx)
  endif
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
  return map(maplist(abbr), (_, val) => {
    return $'{val.mode} {substitute(val.lhs, keytrans(g:mapleader), '<Leader>', 'g')} {val.rhs} {sep} {val.lhsraw}'
  })
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
  posData.winid = win_getid()
enddef

# restore pos
def RestorePos()
  if bufnr('%') == posData.bufnr && getcurpos() != posData.cursor
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
  popData.all.raw = []
  popData.all.lower = []
  popData.all.idx = {}
  popData.shown = []
  popPrompt.query = ''
  popPrompt.ready = false

  var files: list<string> = []
  if popData.kind == 'find'
    if g:searcher_popup_find_async
      PopupCreate('')
      GetCommandAsync(popData.findCmd)
      return
    else
      files = GetFiles()
    endif
  elseif popData.kind == 'grep'
    files = ['']
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
  endif

  if (popData.kind != 'grep' || (popData.kind == 'find' && !g:searcher_popup_find_async)) && empty(files)
    EchoWarningMsg($"Warning: '{popData.kind}' data is empty")
    return
  endif

  # popup data
  popData.all.raw = copy(files)
  popData.all.lower = mapnew(files, (_, v) => tolower(v))
  popData.all.idx = range(len(popData.all.lower))
  popData.prev.idx = copy(popData.all.idx)
  popData.prev.query = ''
  popData.cache.idx = {}
  popData.cache.key = {}
  popData.cache.idx[0] = copy(popData.all.idx)
  popData.cache.key[0] = ''
  popData.shown = copy(files)

  # create
  PopupCreate()

  # TODO?
  # win_execute(popData.id, 'setlocal colorcolumn=1')
  # UpdatePos()

  # unlock
  popPrompt.ready = true
enddef

# popup create
def PopupCreate(titlePrompt: any = v:none)
  popData.id = popup_menu(
      popData.shown, {
      title: '',
      pos: 'center',
      fixed: true,
      posinvert: false,
      minwidth: &columns / 2,
      maxwidth: &columns / 2,
      minheight: &lines / 2,
      maxheight: &lines / 2,
      border: [0, 1, 1, 1],
      padding: [0, 0, 0, 0],
      # borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
      borderchars: [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
      zindex: 20,
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
  popPrompt.id = popup_create([popPrompt.prompt .. popPrompt.query .. popPrompt.shape], {
    title: (type(titlePrompt) == v:t_string) ? titlePrompt : PopupTitle(),
    line: popDataPos.line - 3,
    col: popDataPos.col,
    fixed: true,
    minwidth: (&columns / 2),
    maxwidth: (&columns / 2),
    minheight: 1,
    maxheight: 1,
    border: [1, 1, 1, 1],
    padding: [0, 0, 0, 0],
    borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
    zindex: 40,
    scrollbar: false,
    cursorline: false,
    wrap: false,
  })

  # cursor & prompt colors
  highlight! SearcherPopupCursor guifg=#606060 guibg=NONE ctermfg=59 ctermbg=NONE gui=NONE cterm=NONE term=NONE
  if !empty(popPrompt.prompt)
    highlight! SearcherPopupPrompt guifg=#cc7832 guibg=NONE ctermfg=172 ctermbg=NONE gui=NONE cterm=NONE term=NONE
    win_execute(popPrompt.id, "matchadd('SearcherPopupPrompt', '^' .. popPrompt.prompt .. '\\ze')")
  endif
  # win_execute(popPrompt.id, 'setlocal wincolor=WildMenu')
  win_execute(popPrompt.id, "matchadd('SearcherPopupCursor', popPrompt.shape .. '$')")
enddef

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
    var maxData = strlen(len(popData.all.raw))
    if shown == 1 && empty(popData.shown[0])
      counter = $'{repeat(' ', maxData - 1)}0/{len(popData.all.raw)}'
    else
      counter = $'{repeat(' ', maxData - len(shown))}{shown}/{len(popData.all.raw)}'
    endif
  endif
  var fchars = (popData.kind != 'grep' && g:searcher_popup_fuzzy) ? '+fuzzy ' : ''
  var title = $' {popPrompt.message}{popData.kind}: {cwd} {fchars}{counter} '
  return repeat('─', (&columns / 2) - strchars(title) + 0) .. title  # + 0 (see popPrompt maxwidth)
enddef

# completion filter
def CompletionFilter(id: number, key: string): bool

  # do nothing
  if !popPrompt.ready
    # EchoWarningMsg($'Warning: popup prompt is not ready')
    return true
  endif

  # <Esc>
  if key == "\<Esc>"
    popup_close(popPrompt.id, -1)
    popup_close(id, -1)
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
      # ScheduleFilter(id)
    endif
    return true
  endif

  # delete all chars
  if key == "\<C-u>"
    popPrompt.query = ''
    ApplyFilter(id)
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
    # ScheduleFilter(id)
    return true
  endif

  return popup_filter_menu(id, key)
enddef

# schedule filter (debounce)
def ScheduleFilter(id: number)
  if popPrompt.timer != -1
    timer_stop(popPrompt.timer)
    popPrompt.timer = -1
  endif
  popPrompt.timer = timer_start(0, (_) => {
    popPrompt.timer = -1
    ApplyFilter(id)
  })
enddef

# apply filter
def ApplyFilter(id: number)
  # var t = reltime()

  # grep
  if popData.kind == 'grep'
    popData.shown = ['']
    if strchars(popPrompt.query) >= g:searcher_popup_grep_minchars  # min N+ chars
      popData.shown = systemlist($'cd {shellescape(popData.cwd)} && {popData.grepCmd} {shellescape(popPrompt.query)}')
    endif
  endif

  # any (except grep)
  if popData.kind != 'grep'
    if empty(popPrompt.query)
      popData.shown = copy(popData.all.raw)
      popData.prev.query = ''
      popData.prev.idx = copy(popData.all.idx)
      popData.cache.idx = {}
      popData.cache.key = {}
      popData.cache.idx[0] = copy(popData.all.idx)
      popData.cache.key[0] = ''
    elseif g:searcher_popup_fuzzy
      popData.shown = matchfuzzy(popData.all.raw, popPrompt.query, { limit: g:searcher_popup_fuzzy_limit, smartcase: true })
    else
      var query = tolower(popPrompt.query)
      var queryLen = strchars(query)

      # popData.shown = filter(copy(popData.all.raw), (_, v) => stridx(tolower(v), query) >= 0)

      var pool: list<number>
      if has_key(popData.cache.idx, queryLen) && has_key(popData.cache.key, queryLen) && popData.cache.key[queryLen] == query
          pool = popData.cache.idx[queryLen]
      elseif queryLen > strchars(popData.prev.query) && stridx(query, popData.prev.query) == 0
        pool = popData.prev.idx
      else
        pool = popData.all.idx
      endif

      var out: list<string> = []
      var nextPool: list<number> = []
      for i in pool
        if stridx(popData.all.lower[i], query) >= 0
          add(out, popData.all.raw[i])
          add(nextPool, i)
          # TODO (see nextPool)
          # if len(out) == g:searcher_popup_find_limit
          #   break
          # endif
        endif
      endfor

      popData.shown = out
      popData.prev.query = query
      popData.prev.idx = nextPool
      popData.cache.idx[queryLen] = nextPool
      popData.cache.key[queryLen] = query

    endif
  endif

  # empty line after prompt
  if empty(popData.shown)
    popData.shown = ['']
  endif

  popup_setoptions(popPrompt.id, { title: PopupTitle() })
  popup_settext(popPrompt.id, [popPrompt.prompt .. popPrompt.query .. popPrompt.shape])
  popup_setoptions(id, { firstline: 1, cursorline: 1 })  # reset scroll
  popup_settext(id, popData.shown)

  # echomsg printf('filter: %.1f ms', 1000 * reltimefloat(reltime(t)))
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
  # RestorePos()
enddef
