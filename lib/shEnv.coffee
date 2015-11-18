pty = require 'pty.js'
remote = require 'remote'
BrowserWindow = remote.require 'browser-window'
module.exports = 
  terms: {}

  run: (scripts, @settings={}) ->
    scripts = @preRun scripts

    if 'normal-mode'==@settings.mode
      atom.openDevTools()
    else
      @createBrowserWindow()

    @term = @getTerm()
    global.term = @term

    try
      @term.write scripts+'\r'
    catch e
      console.log e

  createBrowserWindow: ->
    if not @win
      @win = win = new BrowserWindow(width: 800, height: 600, show: false);

      win.on 'closed', =>
        @win = null
        for name, term of @terms
          term?.end()
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
    if ':exit' == scripts
      @terms[name]?.end()
      delete @terms[name]
      scripts = ''

    scripts

  getTerm:  ->
    name = @settings.name
    if not @terms[name]
        @terms[name] = @createTerm()

    @terms[name]
    
  createTerm: ->
    term = pty.fork 'bash', [],
      name: @settings.name
      cols: 80
      rows: 30
      cwd: process.env.HOME
      env: process.env

    term.on 'data', (data) =>
      if 'normal-mode'==@settings.mode
        console.log data
      else
        @win.webContents.send 'data', data

    term


    
      

    
    

    
