vim9script noclear
# by Gonzaru
# Distributed under the terms of the GNU General Public License v3

# do not read the file if it is already loaded
if get(g:, 'autoloaded_lsp') || !get(g:, 'lsp_enabled')
  finish
endif
g:autoloaded_lsp = true

# languages
const LANGUAGES = {
  'go': 1,
  'python': 2,
  'terraform': 3
}

# id
def ID(): number
  return LANGUAGES[&filetype]
enddef

# id request
const ID_REQUEST_INITIALIZE = 1
const ID_REQUEST_TEXT_DOCUMENT_COMPLETION = 2
const ID_REQUEST_SHUTDOWN = 3

# kinds
var DEFAULT_KINDS = {
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
  'active': false,
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

# terraform
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

# active servers
def ActiveServers(): list<string>
  var active = []
  for k in keys(servers)
    if servers[k].active
      add(active, servers[k].name)
    endif
  endfor
  return active
enddef

# enable
export def Enable()
  g:lsp_enabled = true
  g:lsp_complementum = true  # complementum plugin
enddef

# disable
export def Disable()
  g:lsp_enabled = false
  g:lsp_complementum = false  # complementum plugin
enddef

# active server
def ActiveServer(name: string): bool
  return index(ActiveServers(), name) >= 0
enddef

# pre check
def PreCheck(server: dict<any>): string
  if !has_key(LANGUAGES, &filetype)
    return $"lsp: the filetype '{&filetype}' is not supported"
  endif
  if !executable(server.cmd)
	  return $"server: {server.cmd} command not found"
  endif
  if ActiveServer(server.name)
	  return $"server: {server.name} is already active"
  endif
  return ""
enddef

# start
export def Start(): void
  var server = servers[ID()]
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
	server.active = true
	RequestInitialize(server)
enddef

# stop
export def Stop(sid: number = -1)
  const id = sid == -1 ? ID() : sid
  var server = servers[id]
  if server.active
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
	  server.active = false
	else
    EchoWarningMsg($"server: {server.name} is not active")
  endif
enddef

# stop all
export def StopAll()
  for k in keys(servers)
    if servers[k].active
      Stop(servers[k].id)
    endif
  endfor
enddef

# restart
export def Restart()
  Stop()
  sleep! 500m
  Start()
enddef

# info
export def Info()
  for k in keys(servers)
    echo servers[k]
    read
  endfor
enddef

# request initialize
def RequestInitialize(server: dict<any>)
	if server.language == 'go'
    server.rootPath = trim(system('dirname $(go env GOMOD)'))
    server.rootUri = $"file://{trim(system('dirname $(go env GOMOD)'))}"
  else
    server.rootPath = fnamemodify(expand('%:p'), ':h')
    server.rootUri = $"file://{substitute(fnamemodify(expand('%:p'), ':h'), ' ', '%20', 'g')}"
  endif
  ch_sendexpr(server.channel, {
    jsonrpc: '2.0',
    id: ID_REQUEST_INITIALIZE,
    method: 'initialize',
    params: {
      processId: server.pid,
			rootUri: server.rootUri,
      workspaceFolders: [{
          name: fnamemodify(server.rootPath, ':t'),
          uri: server.rootUri
      }],
			capabilities: {
        textDocument: {
          synchronization: {
            didSave: v:false,
            willSave: v:false,
            dynamicRegistration: v:false
          }
        },
      },
      trace: 'off',
    },
  })
enddef

# response initialize
def ResponseInitialize(server: dict<any>, channel: channel, message: any): string
  if has_key(message, 'error')
    return $"initialize error: {string(message.error)}"
  endif

  ch_sendexpr(server.channel, {
    jsonrpc: '2.0',
    method: 'initialized',
    params: {}
  })

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
        text: text,
      }
    }
  })

  # python only
	if server.language == 'python'
  	ch_sendexpr(server.channel, {
    	jsonrpc: '2.0',
    	method: 'workspace/didChangeConfiguration',
    	params: {
      	settings: {
        	python: {
          	analysis: {
            	autoImportCompletions: v:false
          	}
        	}
      	}
    	}
  	})
	endif

	# wait a small time
	if has_key(server, 'waitInit') && server.waitInit
	  echo $"{server.name} waiting to initialize.."
	  sleep! 5
	endif
	server.ready = true
  echomsg $"{server.name} initialized OK"
  return ""
enddef

# do completion
export def Completion(): void
  var server = servers[ID()]
	if !server.ready || empty(server.uri)
		EchoWarningMsg($"{server.name} is not initialized")
		Start()
		sleep! 500m
	endif
	RequestCompletion(server)
enddef

# request completion
def RequestCompletion(server: dict<any>)
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

  ch_sendexpr(server.channel, {
    jsonrpc: '2.0',
    id: ID_REQUEST_TEXT_DOCUMENT_COMPLETION,
    method: 'textDocument/completion',
    params: {
      textDocument: {
        uri: server.uri
      },
      position: {
        line: line0,
        character: u16
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
  var items = []
  if has_key(message, 'result')
    if has_key(message.result, 'items')
      items = message.result.items
    elseif type(message.result) == v:t_list
      items = message.result
    endif
  endif
  if empty(items)
    echo $"{server.name} completion: (empty)"
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

  # id=99 response of request text document completion
	if get(message, 'id', 0) == ID_REQUEST_TEXT_DOCUMENT_COMPLETION
	  var err = ResponseCompletion(server, message)
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
  server.active = false
  var inf = job_info(job)
  var sts = inf['status'] == 'dead' ? 'stopped' : inf['status']
  echomsg $"{inf['cmd'][0]}: {sts}"
  # check active
  if ActiveServer(server.name)
	  EchoErrorMsg($"server: {server.name} still active")
  endif
enddef
