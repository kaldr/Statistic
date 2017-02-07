import { Mongo } from 'meteor/mongo'
import {Meteor} from 'meteor/meteor'

exports.Customer_Record = new Mongo.Collection 'Customer_Record',{idGeneration:'MONGO'}
exports.Statistic_CallingInByProduct = new Mongo.Collection 'Statistic_CallingInByProduct',{idGeneration:'MONGO'}
