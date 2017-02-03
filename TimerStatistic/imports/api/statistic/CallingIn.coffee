import * as db from '../Collection/index.coffee'
import {BasicStatistic, buildStatisticAPI} from './BasicStatistic.coffee'


class CallingIn extends BasicStatistic
  constructor: () ->
    @collection = db.Statistic_CallingInByProduct
    super "callingIn", @collection

  getStatistic: (timeType, spanType, query) =>
    super timeType, spanType, query

  fetchData: (selector, query) =>
    acceptStrList = [
      'SDID',
      'destiniation'
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
    #console.log selector
    @collection.find(selector).fetch()

buildStatisticAPI new CallingIn()
exports.CallingIn = CallingIn
