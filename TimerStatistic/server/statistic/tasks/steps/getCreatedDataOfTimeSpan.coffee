import {Mongo} from 'meteor/mongo'
import {Step} from './Step.coffee'
import _ from 'lodash'
import * as Collections from '/imports/api/Collection/index.coffee'
import {DateTime} from '/imports/util/datetime/datetime.coffee'

class GetCreatedDataOfTimespan extends Step
  constructor: (@stepOb, @logger, @taskOb, @statisticTask) ->
    super @stepOb, @logger, @taskOb, @statisticTask

  buildInput: (input) =>
    @collection = Collections[@statisticTask.sourceCollection]
    @selector = @getDefaultQuery()
    @fields = @getFields()
    @group =
      _id: @getGroupID()
      id:
        $last: '$_id'
      count:
        $sum: @statisticTask.groupSum

    @selector[@statisticTask.timeParameter.createTime] =
      $gte: input.startTime.toDate()
      $lte: input.endTime.toDate()

    @pipeline = [
      {$match: @selector}
      {$project: @fields}
      {$group: @group}
      {$project: @getFinalFields() }
      {$out: @statisticTask.aggregateOutCollection}
    ]


  getAggregatedData: (input) =>
    @buildInput(input)
    @collection.aggregate @pipeline
    resultCollection = Collections[@statisticTask.aggregateOutCollection]
    result = resultCollection.find({} ).fetch()

  process: (input) =>
    #@logger.startRunning '统计时间段内的新增信息'
    getAggregatedData = @getAggregatedData input
    getSpansNeedToUpdate = @getSpansNeedToUpdate input

    result =
      data: getAggregatedData
      spans: getSpansNeedToUpdate
      type: 'insert'
    #@logger.endRunning '完成'
    [result]


exports.GetCreatedDataOfTimespan = GetCreatedDataOfTimespan
