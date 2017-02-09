import * as db from '../Collection/index.coffee'
import _ from 'lodash'
import Moment from 'moment'
import {Meteor} from 'meteor/meteor'
import {Transformer} from '../../util/algorithm/transformer.coffee'

class BasicStatistic

  constructor: (@apiName, @collection, @bannedAPIList = []) ->
    if Meteor.isServer
      #@memcached=new MemJS('localhost:11211',{EJSON:true})
      @transformer=new Transformer()
    Moment.locale 'zh-cn'

  getGroup:(fields,calculation=[],keeps=[])=>
    ob={}
    ob._id=
      start:"$start"
      end:"$end"
    _.map fields,(field)=>
      ob._id[field]="$#{field}"
    _.map calculation,(field)=>
      ob[field]=
        $sum:"$#{field}"
    _.map keeps,(field)=>
      ob[field]=
        $first:"$#{field}"
    ob  
  
  getProject:(fields)=>
    ob={}
    _.map fields,(value,key)=>
      ob[key]="$#{key}"
    ob

  getFinalProject:(separation,data,fields)=>
    ob={}
    ob.start="$_id.start"
    ob.end="$_id.end"
    ob._id=0
    _.map separation,(field)=>
      ob[field]="$_id.#{field}"
    _.map data,(field)=>
      ob[field]="$#{field}"
    _.map fields,(field)=>
      ob[field]="$#{field}"
    ob

  getData:(selector,fields,query)=>
    match=selector
    project=@getProject fields
    group=@getGroup query.separation,query.data,query.fields
    finalProject=@getFinalProject query.separation,query.data,query.fields
    pipeline=[
      {$match:match}
      {$project:project}
      {$group:group}
      {$project:finalProject}
    ]
    data=@collection.aggregate pipeline
    
  getEndTimeBySpanType:(spanType,starttime,endtime)=>
    spanLengthOb=
      day:31
      year:5
      month:12
      hour:24
      week:2
      minute:60
    endTimeByStartTimeAndSpanType=Moment(new Date(starttime)).add spanLengthOb[spanType],spanType
    endTimeByEndTime=Moment(new Date(endtime))
    if endTimeByEndTime < endTimeByStartTimeAndSpanType then endTimeByEndTime.toDate() else endTimeByStartTimeAndSpanType.toDate()
    #endTimeByEndTime.toDate()

  getStatisticOfASpan:(timeType, spanType, query) =>
    if not query.data
      query.data=['count']
    
    chartType=query.chartType
    
    if chartType=='chart.js'
      query.fields=undefined

    selector = {}
    selector.timeType = timeType
    selector.type = spanType
    evalatedEndTime=@getEndTimeBySpanType spanType,query.start,query.end
    selector.start =
      $gte: Moment(new Date(query.start)).toDate()
    selector.end =
      $lte: evalatedEndTime    
    
    queryStartAndEnd=_.clone query
    queryStartAndEnd.start=query.start
    queryStartAndEnd.end=evalatedEndTime
    
    memKey=EJSON.stringify selector
    #memValue=@memcached.get memKey
    memValue=false
    
    if not memValue
      ststamp=Moment().format 'x'
      data = @fetchData selector, query
      endstamp=Moment().format 'x'
      result=@generateTimeWithData timeType, spanType, queryStartAndEnd, data,chartType,query.withTimespanSum
      
      #@memcached.set memKey,EJSON.stringify(result),600
      
      result.timeInfo.fetchDataStart=ststamp
      result.timeInfo.fetchDataEnd=endstamp
      result.query=query  
      result
    
    else
      EJSON.parse memValue    
  getStatistic : (timeType, spanType, request) =>
    #封装query
    query=request.query
    query.data=request.data
    query.separation=request.separation
    query.fields=request.fields
    query.dataType=request.dataType
    query.chartType=request.chartType
    query.withTimespanSum=request.withTimespanSum

    if request.lastTimePeriod#环比同比数据
      periods=@filtPeriods timeType, spanType,query,request.lastTimePeriod
      _.map periods,(period)=>
        q=_.clone query
        q.start=period.start
        q.end=period.end
        {
          period:period.name
          data:@getStatisticOfASpan timeType,spanType,q
        }
    else
      @getStatisticOfASpan timeType, spanType, query
        
  # fetchData: (selector, query) =>
  #   @collection.find(selector).fetch()
  filtPeriods:(timeType, spanType,query,lastTimePeriod)=>
    

  getTimeFormat: (timeType) =>
    ob =
      hour: 'ddd MM/DD HH:mm'
      year: "YYYY"
      month: "YY/MM"
      day: "ddd YY/MM/DD"
      minute: "MM/DD HH:mm:ss"
    ob[timeType]
  
  getDateTimeFields:()=>
    ob=
      start:1
      end:1
      year:1
      month:1
      hour:1
      hourPosition:1
      type:1
      timeType:1
      dateOfMonth:1
      week:1
      weeksInYear:1
      dayOfWeek:1
      dayOfYear:1    

  generateTimeWithData: (timeType, spanType, query, data,chartType='chart.js',withTimespanSum=false) =>
    start=Moment().format('x')
    if chartType=='chart.js'
      data=@getChartJSData timeType, spanType, query, data
    else if chartType=='structured'
      data=@getStructuredData timeType, spanType, query, data,withTimespanSum
    else
      data=@getNormalData timeType, spanType, query, data
    data.timeInfo=
      labelStart:start
      labelEnd:Moment().format("x")
    data

  getSeparationDataStructure:(timeType,spanType,query,data,withTimespanSum=false)=>
    data=@transformer.arrayToTreeBySequence data,query.separation,query.data,withTimespanSum
    data

  getDataStatisticCount:(query,data,fields)=>
    elems=_.filter data,query
    count={}
    _.map fields,(field)=>
      count[field]=0
    _.map elems,(elem)=>
      _.map fields,(field)=>
        count[field]+=elem[field]
    count

  getNormalData:(timeType,spanType,query,data)=>
    data

  getStructuredData:(timeType,spanType,query,data,withTimespanSum=false)=>
    result =
      labels: @getLabels spanType,query
    #startTime = Moment(new Date query.start).subtract(8, 'hour')
    startTime = Moment(new Date query.start)
    #console.log startTime
    #endTime = Moment(new Date query.end).subtract(8, 'hour')
    endTime = Moment(new Date query.end)

    #console.log endTime
    current = startTime
    result.data=@getSeparationDataStructure timeType,spanType,query,data,withTimespanSum
    result        

  getLabels:(spanType,query)=>
    labels=[]
    startTime = Moment(new Date query.start)
    endTime = Moment(new Date query.end)
    current = startTime
    while current < endTime
      labels.push current.format @getTimeFormat spanType    
      if query.span
        current = current.add query.span.count, query.span.type
      else
        if spanType=='minute'
          num=5
        else 
          num=1
        current = current.add num, spanType    
    labels  
  getChartJSData:(timeType, spanType, query, data)=>
    result =
      labels: []
      data: {}
    #startTime = Moment(new Date query.start).subtract(8, 'hour')
    startTime = Moment(new Date query.start)
    #console.log startTime
    #endTime = Moment(new Date query.end).subtract(8, 'hour')
    endTime = Moment(new Date query.end)
    #console.log endTime
    current = startTime
    _.map query.data,(field)=>
      result.data[field]=[]

    while current < endTime
      result.labels.push current.format @getTimeFormat spanType
      eles = _.filter data, (d) =>
        #console.log "%s,%s", d.start.toString(), current.toDate().toString()
        return d.start.toString() == current.toDate().toString()
      count = {}
      _.map query.data,(field)=>
        count[field]=0       
        _.map eles, (e) =>
          count[field]+=e[field]
        result.data[field].push count[field]
      if query.span
        current = current.add query.span.count, query.span.type
      else
        if spanType=='minute'
          num=5
        else 
          num=1
        current = current.add num, spanType
    if query.dataType=='accumulation'
      accumulation={}
      _.map query.data,(field)=>
        accumulation[field]=[]
        len=result.data[field].length
        for i in [0...len] 
          console.log result.data[field][i]
          if i==0
            accumulation[field].push result.data[field][i]
          else
            accumulation[field].push result.data[field][i]+accumulation[field][i-1]
        
      result.data=accumulation
    
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
    # #         
    # #         
    # routes = instance.constructAPIRoutes()
    # routes = instance.apiConfiguration routes
    # _.map routes, (route) =>
    #   RESTstop.add route.url ,{require_login:false,method:'POST'},()->
    #     instance.getStatistic route.timeType, route.spanType, @params    
    
exports.BasicStatistic = BasicStatistic
exports.buildStatisticAPI = buildStatisticAPI
