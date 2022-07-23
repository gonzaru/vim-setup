vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_commentarium') || !get(g:, 'commentarium_enabled') || &cp
  finish
endif
g:autoloaded_commentarium = 1

# prints error message and saves the message in the message-history
def EchoErrorMsg(msg: string)
  if !empty(msg)
    echohl ErrorMsg
    echom  msg
    echohl None
  endif
enddef

# comment by language
export def DoComment()
  var curcol = col('.')
  var curline = line('.')
  if index(["c", "cpp", "java", "sql"], &filetype) >= 0
    execute "normal! I/*\<SPACE>\<ESC>A\<SPACE>*/\<ESC>"
    cursor(curline, curcol + 3)
  elseif index(["go", "php", "javascript"], &filetype) >= 0
    execute "normal! I//\<SPACE>"
    cursor(curline, curcol + 3)
  elseif &filetype == "vim"
    # TODO: detect correctly if running inside a vim9script
    if getline(1) =~ '^vim9script'
      execute "normal! I#\<SPACE>\<ESC>"
    else
      execute "normal! I\"\<SPACE>\<ESC>"
    endif
    cursor(curline, curcol + 2)
  elseif index(["sh", "perl", "python"], &filetype) >= 0
    execute "normal! I#\<SPACE>\<ESC>"
    cursor(curline, curcol + 2)
  elseif index(["html", "xml"], &filetype) >= 0
    execute "normal! I\<!--\<SPACE>\<ESC>A\<SPACE>-->"
    cursor(curline, curcol + 5)
  else
    EchoErrorMsg("Error: commenting filetype '" .. &filetype .. "' is not supported")
  endif
enddef

# uncomment by language
export def UndoComment(): void
  var curcol = col('.')
  var curline = line('.')
  var trimline: string
  var num: number
  if index(["c", "cpp", "java", "sql"], &filetype) >= 0
    execute "normal! ^"
    trimline = trim(getline('.'), " ", 0)
    if trimline[0 : 1] != "/*" || trimline[-2 : -1] != "*/"
      cursor(curline, curcol)
      return
    endif
    num = 2
    if trimline[0 : 2] == "/* " && trimline[-3 : -1] == " */"
      num = 3
    endif
    execute "normal! " .. num .. "x$" .. (num - 1) .. "h" .. num .. "x"
    cursor(curline, curcol - num)
  elseif index(["go", "php", "javascript"], &filetype) >= 0
    execute "normal! ^"
    trimline = trim(getline('.'), " ", 1)
    if trimline[0 : 1] != "//"
      cursor(curline, curcol)
      return
    endif
    num = 2
    if trimline[0 : 2] == "// " && trimline[3] != " "
      num = 3
    endif
    execute "normal! " .. num .. "x"
    cursor(curline, curcol - num)
  elseif &filetype == "vim"
    execute "normal! ^"
    trimline = trim(getline('.'), " ", 1)
    if trimline[0] != '"' && trimline[0] != '#'
      cursor(curline, curcol)
      return
    endif
    num = 1
    if trimline[0 : 1] =~ '^"\|# ' || trimline[0 : 2] =~ '^"\|#  '
      num = 2
    endif
    execute "normal! " .. num .. "x"
    cursor(curline, curcol - num)
  elseif index(["sh", "perl", "python"], &filetype) >= 0
    execute "normal! ^"
    trimline = trim(getline('.'), " ", 1)
    if trimline[0] != "#"
      cursor(curline, curcol)
      return
    endif
    num = 1
    if trimline[0 : 1] == "# " || trimline[0 : 2] == "#  "
      num = 2
    endif
    execute "normal! " .. num .. "x"
    cursor(curline, curcol - num)
  elseif index(["html", "xml"], &filetype) >= 0
    execute "normal! ^"
    trimline = trim(getline('.'), " ", 0)
    if trimline[0 : 4] != "<!-- " || trimline[-4 : -1] != " -->"
      cursor(curline, curcol)
      return
    endif
    num = 5
    execute "normal! " .. num .. "x$xxxx"
    cursor(curline, curcol - num)
  else
    EchoErrorMsg("Error: uncommenting filetype '" .. &filetype .. "' is not supported")
  endif
enddef
