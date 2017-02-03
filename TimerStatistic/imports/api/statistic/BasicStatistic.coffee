import * as db from '../Collection/index.coffee'
import _ from 'lodash'
import Moment from 'moment'

class BasicStatistic
  constructor: (@apiName, @collection, @bannedAPIList = []) ->

  getStatistic : (timeType, spanType, request) =>
    query=request.query
    chartType=request.chartType
    selector = {}
    selector.timeType = timeType
    selector.type = spanType
    # selector.start = Moment(query.start).subtract(8,'hour').toDate()
    # selector.end =
    selector.start =
      #$gte: Moment(query.start).subtract(8, 'hour').toDate()
      $gte: Moment(new Date(query.start)).toDate()
    selector.end =
      #$lte: Moment(query.end).subtract(8, 'hour').toDate()
      $lte: Moment(new Date(query.end)).toDate()
    data = @fetchData selector, query
    @generateTimeWithData timeType, spanType, query, data

  fetchData: (selector, query) =>
    @collection.find(selector).fetch()

  getTimeFormat: (timeType) =>
    ob =
      hour: 'ddd MM/DD HH:mm'
      year: "YYYY"
      month: "YY/MM"
      day: "ddd YY/MM/DD"
      minute: "MM/DD HH:mm:ss"
    ob[timeType]

  generateTimeWithData: (timeType, spanType, query, data,chartType='chart.js') =>
    if chartType=='chart.js'
      @getChartJSData timeType, spanType, query, data

  getChartJSData:(timeType, spanType, query, data)=>
    result =
      labels: []
      data: []
    #startTime = Moment(new Date query.start).subtract(8, 'hour')
    startTime = Moment(new Date query.start)
    #console.log startTime
    #endTime = Moment(new Date query.end).subtract(8, 'hour')
    endTime = Moment(new Date query.end)
    #console.log endTime
    current = startTime
    while current < endTime
      result.labels.push current.format @getTimeFormat spanType
      eles = _.filter data, (d) =>
        #console.log "%s,%s", d.start.toString(), current.toDate().toString()
        return d.start.toString() == current.toDate().toString()
      count = 0
      _.map eles, (e) =>
        count += e.count
      result.data.push count
      if query.span
        current = current.add query.span.count, query.span.type
      else
        if spanType=='minute'
          num=5
        else 
          num=1
        current = current.add num, spanType
    result    

  apiConfiguration: (routes) =>
    r = []
    if @bannedAPIList.length
      _.map routes, (route) =>
        if @bannedAPIList.indexOf(route.spanType) == - 1
          r.push route
    else
      r = routes
    r


  timeTypes: () =>
    timeTypes = ['Basic','Lunar', "Activity","Vocation"]
    [timeTypes[0]]

  spanTypes: () =>
    #TODO:某一个具体时间，例如每天9点，例如每周周二，这些时间也可以提供
    spanTypes = [
      "minute" #获得某个时间区间内按分钟统计的数据
      "hour" #获得某个时间间隔内按照小时统计的数据
      "day" #获得某个时间区间内按日统计的数据
      "month" #获得某个时间区间内按月统计的数据
      "year" #获得某个时间区间按年统计的数据
    ]

  constructAPIRoutes: () =>
    timeTypes = @timeTypes()
    spanTypes = @spanTypes()
    routes = []
    _.map timeTypes, (timeType) =>
      _.map spanTypes, (spanType) =>
         url = @constructUrl @apiName, timeType, spanType
         routes.push
            url: url
            spanType: spanType
            timeType: timeType
    routes

  constructUrl: (apiName, timeType, spanType) =>
    url = "statistic/#{apiName}/#{timeType}/#{spanType}"
    console.log url
    url


buildStatisticAPI = (instance) ->
  if Meteor.isServer
    if not instance then return
    API = new Restivus
      enableCors: true
      useDefaultAuth: false
      prettyJson: true
    routes = instance.constructAPIRoutes()
    routes = instance.apiConfiguration routes
    _.map routes, (route) =>
      API.addRoute route.url ,
        post:
          action: () ->
            instance.getStatistic route.timeType, route.spanType, @bodyParams


exports.BasicStatistic = BasicStatistic
exports.buildStatisticAPI = buildStatisticAPI
