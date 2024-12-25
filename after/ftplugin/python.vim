vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(b:, "did_ftplugin_after")
  finish
endif
b:did_ftplugin_after = true

# see $VIMRUNTIME/ftplugin/python.vim
#^ already done previously

# Python
setlocal syntax=on
# setlocal signcolumn=auto
# setlocal number
# setlocal cursorline
#^ setlocal suffixesadd=.py
#^ setlocal wildignore+=*.pyc
setlocal nowrap
setlocal showbreak=NONE
#^ setlocal tabstop=4
#^ setlocal softtabstop=4
#^ setlocal shiftwidth=4
setlocal shiftround
#^ setlocal expandtab
setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class
#^ setlocal omnifunc=python3complete#Complete
#^ setlocal keywordprg=python3\ -m\ pydoc
setlocal makeprg=pep8\ %
# see :help gq (gqip, gggqG, ...). Also :help 'equalprg' (gg=G, ...)
setlocal formatprg=black\ -S\ -l\ 79\ -q\ 2>/dev/null\ --stdin-filename\ %\ -
# matchadd('ColorColumn', '\%79v', 10)
if g:misc_enabled
  misc#MatchAdd({'group': 'ColorColumn', 'pattern': '\%79v', 'priority': 10})
endif
