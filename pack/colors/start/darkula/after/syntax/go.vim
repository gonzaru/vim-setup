vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
# if exists("b:current_syntax_after")
#   finish
# endif
# b:current_syntax_after = true

# fmt.Printf("Hello world!") (matches fmt)
if hlexists('goCustomFunctionName')
  syntax clear goCustomFunctionName
  syntax match goCustomFunctionName '\w\+\ze\(\.\w\+\)\+'
endif

# TODO:
# // Add description (Add needs to be bold)
# func Add(

# TODO: sf/sf.go line 77 (int, error) color on int"
