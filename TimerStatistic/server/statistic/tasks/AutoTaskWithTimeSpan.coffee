import * as Steps from './steps/index.coffee'
import {Task} from './Task.coffee'
import Moment from 'moment'
import {DateTime} from '/imports/util/datetime/datetime.coffee'

class AutoTaskWithTimeSpan extends Task
    constructor: (@taskOb, @logger, @statisticTask) ->
        super @taskOb, @logger, @statisticTask
        @DT=new DateTime @taskOb.parameters.timespan
        # @taskOb.startTime = Moment new Date()
        # @taskOb.endTime = @taskOb.startTime.add @taskOb.parameters.timespan,'second'
        # @taskOb.minSpan = @getMinSpan()
        workerID=process.env.CLUSTER_WORKER_ID
        if parseInt(workerID) == 1
            @run()
        #Meteor.setTimeout @run, @taskOb.parameters.timespan*1000
        #@runSteps()

    run:()=>
        if not @span
            @span= @DT.getMinTimeSpans Moment().subtract(@taskOb.parameters.timespan,'second').toDate()
        @taskOb.minSpan = @getMinSpan()   
        startTime=Moment @span.Basic.Minute.start
        endTime=Moment @span.Basic.Minute.end
        @taskOb.startTime = Moment @span.Basic.Minute.start
        @taskOb.endTime = Moment @span.Basic.Minute.end             
        console.log "当前正在统计#{startTime.format('YYYY年MM月DD日HH:mm:ss')}到#{endTime.format('YYYY年MM月DD日HH:mm:ss')}更新的数据"
        @runSteps()
        #设定下一次开始的时间
        nextStartTime=startTime.add @taskOb.parameters.timespan,'second'
        @span=@DT.getMinTimeSpans nextStartTime.toDate()
        now= Moment().subtract(@taskOb.parameters.timespan,'second')        
        diff= nextStartTime-now
        #如果当前运行完之后，已经过了下一次的时间，那么立即执行下一个任务
        if diff<=0
            @run()
        #如果当前运行完之后，还没有过下一次的时间，那么计算时间差，到时间之后再执行下一次
        else
            Meteor.setTimeout @run,diff

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
