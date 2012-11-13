"use strict"

# create module for custom directives
d3DemoApp = angular.module("d3DemoApp", [])

# controller business logic
d3DemoApp.controller "AppCtrl", AppCtrl = ($scope, $http) ->
  
  # initialize the model
  $scope.user = "angular"
  $scope.repo = "angular.js"
  
  # helper for formatting date
  humanReadableDate = (d) ->
    d.getUTCMonth() + "/" + d.getUTCDate()

  
  # helper for reformatting the Github API response into a form we can pass to D3
  reformatGithubResponse = (data) ->
    
    # sort the data by author date (rather than commit date)
    data.sort (a, b) ->
      if new Date(a.commit.author.date) > new Date(b.commit.author.date)
        -1
      else
        1

    
    # date objects representing the first/last commit dates
    date0 = new Date(data[data.length - 1].commit.author.date)
    dateN = new Date(data[0].commit.author.date)
    
    # the number of days between the first and last commit
    days = Math.floor((dateN - date0) / 86400000) + 1
    
    # map authors and indexes
    uniqueAuthors = [] # map index -> author
    authorMap = {} # map author -> index
    data.forEach (datum) ->
      name = datum.commit.author.name
      if uniqueAuthors.indexOf(name) is -1
        authorMap[name] = uniqueAuthors.length
        uniqueAuthors.push name

    
    # build up the data to be passed to our d3 visualization
    formattedData = []
    formattedData.length = uniqueAuthors.length
    i = undefined
    j = undefined
    i = 0
    while i < formattedData.length
      formattedData[i] = []
      formattedData[i].length = days
      j = 0
      while j < formattedData[i].length
        formattedData[i][j] =
          x: j
          y: 0
        j++
      i++
    data.forEach (datum) ->
      date = new Date(datum.commit.author.date)
      curDay = Math.floor((date - date0) / 86400000)
      formattedData[authorMap[datum.commit.author.name]][curDay].y += 1
      formattedData[0][curDay].date = humanReadableDate(date)

    
    # add author names to data for the chart's key
    i = 0
    while i < uniqueAuthors.length
      formattedData[i][0].user = uniqueAuthors[i]
      i++
    formattedData

  $scope.getCommitData = ->
    
    # attach this data to the scope
    
    # clear the error messages
    $http(
      method: "GET"
      url: "https://api.github.com/repos/" + $scope.user + "/" + $scope.repo + "/commits"
    ).success((data) ->
      $scope.data = reformatGithubResponse(data)
      $scope.error = ""
    ).error (data, status) ->
      if status is 404
        $scope.error = "That repository does not exist"
      else
        $scope.error = "Error: " + status


  
  # get the commit data immediately
  $scope.getCommitData()

d3DemoApp.directive "ghVisualization", ->
  
  # constants
  margin = 20
  width = 960
  height = 500 - .5 - margin
  color = d3.interpolateRgb("#f77", "#77f")
  restrict: "E"
  terminal: true
  scope:
    val: "="
    grouped: "="

  link: (scope, element, attrs) ->
    
    # set up initial svg object
    vis = d3.select(element[0]).append("svg").attr("width", width).attr("height", height + margin + 100)
    scope.$watch "val", (newVal, oldVal) ->
      
      # clear the elements inside of the directive
      
      # if 'val' is undefined, exit
      
      # Based on: http://mbostock.github.com/d3/ex/stack.html
      # number of layers
      # number of samples per layer
      # or `my` not rescale
      
      # Layers for each color
      # =====================
      
      # Bars
      # ====
      
      # X-axis labels
      # =============
      
      # Chart Key
      # =========
      
      # Animate between grouped and stacked
      # ===================================
      transitionGroup = ->
        transitionEnd = ->
          d3.select(this).transition().duration(500).attr("y", (d) ->
            height - y2(d)
          ).attr "height", y2
        vis.selectAll("g.layer rect").transition().duration(500).delay((d, i) ->
          (i % m) * 10
        ).attr("x", (d, i) ->
          x x: .9 * ~~(i / m) / n
        ).attr("width", x(x: .9 / n)).each "end", transitionEnd
      transitionStack = ->
        transitionEnd = ->
          d3.select(this).transition().duration(500).attr("x", 0).attr "width", x(x: .9)
        vis.selectAll("g.layer rect").transition().duration(500).delay((d, i) ->
          (i % m) * 10
        ).attr("y", y1).attr("height", (d) ->
          y0(d) - y1(d)
        ).each "end", transitionEnd
      vis.selectAll("*").remove()
      return  unless newVal
      n = newVal.length
      m = newVal[0].length
      data = d3.layout.stack()(newVal)
      mx = m
      my = d3.max(data, (d) ->
        d3.max d, (d) ->
          d.y0 + d.y

      )
      mz = d3.max(data, (d) ->
        d3.max d, (d) ->
          d.y

      )
      x = (d) ->
        d.x * width / mx

      y0 = (d) ->
        height - d.y0 * height / my

      y1 = (d) ->
        height - (d.y + d.y0) * height / my

      y2 = (d) ->
        d.y * height / mz

      layers = vis.selectAll("g.layer").data(data).enter().append("g").style("fill", (d, i) ->
        color i / (n - 1)
      ).attr("class", "layer")
      bars = layers.selectAll("g.bar").data((d) ->
        d
      ).enter().append("g").attr("class", "bar").attr("transform", (d) ->
        "translate(" + x(d) + ",0)"
      )
      bars.append("rect").attr("width", x(x: .9)).attr("x", 0).attr("y", height).attr("height", 0).transition().delay((d, i) ->
        i * 10
      ).attr("y", y1).attr "height", (d) ->
        y0(d) - y1(d)

      labels = vis.selectAll("text.label").data(data[0]).enter().append("text").attr("class", "label").attr("x", x).attr("y", height + 6).attr("dx", x(x: .45)).attr("dy", ".71em").attr("text-anchor", "middle").text((d, i) ->
        d.date
      )
      keyText = vis.selectAll("text.key").data(data).enter().append("text").attr("class", "key").attr("y", (d, i) ->
        height + 42 + 30 * (i % 3)
      ).attr("x", (d, i) ->
        155 * Math.floor(i / 3) + 15
      ).attr("dx", x(x: .45)).attr("dy", ".71em").attr("text-anchor", "left").text((d, i) ->
        d[0].user
      )
      keySwatches = vis.selectAll("rect.swatch").data(data).enter().append("rect").attr("class", "swatch").attr("width", 20).attr("height", 20).style("fill", (d, i) ->
        color i / (n - 1)
      ).attr("y", (d, i) ->
        height + 36 + 30 * (i % 3)
      ).attr("x", (d, i) ->
        155 * Math.floor(i / 3)
      )
      
      # reset grouped state to false
      scope.grouped = false
      
      # setup a watch on 'grouped' to switch between views
      scope.$watch "grouped", (newVal, oldVal) ->
        
        # ignore first call which happens before we even have data from the Github API
        return  if newVal is oldVal
        if newVal
          transitionGroup()
        else
          transitionStack()
