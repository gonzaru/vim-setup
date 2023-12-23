vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'loaded_habit') || !get(g:, 'habit_enabled')
  finish
endif
g:loaded_habit = true

# global variables
if !exists('g:habit_mode')
  g:habit_mode = 'soft'
endif

# autoload
import autoload '../autoload/habit.vim'

# define mappings
nnoremap <silent> <script> <Plug>(habit-enable) <ScriptCmd>habit.Enable()<CR>
nnoremap <silent> <script> <Plug>(habit-disable) <ScriptCmd>habit.Disable()<CR>
nnoremap <silent> <script> <Plug>(habit-toggle) <ScriptCmd>habit.Toggle()<CR>

# set mappings
if get(g:, 'habit_no_mappings') == 0
  if empty(mapcheck("<leader>he", "n"))
    nnoremap <leader>he <Plug>(habit-enable)
  endif
  if empty(mapcheck("<leader>hd", "n"))
    nnoremap <leader>hd <Plug>(habit-disable)
  endif
  if empty(mapcheck("<leader>ht", "n"))
    nnoremap <leader>ht <Plug>(habit-toggle)
  endif
endif

# set commands
if get(g:, 'habit_no_commands') == 0
  command! HabitEnable execute "normal \<Plug>(habit-enable)"
  command! HabitDisable execute "normal \<Plug>(habit-disable)"
  command! HabitToggle execute "normal \<Plug>(habit-toggle)"
endif
