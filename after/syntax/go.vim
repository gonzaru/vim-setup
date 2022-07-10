" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
" if exists("b:did_syntax_after")
"   finish
" endif
" let b:did_syntax_after = 1

" only for darkula theme
if g:colors_name !=# "darkula"
  finish
endif

" fmt.Printf("Hello world!")  (matches fmt)
syntax match goCustomFunctionName '\w\+\ze\(\.\w\+\)\+'

" TODO:
" // Add description (Add needs to be bold)
" func Add(

" TODO: sf/sf.go line 77 (int, error) color on int"
