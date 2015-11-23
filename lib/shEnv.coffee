pty = require 'pty.js'
{Task} = require 'atom'
remote = require 'remote'
BrowserWindow = remote.require 'browser-window'
#development hack
global.shHook = require './hooks/sh.coffee'

module.exports = 
  terms: {}

  run: (scripts, @settings={}) ->
    @hook = shHook     
    scripts = @preRun scripts

    @openDevTools()
    @term = @getTerm()
    global.term = @term

    try
      if m = scripts.match(/\\x(\w+)/)
        scripts = String.fromCharCode(parseInt(m[1], 16))
      else
        scripts = scripts+'\r'
      
      @term.send event: 'input', text: scripts
    catch e
      console.log e

  openDevTools: ->
    atom.openDevTools()

    if not @currentWindow
      @currentWindow = BrowserWindow.getFocusedWindow()
      console.log @currentWindow.id
      global.cb = @currentWindow
      global.terms = @terms
      @currentWindow.on 'close', =>
        #tricky: if no this, blow code will not be executed
        setTimeout ()=>
          for name, term of @terms
            term.terminate()
            delete @terms[name]
        , 10

  createBrowserWindow: ->
    if not @win
      @win = win = new BrowserWindow(width: 800, height: 600, show: false);

      win.on 'closed', =>
        @win = null
        for name, term of @terms
          term?.terminate()
        @terms = {}

      win.loadUrl 'file://'+__dirname+'/../statics/console/index.html'
      win.webContents.on "did-finish-load", ->
        initScripts = "require('ipc').on('data', function(message) {console.log(message)});"
        try
          win.openDevTools()
          win.webContents.executeJavaScript initScripts
        catch e
          win.webContents.executeJavaScript e

      win.show()

    @win.setAlwaysOnTop true
    @win.setAlwaysOnTop false
    global.dash = @win


  preRun: (scripts) ->
    name = @settings.name
    if ':reload' == scripts
      try
        @terms[name]?.terminate()
      catch e
        console.log(e)
      finally
        delete @terms[name]
        scripts = ''

    if @hook?.beforeSend
        scripts = @hook.beforeSend scripts
    
    scripts

  getTerm:  ->
    name = @settings.name
    if not @terms[name]
        @terms[name] = @createTerm()

    @terms[name]
    
  createTerm: ->
    processPath = require.resolve './pty'
    ptyProcess = Task.once processPath, @settings.name

    ptyProcess.on 'neoconsole:tty:data', (data) =>
      data = @hook.beforeShowResponse data
      console.log data

    ptyProcess.sendScripts = (scripts) -> 
      ptyProcess.send event:'input', text:scripts+'\r'

    ptyProcess.sendScripts @hook.getInitScripts @settings.name
    ptyProcess


    
      

    
    

    
