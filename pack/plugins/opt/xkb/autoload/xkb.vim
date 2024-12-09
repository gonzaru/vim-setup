vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_xkb') || !get(g:, 'xkb_enabled')
  finish
endif
g:autoloaded_xkb = true

# job queue
final JOB_QUEUE = []

# prints the error message and saves the message in the message-history
def EchoErrorMsg(msg: string)
  if !empty(msg)
    echohl ErrorMsg
    echom msg
    echohl None
  endif
enddef

# run commands
def Run(mode: string, cmd: list<any>)
  var newjob: job
  if mode == "job" && empty(JOB_QUEUE)
    newjob = job_start(cmd, {"exit_cb": "s:ExitHandler"})
    add(JOB_QUEUE, job_info(newjob)['process'])
  elseif mode == "shell"
    # silent! to avoid some terminal garbage (see :h xterm-focus-event)
    silent! system(join(cmd))
    if v:shell_error != 0
      EchoErrorMsg($"Error: cmd failed '{cmd}' with exitval '{v:shell_error}'")
    endif
  endif
enddef

# exit handler for when the job ends
def ExitHandler(job: job, status: number)
  var idx: number
  var exitval = job_info(job)["exitval"]
  if exitval != 0
    EchoErrorMsg($"Error: job failed '{job_info(job)["cmd"]}' with exitval '{exitval}'")
  endif
  idx = index(JOB_QUEUE, job_info(job)["process"])
  if idx >= 0
    remove(JOB_QUEUE, idx)
  endif
enddef

# switch xkb layout
export def Layout(autocmd: list<any>, action: string, mode: string): void
  var cmd: list<any>
  if empty(g:xkb_cmd_layout_first) || empty(g:xkb_layout_next)
    return
  endif
  if action == "next"
    cmd = g:xkb_cmd_layout_next
    g:xkb_layout_current = g:xkb_layout_next
  else
    cmd = g:xkb_cmd_layout_first
    g:xkb_layout_current = g:xkb_layout_first
  endif
  if g:xkb_debug_info && !empty(autocmd)
    writefile(autocmd, g:xkb_debug_file, "a")
  endif
  Run(mode, cmd)
enddef

# toggle xkb layout
export def ToggleLayout(): void
  if empty(g:xkb_cmd_layout_first) || empty(g:xkb_layout_next)
    return
  endif
  if g:xkb_layout_current == g:xkb_layout_first
      Layout([], "next", "job")
  else
      Layout([], "first", "job")
  endif
  g:xkb_enabled = !g:xkb_enabled
  v:statusmsg = $"xkb={g:xkb_enabled}"
enddef
