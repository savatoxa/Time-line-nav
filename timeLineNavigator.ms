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

function SetRangeByRange rangeName = (
	rangeStart_id = FrameTagManager.GetTagID (findItem tags (rangeName + "_start"))
	rangeEnd_id = FrameTagManager.GetTagID (findItem tags (rangeName + "_end"))
	animationRange = interval (FrameTagManager.GetTimeByID rangeStart_id) (FrameTagManager.GetTimeByID rangeEnd_id)
)

function GetIntervalByRanges rangesSelected =
(
	rangestart = FrameTagManager.GetTimeByID (FrameTagManager.GetTagID (findItem tags (rangesSelected[1] + "_start")))
	rangeend = FrameTagManager.GetTimeByID (FrameTagManager.GetTagID (findItem tags (rangesSelected[rangesSelected.count] + "_end")))
	return #(rangestart, rangeend)
	)

function SetRangeByRangeName rangesSelected = (
	rangeStart_id = FrameTagManager.GetTagID (findItem tags (rangesSelected[1] + "_start"))
	rangeEnd_id = FrameTagManager.GetTagID (findItem tags (rangesSelected[rangesSelected.count] + "_end"))
	animationRange = interval (FrameTagManager.GetTimeByID rangeStart_id) (FrameTagManager.GetTimeByID rangeEnd_id)
	sliderTime = FrameTagManager.GetTimeByID rangeStart_id
)

function SetRangeByRangeNameAndSlider rangeName = (
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
	if leftBorder >= animationRange.end then
	(animationRange = interval leftBorder (leftBorder + 1))
	else
	(animationRange = interval leftBorder animationRange.end)
	)
	
function SetEndTime rightBorder = (
	if rightBorder <= animationRange.start then
	(animationRange = interval (rightBorder - 1) rightBorder)
	else
	(animationRange = interval animationRange.start rightBorder)
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

function ExportSelectedRanges exportpath filename rangesSelected upaxis = (
 	FBXExporterSetParam "Animation" true
 	FBXExporterSetParam "BakeAnimation" true
 	FBXExporterSetParam "Removesinglekeys" true
	if upaxis == 1 then
 	(FBXExporterSetParam "UpAxis" "Z")
	else if upaxis == 2 then
	(FBXExporterSetParam "UpAxis" "Y")
	for range in rangesSelected do
	(
	SetRangeByRange range
	fileToExport = exportpath + "\\" + filename + "@" + range + ".fbx"
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
	if fileProperties.findProperty #custom "exportpath" then
	(return fileProperties.getPropertyValue #custom (fileProperties.findProperty #custom "exportpath"))
	else
	(return "")
	)
function GetFilePropertiesFileName = (
	if fileProperties.findProperty #custom "filename" then
	(return fileProperties.getPropertyValue #custom (fileProperties.findProperty #custom "filename"))
	else (return "")
	)

rollout win1 "Time line navigator" width:200 height:550
(
	local rangesSelected = #()
	local newRange = ""
	
	---window width = 200
	multiListBox mlb "Animation ranges" items: (for range in ranges collect range) height: 15
	label displayStartRange "start: " pos:[15, 225] width:80 height: 17
	label displayEndRange "end: " pos:[95, 225] width:80 height: 17
	button setSelRanges "Set selected ranges" pos:[10,240] width:180 height:17
	button setAllRanges "Set all animation ranges" pos:[10,258] width:180 height:17
	button rdfSelRng "Redefine selected range" pos:[10,276] width:180 height:17
	button refresh "Refresh ranges" pos:[10,294] width:180 height:17
	button delSelRanges "Delete selected ranges" pos:[10,312] width:180 height:17
	button delAllTags "Delete all time tags" pos:[10,330] width:180 height:17
	edittext entRngName "Enter range name" pos:[10,345] width:180 height:17 labelOnTop:true
	button crtNewRng "Create new range" pos:[10,382] width:180 height:17
	button renSelRng "Rename selected range" pos:[10,400] width:180 height:17
	button leftSld "Left-Slider" pos:[10, 418] width: 60 height: 17
	button rightSld "Slider-Right" pos:[130, 418] width: 60 height: 17
	button rngSld "Rng-Slider" pos:[70, 418] width: 60 height: 17
	spinner startTime "Start:" range:[-20000,20000,animationRange.start] type:#integer pos:[10, 436] width: 80 height: 17
	spinner endTime "End:" range:[-20000,20000,animationRange.end] type:#integer pos:[110, 436] width: 80 height: 17
	edittext exportpath "Export path" pos:[10,454] width: 180 height: 17 labelOnTop: true text: (GetFilePropertiesExportPath())
	radiobuttons upAxisBtn labels:#("ZUp", "YUp") rows:2 pos:[100, 456]
	edittext filename "File prefix name" pos:[10,490] width: 180 height: 17 labelOnTop: true text: (GetFilePropertiesFileName())
	button exportSel "Export selected ranges" pos:[10,527] width:180 height:17
	
	on mlb selectionEnd do
	(
		rangesSelected = (for idx in mlb.selection collect ranges[idx])
		rangesStartEnd = GetIntervalByRanges rangesSelected
		displayStartRange.text = "start: " + (rangesStartEnd[1] as string)
		displayEndRange.text = "end: " + (rangesStartEnd[2] as string)
		startTime.value = animationRange.start
		endTime.value = animationRange.end
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
		SetRangeByRangeName rangesSelected
		startTime.value = animationRange.start
		endTime.value = animationRange.end
		)
	on setSelRanges pressed do
	(
		if ranges.count > 0 then
		(
			SetRangeByRangeName rangesSelected
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
		exportpath.text = GetFilePropertiesExportPath()
		filename.text = GetFilePropertiesFileName()
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
		SetRangeByRangeNameAndSlider rangesSelected[1]
		startTime.value = animationRange.start
		endTime.value = animationRange.end
		)
		)
	on startTime changed value do
	(
		SetStartTime startTime.value
		endTime.value = animationRange.end
		if startTime.value == 0 then
		(sliderTime = 0)
		)
	on endTime changed value do
	(
		SetEndTime endTime.value
		startTime.value = animationRange.start
		if endTime.value == 0 then
		(sliderTime = 0)
		)
	on exportpath changed text_ do
	(
		SetFileProperties exportpath.text filename.text
		)
	on filename changed text_ do
	(
		SetFileProperties exportpath.text filename.text
		)
	on exportSel pressed do
	(
		ExportSelectedRanges exportpath.text filename.text rangesSelected upAxisBtn.state
		)

)

createRanges()
createDialog win1