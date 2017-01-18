import * as Steps from './steps/index.coffee'
import {Task} from './Task.coffee'

class AutoTaskWithTimeSpan extends Task
  constructor: (@taskOb) ->
    super @taskOb

exports.AutoTaskWithTimeSpan = AutoTaskWithTimeSpan
