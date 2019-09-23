return function(args)
	local Math, CameraRender, Globals, CTypes = args[1], args[2], args[3], args[4]
	local Globals = Globals.Library.Globals
	local IsVector3, type, SetIdentity, SetZero, float = Math.Library.IsVector3,
	Globals.type, Math.Library.SetIdentity, Math.Library.SetZero,
	CTypes.Library.Types["float[?]"].Type
	local GiveBack = {}

	function GiveBack.Reload(args)
		Math, CameraRender, Globals, CTypes = args[1], args[2], args[3], args[4]
		Globals = Globals.Library.Globals
		IsVector3, type, SetIdentity, SetZero, float = Math.Library.IsVector3,
		Globals.type, Math.Library.SetIdentity, Math.Library.SetZero,
		CTypes.Library.Types["float[?]"].Type
  end

	--Creates and returns one Camera
	function GiveBack.Create(GotCamera)
		--Creating the Camera table
		local Camera = {}

		Camera.ViewMatrix = float(16)
		SetIdentity(Camera.ViewMatrix)
		Camera.ProjectionMatrix = float(16)
		SetZero(Camera.ProjectionMatrix)
		Camera.ProjectionMatrix[11] = -1
		Camera.ViewProjectionMatrix = float(16)
		--The translation in the world, Default: origin
		Camera.Translation = {0,1,0}

		--The direction the Camera faces
		Camera.Direction = {0,-1,0}

		--The vector that points to the top of the Camera
		Camera.UpVector = {0,1,0}

		--Defines, which of the Objects it can see, Default: All
		Camera.VisualLayers = {}
		Camera.VLayerKeys = {}
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

			for ak=1,#GotCamera.VisualLayers do
				local av = GotCamera.VisualLayers[ak]
				Camera.VisualLayers[av] = true
				Camera.VLayerKeys[ak] = av
			end

			if Camera.VLayerKeys[1] == nil then
				Camera.VisualLayers["All"] = true
				Camera.VLayerKeys[1] = "All"
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
	function GiveBack.Destroy(GotCamera)
	end
	return GiveBack
end
