vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# see $VIMRUNTIME/syntax/python.vim

# Python
# syntax region Comment start=/'''/ end=/'''/
# syntax region Comment start=/"""/ end=/"""/

syntax region pythonTripleSingleComment start=+'''+ end=+'''+ keepend contains=@Spell
syntax region pythonTripleDoubleComment start=+"""+ end=+"""+ keepend contains=@Spell

highlight default link pythonTripleSingleComment Comment
highlight default link pythonTripleDoubleComment Comment

# b:current_syntax_after = "python"
