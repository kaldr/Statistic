import { Meteor } from 'meteor/meteor'
import { Mongo } from 'meteor/mongo'
import CSON from 'cson'
import path from 'path'
import _ from 'lodash'

StatisticTasks = new Mongo.Collection 'StatisticTasks'
StatisticTaskLog = new Mongo.Collection 'StatisticTaskLog'

###
  获取cson的task配置
  @method getCSONConfig
  @return {object} 任务列表
###
getCSONConfig = () ->
  basePath = path.resolve('.').split('.meteor')[0]
  csonFile = basePath + __dirname + '/defaultTasks.cson'
  tasks = CSON.load csonFile
  tasks.tasks

###
  设置默认的任务数据
  @method setDefaultTasks
###
setDefaultTasks = () =>
  tasks = getCSONConfig()
  len = tasks.length
  if StatisticTasks.find().count() != len
    _.forEach tasks, (task) ->
        if not StatisticTasks.findOne {name: task.name}
          StatisticTasks.insert task

###
  初始化
  @method initiation
  @return {无} 无
###
initiation = () =>
  setDefaultTasks()

initiation()

exports.StatisticTasks = StatisticTasks
exports.StatisticTaskLog = StatisticTaskLog
