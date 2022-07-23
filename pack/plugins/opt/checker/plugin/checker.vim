vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded or checker is not enabled
if exists('g:loaded_checker') || !get(g:, 'checker_enabled') || &cp
  finish
endif
g:loaded_checker = 1

# allowed file types
const g:CHECKER_ALLOWED_TYPES = ["sh", "python", "go"]

# signs errors
g:CHECKER_SIGNS_ERRORS = {
  'sh': {
    'sh': 'checker_sh',
    'shellcheck': 'checker_shellcheck'
  },
  'python': {
    'python': 'checker_python',
    'pep8': 'checker_pep8'
  },
  'go': {
    'gofmt': 'checker_go',
    'govet': 'checker_govet'
  }
}

# statusline regex
const REGEX_STATUSLINE = '^\[..=\d*\]\[..=\d*N\?E\?\] '

# autoload
import autoload '../autoload/checker.vim'

# signs
if has("signs")
  # SH
  execute "sign define " .. g:CHECKER_SIGNS_ERRORS['sh']['sh']
    .. " text=✘ texthl=" .. (hlexists('SyntaxErrorSH') ? 'SyntaxErrorSH' : 'ErrorMsg')
  execute "sign define " .. g:CHECKER_SIGNS_ERRORS['sh']['shellcheck']
    .. " text=↪ texthl=" .. (hlexists('SyntaxErrorSHELLCHECK') ? 'SyntaxErrorSHELLCHECK' : 'WarningMsg')

  # Python
  execute "sign define " .. g:CHECKER_SIGNS_ERRORS['python']['python']
    .. " text=✘ texthl=" .. (hlexists('SyntaxErrorPYTHON') ? 'SyntaxErrorPYTHON' : 'ErrorMsg')
  execute "sign define " .. g:CHECKER_SIGNS_ERRORS['python']['pep8']
    .. " text=↪ texthl=" .. (hlexists('SyntaxErrorPEP8') ? 'SyntaxErrorPEP8' : 'WarningMsg')

  # Go
  execute "sign define " .. g:CHECKER_SIGNS_ERRORS['go']['gofmt']
    .. " text=✘ texthl=" .. (hlexists('SyntaxErrorGO') ? 'SyntaxErrorGO' : 'ErrorMsg')
  execute "sign define " .. g:CHECKER_SIGNS_ERRORS['go']['govet']
    .. " text=↪ texthl=" .. (hlexists('SyntaxErrorGOVET') ? 'SyntaxErrorGOVET' : 'WarningMsg')
endif

# SH
if (executable("sh") || executable("bash")) && executable("shellcheck")
  augroup checker_sh
    autocmd!
    # autocmd DiffUpdated FileType sh b:checker_enabled = 0
    autocmd FileType sh autocmd BufWinEnter <buffer> CheckerSHBufWinEnter()
    autocmd FileType sh autocmd BufWritePost <buffer> CheckerSHBufWritePost()
  augroup END
  def CheckerSHBufWinEnter()
    if get(g:, "checker_enabled") && !&diff && !exists('b:fugitive_type')
      checker.SHCheck(expand('<afile>:p'), "read")
      checker.SHShellCheckAsync(expand('<afile>:p'))
    endif
  enddef
  def CheckerSHBufWritePost()
    if get(g:, "checker_enabled")
      checker.SHCheck(expand('<afile>:p'), "write")
      checker.SHShellCheckAsync(expand('<afile>:p'))
   endif
  enddef
endif

# Python
if executable("python3") && executable("pep8")
  augroup checker_python
    autocmd!
    # autocmd DiffUpdated FileType python b:checker_enabled = 0
    autocmd FileType python autocmd BufWinEnter <buffer> CheckerPYBufWinEnter()
    autocmd FileType python autocmd BufWritePost <buffer> CheckerPYBufWritePost()
  augroup END
  def CheckerPYBufWinEnter()
    if get(g:, "checker_enabled") && !&diff && !exists('b:fugitive_type')
      checker.PYCheck(expand('<afile>:p'), "read")
      checker.PYPep8Async(expand('<afile>:p'))
    endif
  enddef
  def CheckerPYBufWritePost()
    if get(g:, "checker_enabled")
      checker.PYCheck(expand('<afile>:p'), "write")
      checker.PYPep8Async(expand('<afile>:p'))
    endif
  enddef
endif

# Go
if executable("go") && executable("gofmt")
  augroup checker_go
    autocmd!
    # autocmd DiffUpdated *.go b:checker_enabled = 0
    autocmd FileType go autocmd BufWinEnter <buffer> CheckerGOBufWinEnter()
    autocmd FileType go autocmd BufWritePost <buffer> CheckerGOBufWritePost()
  augroup END
  def CheckerGOBufWinEnter()
    if get(g:, "checker_enabled") && !&diff && !exists('b:fugitive_type')
      checker.GOCheck(expand('<afile>:p'), "read")
      checker.GOVetAsync(expand('<afile>:p'))
    endif
  enddef
  def CheckerGOBufWritePost()
    if get(g:, "checker_enabled")
      checker.GOCheck(expand('<afile>:p'), "write")
      checker.GOVetAsync(expand('<afile>:p'))
    endif
  enddef
endif

# define mappings
nnoremap <silent> <unique> <script> <Plug>(checker-enable) :CheckerEnable<CR>
nnoremap <silent> <unique> <script> <Plug>(checker-disable) :CheckerDisable<CR>
nnoremap <silent> <unique> <script> <Plug>(checker-toggle) :CheckerToggle<CR>
nnoremap <silent> <unique> <script> <Plug>(checker-signsdebug-cur) <ScriptCmd>checker.SignsDebug(&filetype, 'cur')<CR>
nnoremap <silent> <unique> <script> <Plug>(checker-signsdebug-prev) <ScriptCmd>checker.SignsDebug(&filetype, 'prev')<CR>
nnoremap <silent> <unique> <script> <Plug>(checker-signsdebug-next) <ScriptCmd>checker.SignsDebug(&filetype, 'next')<CR>

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
  command! CheckerEnable {
    g:checker_enabled = 1
    doautocmd BufWinEnter
  }
  command! CheckerDisable {
    g:checker_enabled = 0
    for b in getbufinfo({'buflisted': 1})
      for s in sign_getplaced(b.bufnr)[0].signs
        for f in g:CHECKER_ALLOWED_TYPES
          for [_, v] in items(g:CHECKER_SIGNS_ERRORS[f])
            if v == s.name
              sign_unplace('', {'buffer': b.bufnr, 'id': s.id, 'name': s.name})
            endif
          endfor
        endfor
      endfor
    endfor
    bufdo &statusline = substitute(&statusline, REGEX_STATUSLINE, "", "")
  }
  command! CheckerToggle {
    if g:checker_enabled == 1
      execute "normal! \<Plug>(checker-disable)"
    else
      execute "normal! \<Plug>(checker-enable)"
    endif
    v:statusmsg = "checker=" .. g:checker_enabled
  }
endif
