root = exports ? this

EventEmitter = require('events').EventEmitter
feedparser   = require 'feedparser'
request      = require 'request'
yaml         = require 'js-yaml'

class YamlFromAtom extends EventEmitter
  constructor: (@atom_yaml_req) ->

  get: ->
    atom_yaml_req = @atom_yaml_req
    request @atom_yaml_req, (err, response, body)->
      
      @emit "error" if err

      #emit raw feed xml
      resp_obj = 
        response: response
        body: body
      @emit "rawResponse", resp_obj
 
      raw_body = resp_obj.body
      feed = feedparser.parseString(raw_body)

      #parse the articles in the atom feed
      feed.on 'article', (art) =>

        #emit the article
        @emit "article", art

        #article is the one with the yaml
        if art.title is atom_yaml_req.label

          ## emit article type and content
          # type = art["atom:content"]["@"]
          # content = art["atom:content"]["#"]
          # @emit "type", type
          # @emit "content", content

          ## emit yaml string
          # yaml_content = content.split("---")[1]
          # @emit "yaml", yaml_content

          #emit parsed yaml (javascript object)
          final_obj = yaml.load(yaml_content)
          @emit "yamlAtomDo", final_obj


scorecard_request = 
  uri:"https://github.com/forforf/code_thoughts/wiki.atom"
  label: "Status"

test = (new YamlFromAtom(scorecard_request).get()

test.on "article" ->
  console.log "OK"

test.on "yamlAtomDo", (yaml_obj) ->
  console.log yaml_obj

root.YamlFromAtom = YamlFromAtom 

