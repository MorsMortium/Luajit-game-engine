local GiveBack = {}
function GiveBack.Create(GotObject, ffi, ffiGive, General, GeneralGive, lgsl, lgslGive)
	local Object = {}
	if type(GotObject) == "table" then
		if General.Library.IsVector3(GotObject.Translation) then
			Object.Translation = GotObject.Translation
		else
			Object.Translation = {0,1,0}
		end
		if General.Library.IsVector3(GotObject.Direction) then
			Object.Direction = GotObject.Direction
		else
			Object.Direction = {0,-1,0}
		end
		Object.UpVector = lgsl.Library.gsl.gsl_vector_alloc(3)
		if General.Library.IsVector3(GotObject.UpVector) then
			for i=1,3 do
				Object.UpVector.data[i-1] = GotObject.UpVector[i]
			end
			--Object.UpVector = GotObject.UpVector
		else
			Object.UpVector.data[0] = 0
			Object.UpVector.data[1] = 1
			Object.UpVector.data[2] = 0
		end
		if type(GotObject.VisualLayers) == "table" then
			Object.VisualLayers = GotObject.VisualLayers
		else
			Object.VisualLayers = {"All"}
		end
		if type(GotObject.MinimumDistance) == "number" then
			Object.MinimumDistance = GotObject.MinimumDistance
		else
			Object.MinimumDistance = 1
		end
		if type(GotObject.MaximumDistance) == "number" then
			Object.MaximumDistance = GotObject.MaximumDistance
		else
			Object.MaximumDistance = 100
		end
		if type(GotObject.HorizontalResolution) == "number" then
			Object.HorizontalResolution = GotObject.HorizontalResolution
		else
			Object.HorizontalResolution = 640
		end
		if type(GotObject.VerticalResolution) == "number" then
			Object.VerticalResolution = GotObject.VerticalResolution
		else
			Object.VerticalResolution = 480
		end
		if type(GotObject.FieldOfView) == "number" then
			Object.FieldOfView = GotObject.FieldOfView
		else
			Object.FieldOfView = 90
		end
		if type(GotObject.FollowDevice) == "number" then
			Object.FollowDevice = GotObject.FollowDevice
			if type(GotObject.FollowObject) == "number" then
				Object.FollowObject = GotObject.FollowObject
			end
			if type(GotObject.FollowPoint) == "number" and GotObject.FollowPoint > 0 and GotObject.FollowPoint < 5 then
				Object.FollowPoint = GotObject.FollowPoint
			end
			if type(GotObject.FollowPointUpVector) == "number" and GotObject.FollowPointUpVector > 0 and GotObject.FollowPointUpVector < 5 then
				Object.FollowPointUpVector = GotObject.FollowPointUpVector
			end
			if type(GotObject.FollowDistance) == "number" then
				Object.FollowDistance = GotObject.FollowDistance
			end
		end
	else
		Object.Translation = {0,1,0}
		Object.Direction = {0,-1,0}
		Object.UpVector = {0,1,0}
		Object.VisualLayers = {"All"}
		Object.MinimumDistance = 1
		Object.MaximumDistance = 100
		Object.HorizontalResolution = 640
		Object.VerticalResolution = 480
		Object.FieldOfView = 90
	end
	return Object
end
GiveBack.Requirements = {"ffi", "General", "lgsl"}
return GiveBack
