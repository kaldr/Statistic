import {Step} from './Step.coffee'
import * as db from '/imports/api/Collection/index.coffee'
import {Mongo} from 'meteor/mongo'

class UpdateStatisticDataByDatetime extends Step
  constructor: (@stepOb, @logger, @taskOb, @statisticTask) ->
    super @stepOb, @logger, @taskOb, @statisticTask
    @processCount = 0

  process: (results) =>
    _.map results, (result) =>
      if result.type
        @[result.type](result)

  insertData: (data, spans) =>
    result = []
    _.map spans, (spanData, spanType) =>
      _.map spanData, (d, time) =>
        if data.length > 0
          _.map data, (adata) =>
            _.map adata, (value, key) =>
              if key != '_id'
                d[key] = value
            d.taskID = @statisticTask.taskID
            db[@statisticTask.targetCollection].insert d

  ###
    如果不是直接插入数据，那么就应该更新相关的数据。

  ###
  ###
    向统计数据库插入初始数据
    TODO: 改成批量插入
    @method insert
    @param {object} result 结果集，结构为{data: {} , spans: {} }
    @return {无} 无
  ###
  insert: (result) =>
    #插入数据
    @insertData result.data, result.spans


  update: (result) =>
    data = result.data
    diff = result.diff
    # _.map data, (adata) =>
    #   db[@statisticTask.targetCollection].update {timeID: adata.timeID} , {$inc: {count: diff} }


  updateCurrentSpan: () =>



exports.UpdateStatisticDataByDatetime = UpdateStatisticDataByDatetime
