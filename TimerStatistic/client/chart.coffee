import 'chart.js/dist/Chart.min.js'
import 'angular-chart.js/dist/angular-chart.min.js'
import './chart.styl'
import templateUrl from './chartExample.ng.jade'
name = 'chart'
import {CallingIn} from '/imports/api/statistic/CallingIn.coffee'

class chartController
  constructor: ($scope, $reactive, $http) ->
    $reactive this
      .attach $scope
    $scope.onClick = (points, evt) =>console.log points, evt
    @getData $scope, $http

  getData: ($scope, $http, data) =>
    if not data
      data =
        start: '2016-01-10'
        end: '2016-12-31'
        #SDID: '000000000000000000000001'
        #destiniation: '000000000000000000000696'
    fail = ->
    success = (response) =>
      $scope.dataReady = true
      $scope.data = [response.data.data]
      $scope.series = ['电话意向']
      $scope.labels = response.data.labels
      console.log $scope.labels
      console.log $scope.data
    $http({
      method: "POST"
      url: "/api/statistic/callingIn/Basic/day/"
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
