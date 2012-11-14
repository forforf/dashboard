express      = require 'express'
YamlFromAtom = require('./lib/yaml_from_atom').YamlFromAtom

server =
  config:
    port: 3000

#dbs =
#  repos:
#    code_thoughts: 
#      uri: "https://github.com/forforf/code_thoughts/wiki.atom"
#      label: "Status"
  

s = express()

s.get '/', (req, res) ->
  res.send 'Hello Express World'

s.get '/test', (req, res) ->
  yaml_req = {uri: req.query.uri, label: req.query.label}
  parser = new YamlFromAtom(yaml_req)
  parsing = parser.get()
  parsing.on "yamlAtomDo", (o) ->
    res.json(o)
  
  

s.use express.static(__dirname + '/public')

s.listen(server.config.port)
console.log 'Dashboard listening on port %s', server.config.port



