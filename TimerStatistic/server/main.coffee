import { Meteor } from 'meteor/meteor'
import {Statistic} from '/imports/api/common/Statistic.coffee'
Meteor.startup ->
  S = new Statistic()
