vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_statusline') || !get(g:, 'statusline_enabled')
  finish
endif
g:autoloaded_statusline = true

# job queue
final JOB_QUEUE1 = []
final JOB_QUEUE2 = []

# script local variables
g:statusline_full = ''

# user tmp directory
const TMPDIR = !empty($TMPDIR) ? ($TMPDIR == "/" ? $TMPDIR : substitute($TMPDIR, "/$", "", "")) : "/tmp"

# statusline files
const pid = getpid()
const STATUSLINE_FILES = {
  'git': $"{TMPDIR}/{$USER}-vim-statusline_git-{pid}.log"
}

# get statusline
export def GetStatus(): string
  return g:statusline_full
enddef

# set statusline
export def SetStatus(s: string)
  g:statusline_full = s
enddef

# get input method options (see help: i_CTRL-^)
export def GetImOptions(kind: string, fsl: bool): string
  var str = ""
  if kind == "lang"
    if mode() == "i" && &l:iminsert == 1
      # add spaces for statusline
      str = fsl ? $"{empty(GetStatus()) ? ' ' : '  '}{b:keymap_name}" : b:keymap_name
    endif
  endif
  return str
enddef

# short path: /full/path/to/dir -> /f/p/t/dir
def ShortPath(path: string): string
  var pathname = fnamemodify(path, ":~")
  var pathnamelist = split(pathname, "/")
  var pathnametail = fnamemodify(pathname, ":t")
  var pathnumslashes = len(pathnamelist)
  var pathnameshort: string
  var dirchars: string
  for d in pathnamelist[0 : pathnumslashes - 2]
    if d[0] == '.'
      dirchars ..= d[0 : 1] .. "/"
    else
      dirchars ..= d[0] .. "/"
    endif
  endfor
  if pathname[0] == "/"
    pathnameshort = "/" .. dirchars .. pathnametail
  else
    pathnameshort = dirchars .. pathnametail
  endif
  return pathnameshort
enddef

# statusline git branch
export def GitBranch(file: string): void
  if empty(file)
    return
  endif
  var cwddir = fnamemodify(file, ':p:h')
  var newjob: job
  if get(g:, 'statusline_showgitbranch') && empty(JOB_QUEUE1)
    newjob = job_start(
      ['git', '--no-pager', 'rev-parse', '--abbrev-ref', 'HEAD'],
      {
        "out_cb": function(OutHandler1),
        "err_cb": function(ErrHandler1),
        "exit_cb": function(ExitHandler1),
        "out_io": "file",
        "out_name": STATUSLINE_FILES['git'],
        "out_msg": 0,
        "out_modifiable": 0,
        "err_io": "out",
        "cwd": cwddir
      }
    )
    add(JOB_QUEUE1, job_info(newjob)['process'])
  endif
enddef

# out handler1
def OutHandler1(channel: channel, message: string)
enddef

# err handler1
def ErrHandler1(channel: channel, message: string)
enddef

# exit handler1 for when the job ends
def ExitHandler1(job: job, status: number)
  var gitbranch: string
  g:statusline_isgitbranch = false
  if filereadable(STATUSLINE_FILES['git']) && getfsize(STATUSLINE_FILES['git']) > 0
  && job_info(job)["exitval"] == 0
    g:statusline_isgitbranch = true
    gitbranch = readfile(STATUSLINE_FILES['git'])[0]
    SetStatus(" {" .. gitbranch .. "}:" .. ShortPath(getcwd()) .. '$')
  else
    #SetStatus(substitute(GetStatus(), '^ {\w\+}:.*\$$', "", ""))
    SetStatus("")
  endif
  # redraw statusline
  # &l:statusline = &l:statusline
  redrawstatus
  delete(STATUSLINE_FILES['git'])
  var idx = index(JOB_QUEUE1, job_info(job)["process"])
  if idx >= 0
    remove(JOB_QUEUE1, idx)
  endif
enddef

# statusline git status file
export def GitStatusFile(file: string)
  var cwddir = fnamemodify(file, ':p:h')
  var newjob: job
  if get(g:, 'statusline_showgitbranch') && empty(JOB_QUEUE2)
    newjob = job_start(
      ['git', 'diff', '--quiet', file],
      {
        "out_cb": function(OutHandler2),
        "err_cb": function(ErrHandler2),
        "exit_cb": function(ExitHandler2),
        "out_io": "null",
        "out_msg": 0,
        "out_modifiable": 0,
        "err_io": "null",
        "cwd": cwddir
      }
    )
    add(JOB_QUEUE2, job_info(newjob)['process'])
  endif
enddef

# out handler2
def OutHandler2(channel: channel, message: string)
enddef

# err handler2
def ErrHandler2(channel: channel, message: string)
enddef

# exit handler2 for when the job ends
def ExitHandler2(job: job, status: number)
  # 1 (modified)
  if job_info(job)["exitval"] == 1
    SetStatus($" [M]" .. substitute(GetStatus(), '^ \[M]', "", ""))
  else
    SetStatus(substitute(GetStatus(), '^ \[M]', "", ""))
  endif
  redrawstatus
  var idx = index(JOB_QUEUE2, job_info(job)["process"])
  if idx >= 0
    remove(JOB_QUEUE2, idx)
  endif
enddef
