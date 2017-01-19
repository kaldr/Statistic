import * as Steps from './steps/index.coffee'
import Q from 'q'
import {Mongo} from 'meteor/mongo'
import {Meteor} from 'meteor/meteor'

class Task
  constructor: (@taskOb, @logger, @statisticTask) ->
    @configuration()

  configuration: () =>

  runStep: (stepOb) =>
    stepOb.id = new Mongo.ObjectID()
    @logger.setStep stepOb
    Step = new Steps[stepOb.name](stepOb, @logger, @taskob, @statisticTask)
    @logger.endStep()

  constructSequence: () =>

  runSteps: () =>
    _.map @taskOb.steps, @runStep

console.log 'ok'
exports.Task = Task
