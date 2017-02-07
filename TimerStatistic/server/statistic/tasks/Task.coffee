import * as Steps from './steps/index.coffee'
import {Mongo} from 'meteor/mongo'
import {Meteor} from 'meteor/meteor'
import _ from 'lodash'

class Task
  constructor: (@taskOb, @logger, @statisticTask) ->
    @configuration()
    @taskSteps = {}

  configuration: () =>
 
  ###*
     * 获取任务配置中默认的查询条件
     * @return {object} 查询条件，可以直接用于mongodb的query中
  ###
  getDefaultQuery: () =>
    query = {}
    transformToObIDList = @statisticTask.objectIDParameters
    addKeyAndValue=(value,key)=>
      if @statisticTask.objectIDParameters.indexOf(key) >= 0
        query[key] = new Mongo.ObjectID value
      else
        query[key] = value        
    _.map @statisticTask.defaultQuery, addKeyAndValue
    # _.map @statisticTask.defaultQueryArray,(keyValuePair)=>
    #   addKeyAndValue keyValuePair.value,keyValuePair.key
    query

  stepOnReject: () =>


  runStep: (result, stepOb) =>
    stepOb.id = new Mongo.ObjectID()
    #@logger.setStep stepOb
    if not @taskSteps[stepOb.name]
      @taskSteps[stepOb.name] = new Steps[stepOb.name](stepOb, @logger, @taskOb, @statisticTask)
    else
      @taskSteps[stepOb.name].setStep stepOb
    #console.log result
    output = @taskSteps[stepOb.name].run result
    #@logger.endStep()
    #


  runSteps: () =>
    result = []
    _.reduce @taskOb.steps, @runStep, @taskOb


exports.Task = Task
