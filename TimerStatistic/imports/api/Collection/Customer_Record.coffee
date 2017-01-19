import { Mongo } from 'meteor/mongo'
Customer_Record = new Mongo.Collection 'Customer_Record',{idGeneration:'MONGO'}
Aggregate_Statistic_CallingInByProduct_NingBo = new Mongo.Collection 'Aggregate_Statistic_CallingInByProduct_NingBo',{idGeneration:'MONGO'}
exports.Customer_Record = Customer_Record
exports.Aggregate_Statistic_CallingInByProduct_NingBo = Aggregate_Statistic_CallingInByProduct_NingBo
