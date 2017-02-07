import { Meteor } from 'meteor/meteor'
import { Mongo } from 'meteor/mongo'
import CSON from 'cson'
import path from 'path'
import _ from 'lodash'
import {StatisticTasks} from './StatisticTasks.coffee'
import {StatisticTaskLog} from './StatisticTaskLog.coffee'

StatisticTasksCollection = new Mongo.Collection 'Statistic_Tasks',{idGeneration: 'MONGO'}
# StatisticTaskLog = new Mongo.Collection 'StatisticTaskLog'

###
  通过cson文件获取所有的任务
  @method getTasksFromCSONConfig
  @return {array} 任务
###
getTasksFromCSONConfig = () =>
  basePath = path.resolve('.').split('.meteor')[0]
  csonFile = basePath + __dirname + '/defaultTasks.cson'
  tasks = CSON.load csonFile
  tasks.statistics

###
Statistic
任务调度类

|__Project_____________________________________________________________________
  |__Statistic__(用于运行和调度项目，是最顶级的程序，下属为StastisticTasks) ___________
    |__Task__(通过StastisticTasks调度，在task文件夹中，所有task都继承Task类) _________
      |__Step__(通过各种Task来调度，所有step都继承Step类) ___________________________
        |__Process__(具体执行的方法，写在Step文件夹的每个step文件中) __________________
          |_____________________________________________________________________
###
class Statistic
  constructor: (@config) ->
    @initializeConfig()
    @getTasks()
    @runTasks()

  ###
    初始化配置
    @method initializeConfig
    @return {null} 无
  ###
  initializeConfig: () =>
    @statisticID = new Mongo.ObjectID()
    if not @config
      @config =
        name: '新系统首页统计'
        taskSource: 'cson'

    if not @config.taskSource
      @config.taskSource = 'cson'

  ###
    利用settimeout运行一个任务
    @method runTask
    @param {object} task 任务对象
    @return {null} null
  ###
  runTask: (task) =>
    @task=task
    Meteor.setTimeout @run,10

  ###*
   * 运行一个方法
   * @param  {object} task 任务对象
   * @return {null}      无
  ###
  run:()=>
    task=@task
    task.id = new Mongo.ObjectID()
    @logger.setStatisticTask task
    currentTask = new StatisticTasks task, @logger
    currentTask.run()
    @logger.endStatisticTask()

  ###
    运行所有任务
    @method runTasks
    @return {null} null
  ###
  runTasks: () =>
    @logger = new StatisticTaskLog(@statisticID, @config.name)
    #_.map @tasks, @runTask
    @runTask @tasks[0]
    @logger.endStatistic()

  ###
    获取任务
    @method getTasks
    @return {null} 无
  ###
  getTasks: () =>
    @tasks = @getTasksFromCSONConfig() if @config.taskSource == 'cson'

  ###
    通过CSON配置获取所有任务
    @method getTasksFromCSONConfig
    @return {array} 任务数组
  ###
  getTasksFromCSONConfig: getTasksFromCSONConfig

  ###
    TODO: 从数据库中获取所有要运行的任务
    @method getTasksFromDB
    @return {array} 任务数组
  ###
  getTasksFromDB: () =>



###
  设置默认的任务数据
  @method setDefaultTasks
###
setDefaultTasks = () =>
  tasks = getTasksFromCSONConfig()
  len = tasks.length
  if StatisticTasksCollection.find().count() != len
    _.forEach tasks, (task) ->
        if not StatisticTasksCollection.findOne {name: task.name}
          StatisticTasksCollection.insert task
###
  初始化 
  @method initiation
  @return {无} 无
###
initiation = () =>
  setDefaultTasks()

initiation()

exports.Statistic = Statistic
