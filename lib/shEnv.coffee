pty = require 'pty.js'
remote = require 'remote'
BrowserWindow = remote.require 'browser-window'
module.exports = 
  run: (scripts, settings) ->
    @settings = settings

    if not @win
      @win = win = new BrowserWindow(width: 800, height: 600, show: false);
      win.on 'closed', =>
        win = null
        @win = null
        @term = null

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

    if not @term
        @term = pty.spawn 'bash', [],
          name: 'neoconsole'
          cols: 80
          rows: 30
          cwd: process.env.HOME

    @term.on 'data', (data) =>
      @win.webContents.send 'data', data

    try
      @term.write scripts+'\r'
    catch e
      console.log e
      

    
    

    
