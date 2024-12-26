vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
# if !empty(get(b:, "current_syntax_after"))
#   finish
# endif

# fmt.Printf("Hello world!") (matches fmt)
if hlexists('goCustomFunctionName1')
  syntax clear goCustomFunctionName1
  syntax match goCustomFunctionName1 '\w\+\ze\.'
endif

# TODO:
# // Add description (Add needs to be bold)
# func Add(

# TODO: sf/sf.go line 77 (int, error) color on int"

b:current_syntax_after = "go"
