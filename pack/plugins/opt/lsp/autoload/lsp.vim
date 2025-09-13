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

# id request
const ID_REQUEST_INITIALIZE = 1
const ID_REQUEST_TEXT_DOCUMENT_COMPLETION = 2
const ID_REQUEST_TEXT_DOCUMENT_COMPLETION_NO_ASYNC = 3
const ID_REQUEST_TEXT_DOCUMENT_DEFINITION = 4
const ID_REQUEST_TEXT_DOCUMENT_REFERENCES = 5
const ID_REQUEST_TEXT_DOCUMENT_RENAME = 6
const ID_REQUEST_TEXT_DOCUMENT_HOVER = 7
const ID_REQUEST_TEXT_DOCUMENT_SYMBOL = 8
const ID_REQUEST_TEXT_DOCUMENT_SIGNATURE = 9
const ID_REQUEST_SHUTDOWN = 99

# completion kinds
const COMPLETION_KINDS = {
   '1': {'short': 't', 'long': 'Text'},
   '2': {'short': 'm', 'long': 'Method'},
   '3': {'short': 'f', 'long': 'Function'},
   '4': {'short': 'C', 'long': 'Constructor'},
   '5': {'short': 'F', 'long': 'Field'},
   '6': {'short': 'v', 'long': 'Variable'},
   '7': {'short': 'c', 'long': 'Class'},
   '8': {'short': 'i', 'long': 'Interface'},
   '9': {'short': 'M', 'long': 'Module'},
  '10': {'short': 'p', 'long': 'Property'},
  '11': {'short': 'u', 'long': 'Unit'},
  '12': {'short': 'V', 'long': 'Value'},
  '13': {'short': 'e', 'long': 'Enum'},
  '14': {'short': 'k', 'long': 'Keyword'},
  '15': {'short': 'S', 'long': 'Snippet'},
  '16': {'short': 'C', 'long': 'Color'},
  '17': {'short': 'f', 'long': 'File'},
  '18': {'short': 'r', 'long': 'Reference'},
  '19': {'short': 'F', 'long': 'Folder'},
  '20': {'short': 'E', 'long': 'EnumMember'},
  '21': {'short': 'd', 'long': 'Constant'},
  '22': {'short': 's', 'long': 'Struct'},
  '23': {'short': 'E', 'long': 'Event'},
  '24': {'short': 'o', 'long': 'Operator'},
  '25': {'short': 'T', 'long': 'TypeParameter'}
}

# symbol kinds
const SYMBOL_KINDS = {
   '1': 'File',
   '2': 'Module',
   '3': 'Namespace',
   '4': 'Package',
   '5': 'Class',
   '6': 'Method',
   '7': 'Property',
   '8': 'Field',
   '9': 'Constructor',
  '10': 'Enum',
  '11': 'Interface',
  '12': 'Function',
  '13': 'Variable',
  '14': 'Constant',
  '15': 'String',
  '16': 'Number',
  '17': 'Boolean',
  '18': 'Array',
  '19': 'Object',
  '20': 'Key',
  '21': 'Null',
  '22': 'EnumMember',
  '23': 'Struct',
  '24': 'Event',
  '25': 'Operator',
  '26': 'TypeParameter'
}

# default server
const defaultServer = {
  'id': 0,
  'name': '',
  'cmd': '',
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

# id
def ID(lang: string): number
  if !has_key(LANGUAGES, lang)
    throw $"lsp: server language '{lang}' is not supported"
  endif
  return LANGUAGES[lang]
enddef

# new server config
def NewServer(overrides: dict<any>): dict<any>
  return extend(deepcopy(defaultServer), overrides, 'force')
enddef

# servers
var servers: dict<dict<any>> = {}

# gopls
servers[LANGUAGES['go']] = NewServer({
  'id': LANGUAGES['go'],
  'name': 'gopls',
  'cmd': 'gopls',
  'args': [],
  'desc': 'The official language server for Go',
  'language': 'go'
})

# pyright
servers[LANGUAGES['python']] = NewServer({
  'id': LANGUAGES['python'],
  'name': 'pyright',
  'cmd': 'pyright-langserver',
  'args': ['--stdio'],
  'desc': 'Static type checker for Python',
  'language': 'python'
})

# terraform-ls
servers[LANGUAGES['terraform']] = NewServer({
  'id': LANGUAGES['terraform'],
  'name': 'terraform-ls',
  'cmd': 'terraform-ls',
  'args': ['serve', '-log-file=/dev/null'],
  'desc': 'The official Terraform language server',
  'language': 'terraform',
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

# normalize
def NormalizeLines(str: string): string
  return substitute(str, '\r\n\|\r\|\%x00', "\n", 'g')
enddef

# add scheme /path -> file:///path
def AddScheme(str: string): string
  return $"file://{str}"
enddef

# remove scheme file:///path -> /path
def RemoveScheme(str: string): string
  return substitute(str, '^file://', '', '')
enddef

# uri encode
def UriEncode(str: string): string
  return substitute(str, ' ', '%20', 'g')
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
  v:statusmsg = 'lsp enabled'
enddef

# disable plugin
export def Disable()
  g:lsp_enabled = false
  v:statusmsg = 'lsp disabled'
enddef

# running server
def RunningServer(name: string): bool
  return index(RunningServers(), name) >= 0
enddef

# running
export def Running()
  var server = servers[ID(&filetype)]
  echomsg $"{server.name}: {server.running}"
enddef

# ready
export def Ready()
  var server = servers[ID(&filetype)]
  echomsg $"{server.name}: {server.ready}"
enddef

# pre-checks of requisites
def PreChecks(server: dict<any>): string
  if !has_key(LANGUAGES, &filetype)
    return $"lsp: the filetype '{&filetype}' is not supported"
  endif
  if !executable(server.cmd)
    return $"server: '{server.cmd}' command not found"
  endif
  if RunningServer(server.name)
    return $"server: {server.name} is already running"
  endif
  return ''
enddef

# check server
def CheckServer(server: dict<any>): string
  if !server.running
    return $"server: {server.name} is not running"
  endif
  if !server.ready
    return $"server: {server.name} is not ready"
  endif
  return ''
enddef

# start server
export def Start(): void
  var server = servers[ID(&filetype)]
  var err = PreChecks(server)
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
  if job_status(job) == 'fail'
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
  if !executable('jq')
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
  var rootGit = systemlist('git rev-parse --show-toplevel')[0]
  if isdirectory(rootGit)
    server.rootPath = rootGit
    server.rootUri = AddScheme(rootGit)
  else
    var rootDir = fnamemodify(expand('%:p'), ':h')
    server.rootPath = rootDir
    server.rootUri = AddScheme(UriEncode(rootDir))
  endif
  if server.language == 'go'
    var rootMod = systemlist('dirname $(go env GOMOD)')[0]
    if isdirectory(rootMod)
      server.rootPath = rootMod
      server.rootUri = AddScheme(rootMod)
    endif
  endif

  # initialization options
  var initOpts = {}

  # gopls only
  if server.name == 'gopls'
    initOpts = {
      directoryFilters: [
        '-**/.cache', '-**/.git', '-**/.idea', '-**/.venv', '-**/build', '-**/dist', '-**/node_modules'
      ]
    }
  endif

  # terraform-ls only
  if server.name == 'terraform-ls'
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
            diagnosticsTrigger: 'Save',
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
            vulncheck: 'Off'
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
              typeCheckingMode: 'off',
              diagnosticMode: 'openFilesOnly',
              autoImportCompletions: v:false
            }
          }
        }
      }
    })
  endif

  var abs = fnamemodify(expand('%:p'), ':p')
  server.uri = AddScheme(UriEncode(abs))
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
  return ''
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

# request completion (no async)
def RequestCompletionNoAsync(server: dict<any>): dict<any>
  RequestDidChange(server)
  var pos = GetCurPos()
  var timeout = 1000  # ms (1 second)
  var out = ch_evalexpr(server.channel, {
    jsonrpc: '2.0',
    id: ID_REQUEST_TEXT_DOCUMENT_COMPLETION_NO_ASYNC,
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
  }, { 'timeout': timeout })
  return !empty(out) ? out : {}
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

  # filter
  items = FilterCompletions(server, items)

  return ShowCompletions(server, items)
enddef

# filter completions
def FilterCompletions(server: dict<any>, items: list<dict<any>>): list<any>
  var fitems = items
  # python only
  if server.language == 'python'
    if !g:lsp_python_auto_imports
      fitems = filter(items, (_, v) => !has_key(v, 'additionalTextEdits'))
    endif
    if g:lsp_python_sort_dunders
      var Key = (d: dict<any>) => get(d, 'sortText', get(d, 'label', ''))
      fitems = sort(items, (a, b) => Key(a) < Key(b) ? -1 : Key(a) > Key(b) ? 1 : 0)
    endif
  endif
  return fitems
enddef

# format completions
def FormatCompletions(server: dict<any>, items: list<dict<any>>): list<any>
  var label: string
  var detail: string
  var kind: number
  var fitems = []
  for it in items
    label  = get(it, 'label', '')
    detail = get(it, 'detail', '')
    kind = get(it, 'kind', -1)
    # TODO, terraform-ls ?
    # returns var.item instead of just item
    if server.name == 'terraform-ls'
      label = join(split(label, '\.')[1 :], '.')
    endif
    add(fitems, {
      'word': label,
      'abbr': label,
      'kind': COMPLETION_KINDS[kind]['short'],
      'info': detail,
      'menu': printf('%s', detail),
      'user_data': string(it)
    })
  endfor
  return fitems
enddef

# show completions
def ShowCompletions(server: dict<any>, items: list<dict<any>>): string
  var compl = FormatCompletions(server, items)
  if empty(compl)
    return $"{server.name} show completion: (empty)"
  endif
  # complete(col('.'), compl)
  b:_items_compl = compl
  const completefunc_orig = &l:completefunc
  &l:completefunc = 'lsp#CompleteFunc'
  feedkeys("\<C-x>\<C-u>", 'n')

  # restore after completion
  timer_start(50, (tid: number) => {
    if !pumvisible()
      if &l:completefunc == 'lsp#CompleteFunc'
        &l:completefunc = completefunc_orig
        unlet! b:_items_compl
      endif
      timer_stop(tid)
    endif
  }, { repeat: -1 })
  return ''

  # without mapping <BS> before '.' (trigger), see CompleteKey (complementum plugin)
  # timer_start(50, (tid: number) => {
  #   if pumvisible()
  #     return
  #   endif
  #   # avoid ic,ix,.. etc
  #   if mode(1)[0] != 'i'
  #     if &l:completefunc == 'lsp#CompleteFunc'
  #       &l:completefunc = completefunc_orig
  #       unlet! b:_items_compl
  #     endif
  #     timer_stop(tid)
  #     return
  #   endif
  #   # insert mode + previous char is '.'
  #   if mode(1)[0] == 'i' && col('.') > 1 && matchstr(getline('.')[ : col('.') - 2], '.$') == '.'
  #     &l:completefunc = 'lsp#CompleteFunc'
  #     feedkeys("\<C-x>\<C-u>", 'n')
  #     return
  #   endif
  # }, { repeat: -1 })
  # return ''

enddef

# complete func
export def CompleteFunc(findstart: number, base: string): any
  if findstart
    return col('.')
  endif
  return exists('b:_items_compl') ? b:_items_compl : []
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

# omni func
export def OmniFunc(findstart: number, base: string): any
  if findstart
    var coln = col('.')
    var prev = matchstr(getline('.')[ : coln - 2], '\k*$')
    return coln - strchars(prev)
  endif

  var server = servers[ID(&filetype)]
  var message = RequestCompletionNoAsync(server)

  var items = []
  if has_key(message, 'result')
    if has_key(message.result, 'items')
      items = message.result.items
    elseif type(message.result) == v:t_list
      items = message.result
    endif
  endif

  if empty(items)
    return []
  endif

  # filter
  items = FilterCompletions(server, items)

  # format
  var compl = FormatCompletions(server, items)

  return !empty(compl) ? compl : []

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
    path = UriEncode(RemoveScheme(items[key].uri))
    var line = items[key].range.start.line + 1
    var col = items[key].range.start.character + 1
    add(defs, {'filename': $"{path}", 'lnum': line, 'col': col})
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
  return ''
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
    path = UriEncode(RemoveScheme(items[key].uri))
    var line = items[key].range.start.line + 1
    var col = items[key].range.start.character + 1
    add(refs, {'filename': $"{path}", 'lnum': line, 'col': col})
  endfor
  setqflist(refs, 'r')
  if !empty(getqflist())
    copen
  endif
  return ''
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
  return ''
enddef

# confirm changes (rename)
def ConfirmChanges(items: list<dict<any>>): bool
  if empty(items)
    return false
  endif
  var changes = []
  for [key, _] in items(items)
    for edit in items[key].edits
      var path = fnamemodify(RemoveScheme(items[key].textDocument.uri), ':p:~')
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
      EchoWarningMsg('rename TODO: when message.result.changes')
      return ''
    endif
  endif

  if empty(items)
    return $"{server.name} rename: (empty)"
  endif

  # confirm
  if g:lsp_rename_confirm && !ConfirmChanges(items)
    return ''
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
  return ''
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
      return ''
    endif
  endif
  var items: dict<any>
  if has_key(message, 'result')
    items = message.result
  endif
  if empty(items)
    return $"{server.name} signature: (empty)"
  endif
  var contents = []
  add(contents, {
    'text': split(NormalizeLines(items.contents.value), "\n", 1),
    'kind': items.contents.kind
  })
  # if contents[0].kind == 'markdown'
  #   contents = filter(contents, (_, s) => s !~ '^\s*$')
  #   contents = filter(contents, (_, s) => s !~ '^\s*```')
  #   # contents = filter(contents, (_, s) => s !~ '^\s*[-*_]\{3,}\s*$'))
  # endif
  PopupHover(contents)
  return ''
enddef

# popup hover
def PopupHover(contents: list<dict<any>>)
  var id = popup_create(
    contents[0].text, {
      title: '',
      post: 'topleft',
      line: 'cursor+1',
      col: 1,
      moved: 'any',
      border: [1, 1, 1, 1],
      close: 'click',
      mapping: false,
      wrap: false
    }
  )
  if contents[0].kind == 'markdown'
    win_execute(id, 'setlocal syntax=OFF')
    win_execute(id, 'setlocal filetype=markdown')
    win_execute(id, 'setlocal conceallevel=0')
  else
    win_execute(id, 'setlocal filetype=text')
    win_execute(id, 'setlocal syntax=OFF')
  endif
enddef

# document symbol
export def DocumentSymbol(): void
  var server = servers[ID(&filetype)]
  var err = CheckServer(server)
  if !empty(err)
    EchoWarningMsg(err)
    return
  endif
  RequestDocumentSymbol(server)
enddef

# request document symbol
def RequestDocumentSymbol(server: dict<any>)
  RequestDidChange(server)
  ch_sendexpr(server.channel, {
    jsonrpc: '2.0',
    id: ID_REQUEST_TEXT_DOCUMENT_SYMBOL,
    method: 'textDocument/documentSymbol',
    params: {
      textDocument: { uri: server.uri }
    }
  })
enddef

# response document symbol
def ResponseDocumentSymbol(server: dict<any>, message: any): string
  if has_key(message, 'error') && has_key(message.error, 'message')
    return $"document symbol error: {string(message.error.message)}"
  endif
  var items = []
  if has_key(message, 'result')
    items = message.result
  endif
  if empty(items)
    return $"{server.name} document symbol: (empty)"
  endif
  # TODO: use UTF-16
  var symbls = []
  for [key, _] in items(items)
    var name = items[key].name
    var kind = items[key].kind
    var text = $"{SYMBOL_KINDS[items[key].kind]} : {items[key].name}"
    var path = UriEncode(RemoveScheme(items[key].location.uri))
    var line = items[key].location.range.start.line + 1
    var col = items[key].location.range.start.character + 1
    add(symbls, {'filename': $"{path}", 'lnum': line, 'col': col, 'text': text})
  endfor
  PopupDocumentSymbol(symbls)
  return ''
enddef

# popup document symbol
def PopupDocumentSymbol(items: list<dict<any>>)
  var pad = max(mapnew(items, (_, val) => len(split(val.text, ':')[0])))
  var symbols = mapnew(items, (_, val) =>
    split(val.text, ':')[0]
    .. repeat(' ', pad - strlen(split(val.text, ':')[0]))
    .. ':' .. join(split(val.text, ':')[1 :])
  )
  # force to go to the first item
  cursor(items[0].lnum, items[0].col)
  var id = popup_menu(
    symbols, {
      title: '',
      pos: 'topleft',
      line: 'cursor+1',
      col: 1,
      moved: [0, 0, 0],
      border: [1, 1, 1, 1],
      close: 'click',
      mapping: false,
      wrap: false,
      filter: function(DocumentSymbolPick, [items]),
  })
enddef

# document symbol pick
def DocumentSymbolPick(items: list<dict<any>>, id: number, key: string): bool
  if key == "\<CR>"
    popup_close(id, line('.', id))
    return true
  elseif key == "\<Esc>"
    popup_close(id, -1)
    return true
  endif
  popup_filter_menu(id, key)
  var cline = line('.', id)
  cursor(items[cline - 1].lnum, items[cline - 1].col)
  return true
enddef

# signature
export def Signature(): void
  var server = servers[ID(&filetype)]
  var err = CheckServer(server)
  if !empty(err)
    EchoWarningMsg(err)
    return
  endif
  RequestSignature(server)
enddef

# request signature
def RequestSignature(server: dict<any>)
  RequestDidChange(server)
  var pos = GetCurPos()
  ch_sendexpr(server.channel, {
    jsonrpc: '2.0',
    id: ID_REQUEST_TEXT_DOCUMENT_SIGNATURE,
    method: 'textDocument/signatureHelp',
    params: {
      textDocument: { uri: server.uri },
      position: {
        line: pos[0],
        character: pos[1]
      }
    }
  })
enddef

# response signature
def ResponseSignature(server: dict<any>, message: any): string
  if has_key(message, 'error') && has_key(message.error, 'message')
    return $"document symbol error: {string(message.error.message)}"
  endif
  if !has_key(message, 'result')
    return $"{server.name} signature: (empty)"
  endif
  if has_key(message, 'result')
    if message.result == null
      EchoWarningMsg($"{server.name} signature: no data available (null)")
      return ''
    endif
  endif
  var items: dict<any>
  if has_key(message, 'result')
    items = message.result
  endif
  if empty(items)
    return $"{server.name} signature: (empty)"
  endif
  var signs = []
  for sign in items.signatures
    add(signs, {
      'label': sign.label,
      'parameters': has_key(sign, 'parameters') ? sign.parameters : [],
      'kind': sign.documentation.kind
    })
  endfor
  PopupSignature(signs)
  return ''
enddef

# popup signature
def PopupSignature(signs: list<dict<any>>)
  var id = popup_create(
    signs[0].label, {
      title: '',
      post: 'topleft',
      line: 'cursor+1',
      col: 1,
      moved: 'any',
      border: [1, 1, 1, 1],
      close: 'click',
      mapping: false,
      wrap: false
    }
  )
  if signs[0].kind == 'markdown'
    win_execute(id, 'setlocal syntax=OFF')
    win_execute(id, 'setlocal filetype=markdown')
    win_execute(id, 'setlocal conceallevel=0')
  else
    win_execute(id, 'setlocal filetype=text')
    win_execute(id, 'setlocal syntax=OFF')
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

  # id=7 response of request text document symbol
  if get(message, 'id', 0) == ID_REQUEST_TEXT_DOCUMENT_SYMBOL
    var err = ResponseDocumentSymbol(server, message)
    if !empty(err)
      EchoErrorMsg(err)
    endif
    return
  endif

  # id=8 response of request text document signature
  if get(message, 'id', 0) == ID_REQUEST_TEXT_DOCUMENT_SIGNATURE
    var err = ResponseSignature(server, message)
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
