" by Gonzaru
" Distributed under the terms of the GNU General Public License v3

" do not read the file if it is already loaded
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

" see $VIMRUNTIME/indent/yaml.vim
" YAML
setlocal nosmartindent
