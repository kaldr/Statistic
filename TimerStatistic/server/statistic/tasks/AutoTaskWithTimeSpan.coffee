import * as Steps from './steps/index.coffee'
import {Task} from './Task.coffee'
import Moment from 'moment'
class AutoTaskWithTimeSpan extends Task
  constructor: (@taskOb, @logger, @statisticTask) ->
    super @taskOb, @logger, @statisticTask
    @taskOb.startTime = Moment new Date "2017/1/14 0:30"
    @taskOb.endTime = Moment new Date "2017/1/14 23:30"
    @taskOb.minSpan = @getMinSpan()
    @runSteps()

  getMinSpan: () =>
    minSpan = @taskOb.parameters.timespan
    minSpan = 'Minute' if minSpan >= 60 and minSpan < 3600
    minSpan = 'Second' if minSpan >= 1 and minSpan < 60
    minSpan = 'Hour' if minSpan >= 3600 and minSpan < 3600 * 24
    minSpan = "Day" if minSpan >= 3600 * 24 and minSpan < 3600 * 24 * 28
    minSpan

exports.AutoTaskWithTimeSpan = AutoTaskWithTimeSpan
