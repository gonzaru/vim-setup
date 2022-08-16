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
  var winnr = tabpagewinnr(arg)
  var tabbuflist = tabpagebuflist(arg)
  var tabbuflistlen = len(tabbuflist)
  var tabsymbol = getbufvar(tabbuflist[winnr - 1], "&modified") ? "+" : ""
  var bufname = bufname(tabbuflist[winnr - 1])
  var pathname = fnamemodify(bufname, ":~")
  var pathnamelist = split(pathname, "/")
  var pathnametail = fnamemodify(pathname, ":t")
  var pathnumlashes = len(pathnamelist)
  var pathnameshort: string
  var dirchars: string
  # exception [No Name]
  if empty(bufname)
    dirchars = "[No Name]"
    pathnameshort = !empty(tabsymbol) ? tabsymbol .. " " .. dirchars : dirchars
  else
    for d in pathnamelist[0 : pathnumlashes - 2]
      if d[0] == '.'
        dirchars ..= d[0 : 1] .. "/"
      else
        dirchars ..= d[0] .. "/"
      endif
    endfor
    if pathname[0] == "/"
      pathnameshort = (tabbuflistlen > 0 ? tabbuflistlen : "") .. tabsymbol .. " " .. "/" .. dirchars .. pathnametail
    else
      pathnameshort = (tabbuflistlen > 0 ? tabbuflistlen : "") .. tabsymbol .. " " .. dirchars .. pathnametail
    endif
  endif
  return pathnameshort
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
    s ..= ' %{' .. MyTabLabel->string() .. '(' .. (i + 1) .. ')} '
  endfor
  s ..= '%#TabLineFill#%T'
  return s
enddef
