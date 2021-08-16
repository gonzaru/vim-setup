" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if is already loaded
if exists('g:loaded_py3_functions') && g:loaded_py3_functions == 1
  finish
endif
let g:loaded_py3_functions = 1

" python doc
function! PYDoc()
	let l:cword = expand("<cWORD>")
	let l:word = split(l:cword, "(")[0]
	let l:pfile = "(pydoc)". l:word
	if empty(l:word)
		echohl ErrorMsg
		echom "Error: word is empty"
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
	silent execute ":0read !python3 -m pydoc " . l:word
	execute ":1"
	let l:curline = getline(".")
	if l:curline =~# "No Python documentation found for"
		bw
		let v:errmsg = "Warning: no Python documentation found for " . l:word
		echohl WarningMsg
		echom v:errmsg
		echohl None
	else
		let v:errmsg = ''
	endif
endfunction
