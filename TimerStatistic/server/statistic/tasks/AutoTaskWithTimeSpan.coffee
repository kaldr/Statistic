import * as Steps from './steps/index.coffee'
import {Task} from './Task.coffee'

class AutoTaskWithTimeSpan extends Task
  constructor: (@taskOb, @logger, @statisticTask) ->
    super @taskOb, @logger, @statisticTask
    @runSteps()

exports.AutoTaskWithTimeSpan = AutoTaskWithTimeSpan
