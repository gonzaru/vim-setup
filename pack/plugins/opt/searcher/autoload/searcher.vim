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
    'command': join(g:searcher_findprg_command)
  },
  'grepprg': {
    'command': join(g:searcher_grepprg_command)
  },
  'gitprg': {
    'command': join(g:searcher_gitprg_command)
  }
}

# find files, grep and git grep searching
export def Search(...args: list<string>): void
  var cmd: string
  var idx: number
  var kind = args[-2]
  var mode = args[-1]
  var nargs = args
  var prg = COMMANDS[kind]['command']
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
  cmd: join(g:searcher_popup_cmd),
  mode: g:searcher_popup_mode,
  kind: g:searcher_popup_kind
}

# popup
export def Popup(kind: string): void
  # TODO: add grep kind
  if kind != 'find'  # && kind != 'grep'
    return
  endif
  pop.kind = kind
  var ocwd = getcwd()
  pop.cwd = DefaultCwd()
  execute $'lcd {fnameescape(pop.cwd)}'
  var files = systemlist(pop.cmd)
  execute $'lcd {fnameescape(ocwd)}'
  if pop.kind == 'find' && empty(files)
    return
  endif
  pop.all = copy(files)
  pop.shown = copy(files)
  pop.query = ''
  var prompt = '> '
  var id = popup_menu(
    [prompt] + files, {
      title: PopupTitle(),
      pos: 'topleft',
      line: 'cursor+1',
      col: 1,
      minwidth: 40,
      maxheight: 12,
      border: [1, 1, 1, 1],
      close: 'click',
      mapping: false,
      wrap: false,
      cursorline: true,
      filter: function(CompletionFilter),
      callback: function(CompletionPick)
  })
  # select next line (prompt)
  popup_filter_menu(id, "\<Down>")
enddef

# popup title
def PopupTitle(): string
  var cwd = fnamemodify(getcwd(), ':~')
  var counter = $'[{len(pop.shown)}/{len(pop.all)}]'
  var fchars = g:searcher_popup_fuzzy ? '+fuzzy' : '-fuzzy'
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

  # toggle fuzzy
  if key == "\<C-f>"
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
  if empty(query)
    pop.shown = copy(pop.all)
  elseif g:searcher_popup_fuzzy
    pop.shown = matchfuzzy(pop.all, pop.query, { limit: g:searcher_popup_fuzzy_limit })
  else
    var q = tolower(query)
    pop.shown = filter(copy(pop.all), (_, v) => stridx(tolower(v), q) >= 0)
  endif
  var prompt = '> ' .. pop.query
  popup_settext(id, [prompt] + pop.shown)
  popup_setoptions(id, { title: PopupTitle() })
enddef

# completion pick
def CompletionPick(id: number, res: number)
  # 1 prompt line, +1 also for pop.shown
  if res <= 1 || res > len(pop.shown) + 1
    return
  endif
  var picked = $'{pop.cwd}/{pop.shown[res - 2]}'  # -2 instead of -1 (prompt)
  if filereadable(picked)
    execute $"{pop.mode} {fnameescape(picked)}"
  endif
  popup_close(id)
enddef
