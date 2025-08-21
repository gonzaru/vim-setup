vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_lsp') || !get(g:, 'lsp_enabled')
  finish
endif
g:autoloaded_lsp = true

# supported languages
const LANGUAGES = {
  'go': 1,
  'python': 2,
  'terraform': 3
}

# id
def ID(lang: string): number
  if !has_key(LANGUAGES, lang)
    throw $"lsp: server language '{lang}' is not supported"
  endif
  return LANGUAGES[lang]
enddef

# id request
const ID_REQUEST_INITIALIZE = 1
const ID_REQUEST_TEXT_DOCUMENT_COMPLETION = 2
const ID_REQUEST_TEXT_DOCUMENT_DEFINITION = 3
const ID_REQUEST_TEXT_DOCUMENT_REFERENCES = 4
const ID_REQUEST_TEXT_DOCUMENT_RENAME = 5
const ID_REQUEST_TEXT_DOCUMENT_HOVER = 6
const ID_REQUEST_SHUTDOWN = 99

# kinds
const DEFAULT_KINDS = {
   '1': 't', # Text
   '2': 'm', # Method
   '3': 'f', # Function
   '4': 'C', # Constructor
   '5': 'F', # Field
   '6': 'v', # Variable
   '7': 'c', # Class
   '8': 'i', # Interface
   '9': 'M', # Module
  '10': 'p', # Property
  '11': 'u', # Unit
  '12': 'V', # Value
  '13': 'e', # Enum
  '14': 'k', # Keyword
  '15': 'S', # Snippet
  '16': 'C', # Color
  '17': 'f', # File
  '18': 'r', # Reference
  '19': 'F', # Folder
  '20': 'E', # EnumMember
  '21': 'd', # Constant
  '22': 's', # Struct
  '23': 'E', # Event
  '24': 'o', # Operator
  '25': 'T', # TypeParameter
  '26': 'B', # Buffer
}

# default server
const defaultServer = {
  'id': 0,
  'name': '',
  'cmd': "",
  'args': [],
  'desc': '',
  'language': '',
  'running': false,
  'ready': false,
  'job': null,
  'channel': null,
  'uri': null,
  'pid': null,
  'rootPath': '', # update on request
  'rootUri': '',  # update on request
  'waitInit': false,
  'version': 1
}

# new server config
def NewServer(overrides: dict<any>): dict<any>
  return extend(deepcopy(defaultServer), overrides, 'force')
enddef

# servers
var servers: dict<dict<any>> = {}

# gopls
servers[LANGUAGES['go']] = NewServer({
  'id': LANGUAGES['go'],
  'name': "gopls",
  'cmd': "gopls",
  'args': [],
  'desc': "The official language server for Go",
  'language': "go"
})

# pyright
servers[LANGUAGES['python']] = NewServer({
  'id': LANGUAGES['python'],
  'name': "pyright",
  'cmd': "pyright-langserver",
  'args': ["--stdio"],
  'desc': "Static type checker for Python",
  'language': "python"
})

# terraform-ls
servers[LANGUAGES['terraform']] = NewServer({
  'id': LANGUAGES['terraform'],
  'name': "terraform-ls",
  'cmd': "terraform-ls",
  'args': ["serve", "-log-file=/dev/null"],
  'desc': "The official Terraform language server",
  'language': "terraform",
  'waitInit': true
})

# prints the error message and saves the message in the message-history
def EchoErrorMsg(msg: string)
  if !empty(msg)
    echohl ErrorMsg
    echom msg
    echohl None
  endif
enddef

# prints the warning message and saves the message in the message-history
def EchoWarningMsg(msg: string)
  if !empty(msg)
    echohl WarningMsg
    echom msg
    echohl None
  endif
enddef

# running servers
def RunningServers(): list<string>
  var svrs = []
  for k in keys(servers)
    if servers[k].running
      add(svrs, servers[k].name)
    endif
  endfor
  return svrs
enddef

# enable plugin
export def Enable()
  g:lsp_enabled = true
  g:lsp_complementum = true  # complementum plugin
  v:statusmsg = "lsp enabled"
enddef

# disable plugin
export def Disable()
  g:lsp_enabled = false
  g:lsp_complementum = false  # complementum plugin
  v:statusmsg = "lsp disabled"
enddef

# running server
def RunningServer(name: string): bool
  return index(RunningServers(), name) >= 0
enddef

# running
export def Running()
  var server = servers[ID(&filetype)]
  echo $"{server.name}: {server.running}"
enddef

# ready
export def Ready()
  var server = servers[ID(&filetype)]
  echo $"{server.name}: {server.ready}"
enddef

# pre-check requisites
def PreCheck(server: dict<any>): string
  if !has_key(LANGUAGES, &filetype)
    return $"lsp: the filetype '{&filetype}' is not supported"
  endif
  if !executable(server.cmd)
    return $"server: {server.cmd} command not found"
  endif
  if RunningServer(server.name)
    return $"server: {server.name} is already running"
  endif
  return ""
enddef

# check server
def CheckServer(server: dict<any>): string
  if !server.running
    return $"server: {server.name} is not running"
  endif
  if !server.ready
    return $"server: {server.name} is not ready"
  endif
  return ""
enddef

# start server
export def Start(): void
  var server = servers[ID(&filetype)]
  var err = PreCheck(server)
  if !empty(err)
    EchoErrorMsg(err)
    return
  endif
  var job = job_start(server.cmd .. ' ' .. join(server.args), {
    'in_mode': 'lsp',
    'out_mode': 'lsp',
    'err_mode': 'raw',
    'noblock': 1,
    'out_cb': function(OutHandler, [server]),
    'err_cb': function(ErrHandler, [server]),
    'exit_cb': function(ExitHandler, [server])
  })
  if job_status(job) == "fail"
    EchoErrorMsg($"{server.name} failed to start")
    return
  endif
  server.job = job
  server.channel = job_getchannel(job)
  server.pid = job_info(job)['process']
  server.running = true
  RequestInitialize(server)
enddef

# stop server
export def Stop(sid: number = -1): void
  const id = sid == -1 ? ID(&filetype) : sid
  var server = servers[id]
  var err = CheckServer(server)
  if !empty(err)
    EchoWarningMsg(err)
    return
  endif
  ch_sendexpr(server.channel, {
    jsonrpc: '2.0',
    id: ID_REQUEST_SHUTDOWN,
    method: 'shutdown',
    params: v:null
  })
  ch_sendexpr(server.channel, {
    jsonrpc: '2.0',
    method: 'exit',
    params: v:null
  })
  if has_key(server, 'job') && server.job isnot 0
    job_stop(server.job)
  endif
  # cleanup
  server.ready = false
  server.running = false
enddef

# stop all servers
export def StopAll()
  var num = 0
  var svrs = []
  for k in keys(servers)
    if servers[k].running
      Stop(servers[k].id)
      add(svrs, servers[k].name)
      ++num
    endif
  endfor
  sleep! 200m
  echomsg $"lsp: ({num}) servers stopped: {join(svrs, ',')}"
enddef

# restart server
export def Restart()
  Stop()
  sleep! 200m
  Start()
enddef

# server info
export def Info(): void
  if !executable("jq")
    echo servers
    input('Press ENTER to continue')
    return
  endif
  var scopy = deepcopy(servers)
  for k in keys(scopy)
    for f in ['job', 'channel']
      if has_key(scopy[k], f)
        remove(scopy[k], f)
      endif
    endfor
  endfor
  var jdict = json_encode(scopy)
  new
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
  setlocal filetype=json
  setline(1, [jdict])
  execute 'silent :%!jq .'
enddef

# get the current line and column
def GetCurPos(): list<number>
  var pos = getcurpos()
  var line0 = pos[1] - 1
  var byteCol0 = pos[2] - 1
  var lineText = getline(line0 + 1)
  var prefix = strpart(lineText, 0, byteCol0)
  var u16 = 0
  for ch in split(prefix, '\zs')
    var cp = char2nr(ch)
    u16 += (cp > 0xFFFF ? 2 : 1)
  endfor
  return [line0, u16]
enddef

# request did change
def RequestDidChange(server: dict<any>)
  server.version += 1
  var buftext = join(getline(1, '$'), "\n")
  ch_sendexpr(server.channel, {
    jsonrpc: '2.0',
    method: 'textDocument/didChange',
    params: {
      textDocument: {
        uri: server.uri,
        version: server.version
      },
      contentChanges: [ { text: buftext } ],
    }
  })
enddef

# request initialize
def RequestInitialize(server: dict<any>)
  # git
  # language
  # default
  var rootGit = trim(system("git rev-parse --show-toplevel"))
  if isdirectory(rootGit)
    server.rootPath = rootGit
    server.rootUri = $"file://{rootGit}"
  else
    var rootDir = fnamemodify(expand('%:p'), ':h')
    server.rootPath = rootDir
    server.rootUri = $"file://{substitute(rootDir, ' ', '%20', 'g')}"
  endif
  if server.language == 'go'
    var rootMod = trim(system('dirname $(go env GOMOD)'))
    if isdirectory(rootMod)
      server.rootPath = rootMod
      server.rootUri = $"file://{rootMod}"
    endif
  endif

  # initialization options
  var initOpts = {}

  # gopls only
  if server.name == "gopls"
    initOpts = {
      directoryFilters: [
        '-**/.cache', '-**/.git', '-**/.idea', '-**/.venv', '-**/build', '-**/dist', '-**/node_modules'
      ]
    }
  endif

  # terraform-ls only
  if server.name == "terraform-ls"
    initOpts = {
      experimentalFeatures: { validateOnSave: false },
      indexing: { ignoreDirectoryNames: ['.cache', '.git', '.idea', '.venv', 'build', 'dist', 'node_modules'] }
    }
  endif

  # initialize
  ch_sendexpr(server.channel, {
    jsonrpc: '2.0',
    id: ID_REQUEST_INITIALIZE,
    method: 'initialize',
    params: {
      # parent process that started the server
      processId: getpid(),
      clientInfo: {
        name: v:progname,
        version: string(v:version)
      },
      rootUri: server.rootUri,
      workspaceFolders: [{
          name: fnamemodify(server.rootPath, ':t'),
          uri: server.rootUri
      }],
      capabilities: {
        general: { positionEncodings: ['utf-16'] },
        workspace: { workspaceFolders: true },
        textDocument: {
          synchronization: {
            dynamicRegistration: false,
            didSave: false,
            willSave: false,
            willSaveWaitUntil: false
          },
          completion: {
            dynamicRegistration: false,
            contextSupport: true,
            completionItem: {
              snippetSupport: false,
              documentationFormat: ['plaintext']  # ['markdown', 'plaintext']
            }
          },
          hover: { contentFormat: ['plaintext'] },  # ['markdown', 'plaintext']
          signatureHelp: {
            dynamicRegistration: false,
            signatureInformation: { documentationFormat: ['plaintext'] },  # ['markdown', 'plaintext']
            contextSupport: true
          },
          definition: { dynamicRegistration: false },
          typeDefinition: { dynamicRegistration: false },
          implementation: { dynamicRegistration: false },
          references: { dynamicRegistration: false },
          codeAction: { dynamicRegistration: false },
        },
      },
      initializationOptions: initOpts,
      trace: 'off',
    },
  })
enddef

# response initialize
def ResponseInitialize(server: dict<any>, channel: channel, message: any): string
  if has_key(message, 'error') && has_key(message.error, 'message')
    return $"initialize error: {string(message.error.message)}"
  endif

  # initialized
  ch_sendexpr(server.channel, {
    jsonrpc: '2.0',
    method: 'initialized',
    params: {}
  })

  # gopls only
  if server.name == 'gopls'
    ch_sendexpr(server.channel, {
      jsonrpc: '2.0',
      method: 'workspace/didChangeConfiguration',
      params: {
        settings: {
          gopls: {
            diagnosticsTrigger: "Save",
            analyses: {
              unusedparams: false,
              unusedvariable: false,
              unreachable: false,
              nilness: false,
              printf: false,
              shadow: false,
              unusedwrite: false
            },
            staticcheck: false,
            vulncheck: "Off"
          }
        }
      }
    })
  endif

  # python only
  if server.language == 'python'
    ch_sendexpr(server.channel, {
      jsonrpc: '2.0',
      method: 'workspace/didChangeConfiguration',
      params: {
        settings: {
          python: {
            analysis: {
              typeCheckingMode: "off",
              diagnosticMode: "openFilesOnly",
              autoImportCompletions: v:false
            }
          }
        }
      }
    })
  endif

  var abs = fnamemodify(expand('%:p'), ':p')
  server.uri = $"file://{substitute(abs, ' ', '%20', 'g')}"
  server.version = 1
  var text = join(getline(1, '$'), "\n")
  ch_sendexpr(server.channel, {
    jsonrpc: '2.0',
    method: 'textDocument/didOpen',
    params: {
      textDocument: {
        uri: server.uri,
        languageId: server.language,
        version: server.version,
        text: text
      }
    }
  })

  # wait a small time
  if has_key(server, 'waitInit') && server.waitInit
    echo $"{server.name} waiting to initialize.."
    sleep! 2
  endif

  server.ready = true
  echomsg $"{server.name} initialized OK"
  return ""
enddef

# completion
export def Completion(): void
  var server = servers[ID(&filetype)]
  var err = CheckServer(server)
  if !empty(err)
    EchoWarningMsg(err)
    return
  endif
  RequestCompletion(server)
enddef

# request completion
def RequestCompletion(server: dict<any>)
  RequestDidChange(server)
  var pos = GetCurPos()
  ch_sendexpr(server.channel, {
    jsonrpc: '2.0',
    id: ID_REQUEST_TEXT_DOCUMENT_COMPLETION,
    method: 'textDocument/completion',
    params: {
      textDocument: { uri: server.uri },
      position: {
        line: pos[0],
        character: pos[1]
      },
      context: {
        triggerKind: 2,  # 2 = TriggerCharacter ".'
        triggerCharacter: '.'
      },
    }
  })
enddef

# response completion
def ResponseCompletion(server: dict<any>, message: any): string
  if has_key(message, 'error') && has_key(message.error, 'message')
    return $"completion error: {string(message.error.message)}"
  endif

  var items = []
  if has_key(message, 'result')
    if has_key(message.result, 'items')
      items = message.result.items
    elseif type(message.result) == v:t_list
      items = message.result
    endif
  endif

  if empty(items)
    return $"{server.name} completion: (empty)"
  endif

  # python only
  if server.language == 'python'
    if !g:lsp_python_auto_imports
      items = filter(items, (_, v) => !has_key(v, 'additionalTextEdits'))
    endif
    if g:lsp_python_sort_dunders
      var Key = (d: dict<any>) => get(d, 'sortText', get(d, 'label', ''))
      items = sort(items, (a, b) => Key(a) < Key(b) ? -1 : Key(a) > Key(b) ? 1 : 0)
    endif
  endif

  ShowCompletion(server, items)
  return ""
enddef

# show completion
def ShowCompletion(server: dict<any>, items: list<dict<any>>)
  var label: string
  var detail: string
  var kind: number
  var compl = []
  for it in items
    label  = get(it, 'label', '')
    detail = get(it, 'detail', '')
    kind = get(it, 'kind', '')
    # TODO, terraform-ls ?
    # returns var.item instead of just item
    if server.name == "terraform-ls"
      label = join(split(label, '\.')[1 :], '.')
    endif
    add(compl, {
      'word': label,
      'abbr': label,
      'kind': DEFAULT_KINDS[kind],
      'info': detail,
      'menu': printf('%s', detail)
    })
  endfor
  complete(col('.'), compl)
enddef

# definition
export def Definition(): void
  var server = servers[ID(&filetype)]
  var err = CheckServer(server)
  if !empty(err)
    EchoWarningMsg(err)
    return
  endif
  RequestDefinition(server)
enddef

# request definition
def RequestDefinition(server: dict<any>)
  RequestDidChange(server)
  var pos = GetCurPos()
  ch_sendexpr(server.channel, {
    jsonrpc: '2.0',
    id: ID_REQUEST_TEXT_DOCUMENT_DEFINITION,
    method: 'textDocument/definition',
    params: {
      textDocument: { uri: server.uri },
      position: {
        line: pos[0],
        character: pos[1]
      }
    }
  })
enddef

# response definition
def ResponseDefinition(server: dict<any>, message: any): string
  if has_key(message, 'error') && has_key(message.error, 'message')
    return $"definition error: {string(message.error.message)}"
  endif
  var items = []
  if has_key(message, 'result')
    items = message.result
  endif
  if empty(items)
    return $"{server.name} definition: (empty)"
  endif
  # TODO: use UTF-16
  var defs = []
  for [key, _] in items(items)
    var path: string
    path = substitute(items[key].uri, '^file://', "", "")
    path = substitute(path, '%20', ' ', 'g')
    var line = items[key].range.start.line + 1
    var col = items[key].range.start.character + 1
    add(defs, {'filename': $'{path}', 'lnum': line, 'col': col})
  endfor
  setqflist(defs, 'r')
  if len(getqflist()) >= 2
    copen
  else
    # results are already in the quickfix
    var item = getqflist()
    var path = bufname(item[0].bufnr)
    var line = item[0].lnum
    var col = item[0].col
    execute $"edit {path}"
    cursor(line, col)
    # setqflist([], 'r')
  endif
  return ""
enddef

# references
export def References(): void
  var server = servers[ID(&filetype)]
  var err = CheckServer(server)
  if !empty(err)
    EchoWarningMsg(err)
    return
  endif
  RequestReferences(server)
enddef

# request references
def RequestReferences(server: dict<any>)
  RequestDidChange(server)
  var pos = GetCurPos()
  ch_sendexpr(server.channel, {
    jsonrpc: '2.0',
    id: ID_REQUEST_TEXT_DOCUMENT_REFERENCES,
    method: 'textDocument/references',
    params: {
      textDocument: { uri: server.uri },
      position: {
        line: pos[0],
        character: pos[1]
      },
      context: { includeDeclaration: true }  # true all project references
    }
  })
enddef

# response references
def ResponseReferences(server: dict<any>, message: any): string
  if has_key(message, 'error') && has_key(message.error, 'message')
    return $"references error: {string(message.error.message)}"
  endif
  var items = []
  if has_key(message, 'result')
    items = message.result
  endif
  if empty(items)
    return $"{server.name} references: (empty)"
  endif
  # TODO: use UTF-16
  var refs = []
  for [key, _] in items(items)
    var path: string
    path = substitute(items[key].uri, '^file://', "", "")
    path = substitute(path, '%20', ' ', 'g')
    var line = items[key].range.start.line + 1
    var col = items[key].range.start.character + 1
    add(refs, {'filename': $'{path}', 'lnum': line, 'col': col})
  endfor
  setqflist(refs, 'r')
  if !empty(getqflist())
    copen
  endif
  return ""
enddef

# rename
export def Rename(): void
  var server = servers[ID(&filetype)]
  var errSe = CheckServer(server)
  if !empty(errSe)
    EchoWarningMsg(errSe)
    return
  endif
  var errRe = RequestRename(server)
  if !empty(errRe)
    EchoErrorMsg(errRe)
  endif
enddef

# request rename
def RequestRename(server: dict<any>): string
  var curWord = expand('<cword>')
  var newWord = trim(input($"Rename '{curWord}' to: ", ''))
  if empty(newWord)
    return $"the new value '{newWord}' cannot be empty"
  endif
  if newWord == curWord
    return $"rename to the same value '{newWord}' is not allowed"
  endif
  RequestDidChange(server)
  var pos = GetCurPos()
  ch_sendexpr(server.channel, {
    jsonrpc: '2.0',
    id: ID_REQUEST_TEXT_DOCUMENT_RENAME,
    method: 'textDocument/rename',
    params: {
      textDocument: { uri: server.uri },
      position: {
        line: pos[0],
        character: pos[1]
      },
      newName: newWord
    }
  })
  return ""
enddef

# confirm changes (rename)
def ConfirmChanges(items: list<dict<any>>): bool
  if empty(items)
    return false
  endif
  var changes = []
  for [key, _] in items(items)
    for edit in items[key].edits
      var path = fnamemodify(substitute(items[key].textDocument.uri, '^file://', "", ""), ':p:~')
      add(changes, {
        'file': path,
        'line': edit.range.start.line + 1,
        'col': edit.range.start.character + 1
      })
    endfor
  endfor
  # TODO: changes
  var res = input($"{changes}\nchanges: Are you sure to continue? (y,n) ", "n")
  return res == 'y' || res == 'yes'
enddef

# response rename
def ResponseRename(server: dict<any>, message: any): string
  if has_key(message, 'error') && has_key(message.error, 'message')
    return $"rename error: {string(message.error.message)}"
  endif

  var items: list<dict<any>>
  if has_key(message, 'result')
    if has_key(message.result, 'documentChanges')
      items = message.result.documentChanges
    elseif has_key(message.result, 'changes')
      # TODO
      # items = message.result.changes
      EchoWarningMsg("rename TODO: when message.result.changes")
      return ""
    endif
  endif

  if empty(items)
    return $"{server.name} rename: (empty)"
  endif

  # confirm
  if g:lsp_rename_confirm && !ConfirmChanges(items)
    return ""
  endif

  # TODO: recheck uri
  for [key, _] in items(items)
    for edit in reverse(items[key].edits)
      var startLine = edit.range.start.line + 1
      var startCol = edit.range.start.character + 1
      var endLine = edit.range.end.line + 1
      var endCol = edit.range.end.character + 1
      var newText = edit.newText
      var lines = getline(startLine, endLine)
      var head = strcharpart(lines[0], 0, startCol - 1)
      var tail = strcharpart(lines[-1], endCol - 1)
      var newLines = [head .. newText .. tail]
      setline(startLine, newLines)
      if endLine > startLine
        deletebufline('%', startLine + 1, endLine)
      endif
    endfor
  endfor
  return ""
enddef

# hover
export def Hover(): void
  var server = servers[ID(&filetype)]
  var err = CheckServer(server)
  if !empty(err)
    EchoWarningMsg(err)
    return
  endif
  RequestHover(server)
enddef

# request hover
def RequestHover(server: dict<any>)
  RequestDidChange(server)
  var pos = GetCurPos()
  ch_sendexpr(server.channel, {
    jsonrpc: '2.0',
    id: ID_REQUEST_TEXT_DOCUMENT_HOVER,
    method: 'textDocument/hover',
    params: {
      textDocument: { uri: server.uri },
      position: {
        line: pos[0],
        character: pos[1]
      }
    }
  })
enddef

# response hover
def ResponseHover(server: dict<any>, message: any): string
  if has_key(message, 'error') && has_key(message.error, 'message')
    return $"hover error: {string(message.error.message)}"
  endif
  if !has_key(message, 'result')
    return $"{server.name} hover: (empty)"
  endif
  if has_key(message, 'result')
    if message.result == null
      EchoWarningMsg($"{server.name} hover: no data available (null)")
      return ""
    endif
  endif
  var value = message.result.contents.value
  var kind = message.result.contents.kind
  value = substitute(value, '\r\n', "\n", 'g')
  value = substitute(value, '\r', "\n", 'g')
  value = substitute(value, '\%x00', "\n", 'g')
  var lines = split(value, "\n", 1)
  # kind: markdown, plaintext, etc.
  if kind == "markdown"
    lines = filter(lines, (_, s) => s !~ '^\s*$')
    lines = filter(lines, (_, s) => s !~ '^\s*```')
    # lines = filter(lines, (_, s) => s !~ '^\s*[-*_]\{3,}\s*$')
  endif
  PopupHover(lines, kind)
  return ""
enddef

# popup hover
def PopupHover(text: list<string>, kind: string)
  var id = popup_create(
    text, {
      title: "",
      post: 'topleft',
      line: 'cursor+1',
      col: 1,
      moved: 'any',
      border: [],
      close: 'click',
      mapping: false,
      wrap: false
    }
  )
  if kind == "markdown"
    win_execute(id, 'setlocal syntax=off')
    win_execute(id, 'setlocal filetype=markdown')
    win_execute(id, 'setlocal conceallevel=0')
  else
    win_execute(id, 'setlocal filetype=text')
    win_execute(id, 'setlocal syntax=off')
  endif
enddef

# out handler
def OutHandler(server: dict<any>, channel: channel, message: any)
  if type(message) != v:t_dict
    return
  endif

  # id=1 response of request initialize
  if get(message, 'id', 0) == ID_REQUEST_INITIALIZE
    var err = ResponseInitialize(server, channel, message)
    if !empty(err)
      EchoErrorMsg(err)
    endif
    return
  endif

  # id=2 response of request text document completion
  if get(message, 'id', 0) == ID_REQUEST_TEXT_DOCUMENT_COMPLETION
    var err = ResponseCompletion(server, message)
    if !empty(err)
      EchoErrorMsg(err)
    endif
    return
  endif

  # id=3 response of request text document definition
  if get(message, 'id', 0) == ID_REQUEST_TEXT_DOCUMENT_DEFINITION
    var err = ResponseDefinition(server, message)
    if !empty(err)
      EchoErrorMsg(err)
    endif
    return
  endif

  # id=4 response of request text document references
  if get(message, 'id', 0) == ID_REQUEST_TEXT_DOCUMENT_REFERENCES
    var err = ResponseReferences(server, message)
    if !empty(err)
      EchoErrorMsg(err)
    endif
    return
  endif

  # id=5 response of request text document rename
  if get(message, 'id', 0) == ID_REQUEST_TEXT_DOCUMENT_RENAME
    var err = ResponseRename(server, message)
    if !empty(err)
      EchoErrorMsg(err)
    endif
    return
  endif

  # id=6 response of request text document hover
  if get(message, 'id', 0) == ID_REQUEST_TEXT_DOCUMENT_HOVER
    var err = ResponseHover(server, message)
    if !empty(err)
      EchoErrorMsg(err)
    endif
    return
  endif
enddef

# error handler
def ErrHandler(server: dict<any>, channel: channel, message: string)
  if !empty(message)
    EchoErrorMsg($"{server.name} stderr: {message}")
    endif
enddef

# exit handler
def ExitHandler(server: dict<any>, job: job, status: number)
  server.ready = false
  server.running = false
  var inf = job_info(job)
  var sts = inf['status'] == 'dead' ? 'stopped' : inf['status']
  echomsg $"{inf['cmd'][0]} {sts}"
  # check running
  if RunningServer(server.name)
    EchoErrorMsg($"server: {server.name} still running")
  endif
enddef
