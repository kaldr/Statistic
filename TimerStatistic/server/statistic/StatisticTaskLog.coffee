import { Meteor } from 'meteor/meteor'
import { Mongo } from 'meteor/mongo'
import CSON from 'cson'
import path from 'path'
import _ from 'lodash'

StatisticTaskLogCollection = new Mongo.Collection 'Statistic_TaskLog',{idGeneration: 'MONGO'}

class StatisticTaskLog
  constructor: (@statisticID, @statisticName) ->
    @content =
      statisticID: @statisticID
      statisticName: @statisticName
    @startStatistic()

  startStatistic: () =>
    @content.text = '开始统计项目'
    @content.description = ""
    @content.type = 1
    @log @content

  endStatistic: () =>
    @content.text = '结束统计项目'
    @content.description = ""
    @content.type = 2
    @log @content

  setStatisticTask: (statisticTask) =>
    @content.statisticTask = statisticTask.name
    @content.statisticTaskID = statisticTask.id
    @content.description = statisticTask.description
    @content.text = '开始统计任务'
    @content.type = 3
    @log @content

  endStatisticTask: () =>
    @content.text = '结束统计任务'
    @content.description = ""
    @content.type = 4
    @log @content

  setTask: (task) =>
    @content.task = task.name
    @content.taskID = task.id
    @content.description = task.description
    @content.text = '开始任务工作'
    @content.type = 5
    @log @content

  endTask: () =>
    @content.text = '结束任务工作'
    @content.description = ""
    @content.type = 6
    @log @content

  setStep: (step) =>
    @content.text = '开始工作步骤'
    @content.description = step.description
    @content.step = step.name
    @content.stepID = step.id
    @content.type = 7
    @log @content

  endStep: () =>
    @content.text = '结束工作步骤'
    @content.description = ""
    @content.type = 8
    @log @content

  startRunning: (content) =>
    @content.text = '开始执行程序'
    @content.description = content
    @content.type = 9
    @log @content

  endRunning: (content) =>
    @content.text = '结束执行程序'
    @content.description = content
    @content.type = 10
    @log @content

  errorRunningInput: (content) =>
    @content.text = '程序输入错误'
    @content.description = content
    @content.type = 11
    @log @content

  errorRunning: (content) =>
    @content.text = '程序运行错误'
    @content.description = content
    @content.type = 12
    @log @content


  log: (content) =>
    content.datetime = new Date()
    console.log content.text + "|" + content.description
    StatisticTaskLogCollection.insert content

exports.StatisticTaskLog = StatisticTaskLog
