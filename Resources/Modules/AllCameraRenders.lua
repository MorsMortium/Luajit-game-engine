return function(args)
  local Space, OpenGL, AllDevices, Math, SDL, CameraRender, AllCameras,
  Globals, CTypes, General = args[1], args[2], args[3], args[4], args[5],
  args[6], args[7], args[8], args[9], args[10]
  local Globals, Math, CTypes, General = Globals.Library.Globals, Math.Library,
  CTypes.Library.Types, General.Library
  local VectorDot, VectorCross, Normalise, VectorSub, VectorLength,
  VectorAdd, VectorScale, OpenGL, SDL, VectorEqual, pi, tan,
  MatrixMul, double, SameLayer, remove, VectorCopy = Math.VectorDot,
  Math.VectorCross, Math.Normalise, Math.VectorSub, Math.VectorLength,
  Math.VectorAdd, Math.VectorScale, OpenGL.Library, SDL.Library,
  Math.VectorEqual, Globals.pi, Globals.tan, Math.MatrixMul,
  CTypes["double[?]"].Type, General.SameLayer, Globals.remove, Math.VectorCopy

  local GiveBack = {}


  --Creates a Camera's projection matrix
  --TODO:Better place for the matrix and update stuff
  local function ProjectionMatrix(FOV, Aspect, MinDistance, MaxDistance, Matrix)
    local D2R = pi / 180
    local YScale = 1 / tan(D2R * FOV / 2)
    local XScale = YScale / Aspect
    local MDMMD = MinDistance - MaxDistance
    local m = Matrix
    m[0], m[5], m[10], m[14] =
    XScale, YScale, (MaxDistance + MinDistance) / MDMMD,
    2 * MaxDistance * MinDistance / MDMMD
  end

  local X, Y, Z = double(3), double(3), double(3)

  --Creates a Camera's view matrix
  local function ViewMatrix(Translation, Direction, UpVector, Matrix)
    local m = Matrix
    VectorSub(Translation, Direction, Z)
    Normalise(Z, Z)
    VectorCross(UpVector, Z, X)
    Normalise(X, X)
    VectorCross(Z, X, Y)
    m[0], m[1], m[2], m[3],
    m[4], m[5], m[6], m[7],
    m[8], m[9], m[10], m[11] =
    X[0], X[1], X[2], -VectorDot(X, Translation),
    Y[0], Y[1], Y[2], -VectorDot(Y, Translation),
    Z[0], Z[1], Z[2], -VectorDot(Z, Translation)
  end

  local TranslationV, PointUp, CenterToPoint, NewTranslation, NewDirection,
  NewUpVector = double(3), double(3), double(3), double(3), double(3), double(3)

  --Updates a Cameras matrices, if needed
  local function UpdateCamera(av)
    if av.FollowDevice and AllDevices.Space.Devices[av.FollowDevice] and
    AllDevices.Space.Devices[av.FollowDevice].Objects[av.FollowObject] then
      local FollowObject =
      AllDevices.Space.Devices[av.FollowDevice].Objects[av.FollowObject]

      local Points = FollowObject.Points

      TranslationV[0], TranslationV[1], TranslationV[2] =
      Points[(av.FollowPoint-1) * 4],
      Points[(av.FollowPoint-1) * 4 + 1],
      Points[(av.FollowPoint-1) * 4 + 2]

      local Length = av.FollowDistance/VectorLength(TranslationV)

      local Center = FollowObject.Translation

      local Transformated = FollowObject.Transformated

      PointUp[0], PointUp[1], PointUp[2] =
      Transformated[(av.FollowPointUp-1) * 4],
      Transformated[(av.FollowPointUp-1) * 4 + 1],
      Transformated[(av.FollowPointUp-1) * 4 + 2]

      NewDirection[0], NewDirection[1], NewDirection[2] =
      Transformated[(av.FollowPoint-1) * 4],
      Transformated[(av.FollowPoint-1) * 4 + 1],
      Transformated[(av.FollowPoint-1) * 4 + 2]

      if not VectorEqual(av.Direction, NewDirection) then
        VectorCopy(NewDirection, av.Direction)
        av.ViewMatrixCalc = true
      end

      VectorSub(PointUp, Center, NewUpVector)

      if not VectorEqual(av.UpVector, NewUpVector) then
        VectorCopy(NewUpVector, av.UpVector)
        av.ViewMatrixCalc = true
      end

      VectorSub(av.Direction, Center, CenterToPoint)

      VectorScale(CenterToPoint, Length, CenterToPoint)

      VectorAdd(NewDirection, CenterToPoint, NewTranslation)

      if not VectorEqual(av.Translation, NewTranslation) then
        VectorCopy(NewTranslation, av.Translation)
        av.ViewMatrixCalc = true
      end

    end
    if av.ViewMatrixCalc then
      ViewMatrix(av.Translation, av.Direction, av.UpVector, av.ViewMatrix)
    end
    if av.ProjectionMatrixCalc then
      ProjectionMatrix(av.FieldOfView,
      av.HorizontalResolution/av.VerticalResolution, av.MinimumDistance,
      av.MaximumDistance, av.ProjectionMatrix)
    end
    if av.ViewMatrixCalc or av.ProjectionMatrixCalc then
      MatrixMul(av.ProjectionMatrix, av.ViewMatrix, av.ViewProjectionMatrix)
      av.ViewMatrixCalc, av.ProjectionMatrixCalc = false, false
    end
  end

  local function UpdateObjectList(Camera)
    local DestroyedObjects = AllDevices.Space.DestroyedObjects
		for ak=1,#DestroyedObjects do
			local av = DestroyedObjects[ak]
      local Temp = Camera.Objects[av]
			if Temp then
				Camera.Objects[av] = nil
				if Temp == #Camera.Objects then
					Camera.Objects[Temp] = nil
				else
					Camera.Objects[Temp] =
					Camera.Objects[#Camera.Objects]
					Camera.Objects[#Camera.Objects] = nil
					Camera.Objects[Camera.Objects[Temp]] = Temp
				end
			end
		end
    local CreatedObjects = AllDevices.Space.CreatedObjects
    for ak=1,#CreatedObjects do
      local av = CreatedObjects[ak]
      if SameLayer(Camera.VisualLayers, av.VisualLayers) then
        Camera.Objects[#Camera.Objects + 1] = av
        Camera.Objects[av] = #Camera.Objects
      end
    end
  end

  --Renders every Camera
  function GiveBack.RenderAllCameras()
    for ak=1,#AllCameras.Space.OpenGLCameras do
      local av = AllCameras.Space.OpenGLCameras[ak]
      UpdateCamera(av)
      UpdateObjectList(av)
      OpenGL.glFramebufferRenderbuffer(OpenGL.GL_FRAMEBUFFER,
      OpenGL.GL_DEPTH_ATTACHMENT, OpenGL.GL_RENDERBUFFER, av.DBO[0])
      OpenGL.glBindFramebuffer(OpenGL.GL_FRAMEBUFFER, AllCameras.Space.FBO[0])
      OpenGL.glFramebufferTexture(OpenGL.GL_FRAMEBUFFER,
      OpenGL.GL_COLOR_ATTACHMENT0, av.Texture[0], 0)
      if Space.LastCamera ~= ak then
        OpenGL.glViewport(0,0,av.HorizontalResolution,av.VerticalResolution)
      end
      Space.LastCamera = ak
      local CRender = CameraRender.Library.CameraRenders[av.CameraRenderer]
      CRender[av.Type].Render(AllCameras.Space.VBO, AllCameras.Space.RDBO, av,
      av.ViewProjectionMatrix, CRender.Space)
    end
    for ak=1,#AllCameras.Space.SoftwareCameras do
      local av = AllCameras.Space.SoftwareCameras[ak]
      UpdateCamera(av)
      UpdateObjectList(av)
      local CRender = CameraRender.Library.CameraRenders[av.CameraRenderer]
      CRender[av.Type].Render(av, Space.Renderer, CRender.Space)
      SDL.upperBlitScaled(Space.RendererSurface, nil, av.Surface, nil)
    end
  end
  function GiveBack.Start(Configurations)
    Space.LastCamera = 0
    Space.RendererSurface = SDL.createRGBSurface(0, 640, 480, 32, 0, 0, 0, 0)
    Space.Renderer = SDL.createSoftwareRenderer(Space.RendererSurface)
  end
  function GiveBack.Stop()
    SDL.destroyRenderer(Space.Renderer)
    SDL.freeSurface(Space.RendererSurface)
  end
  return GiveBack
end
