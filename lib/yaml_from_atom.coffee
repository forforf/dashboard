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
        
        final_obj = null
        #find the article title with the yaml
        if art.title is atom_yaml_req.label

          content = art["atom:content"]["#"]
          yaml_content = content.split("---")[1]

          #emit parsed yaml (javascript object)
          final_obj = yaml.load(yaml_content)

        else
          final_obj = "#{atom_yaml_req.label} not found in article: #{art.title}"

        if final_obj
          @emit "yamlAtomDo", final_obj
        else
          @emit "error", "YamlFromAtom never set the return object"

root.YamlFromAtom = YamlFromAtom 

