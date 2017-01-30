import _ from 'lodash'
import Moment from 'moment'
import path from 'path'
import CSON from 'cson'
import {BasicTimeSpan} from './basicTimeSpan.coffee'

class DateTime
  constructor: (span, structure = ['Basic']) ->
    @configuration(span, structure)

  configuration: ( span, structure) =>

    @time = Moment()
    span = 300 if not span
    @span = span
    configs = @getCSONfileConfig()
    @structure = structure
    @publicWordTimeSpan = configs.wordTimeSpan
    @timeStructure = configs.timeStructure
    @timeStructureList = @buildSpanListFromSpan(span, structure)
    @btsp = new BasicTimeSpan @time, @minSpan, @timeStructureList.Basic

  ###
    获取CSON配置
    @method getCSONfileConfig
    @return {object} 配置
  ###
  getCSONfileConfig: () =>
    basePath = path.resolve('.').split('.meteor')[0]
    csonFile = basePath + __dirname + '/datetimeConfig.cson'
    configs = CSON.load csonFile

  ###
    构建时间架构序列
    @method buildSpanListFromSpan
    @param {number|string} span 时间间隔
    @param {array} structure 时间架构列表
    @return {null} null
  ###
  buildSpanListFromSpan: (span, structure) =>
    if typeof span == 'string'
      @buildSpanListFromWord(span, structure)
    else if typeof span == 'number'
      @buildSpanListFromMinSpan(span, structure)

  ###
    构建时间架构序列（文字）
    @method buildSpanListFromWord
    @param {number|string} span 时间间隔
    @param {array} structure 时间架构列表
    @return {null} null
  ###
  buildSpanListFromWord: (span, structure) =>
    minSpan = '五分'
    spanWordsList = _.keys @publicWordTimeSpan
    if spanWordsList.indexOf span >= 0
      minSpan = span
    @getSpanListFromMinSpan(minSpan, structure)

  ###
    构建时间架构序列（数字）
    @method buildSpanListFromMinSpan
    @param {number|string} span 时间间隔
    @param {array} structure 时间架构列表
    @return {null} null
  ###
  buildSpanListFromMinSpan: (span, structure) =>
    minSpan = 300
    spanSecondList = _.values @publicWordTimeSpan
    index = spanSecondList.indexOf span
    if index >= 0
      minSpan = _.keys(@publicWordTimeSpan)[index]
    @getSpanListFromMinSpan(minSpan, structure)

  ###
    通过最小时间间隔获取时间架构
    @method getSpanListFromMinSpan
    @param {string} minSpan 时间间隔，汉字
    @param {array} structure 时间架构的数组，可以包含basic/lunar/vocation/activity
    @return {array} 时间架构
  ###
  getSpanListFromMinSpan: (minSpan, structure) =>
    @minSpan = minSpan
    spanList = {}
    if ['三十秒','十秒','五秒','秒'].indexOf(minSpan) >= 0
      _.map @timeStructure, (value, key) =>
        if _.indexOf(structure, key) >= 0
          spanList[key] = @timeStructure[key]
          spanList[key][4] = '分'
          spanList[key][5] = minSpan
    else if ['刻','十分','五分','分'].indexOf(minSpan) >= 0
      _.map @timeStructure, (value, key) =>
        if _.indexOf(structure, key) >= 0
          spanList[key] = @timeStructure[key]
          spanList[key][4] = minSpan
          delete spanList[key][5]
          spanList[key] = _.compact spanList[key]
    else
      _.map @timeStructure, (value, key) =>
        if _.indexOf(structure, key) >= 0
          spanList[key] = []
          spanList[key] = _.compact _.dropRight @timeStructure[key], @timeStructure[key].length - @timeStructure[key].indexOf(minSpan)
    spanList


  getTimePositionOfSpan: (time, span) =>
    bts = new BasicTimeSpan time, span
    time = @time if not time
    span = @span if not span
    if span >= 60 then bts.getMinutePosition time, span else bts.getSecondPosition time, span



  getParentTimeSpan: () =>

  getMinTimeSpans: (time) =>
    time = @time if not time
    result = {}
    _.map @structure, (type) =>
      result[type] = @getMinTimeSpan time, type
    result

  getTimeSpans: (time) =>
    time = @time if not time
    result = {}
    _.map @structure, (type) =>
      result[type] = @getTimeSpan time, type
    result

  getMinTimeSpan: (time, timeType = 'Basic') =>
    time = @time if not time
    @["get#{timeType}MinTimeSpan"] time

  getTimeSpan: (time, timeType = 'Basic') =>
    time = @time if not time
    @["get#{timeType}TimeSpan"] time


  ###
    获取时间间隔
    @method getBasicTimeSpan
    @param {momentObject} time 时间
    @return {object} 时间配置
  ###
  getBasicTimeSpan: (t) =>
    @btsp.getTimeSpan t
    @btsp.timeSpan
    # btsp = new BasicTimeSpan t, @minSpan, @timeStructureList.Basic
    # btsp.timeSpan


  ###
    获取节假日的时间间隔
    TODO: 要根据每年的节假日时间，来配置，需要详细了解相关信息
    @method getVocationTimeSpan
    @param {momentObject} time 时间
    @return {object} 时间配置
  ###
  getVocationTimeSpan: (time) =>
    undefined

  ###
    获取阴历的时间间隔
    TODO: 要根据每年的阴历时间，来配置，需要详细了解相关信息
    @method getLunarTimeSpan
    @param {momentObject} time 时间
    @return {object} 时间配置
  ###
  getLunarTimeSpan: (time) =>
    undefined

  ###
    获取活动的时间间隔
    TODO: 要根据每年我们的活动，来配置活动时间
    @method getActivityTimeSpan
    @param {momentObject} time 时间
    @return {object} 时间配置
  ###
  getActivityTimeSpan: (time) =>
    undefined

  ###
    获取时间间隔
    @method getBasicTimeSpan
    @param {momentObject} time 时间
    @return {object} 时间配置
  ###
  getBasicMinTimeSpan: (t) =>
    @btsp.getMinTimeSpan t
    # btsp = new BasicTimeSpan t, @minSpan, @timeStructureList.Basic
    # btsp.timeSpan


  ###
    获取节假日的时间间隔
    TODO: 要根据每年的节假日时间，来配置，需要详细了解相关信息
    @method getVocationTimeSpan
    @param {momentObject} time 时间
    @return {object} 时间配置
  ###
  getVocationMinTimeSpan: (time) =>
    undefined

  ###
    获取阴历的时间间隔
    TODO: 要根据每年的阴历时间，来配置，需要详细了解相关信息
    @method getLunarTimeSpan
    @param {momentObject} time 时间
    @return {object} 时间配置
  ###
  getLunarMinTimeSpan: (time) =>
    undefined

  ###
    获取活动的时间间隔
    TODO: 要根据每年我们的活动，来配置活动时间
    @method getActivityTimeSpan
    @param {momentObject} time 时间
    @return {object} 时间配置
  ###
  getActivityMinTimeSpan: (time) =>
    undefined

exports.DateTime = DateTime
