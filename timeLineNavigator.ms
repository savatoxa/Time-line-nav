/*
when we create range and try to set it without selecting, we get an error
we must check whether list of ranges and rangeWork is not empty
after setting range place slider to start
we shouldn't be able to create range with an empty name
*/
tags = #()
ranges = #()

function createTags = (
tags = #()
for i =1 to FrameTagManager.GetTagCount() do 
(
	id = FrameTagManager.GetTagID i
	tag_name = FrameTagManager.GetNameByID id
	append tags tag_name
	)
)

function createRanges = (
	ranges = #()
	createTags()
	local tagsCuted = #()
	for tag in tags where (tag.count > 5) do
	(
		tagCut  = substring tag (tag.count - 5) -1
		if tagCut == "_start" then ( append tagsCuted (substring tag 1 (tag.count - 6)) )
	)
	for tag in tags where (tag.count > 3) do
	(
		tagCut  = substring tag (tag.count - 3) -1
		if tagCut == "_end" then ( append tagsCuted (substring tag 1 (tag.count - 4)) )
	)
	for i = 1 to tagsCuted.count-1 do
	(
		for j = i+1 to tagsCuted.count do
		(
			if tagsCuted[i] == tagsCuted[j] then (append ranges tagsCuted[i]; exit)
		)
	)
)

	
function setRangeByRangeName rangeName = (
    rangeStart_idx = findItem tags (rangeName + "_start")
	rangeStart_id = FrameTagManager.GetTagID rangeStart_idx
	rangeEnd_idx = findItem tags (rangeName + "_end")
	rangeEnd_id = FrameTagManager.GetTagID rangeEnd_idx
	animationRange = interval (FrameTagManager.GetTimeByID rangeStart_id) (FrameTagManager.GetTimeByID rangeEnd_id)
)

function createTagsByRangeName rangeName = (
	FrameTagManager.CreateNewTag (rangeName + "_start") animationRange.start
	FrameTagManager.CreateNewTag (rangeName + "_end") animationRange.end
)

function deleteTagsByRangeName rangeName = (
	rangeStart_idx = findItem tags (rangeName + "_start")
	rangeStart_id = FrameTagManager.GetTagID rangeStart_idx
	rangeEnd_idx = findItem tags (rangeName + "_end")
	rangeEnd_id = FrameTagManager.GetTagID rangeEnd_idx
	FrameTagManager.DeleteTag rangeStart_id
	FrameTagManager.DeleteTag rangeEnd_id
	)

rollout win1 "Time line navigator" width:286 height:228
(	
	dropdownList ddl1 "Animation ranges" pos:[30,6] width:225 height:40 items: (for range in ranges collect range)
	button btn1 "Set selected range" pos:[30,60] width:225 height:25
	button btn2 "Delete selected range" pos:[30,96] width:225 height:25
	editText edt1 "Enter range name" pos:[30,140] width:225 height:18 labelOnTop:true
	button btn3 "Create new range" pos:[30,180] width:225 height:25
	
	local rangeWork = ranges[1]
	local newRange = ""
	
	on ddl1 selected i do
	(
		rangeWork = ddl1.items[i]		
	)	
	on btn1 pressed do setRangeByRangeName rangeWork
	on btn2 pressed do
	(
		deleteTagsByRangeName rangeWork 
		createRanges()
		rangeWork = ranges[1]
		ddl1.items = (for range in ranges collect range)
	)
	on edt1 entered txt do
	(
		newRange = txt
	)
	on btn3 pressed do 
	(
		createTagsByRangeName newRange
		newRange = ""
		createRanges()
		ddl1.items = (for range in ranges collect range)
	)
)

createRanges()
createDialog win1	