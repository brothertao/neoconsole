vm = require 'vm'
remote = require 'remote'
BrowserWindow = remote.require 'browser-window'

module.exports =
  activate: ->
    @settings = 
      mode: 'normal-mode'

    atom.commands.add 'atom-workspace',
      'jscode:run': =>
        @run()

  run: ->

    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    scripts = editor.getSelectedText()
    if scripts.length
      'run selected'
    else
      scripts = editor.lineTextForBufferRow editor.getCursorBufferPosition().row
    
    if scripts=='atom-mode'
      @settings.mode = scripts
      return
    if scripts=='normal-mode'
      @settings.mode = scripts
      return
    
    @runScripts(scripts);

  runScripts: (scripts) ->

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

    
    

