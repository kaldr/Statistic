import { Meteor } from 'meteor/meteor'
import {Statistic} from './statistic/Statistic.coffee'
import {RestfulAPI} from '/imports/api/restful.coffee'
import {Mongo} from 'meteor/mongo'
import Moment from 'moment'
import * as db from '/imports/api/Collection/index.coffee'

Meteor.startup ->
	console.log 'Service started 😝  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
	
	#S = new Statistic()
