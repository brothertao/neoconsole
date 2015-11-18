# from atom/terminal to reduce cpu usage
# see why: https://github.com/chjj/pty.js/issues/39

pty = require 'pty.js'

module.exports = (name, sh='bash', args=[]) ->
  callback = @async()

  ptyProcess = pty.fork sh, args,
    name: name
    cols: 80
    rows: 40
    cwd: process.env.HOME
    env: process.env

  ptyProcess.on 'data', (data) ->
    emit('neoconsole:tty:data', new Buffer(data).toString("utf-8"))

  ptyProcess.on 'exit', ->
    emit('neoconsole:tty:exit')
    callback()

  process.on 'message', ({event, cols, rows, text}={}) ->
    switch event
      when 'resize' then ptyProcess.resize(cols, rows)
      when 'input' then ptyProcess.write(new Buffer(text).toString("utf-8"))
