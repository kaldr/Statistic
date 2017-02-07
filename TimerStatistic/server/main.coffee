import { Meteor } from 'meteor/meteor'
import {Statistic} from './statistic/Statistic.coffee'
import {RestfulAPI} from '/imports/api/restful.coffee'
import {Mongo} from 'meteor/mongo'
import Moment from 'moment'
import * as db from '/imports/api/Collection/index.coffee'

Meteor.startup ->
	console.log 'Service started 😝  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
	#objID=new Mongo.ObjectID '000000000000000000000001'
	#console.log objID.valueOf()

	S = new Statistic()
	# console.log Cluster.discoverConnection "web"
    #console.log new Date('2016/1/1')
    #console.log typeof parseInt '12'
     #test = new Mongo.Collection 'test',{idGeneration:'MONGO'}
     #test.upsert {a: 33, b: 44, e: Mongo.ObjectID('5889f6462d30b2bcfd9e506f') } , {$inc: {c: 12} }
