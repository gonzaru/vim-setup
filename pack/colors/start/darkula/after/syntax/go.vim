vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# fmt.Printf("Hello world!") (matches fmt)
if hlexists('goCustomFunctionName1')
  syntax clear goCustomFunctionName1
endif
syntax match goCustomFunctionName1 '\w\+\ze\.'

# TODO:
# // Add description (Add needs to be bold)
# func Add(

# TODO: sf/sf.go line 77 (int, error) color on int"

# b:current_syntax_after = "go"
