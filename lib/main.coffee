vm = require 'vm'

module.exports =
  activate: ->
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
    

    try
      vm.runInThisContext scripts
    catch e
      false
    

