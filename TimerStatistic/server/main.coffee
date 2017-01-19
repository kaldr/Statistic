import { Meteor } from 'meteor/meteor'
import {Statistic} from './statistic//Statistic.coffee'
Meteor.startup ->
  S = new Statistic()
