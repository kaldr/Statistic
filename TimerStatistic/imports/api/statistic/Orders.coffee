import * as db from '../Collection/index.coffee'
import {BasicStatistic, buildStatisticAPI} from './BasicStatistic.coffee'
import {Mongo} from 'meteor/mongo'
import Moment from 'moment'
class Orders extends BasicStatistic
  constructor: () ->
    dbname='Statistic_OrdersByProductAndStaff'
    @collection = db[dbname]
    if not @collection
      @collection=new Mongo.Collection dbname
    
    super "orders", @collection

  getStatistic: (timeType, spanType, query) =>
    super timeType, spanType, query

  fetchData: (selector, query) =>
    acceptStrList = [
    	'EndAddressID','OrderTypeID','ProductID','ProductTypeID',
    	'StationID','companyID','createUserDepartmentID','createUserID','opDepartmentID','opID'
    ]
    acceptNumberList = [
     	'OrderSourceTypeID','TripTypeID'
      	'year','month','day','hour','week','dateOfMonth','dayOfWeek','dayOfYear','weeksInYear','hourPosition'
    ]
    _.map query, (value, key) =>
      if acceptStrList.indexOf(key) >= 0
        selector[key] = value
      if acceptNumberList.indexOf(key) >= 0
        selector[key] = parseInt value
    @getData selector
buildStatisticAPI new Orders()
exports.Orders = Orders
