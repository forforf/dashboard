express    = require 'express'
feedparser = require 'feedparser'
request    = require 'request'
yaml       = require 'js-yaml'

server =
  config:
    port: 3000

items =
  repo:
    wiki_rss: 
      uri: "https://github.com/forforf/code_thoughts/wiki.atom"
    status_label: "Status"

find_status = (feed) ->
  if feed.title is items.repo.status_label
    content = feed['atom:content']['#']
    yaml_content = content.split("---")[1]
    console.log yaml.load(yaml_content)

request items.repo.wiki_rss, (err, resp, body)  ->
  feedparser.parseString(body).on('article', find_status)    

s = express()

s.get '/', (req, res) ->
  res.send 'Hello Express World'

s.get '/test', (req, res) ->
  

s.use express.static(__dirname + '/public')

#s.listen(server.config.port)
#console.log 'Dashboard listening on port %s', server.config.port
