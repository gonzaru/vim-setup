vim9script
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if exists('g:autoloaded_commentarium') || !get(g:, 'commentarium_enabled') || &cp
  finish
endif
g:autoloaded_commentarium = 1

# allowed file types
const COMMENT_C_STYLE_BLOCK = ["c", "cpp", "java", "sql"]
const COMMENT_C_STYLE_LINE = ["go", "php", "javascript"]
const COMMENT_HASH_STYLE = ["sh", "perl", "python"]
const COMMENT_HTML_TAG = ["html", "xml"]
const COMMENT_VIM = ["vim"]

# prints error message and saves the message in the message-history
def EchoErrorMsg(msg: string)
  if !empty(msg)
    echohl ErrorMsg
    echom  msg
    echohl None
  endif
enddef

# comment C-style block /* comment */
def CommentCStyleBlock(line: number, col: number)
  cursor(line, col)
  execute "normal! ^"
  execute "normal! I/*\<SPACE>\<ESC>A\<SPACE>*/\<ESC>"
  cursor(line, col + 3)
enddef

# comment C-style line // comment
def CommentCStyleLine(line: number, col: number)
  cursor(line, col)
  execute "normal! ^"
  execute "normal! I//\<SPACE>"
  cursor(line, col + 3)
enddef

# comment hash style # comment
def CommentHashStyle(line: number, col: number)
  cursor(line, col)
  execute "normal! ^"
  execute "normal! I#\<SPACE>\<ESC>"
  cursor(line, col + 2)
enddef

# comment HTML tag <!-- comment -->
def CommentHtmlTag(line: number, col: number)
  cursor(line, col)
  execute "normal! ^"
  execute "normal! I\<!--\<SPACE>\<ESC>A\<SPACE>-->"
  cursor(line, col + 5)
enddef

# comment Vim legacy " comment or Vim9 # comment
def CommentVim(line: number, col: number)
  cursor(line, col)
  execute "normal! ^"
  # TODO: detect more precisely if running inside a vim9script
  if getline(1) =~ '^vim9script'
    execute "normal! I#\<SPACE>\<ESC>"
  else
    execute "normal! I\"\<SPACE>\<ESC>"
  endif
  cursor(line, col + 2)
enddef

# uncomment C-style block /* comment */
def UndoCommentCStyleBlock(line: number, col: number): void
  var repeat: number
  var trimline: string
  cursor(line, col)
  execute "normal! ^"
  trimline = trim(getline(line))
  if trimline[0 : 1] != "/*" || trimline[-2 : -1] != "*/"
    cursor(line, col)
    return
  endif
  repeat = trimline[0 : 2] == "/* " && trimline[-3 : -1] == " */" ? 3 : 2
  execute "normal! " .. repeat .. "x$" .. (repeat - 1) .. "h" .. repeat .. "x"
  cursor(line, col - repeat)
enddef

# uncomment C-style line // comment
def UndoCommentCStyleLine(line: number, col: number): void
  var repeat: number
  var trimline: string
  cursor(line, col)
  execute "normal! ^"
  trimline = trim(getline(line))
  if trimline[0 : 1] != "//"
    cursor(line, col)
    return
  endif
  repeat = trimline[0 : 2] == "// " && trimline[3] != " " ? 3 : 2
  execute "normal! " .. repeat .. "x"
  cursor(line, col - repeat)
enddef

# uncomment hash style # comment
def UndoCommentHashStyle(line: number, col: number): void
  var repeat: number
  var trimline: string
  cursor(line, col)
  execute "normal! ^"
  trimline = trim(getline(line))
  if trimline[0] != "#"
    cursor(line, col)
    return
  endif
  repeat = trimline[0 : 1] == "# " || trimline[0 : 2] == "#  " ? 2 : 1
  execute "normal! " .. repeat .. "x"
  cursor(line, col - repeat)
enddef

# uncomment HTML tag <!-- comment -->
def UndoCommentHtmlTag(line: number, col: number): void
  var repeat: number
  var trimline: string
  cursor(line, col)
  execute "normal! ^"
  trimline = trim(getline(line))
  if trimline[0 : 4] != "<!-- " || trimline[-4 : -1] != " -->"
    cursor(line, col)
    return
  endif
  repeat = 5
  execute "normal! " .. repeat .. "x$xxxx"
  cursor(line, col - repeat)
enddef

# uncomment Vim legacy " comment or vim9 # comment
def UndoCommentVim(line: number, col: number): void
  var repeat: number
  var trimline: string
  cursor(line, col)
  execute "normal! ^"
  trimline = trim(getline(line))
  if trimline[0] != '"' && trimline[0] != '#'
    cursor(line, col)
    return
  endif
  repeat = trimline[0 : 1] =~ '^"\|# ' || trimline[0 : 2] =~ '^"\|#  ' ? 2 : 1
  execute "normal! " .. repeat .. "x"
  cursor(line, col - repeat)
enddef

# comment by language
export def DoComment(line: number, col: number)
  if index(COMMENT_C_STYLE_BLOCK, &filetype) >= 0
    CommentCStyleBlock(line, col)
  elseif index(COMMENT_C_STYLE_LINE, &filetype) >= 0
    CommentCStyleLine(line, col)
  elseif index(COMMENT_HASH_STYLE, &filetype) >= 0
    CommentHashStyle(line, col)
  elseif index(COMMENT_HTML_TAG, &filetype) >= 0
    CommentHtmlTag(line, col)
  elseif index(COMMENT_VIM, &filetype) >= 0
    CommentVim(line, col)
  else
    EchoErrorMsg("Error: commenting filetype '" .. &filetype .. "' is not supported")
  endif
enddef

# comment by language with range
export def DoCommentRange(start: number, end: number, pos: list<number>)
  for line in range(start, end)
    DoComment(line, pos[2])
  endfor
  cursor(pos[1], pos[2])
enddef

# uncomment by language
export def UndoComment(line: number, col: number): void
  if index(COMMENT_C_STYLE_BLOCK, &filetype) >= 0
    UndoCommentCStyleBlock(line, col)
  elseif index(COMMENT_C_STYLE_LINE, &filetype) >= 0
    UndoCommentCStyleLine(line, col)
  elseif index(COMMENT_HASH_STYLE, &filetype) >= 0
    UndoCommentHashStyle(line, col)
  elseif index(COMMENT_HTML_TAG, &filetype) >= 0
    UndoCommentHtmlTag(line, col)
  elseif index(COMMENT_VIM, &filetype) >= 0
    UndoCommentVim(line, col)
  else
    EchoErrorMsg("Error: uncommenting filetype '" .. &filetype .. "' is not supported")
  endif
enddef

# uncomment by language with range
export def UndoCommentRange(start: number, end: number, pos: list<number>)
  for line in range(start, end)
    UndoComment(line, pos[2])
  endfor
  cursor(pos[1], pos[2])
enddef
