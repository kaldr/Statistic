import {GetCreatedDataOfTimespan} from './getCreatedDataOfTimeSpan.coffee'

class GetUpdatedDataOfTimespan extends GetCreatedDataOfTimespan
  constructor: (@stepOb, @logger, @taskOb, @statisticTask) ->
    super @stepOb, @logger, @taskOb, @statisticTask

  buildInput: (input) =>
    super.buildInput(input)
    delete @selector[@statisticTask.timeParameter.createTime]
    @selector[@statisticTask.timeParameter.updateTime] =
      $gte: input.startTime
      $lt: input.endTime

  process: (input) =>
    @logger.startRunning '统计时间段内的更新的信息'
    @buildInput(input)
    @collection.aggregate @pipeline
    resultCollection = Collections[@statisticTask.aggregateOutCollection]
    result = resultCollection.find({} ).fetch()
    @logger.endRunning '完成'
    result
exports.GetUpdatedDataOfTimespan = GetUpdatedDataOfTimespan
