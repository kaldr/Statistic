import * as Steps from './steps/index.coffee'
import {Task} from './Task.coffee'
import Moment from 'moment'
import {DateTime} from '/imports/util/datetime/datetime.coffee'

class AutoTaskWithTimeSpan extends Task
    constructor: (@taskOb, @logger, @statisticTask) ->
        super @taskOb, @logger, @statisticTask
        @DT=new DateTime @taskOb.parameters.timespan
        @taskOb.startTime = Moment new Date()
        @taskOb.endTime = @taskOb.startTime.add @taskOb.parameters.timespan,'second'
        @taskOb.minSpan = @getMinSpan()
        @run()
        #Meteor.setTimeout @run, @taskOb.parameters.timespan*1000
        #@runSteps()

    run:=>
        @taskOb.startTime = Moment new Date "2017-01-25T19:00:00.000Z"
        @taskOb.endTime = Moment new Date "2017-01-25T19:04:59.999Z"
        @taskOb.minSpan = @getMinSpan()        
        @runSteps()
        nextTime=200
        #setTimeout @run,nextTime        

    tryMe:()=>
        console.log "CurrentTime:#{new Date()}"
        
    getMinSpan: () =>
        minSpan = @taskOb.parameters.timespan
        minSpan = 'Minute' if minSpan >= 60 and minSpan < 3600
        minSpan = 'Second' if minSpan >= 1 and minSpan < 60
        minSpan = 'Hour' if minSpan >= 3600 and minSpan < 3600 * 24
        minSpan = "Day" if minSpan >= 3600 * 24 and minSpan < 3600 * 24 * 28
        minSpan

exports.AutoTaskWithTimeSpan = AutoTaskWithTimeSpan
