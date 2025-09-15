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
var _gitOutput = []
g:statusline_full = ''

# user tmp directory
# const TMPDIR = !empty($TMPDIR) ? ($TMPDIR == '/' ? $TMPDIR : substitute($TMPDIR, '/$', '', '')) : '/tmp'

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
def ShortPath(path: string): string
  var pathName = fnamemodify(path, ':~')
  var pathNameList = split(pathName, '/')
  var pathNameTail = fnamemodify(pathName, ':t')
  var pathNumSlashes = len(pathNameList)
  var pathNameShort: string
  var dirChars: string
  for d in pathNameList[0 : pathNumSlashes - 2]
    if d[0] == '.'
      dirChars ..= d[0 : 1] .. '/'
    else
      dirChars ..= d[0] .. '/'
    endif
  endfor
  if pathName[0] == '/'
    pathNameShort = '/' .. dirChars .. pathNameTail
  else
    pathNameShort = dirChars .. pathNameTail
  endif
  return pathNameShort
enddef

# statusline git branch
export def GitBranch(file: string): void
  if empty(file)
    return
  endif
  var cwd = fnamemodify(file, ':p:h')
  var newJob: job
  if get(g:, 'statusline_gitbranch') && empty(JOB_QUEUE)
    _gitOutput = []
    # var cmd = ['git', '--no-pager', 'rev-parse', '--abbrev-ref', 'HEAD']
    var cmd = ['git', 'status', '--short', '--branch', file]
    newJob = job_start(cmd, {
      'out_cb': function(OutHandler),
      'err_cb': function(ErrHandler),
      'exit_cb': function(ExitHandler),
      'out_io': 'pipe',
      'out_msg': 0,
      'out_modifiable': 0,
      'err_io': 'out',
      'cwd': cwd
    })
    add(JOB_QUEUE, job_info(newJob)['process'])
  endif
enddef

# out handler
def OutHandler(channel: channel, message: string)
  # output is by parts (lines)
  if !empty(message)
    add(_gitOutput, message)
  endif
enddef

# err handler
def ErrHandler(channel: channel, message: string)
enddef

# exit handler for when the job ends
def ExitHandler(job: job, status: number)
  g:statusline_isgitbranch = false
  if !empty(_gitOutput) && job_info(job)['exitval'] == 0
    g:statusline_isgitbranch = true
    # SetStatus(' {' .. gitBranch .. '}:' .. ShortPath(getcwd()) .. '$')
    var outMsg: string
    var gitBranch = split(_gitOutput[0])[1]
    outMsg = gitBranch
    if get(g:, 'statusline_gitstatusfile') && len(_gitOutput) >= 2
      var gitStat = join(split(_gitOutput[1], ' ', 1)[0 : -2])
      if !empty(gitStat)
        outMsg = $'[{gitStat}] {gitBranch}'
      endif
    endif
    SetStatus($' {outMsg}')
  else
    #SetStatus(substitute(GetStatus(), '^ {\w\+}:.*\$$', '', ''))
    SetStatus('')
  endif
  # redraw statusline
  # &l:statusline = &l:statusline
  redrawstatus
  var idx = index(JOB_QUEUE, job_info(job)['process'])
  if idx >= 0
    remove(JOB_QUEUE, idx)
  endif
enddef
