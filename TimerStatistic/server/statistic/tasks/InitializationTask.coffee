import {DateTime} from '/imports/util/datetime/datetime.coffee'
import Moment from 'moment'
import {Task} from './Task.coffee'
import _ from 'lodash'
import * as db from '/imports/api/Collection/index.coffee'

class InitializationTask extends Task
  constructor: (@taskOb, @logger, @statisticTask) ->
    super @taskOb, @logger, @statisticTask

    @collection = db[@statisticTask.sourceCollection]
    @perFetch = 1000
    @run()

  generateSpansForAYearByDay: (startDate, endDate) =>
    if not startDate then startDay = Moment().year(year).month(0).date(1).hour(0).minute(0).second(0).millisecond(0) else startDay = startDate
    if not endDate then endDay = Moment().year(year + 1).month(0).date(1).hour(0).minute(0).second(0).millisecond(0) else endDay = endDate
    dates = []
    currentDay = startDay
    i=0
    # console.log '==========================================='
    # console.log startDate,endDate 
    # console.log '==========================================='
    while currentDay <= endDay
      workerID=parseInt process.env.CLUSTER_WORKER_ID
      workerCount=parseInt process.env.CLUSTER_WORKERS_COUNT
      if i%workerCount == workerID-1
        dates.push
          start: currentDay.startOf('day').toDate()
          end: currentDay.endOf('day').toDate()
      # console.log '==========================================='
      # console.log currentDay.startOf('day').toDate(),currentDay.endOf('day').toDate()
      # console.log '==========================================='
      currentDay.add 1, 'day'
      i++
    dates

  fetchAll: () =>
    startTime = Moment new Date @taskOb.parameters.start
    endTime = Moment new Date @taskOb.parameters.end
    spans = @generateSpansForAYearByDay startTime, endTime
    #console.log spans
    _.map spans, @fetch
    #@fetch i, count, perFetch for i in [0...@fetchTimes]

  getTimespansForFetchedData: (fetchedData) =>
    #TODO: 这个方法有问题！但是没有找到
    #FIX: 有bug

    spanList = []
    dt = new DateTime @taskOb.parameters.timespan
    _.map fetchedData, (data) =>
      spanList.push dt.getMinTimeSpans data[@statisticTask.timeParameter.createTime]
    spans = []
    excludeTime = []
    util=require 'util'

    _.map spanList, (ob, index) =>
      if excludeTime.indexOf(index) >= 0 then return
      if @taskOb.parameters.timespan >= 60 then cmpOb = ob.Basic.Minute else cmpOb = ob.Basic.Second
      #TODO:当前只支持basic类型的时间，尚未根据节假日等数据进行协调
      _.map spanList, (ob2Cmp, i) =>
        if i <= index then return
        if @taskOb.parameters.timespan >= 60 then cmpOb2 = ob2Cmp.Basic.Minute else cmpOb2 = ob2Cmp.Basic.Second
        if cmpOb.start.getTime() == cmpOb2.start.getTime() and cmpOb.end.getTime() == cmpOb2.end.getTime()
          excludeTime.push i
    timeTags = ["Second","Minute","Hour","Day","Month", 'Year']

    _.map spanList, (ob, index) =>
      if excludeTime.indexOf(index) == - 1
        _.map ob.Basic, (value, key) =>
          notInFlag = true
          _.map spans, (v, k) =>
            if v.start.getTime() == value.start.getTime() and v.end.getTime() == value.end.getTime()
              notInFlag = false
          if notInFlag
            spans.push
              start: value.start
              end: value.end
    spans

  fetch: (dateObject, i, array) =>

    @selector = @getDefaultQuery()
    options =
      fields: {}
    options.fields[@statisticTask.timeParameter.createTime] = 1
    @selector[@statisticTask.timeParameter.createTime] =
      $gte: dateObject.start
      $lte: dateObject.end
    #console.log @selector
    data = @collection.find(@selector,options).fetch()
    # console.log "current day has #{data.length} pieces of data."
    #console.log data
    spans = @getTimespansForFetchedData data
    # console.log "current day has #{spans.length} spans to fetch."
    console.log "Worker #{process.env.CLUSTER_WORKER_ID}: %s/%s #{data.length} pieces of data / #{spans.length} spans ", i + 1, array.length

    _.map spans, (span) =>
      @taskOb.startTime = Moment span.start
      @taskOb.endTime = Moment span.end
      @runSteps()

  removeData: () =>
    db[@statisticTask.targetCollection].remove {
      taskID: @statisticTask.taskID
    }

  run: () =>
    @removeData() #删除已经导入的数据
    @fetchAll()

  getDBData: () =>



  generateSpans: () =>
    start = Moment new Date @taskOb.parameters.start
    span = @taskOb.parameters.timespan
    end = Moment new Date @taskOb.parameters.end ? Moment().endOf 'day'
    console.log end
    total = (end - start) / 1000
    spans = []
    spanCount = _.ceil total / span

    _.map [0...spanCount], (i) =>
      start = Moment(new Date @taskOb.parameters.start).add span * i, 'seconds'
      end = Moment(new Date @taskOb.parameters.start).add span * i + span, 'seconds'
      spans.push
        start: start
        end: end
    spans

exports.InitializationTask = InitializationTask
