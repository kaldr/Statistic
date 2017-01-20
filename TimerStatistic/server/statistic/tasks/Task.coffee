import * as Steps from './steps/index.coffee'
import {Mongo} from 'meteor/mongo'
import {Meteor} from 'meteor/meteor'

class Task
  constructor: (@taskOb, @logger, @statisticTask) ->
    @configuration()

  configuration: () =>
  stepOnReject: () =>

  runStep: (result, stepOb) =>
    stepOb.id = new Mongo.ObjectID()
    #@logger.setStep stepOb
    Step = new Steps[stepOb.name](stepOb, @logger, @taskOb, @statisticTask)
    output = Step.run result
    #@logger.endStep()
    output

  runSteps: () =>
    result = []
    _.reduce @taskOb.steps, @runStep, @taskOb

exports.Task = Task
