vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_calculator') || !get(g:, 'calculator_enabled')
  finish
endif
g:loaded_calculator = true

# autoload
import autoload '../autoload/calculator.vim'

# define mappings
nnoremap <silent> <script> <Plug>(calculator-run) <ScriptCmd>calculator.Run()<CR>
nnoremap <silent> <script> <Plug>(calculator-evaluate) <ScriptCmd>calculator.Evaluate()<CR>
nnoremap <silent> <script> <Plug>(calculator-close) <ScriptCmd>calculator.Close()<CR>

# set mappings
if !get(g:, 'calculator_no_mappings')
  if empty(mapcheck("<leader>qr", "n"))
    nnoremap <leader>qr <Plug>(calculator-run)
  endif
  if empty(mapcheck("<leader>qc", "n"))
    nnoremap <leader>qc <Plug>(calculator-close)
  endif
  if empty(mapcheck("<leader>qc", "i"))
    inoremap <leader>qc <C-o><Plug>(calculator-close)
  endif
endif

# set commands
if !get(g:, 'calculator_no_commands')
  command! Calculator execute "normal \<Plug>(calculator-run)"
  command! CalculatorClose execute "normal \<Plug>(calculator-close)"
endif
