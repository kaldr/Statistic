import { Meteor } from 'meteor/meteor'
import { Mongo } from 'meteor/mongo'
import CSON from 'cson'
import path from 'path'
import _ from 'lodash'
import {StatisticTaskLog} from './StatisticTaskLog.coffee'
import * as Tasks from './tasks/index.coffee'
import Moment from 'moment'
#StatisticTasks = new Mongo.Collection 'StatisticTasks'

class StatisticTasks
  constructor: (@task, @logger) ->

  run: () =>
    _.map @task.tasks, @runTask

  runTask: (taskOb) =>
    taskOb.id = new Mongo.ObjectID()
    @logger.setTask taskOb
    taskClass = Tasks[taskOb.name]
    taskOb.startTime = new Date('2016-05-04 09:21:35')
    taskOb.endTime = new Date('2016-05-04 09:31:35')

    task = new taskClass(taskOb, @logger, @task)
    @logger.endTask()

exports.StatisticTasks = StatisticTasks
