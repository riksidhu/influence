'use strict'

angular.module('appApp.controllers')
  .controller('WordsCtrl', ['$scope', '$http', '$location', ($scope, $http, $location) ->
    $scope.rep = {}
    $scope.reps = []
    $scope.words = []
    $scope.wordQuery = ""
    $scope.wordFrequency = ""
    $scope.$watch "rep", ->
      $scope.getRepWords()
    $scope.$watch "wordQuery", ->
      $scope.wordFrequency = "?"
      clearTimeout $scope.waitForTypingToEnd()
      $scope.waitForTypingToEnd()
    

    $scope.waitForTypingToEnd = ->
      setTimeout (->
        $scope.getWordFrequency()
      ), 2000

    $scope.getRepWords = ->
      url = "http://capitolwords.org/api/1/phrases.json?entity_type=legislator&entity_value=#{$scope.rep.bioguide_id}&apikey=3cdfa27b289e4d4090fd1b176c45e6cf"
      $http(
        method: "GET"
        url: "http://query.yahooapis.com/v1/public/yql"
        params:
          q: "select * from json where url=\'#{url}\'"
          format: "json"
      ).success((data, status) ->
        $scope.words = $scope.stringToIntForWordCount(data.query.results.json.json)
      ).error (data, status) ->
        console.log "Error #{status}: #{data}"

    $scope.getRepList = ->
      $http(
        method: "GET"
        url: "http://congress.api.sunlightfoundation.com/legislators?apikey=3cdfa27b289e4d4090fd1b176c45e6cf&chamber=senate&per_page=50&page=2"
      ).success((data, status) ->
        $scope.reps = data.results
      ).error (data, status) ->
        console.log "Error #{status}: #{data}"

    $scope.getWordFrequency = ->
      url = "http://capitolwords.org/api/1/dates.json?phrase=#{$scope.wordQuery.replace(/\s/g, '+')}&apikey=3cdfa27b289e4d4090fd1b176c45e6cf"
      $http(
        method: "GET"
        url: "http://query.yahooapis.com/v1/public/yql"
        params:
          q: "select * from json where url=\'#{url}\'"
          format: "json"
      ).success((data, status) ->
        console.log data
        if data.query.results.json == null
          $scope.wordFrequency = 0
        else
          $scope.wordFrequency = $scope.countFrequency(data.query.results.json.results)
      ).error (data, status) ->
        console.log "Error #{status}: #{data}"

    $scope.stringToIntForWordCount = (array) ->
      i = 0

      while i < array.length
        array[i].count = Number(array[i].count)
        i++
      return array

    $scope.countFrequency = (array) ->
      i = 0
      count = 0

      while i < array.length
        count += Number(array[i].count)
        i++
      return count

    $scope.getRepList()
  ])