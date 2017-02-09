import * as db from '../Collection/index.coffee'
import {BasicStatistic, buildStatisticAPI} from './BasicStatistic.coffee'
import {Mongo} from 'meteor/mongo'
import Moment from 'moment'
class Orders extends BasicStatistic
  constructor: () ->
    dbname='Statistic_OrdersByProductAndSales'
    @collection = db[dbname]
    if not @collection
      @collection=new Mongo.Collection dbname
    
    super "orders", @collection

  getStatistic: (timeType, spanType, query) =>
    super timeType, spanType, query

  fetchData: (selector, query) =>
    defaultFields=
      count:1
      "ElderNumber":1
      "AdultNumber":1
      "ChildNumber":1
      "BabyNumber":1
      "TotalNumber":1
      "TotalUnPayPrice":1
      'TotalSalesPrice':1
      'TotalFinalPrice':1
    acceptStrList = [
    	'EndAddressID','OrderTypeID','ProductID','ProductTypeID',
    	'StationID','companyID','createUserDepartmentID','createUserID','opDepartmentID','opID'
    ]
    acceptNumberList = [
     	'OrderSourceTypeID','TripTypeID'
      	'year','month','day','hour','week','dateOfMonth','dayOfWeek','dayOfYear','weeksInYear','hourPosition'
    ]
    fields={}
    if not query.data and not query.separation and not query.fields
      fields=defaultFields
    else
      _.map ['data','separation','fields'],(type)=>
        _.map query[type],(f)=>
          fields[f]=1
    
    dateTimeFields=@getDateTimeFields()
    
    _.extend fields,dateTimeFields
    
    _.map query, (value, key) =>
      if acceptStrList.indexOf(key) >= 0
        if value instanceof Array
          selector[key]=
            $in:value
        else
          selector[key] = value
      if acceptNumberList.indexOf(key) >= 0
        if value instanceof Array
          numValue=_.map value,(v)=>parseInt v
          selector[key]=
            $in:numValue
        else
          selector[key] = parseInt value

    @getData selector,fields,query

buildStatisticAPI new Orders()
exports.Orders = Orders
