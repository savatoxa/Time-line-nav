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

	
function setRangeByRangeName rangesSelected = (
	rangeStart = rangesSelected[1]
	rangeEnd = rangesSelected[rangesSelected.count]
    rangeStart_idx = findItem tags (rangeStart + "_start")
	rangeStart_id = FrameTagManager.GetTagID rangeStart_idx
	rangeEnd_idx = findItem tags (rangeEnd + "_end")
	rangeEnd_id = FrameTagManager.GetTagID rangeEnd_idx
	animationRange = interval (FrameTagManager.GetTimeByID rangeStart_id) (FrameTagManager.GetTimeByID rangeEnd_id)
	sliderTime = FrameTagManager.GetTimeByID rangeStart_id
)

function SetLeftSlider = (
	try(
	animationRange = interval animationRange.start sliderTime
	)catch()
	)
	
function SetRightSlider = (
	try(
	animationRange = interval sliderTime animationRange.end
	)catch()
	)
	
function SetStartTime leftBorder = (
	try(
	animationRange = interval leftBorder animationRange.end
	)catch()
	)
	
function SetEndTime rightBorder = (
	try(
	animationRange = interval animationRange.start rightBorder
	)catch()
	)

function setAllAnimationRanges = (
	allTagFrames = #()
	for tag_idx = 1 to tags.count do
	(
		tag_id = FrameTagManager.GetTagID tag_idx
		tagFrame = FrameTagManager.GetTimeByID tag_id
		append allTagFrames tagFrame
	)
	sort allTagFrames
	animationRange = interval allTagFrames[1] allTagFrames[allTagFrames.count]
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
	
function redefineRange rangeName = (
	rangeStart_idx = findItem tags (rangeName + "_start")
	rangeStart_id = FrameTagManager.GetTagID rangeStart_idx
	rangeEnd_idx = findItem tags (rangeName + "_end")
	rangeEnd_id = FrameTagManager.GetTagID rangeEnd_idx
	FrameTagManager.SetTimeByID rangeStart_id animationRange.start
	FrameTagManager.SetTimeByID rangeEnd_id animationRange.end
)

function renameRange oldRangeName newRangeName = (
	rangeStart_idx = findItem tags (oldRangeName + "_start")
	rangeStart_id = FrameTagManager.GetTagID rangeStart_idx
	rangeEnd_idx = findItem tags (oldRangeName + "_end")
	rangeEnd_id = FrameTagManager.GetTagID rangeEnd_idx
	FrameTagManager.SetNameByID rangeStart_id (newRangeName + "_start")
	FrameTagManager.SetNameByID rangeEnd_id (newRangeName + "_end")
)

rollout win1 "Time line navigator" width:200 height:505
(
	---window width = 200
	multiListBox mlb "Animation ranges" items: (for range in ranges collect range) height: 15
	button setSelRanges "Set selected ranges" pos:[10,225] width:180 height:20
	button btn2 "Delete selected ranges" pos:[10,305] width:180 height:20
	edittext edt1 "Enter range name" pos:[10,345] width:180 height:17 labelOnTop:true
	button btn3 "Create new range" pos:[10,382] width:180 height:20
	button btn4 "Redefine selected range" pos:[10,265] width:180 height:20
	button btn5 "Rename selected range" pos:[10,402] width:180 height:20
	button btn6 "Refresh ranges" pos:[10,285] width:180 height:20
	button btn7 "Delete all time tags" pos:[10,325] width:180 height:20
	button btn8 "Set all animation ranges" pos:[10,245] width:180 height:20
	button leftSld "Left - slider" pos:[10, 425] width: 80 height: 20
	button rightSld "Slider - right" pos:[110, 425] width: 80 height: 20
	spinner startTime "Start:" range:[-10000,10000,0] type:#integer pos:[10, 445] width: 80 height: 17
	spinner endTime "End:" range:[-10000,10000,0] type:#integer pos:[110, 445] width: 80 height: 17
	
	local rangesSelected = #()
	local newRange = ""
		
	on mlb selectionEnd do
	(
		rangesSelected = (for idx in mlb.selection collect ranges[idx])
		if rangesSelected.count == 1 then
			(
			edt1.text = rangesSelected[1]
			)
			else
			(
			edt1.text = ""
			)
	)
	on mlb doubleClicked i do
	(
		rangesSelected = #()
		append rangesSelected ranges[i]
		setRangeByRangeName rangesSelected
		startTime.value = animationRange.start
		endTime.value = animationRange.end
		)
	on setSelRanges pressed do
	(
		if ranges.count > 0 then
		(
			setRangeByRangeName rangesSelected
			startTime.value = animationRange.start
			endTime.value = animationRange.end
		)
	)
	on btn2 pressed do
	(
		if ranges.count > 0 and rangesSelected.count > 0 then 
		(
			for range in rangesSelected do
			(
			deleteTagsByRangeName range
			createRanges()
			)
			mlb.items = (for range in ranges collect range)
			rangesSelected = (for idx in mlb.selection collect ranges[idx])
		)
	)
	on edt1 entered txt do
	(
		newRange = txt
	)
	on btn3 pressed do
	(
		if newRange != "" then
		(
			createTagsByRangeName newRange
			createRanges()
			mlb.items = (for range in ranges collect range)
			edt1.text = ""
		)
	)
	on btn4 pressed do
	(
		if ranges.count > 0 and rangesSelected.count == 1 then
		(
			redefineRange rangesSelected[1]
			createRanges()
			mlb.items = (for range in ranges collect range)
		)
	)
	on btn5 pressed do
	(
		if ranges.count > 0 and newRange != "" and rangesSelected.count == 1 then
		(
			renameRange rangesSelected[1] newRange
			createRanges()
			rangesSelected[1] = newRange
			mlb.items = (for range in ranges collect range)
			edt1.text = ""
		)
	)
	on btn6 pressed do
	(
		createRanges()
		mlb.items = (for range in ranges collect range)
		mlb.selection = #{}
	)
	on btn7 pressed do
	(
		if queryBox "Delete all time tags ?" beep: True then
		(
			FrameTagManager.ResetFrameTags()
			createRanges()
			mlb.items = (for range in ranges collect range)
		)
	)
	on btn8 pressed do
	(
		if tags.count > 0 then
		(
		setAllAnimationRanges()
		)
	)
	on leftSld pressed do
	(
		SetLeftSlider()
		)
	on rightSld pressed do
	(
		SetRightSlider()
		)
	on startTime entered do
	(
		SetStartTime startTime.value
		if startTime.value == 0 then 
		(
			sliderTime = 0
			)
		)
	on endTime entered do
	(
		SetEndTime endTime.value
		)
)

createRanges()
createDialog win1