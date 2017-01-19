import {Step} from './Step.coffee'

class UpdateStatisticDataByDatetime extends Step
  constructor: (@stepOb, @logger, @taskOb, @statisticTask) ->
    super @stepOb, @logger, @taskOb, @statisticTask


exports.UpdateStatisticDataByDatetime = UpdateStatisticDataByDatetime
