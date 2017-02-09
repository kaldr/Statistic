class Transformer
	constructor:()->
	
	arrayToParentChildTree:(data,sequence)=>
		if typeof sequence == 'object'
			parent=sequence.parent
			grandParent=sequence.grandParent
		else if typeof sequence== 'string'
			parent=sequence
			grandParent=undefined
		if not parent
			data
		else
			data.reduce(((map,node)=>
				if not map[node[parent]]
				 	map[node[parent]]=
				 		data:[]
				 		sequence:sequence
				 	map[node[parent]][parent]=node[parent]
				 	if grandParent
				 		map[node[parent]].grandParent=grandParent
				map[node[parent]].data.push node
				map
			),{})
	
	arrayToParentChildTreeBySequence:(data,sequence,index=0,sumFields=[],withTimespanSum=false)=>
		if index==sequence.length
			data
		else
			groupedObject=data.reduce(((map,node)->
				current=sequence[index].current
				child=sequence[index].child
				
				if not map[node[current]]
					map[node[current]]=
						data:[]
						#sequence:sequence[index]
					if withTimespanSum
						map[node[current]].statistic={}
					map[node[current]][current]=node[current]
					_.map sumFields,(field)=>
						map[node[current]][field]=0
				map[node[current]].data.push node
				_.map sumFields,(field)=>
					map[node[current]][field]+=node[field]
					if withTimespanSum
						if not map[node[current]]['statistic'][node.start]
							map[node[current]]['statistic'][node.start]={}
						if not map[node[current]]['statistic'][node.start][field]
							map[node[current]]['statistic'][node.start][field]=0
						map[node[current]]['statistic'][node.start][field]+=node[field]
				map
			),{})
			_.map groupedObject,(value,key)=>
				object=@arrayToParentChildTreeBySequence value.data,sequence,index+1,sumFields,withTimespanSum
				value.data=object
			groupedObject

	parseSequence:(sequence)=>
		parsedSequence=[]
		_.map sequence,(field,index)=>
			ob={}
			if index<sequence.length-1#具备祖父节点
				ob.child=sequence[index+1]
				ob.current=sequence[index]
				parsedSequence.push ob
			else
				ob.current=sequence[index]
				parsedSequence.push ob
		parsedSequence

	arrayToTreeBySequence:(data,sequence,fields=[],withTimespanSum=false)=>
		parsedSequence=@parseSequence sequence
		@arrayToParentChildTreeBySequence data,parsedSequence,0,fields,withTimespanSum

		# _.reduce(parsedSequence,((map,node)=>
		# 	if  _.isArray data
		# 		result=@arrayToParentChildTree map,node

		# 	result
		# ),data)
			
		

exports.Transformer=Transformer