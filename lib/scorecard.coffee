EventEmitter = require('events').EventEmitter
feedparser   = require 'feedparser'
request      = require 'request'
yaml         = require 'js-yaml'

scorecard_request = 
  uri:"https://github.com/forforf/code_thoughts/wiki.atom"
  label: "Status"

class Scorecard extends EventEmitter
  constructor: (@sc_req) ->

  get: ->
    sc_req = @sc_req
    request @sc_req, (err, response, body)->
      
      @emit "error" if err

      #emit raw feed xml
      resp_obj = 
        response: response
        body: body
      @emit "rawResponse", resp_obj
      

      #emit parsed feed content
      raw_body = resp_obj.body
      feed = feedparser.parseString(raw_body)

      feed.on 'article', (art) =>
        #console.log "Art:", art
        @emit "article", art
        #if true
        #  console.log "Art:", art.title
        
        if art.title is sc_req.label
          #emit article type and content
          type = art["atom:content"]["@"]
          content = art["atom:content"]["#"]
          @emit "type", type
          @emit "content", content

          #emit yaml string
          yaml_content = content.split("---")[1]
          @emit "yaml", yaml_content

          #emit parsed yaml (javascript object)
          final_obj = yaml.load(yaml_content)
          @emit "parsedObj", final_obj

    



test = new Scorecard(scorecard_request)

data = test.get()
data.on "error", (err_data) ->
  console.log "Error: #{err_data}"


data.on "parsedObj", (data) ->
  console.log "Obj Data:", data


