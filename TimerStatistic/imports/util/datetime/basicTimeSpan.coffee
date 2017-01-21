import _ from 'lodash'
import Moment from 'moment'
import {Meteor} from 'meteor/meteor'
import path from 'path'
import CSON from 'cson'
import { Random } from 'meteor/random'
import {Mongo} from 'meteor/mongo'

class BasicTimeSpan
  constructor: (t = 0, span = '十秒', spanlist = ['年','月','日','时','分']) ->
    @configs = @getCSONfileConfig()
    spanNumber = @configs.wordTimeSpan[span]
    spanNumber = 300 if not spanNumber
    @getTimeSpanObject t, spanNumber, spanlist

  ###
    获取CSON配置
    @method getCSONfileConfig
    @return {object} 配置
  ###
  getCSONfileConfig: () =>
    basePath = path.resolve('.').split('.meteor')[0]
    csonFile = basePath + __dirname + '/datetimeConfig.cson'
    configs = CSON.load csonFile

  getTimeSpanObject: (time, span = 1, spanlist = ['年','月','日','时','分']) =>
    spanlist = _.compact spanlist
    if _.last(spanlist).indexOf('分') >= 0
      spanlist[spanlist.length - 1] = '分'
    if _.last(spanlist).indexOf('秒') >= 0
      spanlist[spanlist.length - 1] = '秒'
    if not time
      t = new Date()
    else
      if typeof time == 'string'
        t = new Date(time)
      else if typeof time == 'object'
        t = time
    @timeSpan = @getBasicObject t, span, spanlist

  getBasicObject: (time, span, spanlist) =>
    matchOb =
      "年":"Year"
      "月":"Month"
      "日":"Day"
      "时":"Hour"
      "分":"Minute"
      "秒":"Second"
    spans = {}
    _.map matchOb, (value, key) =>
      if spanlist.indexOf(key) >= 0
          spans[value] = @["get#{value}Object"] time,  span
    spans

  getYearObject : (t) =>
    time = Moment t
    yearObject =
      timeID: Random.id()
      id: new Mongo.ObjectID()
      type: 'year'
      year: time.year()
      start: Moment(time).startOf('year').toDate()
      end: Moment(time).endOf('year').toDate()
      timeType: "Basic"

  getMonthObject : (t) =>
    time = Moment t
    startOfMonth = new Date()
    endOfMonth = new Date()
    monthObject =
      timeID: Random.id()
      id: new Mongo.ObjectID()
      type: 'month'
      month: time.month() + 1
      year: time.year()
      start: Moment(time).startOf('month').toDate()
      end: Moment(time).endOf('month').toDate()
      timeType: "Basic"

  getDayObject : (t) =>
    time = Moment t
    startOfDay = new Date()
    endOfDay = new Date()
    dayObject =
      timeID: Random.id()
      id: new Mongo.ObjectID()
      type: 'day'
      dateOfMonth: time.date()
      dayOfYear: time.dayOfYear()
      dayOfWeek: time.day()
      week: time.week()
      weeksInYear: time.weeksInYear()
      month: time.month() + 1
      year: time.year()
      start: Moment(time).startOf('day').toDate()
      end: Moment(time).endOf('day').toDate()
      timeType: "Basic"

  getHourObject : (t) =>
    time = Moment t
    startOfHour = new Date()
    endOfHour = new Date()
    hourObject =
      timeID: Random.id()
      id: new Mongo.ObjectID()
      type: 'hour'
      hour: time.hour()
      dateOfMonth: time.date()
      dayOfYear: time.dayOfYear()
      dayOfWeek: time.day()
      week: time.week()
      weeksInYear: time.weeksInYear()
      month: time.month() + 1
      year: time.year()
      start: Moment(time).startOf('hour').toDate()
      end: Moment(time).endOf('hour').toDate()
      timeType: "Basic"

  numberSpans: (total, span, value, t, type) =>
    spanCount = total / span
    result = {}
    _.map [0...spanCount], (i) =>
      start = span * i
      end = span * i + span
      if value < end and value >= start
        if type == 'minute'
          result =
            start: Moment(t)[type](start).second(0).millisecond(0).toDate()
            end: Moment(t)[type](end - 1).second(59).millisecond(999).toDate()
            position: i
        else if type == 'second'
          result =
            start: Moment(t)[type](start).millisecond(0).toDate()
            end: Moment(t)[type](end - 1).millisecond(999).toDate()
            position: i
    result

  getMinuteObject : (t, span) =>
    time = Moment t
    minute = time.minute()
    if span > 60
      r = @numberSpans 60, span / 60, minute, t, 'minute'
    else
      r =
        start: Moment(t).startOf('minute').toDate()
        end: Moment(t).endOf('minute').toDate()
        position: 0
    startOfMinute = new Date()
    endOfMinute = new Date()
    minuteObject =
      timeID: Random.id()
      id: new Mongo.ObjectID()
      type: 'minute'
      hourPosition: r.position
      hour: time.hour()
      dateOfMonth: time.date()
      dayOfYear: time.dayOfYear()
      dayOfWeek: time.day()
      week: time.week()
      weeksInYear: time.weeksInYear()
      month: time.month() + 1
      year: time.year()
      start: r.start
      end: r.end
      timeType: "Basic"

  getSecondObject : (t, span) =>
    time = Moment t
    second = time.second()
    r = @numberSpans 60, span, second, t, 'second'
    secondObject =
      timeID: Random.id()
      id: new Mongo.ObjectID()
      type: 'second'
      minute: time.minute()
      minutePosition: r.position
      hour: time.hour()
      dateOfMonth: time.date()
      dayOfYear: time.dayOfYear()
      dayOfWeek: time.day()
      week: time.week()
      weeksInYear: time.weeksInYear()
      month: time.month() + 1
      year: time.year()
      start: r.start
      end: r.end
      timeType: "Basic"

buildAPI = () =>
    timeSpanFunc = (urlParams) =>
      time = urlParams.time
      timeSpan = urlParams.timespan?300
      bts = new BasicTimeSpan()
      bts.getTimeSpanObject time, timeSpan

    if Meteor.isServer
      API = new Restivus
        useDefaultAuth: false
        prettyJson: true

      API.addRoute 'time/basicTimeSpan/:timespan', {} ,
        get: ->
          timeSpanFunc @urlParams
      API.addRoute 'time/basicTimeSpan/:timespan/:time', {} ,
        get: ->
          timeSpanFunc @urlParams

buildAPI()

exports.BasicTimeSpan = BasicTimeSpan
