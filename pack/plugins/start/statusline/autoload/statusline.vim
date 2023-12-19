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
const TMPDIR = !empty($TMPDIR) ? ($TMPDIR == "/" ? $TMPDIR : substitute($TMPDIR, "/$", "", "")) : "/tmp"

# statusline files
const STATUSLINE_FILES = {
  'git': $"{TMPDIR}/{$USER}-vim-statusline_git.txt"
}

# get statusline
export def GetStatus(): string
  return g:statusline_full
enddef

# set statusline
export def SetStatus(s: string)
  g:statusline_full = s
enddef

# short path: /full/path/to/dir -> /f/p/t/dir
export def ShortPath(path: string): string
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

# my statusline async
export def MyStatusLineAsync(file: string)
  var newjob: job
  if get(g:, 'statusline_showgitbranch') && empty(JOB_QUEUE)
    newjob = job_start(
      ['git', '--no-pager', 'rev-parse', '--abbrev-ref', 'HEAD'],
      {
        "out_cb": "s:OutHandler",
        "err_cb": "s:ErrHandler",
        "exit_cb": "s:ExitHandler",
        "out_io": "file",
        "out_name": STATUSLINE_FILES['git'],
        "out_msg": 0,
        "out_modifiable": 0,
        "err_io": "out"
      }
    )
    add(JOB_QUEUE, job_info(newjob)['process'])
  endif
enddef

# def OutHandler(channel: channel, message: string)
# enddef

# def ErrHandler(channel: channel, message: string)
# enddef

# exit handler for when the job ends
def ExitHandler(job: job, status: number)
  var idx: number
  var gitbranch: string
  if filereadable(STATUSLINE_FILES['git'])
    if getfsize(STATUSLINE_FILES['git']) > 0 && job_info(job)["exitval"] == 0
      gitbranch = readfile(STATUSLINE_FILES['git'])[0]
      SetStatus(" {" .. gitbranch .. "}:" .. ShortPath(getcwd()) .. '$')
    else
      SetStatus(substitute(GetStatus(), '^ {\w\+}:.*\$$', "", ""))
    endif
    # redraw statusline
    &l:statusline = &l:statusline
    delete(STATUSLINE_FILES['git'])
  endif
  idx = index(JOB_QUEUE, job_info(job)["process"])
  if idx >= 0
    remove(JOB_QUEUE, idx)
  endif
enddef
