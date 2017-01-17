import { Meteor } from 'meteor/meteor'
import { Mongo } from 'meteor/mongo'
import CSON from 'cson'
import path from 'path'
import _ from 'lodash'

class StatisticCollection extends Mongo.Collection
  constructor: (@taskObj = {} ) ->
    super @taskObj.sourceCollection

  appendDefaultValue : (query) =>
    keys = _.keys @taskObj.defaultQuery
    _.map keys, (key) =>
      query[key] = @taskObj.defaultQuery[key]
    console.log query
    query

  find : (query, options) =>
    @appendDefaultValue query
    super.find(query, options)

StatisticTasks = new Mongo.Collection 'StatisticTasks'
StatisticTaskLog = new Mongo.Collection 'StatisticTaskLog'
CallingIn = new Mongo.Collection 'Customer_Record'
CallingIn.before.find (userId, selector, options) ->
  selector.DelStatus = 0#未删除
  selector.RecordType_ID = 1#业务类型
  selector.AddType = 1#400客服电话
logs = CallingIn.find {CreateUserName: '网络订单'}
  .fetch()
console.log logs
###
  获取cson的task配置
  @method getTasksFromCSONConfig
  @return {object} 任务列表
###
getTasksFromCSONConfig = () ->
  basePath = path.resolve('.').split('.meteor')[0]
  csonFile = basePath + __dirname + '/defaultTasks.cson'
  tasks = CSON.load csonFile
  tasks.tasks

###
  设置默认的任务数据
  @method setDefaultTasks
###
setDefaultTasks = () =>
  tasks = getTasksFromCSONConfig()
  len = tasks.length
  if StatisticTasks.find().count() != len
    _.forEach tasks, (task) ->
        if not StatisticTasks.findOne {name: task.name}
          StatisticTasks.insert task

getSomeData = () =>
  tasks = getTasksFromCSONConfig()
  CallingIn = new StatisticCollection tasks[0]
  logs = CallingIn.find {CreateUserName: '网络订单'} , {}
    .fetch()
  console.log logs
###
  初始化
  @method initiation
  @return {无} 无
###
initiation = () =>
  setDefaultTasks()
  #getSomeData()

initiation()

exports.StatisticCollection = StatisticCollection
exports.StatisticTasks = StatisticTasks
exports.StatisticTaskLog = StatisticTaskLog
