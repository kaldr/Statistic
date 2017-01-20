import {DateTime} from '/imports/util/datetime/datetime.coffee'
import Moment from 'moment'
import {Task} from './Task.coffee'
import _ from 'lodash'

class InitializationTask extends Task
  constructor: (@taskOb, @logger, @statisticTask) ->
    super @taskOb, @logger, @statisticTask
    @run()


  run: () =>
    spans = @generateSpans()
    _.map spans, (span) =>
      @taskOb.startTime = span.start
      @taskOb.endTime = span.end
      @runSteps()

  generateSpans: () =>
    start = Moment new Date @taskOb.parameters.start
    span = @taskOb.parameters.timespan
    end = Moment().endOf 'day'
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
