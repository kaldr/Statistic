import {Meteor} from 'meteor/meteor'
import {Mongo} from 'meteor/mongo'
import {DateTime} from '/imports/util/datetime/datetime.coffee'
import _ from "lodash"
import {Step} from './Step.coffee'
import * as Collections from '/imports/api/Collection/index.coffee'
import Moment from 'moment'

class BuildNeccesarySpans extends Step

  constructor: (@stepOb, @logger, @taskOb, @statisticTask) ->
    super @stepOb, @logger, @taskOb, @statisticTask
    @collection = Collections[@statisticTask.sourceCollection]
    @perFetch = 1000

  getDataCount: () =>
    @selector = @getDefaultQuery()
    @selector[@statisticTask.timeParameter.createTime] =
      $gte: new Date @taskOb.parameters.start
      $lt: new Date @taskOb.parameters.end
    count = @collection.find(@selector).count()


  generateSpansForAYearByDay: (startDate, endDate) =>
    if not startDate then startDay = Moment().year(year).month(0).date(1).hour(0).minute(0).second(0).millisecond(0) else startDay = startDate
    if not endDate then endDay = Moment().year(year + 1).month(0).date(1).hour(0).minute(0).second(0).millisecond(0) else endDay = endDate
    dates = []
    currentDay = startDay
    while currentDay <= endDay
      dates.push
        start: currentDay.startOf('day').toDate()
        end: currentDay.endOf('day').toDate()
      currentDay.add 1, 'day'
    dates

  fetchAll: () =>
    startTime = Moment new Date @taskOb.parameters.start
    endTime = Moment new Date @taskOb.parameters.end
    spans = @generateSpansForAYearByDay startTime, endTime
    @spans = []
    _.map spans, @fetch
    #@fetch i, count, perFetch for i in [0...@fetchTimes]
    console.log @spans

  getTimespansForFetchedData: (fetchedData) =>

    spanList = []
    dt = new DateTime @taskOb.parameters.timespan
    _.map fetchedData, (data) =>
      spanList.push dt.getMinTimeSpans data.Record_Time
    spans = []
    excludeTime = []

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

  fetch: (dateObject, i) =>
    @selector = @getDefaultQuery()
    options =
      fields: {}
    options.fields[@statisticTask.timeParameter.createTime] = 1
    @selector[@statisticTask.timeParameter.createTime] =
      $gte: dateObject.start
      $lte: dateObject.end
    data = @collection.find(@selector).fetch()
    @getTimespansForFetchedData data



exports.BuildNeccesarySpans = BuildNeccesarySpans
