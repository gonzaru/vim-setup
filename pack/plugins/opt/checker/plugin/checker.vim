vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded or checker is not enabled
if get(g:, 'loaded_checker') || !get(g:, 'checker_enabled')
  finish
endif
g:loaded_checker = true

# language tool
const TOOL = {
  'sh': {
    'default': 'sh',
    'exttool': 'shellcheck'
  },
  'python': {
    'default': 'python',
    'exttool': 'pep8'
  },
  'go': {
    'default': 'go',
    'exttool': 'govet'
  }
}

# global variables
if !exists('g:checker_showpopup')
  g:checker_showpopup = true
endif

# autoload
import autoload '../autoload/checker.vim'

# signs
if has("signs")
  checker.CreateSigns()
endif

# SH
if (executable("sh") || executable("bash")) && executable(TOOL['sh']['exttool'])
  augroup checker_sh
    autocmd!
    # autocmd DiffUpdated FileType sh b:checker_enabled = false
    autocmd FileType sh {
      autocmd BufWinEnter <buffer> noautocmd
      \ checker.DoChecker("sh", TOOL['sh']['default'], TOOL['sh']['exttool'], expand('<afile>:p'), "read")
    }
    autocmd FileType sh {
      autocmd BufWriteCmd <buffer> noautocmd
      \ checker.DoChecker("sh", TOOL['sh']['default'], TOOL['sh']['exttool'], expand('<afile>:p'), "write")
    }
  augroup END
endif

# Python
if executable("python3") && executable(TOOL['python']['exttool'])
  augroup checker_python
    autocmd!
    # autocmd DiffUpdated FileType python b:checker_enabled = false
    autocmd FileType python {
      autocmd BufWinEnter <buffer> noautocmd
      \ checker.DoChecker("python", TOOL['python']['default'], TOOL['python']['exttool'], expand('<afile>:p'), "read")
    }
    autocmd FileType python {
      autocmd BufWriteCmd <buffer> noautocmd
      \ checker.DoChecker("python", TOOL['python']['default'], TOOL['python']['exttool'], expand('<afile>:p'), "write")
    }
  augroup END
endif

# Go
if executable("go") && executable("gofmt")
  augroup checker_go
    autocmd!
    # autocmd DiffUpdated *.go b:checker_enabled = false
    autocmd FileType go {
      autocmd BufWinEnter <buffer> noautocmd
      \ checker.DoChecker("go", TOOL['go']['default'], TOOL['go']['exttool'], expand('<afile>:p'), "read")
    }
    autocmd FileType go {
      autocmd BufWriteCmd <buffer> noautocmd
      \ checker.DoChecker("go", TOOL['go']['default'], TOOL['go']['exttool'], expand('<afile>:p'), "write")
    }
  augroup END
endif

# define mappings
nnoremap <silent> <unique> <script> <Plug>(checker-enable) <ScriptCmd>checker.Enable()<CR>
nnoremap <silent> <unique> <script> <Plug>(checker-disable) <ScriptCmd>checker.Disable()<CR>
nnoremap <silent> <unique> <script> <Plug>(checker-toggle) <ScriptCmd>checker.Toggle()<CR>
nnoremap <silent> <unique> <script> <Plug>(checker-signsdebug-cur)
\ <ScriptCmd>checker.SignsDebug(&filetype, TOOL[&filetype]['default'], TOOL[&filetype]['exttool'], 'cur')<CR>
nnoremap <silent> <unique> <script> <Plug>(checker-signsdebug-prev)
\ <ScriptCmd>checker.SignsDebug(&filetype, TOOL[&filetype]['default'], TOOL[&filetype]['exttool'], 'prev')<CR>
nnoremap <silent> <unique> <script> <Plug>(checker-signsdebug-next)
\ <ScriptCmd>checker.SignsDebug(&filetype, TOOL[&filetype]['default'], TOOL[&filetype]['exttool'], 'next')<CR>

# set mappings
if get(g:, 'checker_no_mappings') == 0
  # signs debug information
  if empty(mapcheck("<F6>", "n"))
    nnoremap <buffer><F6> <Plug>(checker-signsdebug-cur)
  endif
  if empty(mapcheck("<leader>ec", "n"))
    nnoremap <buffer><leader>ec <Plug>(checker-signsdebug-cur)
  endif
  if empty(mapcheck("<F7>", "n"))
    nnoremap <buffer><F7> <Plug>(checker-signsdebug-prev)
  endif
  if empty(mapcheck("<leader>ep", "n"))
    nnoremap <buffer><leader>ep <Plug>(checker-signsdebug-prev)
  endif
  if empty(mapcheck("<F8>", "n"))
    nnoremap <buffer><F8> <Plug>(checker-signsdebug-next)
  endif
  if empty(mapcheck("<leader>en", "n"))
    nnoremap <buffer><leader>en <Plug>(checker-signsdebug-next)
  endif
  # toggle
  if empty(mapcheck("<leader>tgk", "n"))
    nnoremap <leader>tgk <Plug>(checker-toggle):echo v:statusmsg<CR>
  endif
endif

# set commands
if get(g:, 'checker_no_commands') == 0
  command! CheckerEnable execute "normal \<Plug>(checker-enable)"
  command! CheckerDisable execute "normal \<Plug>(checker-disable)"
  command! CheckerToggle execute "normal \<Plug>(checker-toggle)"
endif
