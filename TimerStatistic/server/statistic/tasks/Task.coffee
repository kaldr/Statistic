import * as Steps from './steps/index.coffee'
import {Mongo} from 'meteor/mongo'
import {Meteor} from 'meteor/meteor'

class Task
  constructor: (@taskOb, @logger, @statisticTask) ->
    @configuration()
    @taskSteps = {}
  configuration: () =>
  stepOnReject: () =>
  runStep: (result, stepOb) =>
    stepOb.id = new Mongo.ObjectID()
    #@logger.setStep stepOb
    if not @taskSteps[stepOb.name]
      @taskSteps[stepOb.name] = new Steps[stepOb.name](stepOb, @logger, @taskOb, @statisticTask)
    else
      @taskSteps[stepOb.name].setStep stepOb
    output = @taskSteps[stepOb.name].run result
    #@logger.endStep()


  runSteps: () =>
    result = []
    _.reduce @taskOb.steps, @runStep, @taskOb

exports.Task = Task
