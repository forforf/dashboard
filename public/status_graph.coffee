root = exports ? this

old_interpolateColor = (minColor,maxColor,maxDepth,depth) ->
    d2h = (d)-> return d.toString(16)
    h2d = (h)-> return parseInt(h,16)
   

    if depth is 0
      return minColor

    if depth is maxDepth
        return maxColor
   
    color = "#"
   
    for i in [1..6] by 2             #(var i=1; i <= 6; i+=2){
        minVal = new Number(h2d(minColor.substr(i,2)))
        maxVal = new Number(h2d(maxColor.substr(i,2)))
        nVal = minVal + (maxVal-minVal) * (depth/maxDepth)
        val = d2h(Math.floor(nVal))
        while val.length < 2
            val = "0"+val
        
        color += val
    
    return color

#####

#Color helpers
Color =
  #  choose depth (step) color between min and max, out of maxDepth steps
  interpolate: (minColor,maxColor,maxDepth,depth) ->
    d2h = (d)-> return d.toString(16)
    h2d = (h)-> return parseInt(h,16)

    if depth is 0
      return minColor

    if depth is maxDepth
        return maxColor

    color = "#"
   
    for i in [1..6] by 2 
        minVal = new Number(h2d(minColor.substr(i,2)))
        maxVal = new Number(h2d(maxColor.substr(i,2)))
        nVal = minVal + (maxVal-minVal) * (depth/maxDepth)
        val = d2h(Math.floor(nVal))
        while val.length < 2
            val = "0"+val
        
        color += val
    
    return color 


class StatusGraph
  gradient_colors = 
    start: "#cc8282" 
    stop: "#22ff22"  

  colors =
    bg_start: Color.interpolate("#ffffff", gradient_colors.start, 4,1)
    bg_stop: Color.interpolate("#ffffff", gradient_colors.stop, 4,1)
    max_color_steps: 10
    text: "#003300"

  data_bounds =
    min_score: 0
    max_score: 10
  
  constructor: (@d3_parent, @repo_data) ->
    console.log "d3El", @de_parent
    @sizing = 
      chart_width: -> document.getElementById('repos').offsetWidth
      bar_height: 16
    @text =
      font_size: parseInt(@sizing.bar_height * .75)
      color: colors.text  #sugar

    bar_data = []
    for cat_name, cat_data of @repo_data
      if cat_data.score
        bar_data.push {name: cat_name, score: cat_data.score}  
    @bar_data = bar_data
    @chart_height = @sizing.bar_height * @bar_data.length


    console.log data_bounds.min_score, data_bounds.max_score
    @scaler = d3.scale.linear()
      .domain([data_bounds.min_score, data_bounds.max_score])
      .range([0, @sizing.chart_width()])
    console.log "Scaler Test", @scaler(100)

  interpolateColors: (color_step) ->
    start = gradient_colors.start
    stop  = gradient_colors.stop
    Color.interpolate(start, stop, colors.max_color_steps, color_step)

  svg: =>
    chart = @d3_parent.append('svg:svg')
    gradient_defs = chart.append("svg:defs")

    bg_gradient = gradient_defs.append("svg:linearGradient")
      .attr("id", "bg_gradient")
      .attr("x1", "0%")
      .attr("y1", "0%")
      .attr("x2", "100%")
      .attr("y2", "0%")
      .attr("spreadMethod", "pad")

    #start color
    bg_gradient.append("svg:stop")
      .attr("offset", "0%")
      .attr("stop-color", colors.bg_start)
      .attr("stop-opacity", 1)

    #default stop
    bg_gradient.append("svg:stop")
      .attr("offset", "100%")
      .attr("stop-opacity", 1)
      .attr("stop-color", colors.bg_stop)

    iters = [0..colors.max_color_steps]
    gradients = []
    for i in iters
      console.log i

      gradients[i] = gradient_defs.append("svg:linearGradient")
        .attr("id", "gradient-#{i}")
        .attr("x1", "0%")
        .attr("y1", "0%")
        .attr("x2", "100%")
        .attr("y2", "0%")
        .attr("spreadMethod", "pad")

      #start color
      gradients[i].append("svg:stop")
        .attr("offset", "0%")
        .attr("stop-color", gradient_colors.start)
        .attr("stop-opacity", 1)

      #stop color
      gradients[i].append("svg:stop")
        .attr("offset", "100%")
        .attr("stop-opacity", 1)
        .attr("stop-color", @interpolateColors(i) )

    chart.attr("class", "chart")
      .attr("height", @chart_height)
  
    #sets the width, not strictly necessary, but helpful when reading the html
    chart.attr("width", @sizing.chart_width )

    chart.append("rect")
      .attr("class", "bg")
      .attr("width", @sizing.chart_width)
      .attr("height", @chart_height)
      .style("fill", "url(#bg_gradient)")

    self = @
    chart.selectAll("rect.repo-chart-bg")
      .data(@bar_data)
      .enter().append("rect")
        .attr("class", "bars")
        .attr("y", (d,i)-> 
          return i*self.sizing.bar_height )
        .attr("width", (d) ->
          self.scaler(d.score))

        .attr("height", self.sizing.bar_height)
        .style("fill", (d,i) -> 
           #console.log "fill-", d, i
           #console.log "url(#gradient-#{d.score})"
           return "url(#gradient-#{d.score})")
         #.attr("transform", "translate(0,0)")

    chart.selectAll("text")
      .data(@bar_data)
      .enter().append("text")
        .attr("x", 0)
        .attr("y", (d,i) -> self.sizing.bar_height*i)
      .attr("dy", 10)
      .attr("text-anchor", "left")
      .attr("style", "font-size: #{self.text.font_size}; font-family: Arial, sans-serif")
      .attr("fill", self.text.color)
      .text( (d) ->  d.name )
      .attr("transform", "translate(8,1)")
      .attr("class", "labels")


  

root.StatusGraph = StatusGraph

