import _ from 'lodash'
import {StatisticTaskLog} from '../../StatisticTaskLog.coffee'

class Step
    constructor: (@stepOb, @logger, @taskOb, @statisticTask) ->
      @configuration()

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
          query[key] = new Mongo.ObjectID value
        else
          query[key] = value
      query

exports.Step = Step
