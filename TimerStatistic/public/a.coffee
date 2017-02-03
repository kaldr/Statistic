# startTime=new Date().getTime()
# count=0
# a=()->
# 	i=0
# 	while i++ < 10000000
# 		''

# setInterval a,0
# fixed=->
# 	count++
# 	offset=new Date().getTime() - (startTime+count*1000)
# 	nextTime=1000-offset
# 	if nextTime<0 then nextTime=0
# 	setTimeout fixed,nextTime
# 	console.log new Date().getTime()-(startTime+count*1000)
# b=()->
# 	count++
# 	console.log new Date().getTime()-(startTime+count*1000)

# setTimeout fixed,1000
moment=require 'moment-timezone'

timezone='Asia/Shanghai'
date= new Date('2017-02-01T16:00:00.000Z')
date2= new Date('2017-02-02T15:59:59.999Z')
console.log new Date('2017-02-01')
console.log moment(date).utc().tz(timezone).format()
console.log moment(date2).utc().tz(timezone).format()
console.log moment(new Date('2016/01/01'),'Asia/Shanghai')
console.log moment(new Date('2016/01/01')).toDate()
console.log moment(new Date()).local().get 'hour'
console.log new Date()

console.log moment(date2).get 'hour'



