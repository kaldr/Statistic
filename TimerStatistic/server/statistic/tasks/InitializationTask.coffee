import {Task} from './Task.coffee'
class InitializationTask extends Task
  constructor: (@taskOb, @logger, @statisticTask) ->
    super @taskOb, @logger, @statisticTask
    @runSteps()

exports.InitializationTask = InitializationTask
