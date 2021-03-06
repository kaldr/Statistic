import 'chart.js/dist/Chart.min.js'
import 'angular-chart.js/dist/angular-chart.min.js'
import './chart.styl'
import templateUrl from './chartExample.ng.jade'
import {CallingIn} from '/imports/api/statistic/CallingIn.coffee'

name = 'chart'

class chartController
  constructor: ($scope, $reactive, $http) ->
    # $reactive this
    #   .attach $scope
    $scope.onClick = (points, evt) =>console.log points, evt
    #@getData $scope, $http
    @getOrderData $scope,$http

  getOrderData: ($scope, $http, data) =>
    if not data
      data =
        query:
          start: '2014-3-1 00:00:00'
          end:"2015-1-1 23:59:59"
          createUserDepartmentID:['000000000000000000000015','000000000000000000000759','000000000000000000000748']
        #chartType:'chart.js'
        chartType:'flat'
        #dataType:"accumulation"
        data:['ElderNumber','AdultNumber','ChildNumber','BabyNumber','TotalNumber']
        separation:['createUserDepartmentID','createUserID','OrderTypeID']
        fields:['year','month','dayOfWeek','dateOfMonth']
        withTimespanSum:true
        lastData:['span','year','month','day','hour']
        
    fail = ->
    
    success = (response) =>
      if not $scope.Orderdata
        $scope.Orderdata=[]
      if not $scope.Orderlabels
        $scope.Orderlabels=[]
      
      $scope.OrderdataReady = true
      $scope.Orderdata = [response.data.data.ElderNumber,response.data.data.AdultNumber,response.data.data.ChildNumber,response.data.data.BabyNumber,response.data.data.TotalNumber]
      $scope.Orderseries = ['老人数','成人数','儿童数','婴儿数','总数']
      $scope.Orderlabels = response.data.labels
      console.log $scope.Orderlabels
      console.log $scope.Orderdata
    $http({
      method: "POST"
      url: "/api/statistic/orders/Basic/month/"
      data: data
    } ).then(success, fail)

  getData: ($scope, $http, data) =>
    if not data
      data =
        query:
          start: '2014-1-1 00:00:00'
          end:"2014-3-30 23:59:59"
          #end: '2017-1-10'
          SDID: '000000000000000000000001'
          ProductAreaType_ID: 1
          Record_Type:1
          LineType_ID:2
          #destination:'000000000000000000003602'
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
