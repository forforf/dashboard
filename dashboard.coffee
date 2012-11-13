express = require 'express'
port = 3000

s = express()

s.get '/', (req, res) ->
  res.send 'Hello Express World'

s.use express.static(__dirname + '/public')

s.listen(port)
console.log 'Dashboard listening on port %s', port
