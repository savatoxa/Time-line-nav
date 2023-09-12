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

function setRangeByRange rangeName = (
	rangeStart_id = FrameTagManager.GetTagID (findItem tags (rangeName + "_start"))
	rangeEnd_id = FrameTagManager.GetTagID (findItem tags (rangeName + "_end"))
	animationRange = interval (FrameTagManager.GetTimeByID rangeStart_id) (FrameTagManager.GetTimeByID rangeEnd_id)
)

function setRangeByRangeName rangesSelected = (
	rangeStart_id = FrameTagManager.GetTagID (findItem tags (rangesSelected[1] + "_start"))
	rangeEnd_id = FrameTagManager.GetTagID (findItem tags (rangesSelected[rangesSelected.count] + "_end"))
	animationRange = interval (FrameTagManager.GetTimeByID rangeStart_id) (FrameTagManager.GetTimeByID rangeEnd_id)
	sliderTime = FrameTagManager.GetTimeByID rangeStart_id
)

function setRangeByRangeNameAndSlider rangeName = (
	rangeStartTime = FrameTagManager.GetTimeByID (FrameTagManager.GetTagID (findItem tags (rangeName + "_start")))
	rangeEndTime = FrameTagManager.GetTimeByID (FrameTagManager.GetTagID (findItem tags (rangeName + "_end")))
	if sliderTime > rangeStartTime then
	(
		animationRange = interval rangeStartTime sliderTime
		)
	else if sliderTime < rangeEndTime then
	(
		animationRange = interval sliderTime rangeEndTime
		)
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
	rangeStart_id = FrameTagManager.GetTagID (findItem tags (rangeName + "_start"))
	rangeEnd_id = FrameTagManager.GetTagID (findItem tags (rangeName + "_end"))
	FrameTagManager.DeleteTag rangeStart_id
	FrameTagManager.DeleteTag rangeEnd_id
	)
	
function redefineRange rangeName = (
	rangeStart_id = FrameTagManager.GetTagID (findItem tags (rangeName + "_start"))
	rangeEnd_id = FrameTagManager.GetTagID (findItem tags (rangeName + "_end"))
	FrameTagManager.SetTimeByID rangeStart_id animationRange.start
	FrameTagManager.SetTimeByID rangeEnd_id animationRange.end
)

function renameRange oldRangeName newRangeName = (
	rangeStart_id = FrameTagManager.GetTagID (findItem tags (oldRangeName + "_start"))
	rangeEnd_id = FrameTagManager.GetTagID (findItem tags (oldRangeName + "_end"))
	FrameTagManager.SetNameByID rangeStart_id (newRangeName + "_start")
	FrameTagManager.SetNameByID rangeEnd_id (newRangeName + "_end")
)

function ExportSelectedRanges exportpath filename rangesSelected = (
	for range in rangesSelected do
	(
	setRangeByRange range
	fileToExport = exportpath + "\\" + filename + "@" + range + ".fbx"
	FBXExporterSetParam "Animation" true
	FBXExporterSetParam "BakeAnimation" true
	FBXExporterSetParam "Removesinglekeys"
	exportFile fileToExport #noPrompt selectedOnly: true
	)
	)
	
function SetFileProperties exportpath filename = (
	if filename != undefined then
	(
		fileProperties.addProperty #custom "filename" filename
		)
	if exportpath != undefined then
	(
		fileProperties.addProperty #custom "exportpath" exportpath
		)
)

function GetFilePropertiesExportPath = (
	return fileProperties.getPropertyValue #custom (fileProperties.findProperty #custom "exportpath")
	)
function GetFilePropertiesFileName = (
	return fileProperties.getPropertyValue #custom (fileProperties.findProperty #custom "filename")
	)

rollout win1 "Time line navigator" width:200 height:560
(
	local rangesSelected = #()
	local newRange = ""
	
	---window width = 200
	multiListBox mlb "Animation ranges" items: (for range in ranges collect range) height: 15
	button setSelRanges "Set selected ranges" pos:[10,225] width:180 height:20
	button delSelRanges "Delete selected ranges" pos:[10,305] width:180 height:20
	edittext entRngName "Enter range name" pos:[10,345] width:180 height:17 labelOnTop:true
	button crtNewRng "Create new range" pos:[10,382] width:180 height:20
	button rdfSelRng "Redefine selected range" pos:[10,265] width:180 height:20
	button renSelRng "Rename selected range" pos:[10,402] width:180 height:20
	button refresh "Refresh ranges" pos:[10,285] width:180 height:20
	button delAllTags "Delete all time tags" pos:[10,325] width:180 height:20
	button setAllRanges "Set all animation ranges" pos:[10,245] width:180 height:20
	button leftSld "Left-Slider" pos:[10, 425] width: 60 height: 20
	button rightSld "Slider-Right" pos:[130, 425] width: 60 height: 20
	button rngSld "Rng-Slider" pos:[70, 425] width: 60 height: 20
	spinner startTime "Start:" range:[-20000,20000,animationRange.start] type:#integer pos:[10, 445] width: 80 height: 17
	spinner endTime "End:" range:[-20000,20000,animationRange.end] type:#integer pos:[110, 445] width: 80 height: 17
	edittext exportpath "Export path" pos:[10,460] width: 180 height: 17 labelOnTop: true text: (GetFilePropertiesExportPath())
	edittext filename "File prefix name" pos:[10,495] width: 180 height: 17 labelOnTop: true text: (GetFilePropertiesFileName())
	button exportSel "Export selected ranges" pos:[10,532] width:180 height:20
	
	on mlb selectionEnd do
	(
		rangesSelected = (for idx in mlb.selection collect ranges[idx])
		if rangesSelected.count == 1 then
			(
			entRngName.text = rangesSelected[1]
			)
			else
			(
			entRngName.text = ""
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
	on delSelRanges pressed do
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
	on entRngName entered txt do
	(
		newRange = txt
	)
	on crtNewRng pressed do
	(
		if newRange != "" then
		(
			createTagsByRangeName newRange
			createRanges()
			mlb.items = (for range in ranges collect range)
			entRngName.text = ""
		)
	)
	on rdfSelRng pressed do
	(
		if ranges.count > 0 and rangesSelected.count == 1 then
		(
			redefineRange rangesSelected[1]
			createRanges()
			mlb.items = (for range in ranges collect range)
		)
	)
	on renSelRng pressed do
	(
		if ranges.count > 0 and newRange != "" and rangesSelected.count == 1 then
		(
			renameRange rangesSelected[1] newRange
			createRanges()
			rangesSelected[1] = newRange
			mlb.items = (for range in ranges collect range)
			entRngName.text = ""
		)
	)
	on refresh pressed do
	(
		createRanges()
		mlb.items = (for range in ranges collect range)
		mlb.selection = #{}
		startTime.value = animationRange.start
		endTime.value = animationRange.end
	)
	on delAllTags pressed do
	(
		if queryBox "Delete all time tags ?" beep: True then
		(
			FrameTagManager.ResetFrameTags()
			createRanges()
			mlb.items = (for range in ranges collect range)
		)
	)
	on setAllRanges pressed do
	(
		if tags.count > 0 then
		(
		setAllAnimationRanges()
		)
		startTime.value = animationRange.start
		endTime.value = animationRange.end
	)
	on leftSld pressed do
	(
		SetLeftSlider()
		startTime.value = animationRange.start
		endTime.value = animationRange.end
		)
	on rightSld pressed do
	(
		SetRightSlider()
		startTime.value = animationRange.start
		endTime.value = animationRange.end
		)
	on rngSld pressed do
	(
		if rangesSelected.count == 1 then
		(
		setRangeByRangeNameAndSlider rangesSelected[1]
		startTime.value = animationRange.start
		endTime.value = animationRange.end
		)
		)
	on startTime changed value do
	(
		SetStartTime startTime.value
		if startTime.value == 0 then
		(
			sliderTime = 0
			)
		)
	on endTime changed value do
	(
		SetEndTime endTime.value
		)
	on exportpath changed text_ do
	(
		SetFileProperties exportpath.text filename.text
		)
	on filename_ changed text_ do
	(
		SetFileProperties exportpath.text filename.text
		)
	on exportSel pressed do
	(
		ExportSelectedRanges exportpath.text filename.text rangesSelected
		)

)

createRanges()
createDialog win1