import {Step} from './Step.coffee'

class GetStatisticDataOfTimeSpan extends Step
    constructor: (@stepOb, @logger, @taskOb, @statisticTask) ->
      super @stepOb, @logger, @taskOb, @statisticTask
exports.GetStatisticDataOfTimeSpan = GetStatisticDataOfTimeSpan
