import { Meteor } from 'meteor/meteor'
import {Statistic} from './statistic//Statistic.coffee'
import {RestfulAPI} from '/imports/api/restful.coffee'
Meteor.startup ->
  S = new Statistic()
