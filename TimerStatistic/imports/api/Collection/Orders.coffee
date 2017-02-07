import { Mongo } from 'meteor/mongo'
import {Meteor} from 'meteor/meteor'

exports.Orders = new Mongo.Collection 'Orders',{idGeneration:'MONGO'}
exports.Statistic_OrdersByProductAndStaff = new Mongo.Collection 'Statistic_OrdersByProductAndStaff',{idGeneration:'MONGO'}
exports.Statistic_OrdersByProductAndOP=new Mongo.Collection 'Statistic_OrdersByProductAndOP',{idGeneration:"MONGO"}
exports.Statistic_OrdersByProductAndSales=new Mongo.Collection 'Statistic_OrdersByProductAndSales',{idGeneration:"MONGO"}