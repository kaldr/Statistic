import { Mongo } from 'meteor/mongo'
import {Meteor} from 'meteor/meteor'

Customer_Record = new Mongo.Collection 'Customer_Record',{idGeneration:'MONGO'}

Customer_Record_GetOne = (delstatus) ->
  Customer_Record.findOne {
    delstatus: delstatus?0
  }

Aggregate_Statistic_CallingInByProduct_NingBo = new Mongo.Collection 'Aggregate_Statistic_CallingInByProduct_NingBo',{idGeneration:'MONGO'}

exports.Customer_Record = Customer_Record
exports.Aggregate_Statistic_CallingInByProduct_NingBo = Aggregate_Statistic_CallingInByProduct_NingBo
exports.Customer_Record_GetOne = Customer_Record_GetOne
