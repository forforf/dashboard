// Generated by CoffeeScript 1.3.3
(function() {
  "use strict";

  var AppCtrl, d3DemoApp;

  d3DemoApp = angular.module("d3DemoApp", []);

  d3DemoApp.controller("AppCtrl", AppCtrl = function($scope, $http) {
    var humanReadableDate, reformatGithubResponse;
    $scope.user = "angular";
    $scope.repo = "angular.js";
    humanReadableDate = function(d) {
      return d.getUTCMonth() + "/" + d.getUTCDate();
    };
    reformatGithubResponse = function(data) {
      var authorMap, date0, dateN, days, formattedData, i, j, uniqueAuthors;
      data.sort(function(a, b) {
        if (new Date(a.commit.author.date) > new Date(b.commit.author.date)) {
          return -1;
        } else {
          return 1;
        }
      });
      date0 = new Date(data[data.length - 1].commit.author.date);
      dateN = new Date(data[0].commit.author.date);
      days = Math.floor((dateN - date0) / 86400000) + 1;
      uniqueAuthors = [];
      authorMap = {};
      data.forEach(function(datum) {
        var name;
        name = datum.commit.author.name;
        if (uniqueAuthors.indexOf(name) === -1) {
          authorMap[name] = uniqueAuthors.length;
          return uniqueAuthors.push(name);
        }
      });
      formattedData = [];
      formattedData.length = uniqueAuthors.length;
      i = void 0;
      j = void 0;
      i = 0;
      while (i < formattedData.length) {
        formattedData[i] = [];
        formattedData[i].length = days;
        j = 0;
        while (j < formattedData[i].length) {
          formattedData[i][j] = {
            x: j,
            y: 0
          };
          j++;
        }
        i++;
      }
      data.forEach(function(datum) {
        var curDay, date;
        date = new Date(datum.commit.author.date);
        curDay = Math.floor((date - date0) / 86400000);
        formattedData[authorMap[datum.commit.author.name]][curDay].y += 1;
        return formattedData[0][curDay].date = humanReadableDate(date);
      });
      i = 0;
      while (i < uniqueAuthors.length) {
        formattedData[i][0].user = uniqueAuthors[i];
        i++;
      }
      return formattedData;
    };
    $scope.getCommitData = function() {
      return $http({
        method: "GET",
        url: "https://api.github.com/repos/" + $scope.user + "/" + $scope.repo + "/commits"
      }).success(function(data) {
        $scope.data = reformatGithubResponse(data);
        return $scope.error = "";
      }).error(function(data, status) {
        if (status === 404) {
          return $scope.error = "That repository does not exist";
        } else {
          return $scope.error = "Error: " + status;
        }
      });
    };
    return $scope.getCommitData();
  });

  d3DemoApp.directive("ghVisualization", function() {
    var color, height, margin, width;
    margin = 20;
    width = 960;
    height = 500 - .5 - margin;
    color = d3.interpolateRgb("#f77", "#77f");
    return {
      restrict: "E",
      terminal: true,
      scope: {
        val: "=",
        grouped: "="
      },
      link: function(scope, element, attrs) {
        var vis;
        vis = d3.select(element[0]).append("svg").attr("width", width).attr("height", height + margin + 100);
        return scope.$watch("val", function(newVal, oldVal) {
          var bars, data, keySwatches, keyText, labels, layers, m, mx, my, mz, n, transitionGroup, transitionStack, x, y0, y1, y2;
          transitionGroup = function() {
            var transitionEnd;
            transitionEnd = function() {
              return d3.select(this).transition().duration(500).attr("y", function(d) {
                return height - y2(d);
              }).attr("height", y2);
            };
            return vis.selectAll("g.layer rect").transition().duration(500).delay(function(d, i) {
              return (i % m) * 10;
            }).attr("x", function(d, i) {
              return x({
                x: .9 * ~~(i / m) / n
              });
            }).attr("width", x({
              x: .9 / n
            })).each("end", transitionEnd);
          };
          transitionStack = function() {
            var transitionEnd;
            transitionEnd = function() {
              return d3.select(this).transition().duration(500).attr("x", 0).attr("width", x({
                x: .9
              }));
            };
            return vis.selectAll("g.layer rect").transition().duration(500).delay(function(d, i) {
              return (i % m) * 10;
            }).attr("y", y1).attr("height", function(d) {
              return y0(d) - y1(d);
            }).each("end", transitionEnd);
          };
          vis.selectAll("*").remove();
          if (!newVal) {
            return;
          }
          n = newVal.length;
          m = newVal[0].length;
          data = d3.layout.stack()(newVal);
          mx = m;
          my = d3.max(data, function(d) {
            return d3.max(d, function(d) {
              return d.y0 + d.y;
            });
          });
          mz = d3.max(data, function(d) {
            return d3.max(d, function(d) {
              return d.y;
            });
          });
          x = function(d) {
            return d.x * width / mx;
          };
          y0 = function(d) {
            return height - d.y0 * height / my;
          };
          y1 = function(d) {
            return height - (d.y + d.y0) * height / my;
          };
          y2 = function(d) {
            return d.y * height / mz;
          };
          layers = vis.selectAll("g.layer").data(data).enter().append("g").style("fill", function(d, i) {
            return color(i / (n - 1));
          }).attr("class", "layer");
          bars = layers.selectAll("g.bar").data(function(d) {
            return d;
          }).enter().append("g").attr("class", "bar").attr("transform", function(d) {
            return "translate(" + x(d) + ",0)";
          });
          bars.append("rect").attr("width", x({
            x: .9
          })).attr("x", 0).attr("y", height).attr("height", 0).transition().delay(function(d, i) {
            return i * 10;
          }).attr("y", y1).attr("height", function(d) {
            return y0(d) - y1(d);
          });
          labels = vis.selectAll("text.label").data(data[0]).enter().append("text").attr("class", "label").attr("x", x).attr("y", height + 6).attr("dx", x({
            x: .45
          })).attr("dy", ".71em").attr("text-anchor", "middle").text(function(d, i) {
            return d.date;
          });
          keyText = vis.selectAll("text.key").data(data).enter().append("text").attr("class", "key").attr("y", function(d, i) {
            return height + 42 + 30 * (i % 3);
          }).attr("x", function(d, i) {
            return 155 * Math.floor(i / 3) + 15;
          }).attr("dx", x({
            x: .45
          })).attr("dy", ".71em").attr("text-anchor", "left").text(function(d, i) {
            return d[0].user;
          });
          keySwatches = vis.selectAll("rect.swatch").data(data).enter().append("rect").attr("class", "swatch").attr("width", 20).attr("height", 20).style("fill", function(d, i) {
            return color(i / (n - 1));
          }).attr("y", function(d, i) {
            return height + 36 + 30 * (i % 3);
          }).attr("x", function(d, i) {
            return 155 * Math.floor(i / 3);
          });
          scope.grouped = false;
          return scope.$watch("grouped", function(newVal, oldVal) {
            if (newVal === oldVal) {
              return;
            }
            if (newVal) {
              return transitionGroup();
            } else {
              return transitionStack();
            }
          });
        });
      }
    };
  });

}).call(this);
