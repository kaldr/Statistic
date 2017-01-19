import {Mongo} from 'meteor/mongo'
import {Step} from './Step.coffee'
import _ from 'lodash'
import * as Collections from '/imports/api/Collection/index.coffee'

class GetCreatedDataOfTimespan extends Step
  constructor: (@stepOb, @logger, @taskOb, @statisticTask) ->
    super @stepOb, @logger, @taskOb, @statisticTask

  buildInput: (input) =>
    @collection = Collections[@statisticTask.sourceCollection]
    @collection._ensureIndex @getIndex()
    @selector = @getDefaultQuery()
    @fields = @getFields()
    @group =
      _id: @getGroupID()
      id:
        $last: '$_id'
      count:
        $sum: @statisticTask.groupSum

    @selector[@statisticTask.timeParameter.createTime] =
      $gte: input.startTime
      $lt: input.endTime

    @pipeline = [
      {$match: @selector}
      {$project: @fields}
      {$group: @group}
      {$project: @getFinalFields() }
      {$out: @statisticTask.aggregateOutCollection}
    ]

  process: (input) =>
    @logger.startRunning '统计时间段内的新增信息'
    @buildInput(input)
    @collection.aggregate @pipeline
    resultCollection = Collections[@statisticTask.aggregateOutCollection]
    result = resultCollection.find({} ).fetch()
    @logger.endRunning '完成'
    result


exports.GetCreatedDataOfTimespan = GetCreatedDataOfTimespan
