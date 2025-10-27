vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_statusline') || !get(g:, 'statusline_enabled')
  finish
endif
g:autoloaded_statusline = true

# job queue
final JOB_QUEUE = []

# script local variables
g:statusline_full = ''

# user tmp directory
const TMPDIR = !empty($TMPDIR) ? ($TMPDIR == '/' ? $TMPDIR : substitute($TMPDIR, '/$', '', '')) : '/tmp'

# statusline files
const PID = getpid()
const STATUSLINE_FILES = {
  'git': $"{TMPDIR}/{$USER}-vim-statusline_git-{PID}.log"
}

# get statusline
export def GetStatus(): string
  return g:statusline_full
enddef

# set statusline
export def SetStatus(s: string)
  g:statusline_full = s
enddef

# clear git status file
export def ClearGitStatusFile()
  SetStatus(substitute(GetStatus(), '^ \[[^]]*]', '', ''))
enddef

# get input method options (see help: i_CTRL-^)
export def GetImOptions(kind: string, fsl: bool): string
  var str = ''
  if kind == 'lang'
    if mode() == 'i' && &l:iminsert == 1
      # add spaces for statusline
      str = fsl ? $'{empty(GetStatus()) ? ' ' : '  '}{b:keymap_name}' : b:keymap_name
    endif
  endif
  return str
enddef

# short path: /full/path/to/dir -> /f/p/t/dir
export def ShortPath(path: string): string
  var name = trim(fnamemodify(path, ':~'), '/', 2)
  var nameList = split(name, '/')
  var nameTail = nameList[-1]
  var numSlashes = len(nameList)
  var dirChars: string
  if numSlashes == 1
    return name
  endif
  for d in nameList[0 : numSlashes - 2]
    if d[0] == '.'
      dirChars ..= $'{d[0 : 1]}/'
    else
      dirChars ..= $'{d[0]}/'
    endif
  endfor
  var prefix = name[0] == '/' ? '/' : ''
  var nameShort = $'{prefix}{dirChars}{nameTail}'
  return nameShort
enddef

# statusline git branch
export def GitBranch(file: string): void
  if empty(file)
    return
  endif
  var newJob: job
  if get(g:, 'statusline_gitbranch') && empty(JOB_QUEUE)
    # var cmd = ['git', '--no-pager', 'rev-parse', '--abbrev-ref', 'HEAD']
    var cwd = fnamemodify(file, ':p:h')
    if !isdirectory(cwd)
      SetStatus('')
      return
    endif
    var cmd = ['git', 'status', '--short', '--branch', '--porcelain', file]
    newJob = job_start(cmd, {
      'out_cb': function(OutHandler),
      'err_cb': function(ErrHandler),
      'exit_cb': function(ExitHandler),
      'out_io': 'file',
      'out_name': STATUSLINE_FILES['git'],
      'out_msg': 0,
      'out_modifiable': 0,
      'err_io': 'out',
      'cwd': cwd
    })
    if job_status(newJob) == 'run'
      add(JOB_QUEUE, job_info(newJob)['process'])
    endif
  endif
enddef

# out handler
def OutHandler(channel: channel, message: string)
enddef

# err handler
def ErrHandler(channel: channel, message: string)
enddef

# exit handler for when the job ends
def ExitHandler(job: job, status: number)
  if filereadable(STATUSLINE_FILES['git']) && getfsize(STATUSLINE_FILES['git']) > 0
  && job_info(job)["exitval"] == 0
    var line: string
    var gitOutput = readfile(STATUSLINE_FILES['git'])
    var gitBranch = substitute(gitOutput[0], '^##\s*\([^. ]\+\)\(\.\.\+.*\)\?', '\1', '')
    line = gitBranch
    if get(g:, 'statusline_gitstatusfile') && len(gitOutput) >= 2
      var gitStat = join(split(gitOutput[1], ' ', 1)[0 : -2])
      if !empty(gitStat)
        line = $'[{gitStat}] {gitBranch}'
      endif
    endif
    SetStatus($' {line}')
  else
    SetStatus('')
  endif
  # redraw statusline
  # &l:statusline = &l:statusline
  redrawstatus
  delete(STATUSLINE_FILES['git'])
  var idx = index(JOB_QUEUE, job_info(job)['process'])
  if idx >= 0
    remove(JOB_QUEUE, idx)
  endif
enddef
