import { Mongo } from 'meteor/mongo'
import {Meteor} from 'meteor/meteor'

Customer_Record = new Mongo.Collection 'Customer_Record',{idGeneration:'MONGO'}

Customer_Record_GetOne = (delstatus) ->
  Customer_Record.findOne {
    delstatus: delstatus?0
  }

Aggregate_Statistic_CallingInByProduct = new Mongo.Collection 'Aggregate_Statistic_CallingInByProduct',{idGeneration:'MONGO'}
Statistic_CallingInByProduct = new Mongo.Collection 'Statistic_CallingInByProduct',{idGeneration:'MONGO'}
exports.Customer_Record = Customer_Record
exports.Aggregate_Statistic_CallingInByProduct = Aggregate_Statistic_CallingInByProduct
exports.Customer_Record_GetOne = Customer_Record_GetOne
exports.Statistic_CallingInByProduct = Statistic_CallingInByProduct
