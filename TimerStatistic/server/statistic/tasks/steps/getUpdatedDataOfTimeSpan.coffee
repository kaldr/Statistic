import {GetCreatedDataOfTimespan} from './getCreatedDataOfTimeSpan.coffee'
import * as Collections from '/imports/api/Collection/index.coffee'
import {DateTime} from '/imports/util/datetime/datetime.coffee'
import _ from 'lodash'
import util from 'util'

class GetUpdatedDataOfTimespan extends GetCreatedDataOfTimespan
  constructor: (@stepOb, @logger, @taskOb, @statisticTask) ->
    super @stepOb, @logger, @taskOb, @statisticTask

  buildUpdateAggregatePipeline: (input) =>
    @collection = Collections[@statisticTask.sourceCollection]
    @group =
      _id: @getGroupID()
      id:
        $last: '$_id'
      count:
        $sum: @statisticTask.groupSum
    @pipeline = [
      {$match: @selector}
      {$project: @getFields() }
      {$group: @group}
      {$project: @getFinalFields() }
      {$out: @statisticTask.aggregateOutCollection}
    ]

  buildUpdateTimeInput: (input) =>
    @selector = @getDefaultQuery()
    @selector[@statisticTask.timeParameter.updateTime] =
      $gte: input.startTime.toDate()
      $lt: input.endTime.toDate()
    # @selector[@statisticTask.timeParameter.createTime] =
    #   $lt: input.startTime.toDate()

  ###
    获取更新的数据
    @method getUpdatedData
    @param {object} input 任务对象
    @return {array} 结果数组
  ###
  getUpdatedData: (input) =>
    @buildUpdateTimeInput input
    @buildUpdateAggregatePipeline()
    fields = {_id: 1}
    fields[@statisticTask.timeParameter.createTime] = 1
    console.log @selector
    @collection.find(@selector, {fields: fields} ).fetch()

  getStatisticSelector: (data) =>
    spans

  getTimeSpans: (data) =>

  getTimeSpanForACreateTime: (time) =>

  ###
    从原始数据表通过aggregate获取新增数据的最小时间段的统计
    @method getAggregatedData
    @param {object} input 任务对象
    @return {array} aggregate数据结果
  ###
  getAggregatedData: (input) =>
    result = super input


  ###
    构建最小时间片的统计数据
    根据aggregate出来的数据，把新时间片的数据存储到数据库
    @method buildMinSpanStatistic
    @param {object} input 任务对象
    @param {array} newlyAddedStatisticData 新增数据的统计
    @return {array} 返回数据依然是新增数据统计
  ###
  buildMinSpanStatistic: (input, newlyAddedStatisticData) =>
    minSpan = @getMinSpan()
    result =
      data: newlyAddedStatisticData
      spans: minSpan
      type: 'insert'

  ###
    根据当期那新增的数据，获取要更新的时间维度的信息
    @method buildParentSpanStatistic
    @param {object} input 任务对象
    @param {array} minSpanStatistic 上一步统计信息
    @return {object} 结果对象
  ###
  buildParentSpanStatistic: (input, minSpanStatistic) =>
    parentSpans = @getParentSpans()
    result =
      data: minSpanStatistic#本质是各个维度的统计结果
      spans: parentSpans#本质是要更新的时间的维度
      type: 'update'

  getTimespansForUpdatedData: (input, newlyUpdatedData) =>
    timeList = []
    _.map newlyUpdatedData, (data) =>timeList.push data.Record_Time
    spanList = []

    _.map timeList, (RecordTime) =>
      dt = new DateTime @taskOb.parameters.timespan
      spanList.push dt.getTimeSpans RecordTime
    spans = []
    excludeTime = []

    _.map spanList, (ob, index) =>
      if excludeTime.indexOf(index) >= 0 then return
      if @taskOb.parameters.timespan >= 60 then cmpOb = ob.Basic.Minute else cmpOb = ob.Basic.Second
      #TODO:当前只支持basic类型的时间，尚未根据节假日等数据进行协调
      _.map spanList, (ob2Cmp, i) =>
        if i <= index then return
        if @taskOb.parameters.timespan >= 60 then cmpOb2 = ob2Cmp.Basic.Minute else cmpOb2 = ob2Cmp.Basic.Second
        if cmpOb.start.getTime() == cmpOb2.start.getTime() and cmpOb.end.getTime() == cmpOb2.end.getTime()
          excludeTime.push i
    timeTags = ["Second","Minute","Hour","Day","Month", 'Year']

    _.map spanList, (ob, index) =>
      if excludeTime.indexOf(index) == - 1
        _.map ob.Basic, (value, key) =>
          notInFlag = true
          _.map spans, (v, k) =>
            if v.start.getTime() == value.start.getTime() and v.end.getTime() == value.end.getTime()
              notInFlag = false
          if notInFlag
            spans.push
              start: value.start
              end: value.end
    spans

  getStatisticDataOfTimeSpans: ( input, newlyUpdatedData) =>
      spans = @getTimespansForUpdatedData input, newlyUpdatedData
      collection = Collections[@statisticTask.targetCollection]
      selector =
        $or: spans
      data = collection.find selector
        .fetch()
      console.log data.length
      data

  getCurrentStatisticDataOfTimeSpans : (input, newlyUpdatedData) =>
      @buildUpdateTimeInput input
      @buildUpdateAggregatePipeline()
      fields = {_id: 1}
      fields[@statisticTask.timeParameter.createTime] = 1
      console.log @selector
      @collection.aggregate @pipeline

  getDifferenceOfData: (input, newlyUpdatedDataStatistic, currentUpdatedDataStatistic) =>
    #最后一个方法

  constructResult: (input, differenceOfData) =>
  ###
    运行
    @method process
    @param {object} input 任务对象
    @return {object} 结果对象
  ###
  process: (input) =>
    #========================================================
    # 1.处理新增的数据
    #========================================================
    # 1.1 获取新增的数据
    # DONE
    # 通过aggregate，获取这个时间间隔下的数据增量
    newlyAddedStatisticData = @getAggregatedData input

    #--------------------------------------------------------
    # 1.2 向statistic表插入当前时间间隔下的统计数据
    # TODO
    # 当前时间片，数据库中还不存在，因此，可以直接插入，数据结构是{data:[],spans:{Basic:[{Minute:{...}}],...},type:'insert'}，可以被下一步直接识别
    minSpanStatistic = @buildMinSpanStatistic input, newlyAddedStatisticData

    #--------------------------------------------------------
    # 1.3 更新更高维度的数据，所有的都增加相关的数量
    # TODO:
    # 但是比当前维度更高的时间片的统计，数据库中已经存在了，要对这些数据进行更新。
    # 由于是增量数据，每个要更改的时间片统计，只需要增加增量计数值即可。
    # 数据结构{data:[{selector:{},data:{}},...],type:'update'},其中selector是每条数据的查询条件，data是新数据结构
    parentSpanStatistic = @buildParentSpanStatistic input, minSpanStatistic

    #========================================================
    # 2.处理更新的数据
    #========================================================
    # 2.1 获取时间片之内更新的数据
    # 获取到当前时间间隔下更新的数据的添加时间
    newlyUpdatedData = @getUpdatedData input

    #--------------------------------------------------------
    # 2.2 从原始数据表中，获取最新的每个添加时间aggregate统计
    # 这是最新的统计，将会把这个时间段的统计，都变成这个模样
    newlyUpdatedDataStatistic = @getStatisticDataOfTimeSpans input, newlyUpdatedData

    #--------------------------------------------------------
    # 2.3 从统计表中，获取每个添加时间的统计信息
    # 获取新的统计信息的目的，是为了计算这个时间维度内的数量的变化，比如获取了所有5分钟统计的数量之后，可以获取每个数据统计维度的数据变化
    currentUpdatedDataStatistic = @getCurrentStatisticDataOfTimeSpans input, newlyUpdatedData

    #--------------------------------------------------------
    # 2.4 新老统计数据进行对比，获取每个数据统计维度的数据变化
    # 获得了各个统计维度的变化之后，才可以对更高维度的数据进行更新
    differenceOfData = @getDifferenceOfData input, newlyUpdatedDataStatistic, currentUpdatedDataStatistic

    #--------------------------------------------------------
    # 2.5 根据变化，获得最后的结果，并且输出到下一步中
    result = [ minSpanStatistic, parentSpanStatistic, differenceOfData ]


exports.GetUpdatedDataOfTimespan = GetUpdatedDataOfTimespan
