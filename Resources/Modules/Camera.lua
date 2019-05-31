local GiveBack = {}
function GiveBack.Create(GotObject, Arguments)
	local General, CameraRender = Arguments[1], Arguments[3]
	local Object = {}
	Object.Translation = {0,1,0}
	Object.Direction = {0,-1,0}
	Object.UpVector = {0,1,0}
	Object.VisualLayers = {"All"}
	Object.MinimumDistance = 1
	Object.MaximumDistance = 100
	Object.HorizontalResolution = 640
	Object.VerticalResolution = 480
	Object.FieldOfView = 90
	Object.Type = "Software"
	Object.CameraRenderer = "Default"
	Object.ViewMatrixCalc = true
	Object.ProjectionMatrixCalc = true
	if type(GotObject) == "table" then
		if General.Library.IsVector3(GotObject.Translation) then
			Object.Translation = GotObject.Translation
		end
		if General.Library.IsVector3(GotObject.Direction) then
			Object.Direction = GotObject.Direction
		end
		if General.Library.IsVector3(GotObject.UpVector) then
			Object.UpVector = GotObject.UpVector
		end
		if type(GotObject.VisualLayers) == "table" then
			Object.VisualLayers = GotObject.VisualLayers
		end
		if type(GotObject.MinimumDistance) == "number" then
			Object.MinimumDistance = GotObject.MinimumDistance
		end
		if type(GotObject.MaximumDistance) == "number" then
			Object.MaximumDistance = GotObject.MaximumDistance
		end
		if type(GotObject.HorizontalResolution) == "number" then
			Object.HorizontalResolution = GotObject.HorizontalResolution
		end
		if type(GotObject.VerticalResolution) == "number" then
			Object.VerticalResolution = GotObject.VerticalResolution
		end
		if type(GotObject.FieldOfView) == "number" then
			Object.FieldOfView = GotObject.FieldOfView
		end
		if GotObject.Type == "OpenGL" then
			Object.Type = "OpenGL"
		end
		if CameraRender.Library.CameraRenders[GotObject.CameraRenderer] ~= nil then
			Object.CameraRenderer = GotObject.CameraRenderer
		end
		if type(GotObject.FollowDevice) == "number" then
			Object.FollowDevice = GotObject.FollowDevice
			if type(GotObject.FollowObject) == "number" then
				Object.FollowObject = GotObject.FollowObject
			end
			if type(GotObject.FollowPoint) == "number" and
			GotObject.FollowPoint > 0 and GotObject.FollowPoint < 5 then
				Object.FollowPoint = GotObject.FollowPoint
			end
			if type(GotObject.FollowPointUp) == "number" and
			GotObject.FollowPointUp > 0 and GotObject.FollowPointUp < 5 then
				Object.FollowPointUp = GotObject.FollowPointUp
			end
			if type(GotObject.FollowDistance) == "number" then
				Object.FollowDistance = GotObject.FollowDistance
			end
		end
	end
	return Object
end
function GiveBack.Destroy(GotObject, Arguments)
	for ak,av in pairs(GotObject) do
		GotObject[ak] = nil
	end
end
GiveBack.Requirements = {"General", "CameraRender"}
return GiveBack
