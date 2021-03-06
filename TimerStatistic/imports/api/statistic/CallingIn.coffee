import * as db from '../Collection/index.coffee'
import {BasicStatistic, buildStatisticAPI} from './BasicStatistic.coffee'
import {Mongo} from 'meteor/mongo'

class CallingIn extends BasicStatistic
  constructor: () ->
    dbname='Statistic_CallingInByProduct'
    @collection = db[dbname]
    if not @collection
      @collection=new Mongo.Collection dbname
    
    super "callingIn", @collection

  getStatistic: (timeType, spanType, query) =>
    super timeType, spanType, query

  fetchData: (selector, query) =>
    acceptStrList = [
      'SDID',
      'destination'
    ]
    acceptNumberList = [
      'Record_Type',
      'ProductAreaType_ID',
      'LineType_ID',
      'year'
      'month'
      'day'
      'hour'
      'week'
      'dateOfMonth'
      'dayOfWeek'
      'dayOfYear'
      'weeksInYear'
      'hourPosition'
    ]
    _.map query, (value, key) =>
      if acceptStrList.indexOf(key) >= 0
        selector[key] = value
      if acceptNumberList.indexOf(key) >= 0
        selector[key] = parseInt value
    @getData selector

buildStatisticAPI new CallingIn()
exports.CallingIn = CallingIn
