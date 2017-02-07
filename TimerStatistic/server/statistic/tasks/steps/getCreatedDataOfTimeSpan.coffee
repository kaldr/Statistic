import {Mongo} from 'meteor/mongo'
import {Step} from './Step.coffee'
import _ from 'lodash'
import * as Collections from '/imports/api/Collection/index.coffee'
import {DateTime} from '/imports/util/datetime/datetime.coffee'
import util from 'util'

class GetCreatedDataOfTimespan extends Step
  constructor: (@stepOb, @logger, @taskOb, @statisticTask) ->
    super @stepOb, @logger, @taskOb, @statisticTask

  buildInput: (input,anti=false) =>
    @collection = Collections[@statisticTask.sourceCollection]
    @selector = @getDefaultQuery(anti)
    @fields = @getFields()
    @group =
      _id: @getGroupID()
      id:
        $last: '$_id'
      # ids:
      #   $push:{_id:"$_id"}
      count:
        $sum: @statisticTask.groupSum
    @getSumParameters()
    @selector[@statisticTask.timeParameter.createTime] =
      $gte: input.startTime.toDate()
      $lte: input.endTime.toDate()

    @pipeline = [
      {$match: @selector}
      {$project: @fields}
      {$group: @group}
      {$project: @getFinalFields() }
    ]


  getAggregatedData: (input) =>
    @buildInput(input)
    #console.log util.inspect @pipeline,true,5
    #console.log @collection._name
    #console.log @selector
    #console.log 
    @pipeline = [
      {$match: @selector}
      {$project: @fields}
      {$group: @group}
      {$project: @getFinalFields() }
    ]
    # console.log @pipeline
    data=@collection.aggregate @pipeline
    # console.log "===================================="
    # console.log data
    data


  process: (input) =>
    #@logger.startRunning '统计时间段内的新增信息'
    getAggregatedData = @getAggregatedData input
    #console.log getAggregatedData[0].count + ":#{input.startTime.toDate()},#{input.endTime.toDate()}"
    getSpansNeedToUpdate = @getSpansNeedToUpdate input
    # console.log getSpansNeedToUpdate
    result =
      data: getAggregatedData
      spans: getSpansNeedToUpdate
      type: 'insert'
    #@logger.endRunning '完成'
    [result]


exports.GetCreatedDataOfTimespan = GetCreatedDataOfTimespan
