import 'chart.js/dist/Chart.min.js'
import 'angular-chart.js/dist/angular-chart.min.js'
import './chart.styl'
import templateUrl from './chartExample.ng.jade'
import {CallingIn} from '/imports/api/statistic/CallingIn.coffee'

name = 'chart'

class chartController
  constructor: ($scope, $reactive, $http) ->
    $reactive this
      .attach $scope
    $scope.onClick = (points, evt) =>console.log points, evt
    @getData $scope, $http


  getData: ($scope, $http, data) =>
    if not data
      data =
        query:
          start: '2014-1-1 00:00:00'
          end:"2014-1-1 23:59:59"
          #end: '2017-1-10'
          #SDID: '000000000000000000000001'
          #ProductAreaType_ID: 3
          #Record_Type:1
          #LineType_ID:1
          #destination:'000000000000000000003514'
        chartType:'chat.js'
    
    fail = ->
    
    success = (response) =>
      if not $scope.data
        $scope.data=[]
      if not $scope.labels
        $scope.labels=[]
      
      $scope.dataReady = true
      $scope.data = [response.data.data]
      $scope.series = ['电话意向']
      $scope.labels = response.data.labels
      console.log $scope.labels
      console.log $scope.data
    $http({
      method: "POST"
      url: "/api/statistic/callingIn/Basic/hour/"
      data: data
    } ).then(success, fail)



config = (ChartJsProvider) ->
  ChartJsProvider.setOptions
    chartColors: ['#FF5252','#FF8A80']
    responsive: false
  ChartJsProvider.setOptions 'line',
    showLines: true

chart = angular.module name, [
  'chart.js'
]
  .component name, {
    templateUrl: templateUrl
    controllerAs: name
    controller: chartController
  }
  .config config
  .name

exports.chart = chart
