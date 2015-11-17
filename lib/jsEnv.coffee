vm = require 'vm'
remote = require 'remote'
BrowserWindow = remote.require 'browser-window'
module.exports = 
  run: (scripts, settings) ->
    @settings = settings
    if scripts=='atom-mode'
      @settings.mode = scripts
      return
    if scripts=='normal-mode'
      @settings.mode = scripts
      return
    if @settings.mode=='atom-mode'
      @runScriptsInAtomBrowser(scripts)
    else
      @runScriptsInNormalBrowser(scripts)

  runScriptsInAtomBrowser: (scripts) ->
    atom.openDevTools()
    try
      console.log vm.runInThisContext scripts
    catch e
      console.log scripts
      console.log e

  runScriptsInNormalBrowser: (scripts) ->
    if not @win
      win = new BrowserWindow(width: 800, height: 600, show: false);
      win.on 'closed', =>
        win = null
        @win = null

      win.loadUrl 'file://'+__dirname+'/../statics/console/index.html'
      win.show()

      @win = win

    @win.setAlwaysOnTop true
    @win.setAlwaysOnTop false
    global.dash = @win
    try
      @win.openDevTools()
      @win.webContents.executeJavaScript scripts
    catch e
      @win.webContents.executeJavaScript e

    
    

    
