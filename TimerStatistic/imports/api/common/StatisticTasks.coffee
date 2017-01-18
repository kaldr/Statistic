import { Meteor } from 'meteor/meteor'
import { Mongo } from 'meteor/mongo'
import CSON from 'cson'
import path from 'path'
import _ from 'lodash'
import {StatisticTaskLog} from './StatisticTaskLog.coffee'
import * as Tasks from './tasks/index.coffee'

#StatisticTasks = new Mongo.Collection 'StatisticTasks'

class StatisticTasks
  constructor: (@task, @logger) ->

  run: () =>
    _.map @task.tasks, @runTask

  runTask: (taskOb) =>
    taskOb.id = new Mongo.ObjectID()
    @logger.setTask taskOb
    taskClass = Tasks[taskOb.name]
    task = new taskClass(taskOb, @logger)
    @logger.endTask

exports.StatisticTasks = StatisticTasks
