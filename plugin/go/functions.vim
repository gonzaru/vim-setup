" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if is already loaded
if exists('g:loaded_go_functions') && g:loaded_go_functions == 1
  finish
endif
let g:loaded_go_functions = 1

" godoc
function! GODoc()
  let l:cword = expand("<cWORD>")
	let l:word = split(l:cword, "(")[0]
	let l:pfile = "(godoc)". l:word

	if empty(l:word)
		echohl ErrorMsg
		echo "word is empty!"
		echohl None
		return 0
	endif
	if bufexists(l:pfile)
		silent execute ":bw! " . l:pfile
	endif
	new
	silent execute ":file " . l:pfile
	setlocal buftype=nowrite
	setlocal bufhidden=hide
	setlocal noswapfile
	setlocal nobuflisted
	silent execute ":0read !go doc " . l:word
	execute ":1"
	let l:curline = getline(".")
	if l:curline =~# "no buildable Go source files"
		bw
		echohl WarningMsg
		echom "No buildable Go source files for " . l:word . "!"
		echohl None
		let v:errmsg = "No buildable Go source files for " . l:word . "!"
	else
		let v:errmsg = ""
	endif
endfunction
