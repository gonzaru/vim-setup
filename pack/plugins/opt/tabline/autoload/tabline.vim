vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_tabline') || !get(g:, 'tabline_enabled') || &cp
  finish
endif
g:autoloaded_tabline = 1

# my tablabel
def MyTabLabel(arg: number): string
  var buflist = tabpagebuflist(arg)
  var winnr = tabpagewinnr(arg)
  var dirname = fnamemodify(bufname(buflist[winnr - 1]), ":~")
  var dirnamelist = split(dirname, "/")
  var nametail = fnamemodify(dirname, ":t")
  var shortname: string
  var dirchars: string
  var namelen: number
  var count: number
  # exception [No Name]
  if empty(dirname)
    dirchars = "[No Name]"
    if getbufvar(buflist[winnr - 1], "&modified")
      if len(buflist) > 1
        shortname = len(buflist) .. "+" .. " " .. dirchars
      else
        shortname = "+" .. " " .. dirchars
      endif
    else
      if len(buflist) > 1
        shortname = len(buflist) .. " " .. dirchars
      else
       shortname = dirchars
      endif
    endif
    return shortname
  endif
  namelen = len(dirnamelist)
  count = 0
  for d in dirnamelist
    if count < namelen - 1
      if d[0] == '.'
        dirchars ..= d[0 : 1] .. "/"
      else
        dirchars ..= d[0] .. "/"
      endif
    endif
    ++count
  endfor
  if getbufvar(buflist[winnr - 1 ], "&modified")
    if len(buflist) > 1
      if dirname[0] == "/"
        shortname = len(buflist) .. "+" .. " " .. "/" .. dirchars .. nametail
      else
        shortname = len(buflist) .. "+" .. " " .. dirchars .. nametail
      endif
    else
      if dirname[0] == "/"
        dirname = "+" .. " " .. "/" .. dirchars .. nametail
      else
        shortname = "+" .. " " .. dirchars .. nametail
      endif
    endif
  else
    if len(buflist) > 1
      if dirname[0] == "/"
        shortname = len(buflist) .. " " .. "/" .. dirchars .. nametail
      else
        shortname = len(buflist) .. " " .. dirchars .. nametail
      endif
    else
      if dirname[0] == "/"
        shortname = "/" .. dirchars .. nametail
      else
        shortname = dirchars .. nametail
      endif
    endif
  endif
  return shortname
enddef

# my tabline
export def MyTabLine(): string
  var s: string
  for i in range(tabpagenr('$'))
    if i + 1 == tabpagenr()
      s ..= '%#TabLineSel#'
    else
      s ..= '%#TabLine#'
    endif
    s ..= '%' .. (i + 1) .. 'T'
    # s ..= ' %{MyTabLabel(' .. (i + 1) .. ')} '
    s ..= ' %{' .. MyTabLabel->string() .. '(' .. (i + 1) .. ')} '
  endfor
  s ..= '%#TabLineFill#%T'
  return s
enddef
