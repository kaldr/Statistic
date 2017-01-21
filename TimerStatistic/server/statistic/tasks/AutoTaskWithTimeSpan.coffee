import * as Steps from './steps/index.coffee'
import {Task} from './Task.coffee'
import Moment from 'moment'
class AutoTaskWithTimeSpan extends Task
  constructor: (@taskOb, @logger, @statisticTask) ->
    super @taskOb, @logger, @statisticTask
    return
    @taskOb.startTime = Moment()
    @taskOb.endTime = Moment()
    @runSteps()

exports.AutoTaskWithTimeSpan = AutoTaskWithTimeSpan
