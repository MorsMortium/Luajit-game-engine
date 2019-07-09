local GiveBack = {}

--Creates and returns one Camera
function GiveBack.Create(GotCamera, Arguments)
	local General, CameraRender, lgsl = Arguments[1], Arguments[3], Arguments[5]
	local IsVector3 = General.Library.IsVector3
	local type = type
	local gsl = lgsl.Library.gsl

	--Creating the Camera table
	local Camera = {}

	Camera.ViewMatrix = gsl.gsl_matrix_alloc(4, 4)
	Camera.ProjectionMatrix = gsl.gsl_matrix_alloc(4, 4)
	Camera.ViewProjectionMatrix = gsl.gsl_matrix_alloc(4, 4)
	--The translation in the world, Default: origin
	Camera.Translation = {0,1,0}

	--The direction the Camera faces
	Camera.Direction = {0,-1,0}

	--The vector that points to the top of the Camera
	Camera.UpVector = {0,1,0}

	--Defines, which of the Objects it can see, Default: All
	Camera.VisualLayers = {["All"] = true}

	--Closest vertices it renders
	Camera.MinimumDistance = 1

	--Farthest vertices it renders
	Camera.MaximumDistance = 100

	--Resolutions of the Camera
	Camera.HorizontalResolution = 640
	Camera.VerticalResolution = 480

	--Field Of View of the Camera
	Camera.FieldOfView = 90

	--Type of the Camera, it can be "Software" or "OpenGL"
	Camera.Type = "Software"

	--Camera Renderer from CameraRender.lua
	Camera.CameraRenderer = "Default"

	--Flags for upgrading the matrices
	Camera.ViewMatrixCalc = true
	Camera.ProjectionMatrixCalc = true

	--Creating the Camera from the actual data
	if type(GotCamera) == "table" then
		if IsVector3(GotCamera.Translation) then
			Camera.Translation = GotCamera.Translation
		end
		if IsVector3(GotCamera.Direction) then
			Camera.Direction = GotCamera.Direction
		end
		if IsVector3(GotCamera.UpVector) then
			Camera.UpVector = GotCamera.UpVector
		end
		if General.Library.GoodTypesOfHashTable(GotCamera.VisualLayers, "boolean") then
			Camera.VisualLayers = GotCamera.VisualLayers
		end
		if type(GotCamera.MinimumDistance) == "number" then
			Camera.MinimumDistance = GotCamera.MinimumDistance
		end
		if type(GotCamera.MaximumDistance) == "number" then
			Camera.MaximumDistance = GotCamera.MaximumDistance
		end
		if type(GotCamera.HorizontalResolution) == "number" then
			Camera.HorizontalResolution = GotCamera.HorizontalResolution
		end
		if type(GotCamera.VerticalResolution) == "number" then
			Camera.VerticalResolution = GotCamera.VerticalResolution
		end
		if type(GotCamera.FieldOfView) == "number" then
			Camera.FieldOfView = GotCamera.FieldOfView
		end
		if GotCamera.Type == "OpenGL" then
			Camera.Type = "OpenGL"
		end
		if CameraRender.Library.CameraRenders[GotCamera.CameraRenderer] then
			Camera.CameraRenderer = GotCamera.CameraRenderer
		end

		--The Camera is able to follow a Device's Object from any distance with
		--One of it's vertices as direction and up vector
		if type(GotCamera.FollowDevice) == "number" then
			Camera.FollowDevice = GotCamera.FollowDevice
			if type(GotCamera.FollowObject) == "number" then
				Camera.FollowObject = GotCamera.FollowObject
			end
			if type(GotCamera.FollowPoint) == "number" and
			GotCamera.FollowPoint > 0 and GotCamera.FollowPoint < 5 then
				Camera.FollowPoint = GotCamera.FollowPoint
			end
			if type(GotCamera.FollowPointUp) == "number" and
			GotCamera.FollowPointUp > 0 and GotCamera.FollowPointUp < 5 then
				Camera.FollowPointUp = GotCamera.FollowPointUp
			end
			if type(GotCamera.FollowDistance) == "number" then
				Camera.FollowDistance = GotCamera.FollowDistance
			end
		end
	end
	return Camera
end

--Destroys a Camera, freeing up all it's matrices, then clearing the other data
function GiveBack.Destroy(GotCamera, Arguments)
	local gsl = Arguments[5].gsl
	gsl.gsl_matrix_free(GotCamera.ViewMatrix)
	gsl.gsl_matrix_free(GotCamera.ProjectionMatrix)
	gsl.gsl_matrix_free(GotCamera.ViewProjectionMatrix)
	for ak,av in pairs(GotCamera) do
		GotCamera[ak] = nil
	end
end
GiveBack.Requirements = {"General", "CameraRender", "lgsl"}
return GiveBack
