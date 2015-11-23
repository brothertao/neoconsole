module.exports = 
  beforeSend: (scripts) ->
    scripts
  beforeShowResponse: (data) ->
    data
  getInitScripts: (name) ->
    'stty -echo'
