import {DateTime} from '/imports/util/datetime/datetime.coffee'
import Moment from 'moment'
import {Task} from './Task.coffee'
import _ from 'lodash'
import * as db from '/imports/api/Collection/index.coffee'

class InitializationTask extends Task
  constructor: (@taskOb, @logger, @statisticTask) ->
    super @taskOb, @logger, @statisticTask
    @run()

  removeData: () =>
    db[@statisticTask.targetCollection].remove {
      taskID: @statisticTask.taskID
    }

  run: () =>
    @removeData() #删除已经导入的数据
    spans = @generateSpans()
    _.map spans, (span) =>
      @taskOb.startTime = span.start
      @taskOb.endTime = span.end
      @runSteps()

  generateSpans: () =>
    start = Moment new Date @taskOb.parameters.start
    span = @taskOb.parameters.timespan
    end = Moment new Date @taskOb.parameters.end ? Moment().endOf 'day'

    total = (end - start) / 1000
    spans = []
    spanCount = _.ceil total / span

    _.map [0...spanCount], (i) =>
      start = Moment(new Date @taskOb.parameters.start).add span * i, 'seconds'
      end = Moment(new Date @taskOb.parameters.start).add span * i + span, 'seconds'
      spans.push
        start: start
        end: end
    spans

exports.InitializationTask = InitializationTask
