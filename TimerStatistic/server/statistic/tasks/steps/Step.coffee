import _ from 'lodash'
import {StatisticTaskLog} from '../../StatisticTaskLog.coffee'
import {DateTime} from '/imports/util/datetime/datetime.coffee'
class Step
    constructor: (@stepOb, @logger, @taskOb, @statisticTask) ->
      @configuration()

    setStep: (stepOb) =>
      @stepOb = stepOb
      @configuration()

    getSpansNeedToUpdate: () =>
      dt = new DateTime @taskOb.parameters.timespan
      spans = dt.getTimeSpans @taskOb.startTime

    ###
      获取最小的时间间隔信息
      @method getMinSpan
      @return {object} 时间间隔信息
    ###
    getMinSpan : () =>
      spans = @getSpansNeedToUpdate()
      currentSpan = {}
      _.map spans, (spansTypeData, spansType) =>#basic/lunar/... : {}
        currentSpan[spansType] = {}
        _.map spansTypeData, (data, timeType) =>#year/month/day... : {}
          if timeType == @taskOb.minSpan
            currentSpan[spansType][timeType] = _.clone data
      currentSpan

    ###
      获取当前时间间隔维度的更高时间维度的时间间隔对象
      @method getParentSpans
      @param {object} input 任务对象
      @return {object} 时间间隔信息
    ###
    getParentSpans: () =>
      spans = @getSpansNeedToUpdate()
      parentSpans = {}
      _.map spans, (spansTypeData, spansType) =>#basic/lunar/... : {}
        parentSpans[spansType] = {}
        _.map spansTypeData, (data, timeType) =>#year/month/day... : {}
          if timeType != @taskOb.minSpan
            parentSpans[spansType][timeType] = _.clone data
      parentSpans

    run: (result) =>
      if @runCheck() then @process?(result)

    runCheck: () =>
      if (not @stepOb) or (not @taskOb) or (not @statisticTask) then false else true

    configuration: () =>
      if not @logger
        @logger = new StatisticTaskLog new Mongo.ObjectID(), '未定义统计项目名称'

      if not (@stepOb and @taskOb and @statisticTask)
        text = '没有输入本步骤的配置，缺失输入为:'
        text += 'stepOb ' if not @stepOb
        text += 'taskOb ' if not @taskOb
        text += 'statisticTask ' if not @statisticTask
        @logger.errorRunningInput text

    getFinalFields: () =>
      fields = {}
      _.map @statisticTask.parameters, (value, key) ->
        fields[key] = "$_id." + key
      fields.count = "$count"
      fields._id = '$id'
      #fields.ids="$ids"
      fields

    getGroupID: () =>
      group = {}
      _.map @statisticTask.parameters, (value, key) ->
        group[key] = "$" + key
      group

    getIndex: () =>
      index = {}
      _.map @statisticTask.defaultQuery, (value, key) ->
        index[key] = 1
      index

    getFields: () =>
      fields = {}
      _.map @statisticTask.parameters, (value, key) ->
          fields[key] = value
      fields["_id"] = 1
      fields

    getDefaultQuery: () =>
      query = {}
      transformToObIDList = @statisticTask.objectIDParameters
      _.map @statisticTask.defaultQuery, (value, key) ->
        if transformToObIDList.indexOf(key) >= 0
          query[key] = Mongo.ObjectID value
        else
          query[key] = value
      query

exports.Step = Step
