import {Step} from './Step.coffee'
import * as db from '/imports/api/Collection/index.coffee'
import {Mongo} from 'meteor/mongo'
import {Meteor} from 'meteor/meteor'

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
    batch = db[@statisticTask.targetCollection].rawCollection().initializeUnorderedBulkOp() ;
    _.map spans, (spanData, spanType) =>
      _.map spanData, (sd, time) =>
        if data.length > 0
          d =
            start: sd.start
            end: sd.end
          _.map data, (adata) =>
            _.map adata, (value, key) =>
              if key != '_id' and key!='count'
                if @statisticTask.objectIDParameters.indexOf(key) >= 0
                  d[key] = value._str
                else
                  d[key] = value
            d.taskID = @statisticTask.taskID
            count = adata.count
            batch.find(d).upsert().updateOne {$inc: {count: count} } , {upsert: true}
    execute = Meteor.wrapAsync(batch.execute, batch)
    execute()

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
    # _.map data, (adata) =>
    #   db[@statisticTask.targetCollection].update {timeID: adata.timeID} , {$inc: {count: diff} }


  updateCurrentSpan: () =>



exports.UpdateStatisticDataByDatetime = UpdateStatisticDataByDatetime
