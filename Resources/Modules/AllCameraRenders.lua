return function(args)
  local Space, OpenGL, AllDevices, lgsl, General, SDL, CameraRender, AllCameras, CTypes =
  args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9]
  local DotProduct, CrossProduct, Normalise, VectorSubtraction, VectorLength,
  VectorAddition, VectorScale, gsl, OpenGL, SDL, VectorEqual =
  General.Library.DotProduct, General.Library.CrossProduct,
  General.Library.Normalise, General.Library.VectorSubtraction,
  General.Library.VectorLength, General.Library.VectorAddition,
  General.Library.VectorScale, lgsl.Library.gsl, OpenGL.Library, SDL.Library,
  General.Library.VectorEqual

  local GiveBack = {}

  function GiveBack.Reload(args)
    Space, OpenGL, AllDevices, lgsl, General, SDL, CameraRender, AllCameras, CTypes =
    args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9]
    DotProduct, CrossProduct, Normalise, VectorSubtraction, VectorLength,
    VectorAddition, VectorScale, gsl, OpenGL, SDL, VectorEqual =
    General.Library.DotProduct, General.Library.CrossProduct,
    General.Library.Normalise, General.Library.VectorSubtraction,
    General.Library.VectorLength, General.Library.VectorAddition,
    General.Library.VectorScale, lgsl.Library.gsl, OpenGL.Library, SDL.Library,
    General.Library.VectorEqual
  end

  --Creates a Camera's projection matrix
  --TODO:Better place for the matrix and update stuff
  local function ProjectionMatrix(FieldOfView, Aspect, MinimumDistance, MaximumDistance, ProjectionMatrix)
    local D2R = math.pi / 180
    local YScale = 1 / math.tan(D2R * FieldOfView / 2)
    local XScale = YScale / Aspect
    local MDMMD = MinimumDistance - MaximumDistance
    local m = ProjectionMatrix.data
    m[0], m[5], m[10], m[14] =
    XScale, YScale, (MaximumDistance + MinimumDistance) / MDMMD,
    2 * MaximumDistance * MinimumDistance / MDMMD
  end

  --Creates a Camera's view matrix
  local function ViewMatrix(Translation, Direction, UpVector, ViewMatrix)
    local Z = Normalise(VectorSubtraction(Translation, Direction))
    local X = Normalise(CrossProduct(UpVector, Z))
    local Y = CrossProduct(Z, X)
    local m = ViewMatrix.data
    m[0], m[1], m[2], m[3],
    m[4], m[5], m[6], m[7],
    m[8], m[9], m[10], m[11] =
    X[1], X[2], X[3], -DotProduct(X, Translation),
    Y[1], Y[2], Y[3], -DotProduct(Y, Translation),
    Z[1], Z[2], Z[3], -DotProduct(Z, Translation)
  end

  --Checks whether a Camera needs their matrices to be updated, and if so it does it
  local function UpdateCamera(av)
    if av.FollowDevice and AllDevices.Space.Devices[av.FollowDevice] and
    AllDevices.Space.Devices[av.FollowDevice].Objects[av.FollowObject] then
      local FollowObject =
      AllDevices.Space.Devices[av.FollowDevice].Objects[av.FollowObject]

      local Translationv = {FollowObject.Points.data[(av.FollowPoint-1) * 4],
                            FollowObject.Points.data[(av.FollowPoint-1) * 4 + 1],
                            FollowObject.Points.data[(av.FollowPoint-1) * 4 + 2]}
      local Length = av.FollowDistance/VectorLength(Translationv)
      local Center = FollowObject.Translation
      local PointUp = {FollowObject.Transformated.data[(av.FollowPointUp-1) * 4],
                      FollowObject.Transformated.data[(av.FollowPointUp-1) * 4 + 1],
                      FollowObject.Transformated.data[(av.FollowPointUp-1) * 4 + 2]}

      local NewDirection = {FollowObject.Transformated.data[(av.FollowPoint-1) * 4],
                            FollowObject.Transformated.data[(av.FollowPoint-1) * 4 + 1],
                            FollowObject.Transformated.data[(av.FollowPoint-1) * 4 + 2]}
      if not VectorEqual(av.Direction, NewDirection) then
        av.Direction = NewDirection
        av.ViewMatrixCalc = true
      end
      local NewUpVector = VectorSubtraction(PointUp, Center)
      if not VectorEqual(av.UpVector, NewUpVector) then
        av.UpVector = NewUpVector
        av.ViewMatrixCalc = true
      end
      local CenterToPoint = VectorSubtraction(av.Direction, Center)
      local NewTranslation =
      VectorAddition(NewDirection, VectorScale(CenterToPoint, Length))
      if not VectorEqual(av.Translation, NewTranslation) then
        av.Translation = NewTranslation
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
      av.ViewProjectionMatrix = av.ProjectionMatrix * av.ViewMatrix
      gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasNoTrans, 1,
      av.ProjectionMatrix, av.ViewMatrix, 0, av.ViewProjectionMatrix)
      av.ViewMatrixCalc, av.ProjectionMatrixCalc = false, false
    end
  end

  --Renders every Camera
  function GiveBack.RenderAllCameras()
    for ak=1,#AllCameras.Space.OpenGLCameras do
      local av = AllCameras.Space.OpenGLCameras[ak]
      UpdateCamera(av, lgsl, General, AllDevices)
      OpenGL.glFramebufferRenderbuffer(OpenGL.GL_FRAMEBUFFER,
      OpenGL.GL_DEPTH_ATTACHMENT, OpenGL.GL_RENDERBUFFER, av.DBO[0])
      OpenGL.glBindFramebuffer(OpenGL.GL_FRAMEBUFFER, AllCameras.Space.FBO[0])
      OpenGL.glFramebufferTexture(OpenGL.GL_FRAMEBUFFER,
      OpenGL.GL_COLOR_ATTACHMENT0, av.Texture[0], 0)
      if Space.LastCamera ~= ak then
        OpenGL.glViewport(0,0,av.HorizontalResolution,av.VerticalResolution)
      end
      Space.LastCamera = ak
      for bk=0,15 do
        Space.ViewProjectionMatrix[bk] = av.ViewProjectionMatrix.data[bk]
      end
      local CRender = CameraRender.Library.CameraRenders[av.CameraRenderer]
      CRender[av.Type].Render(AllCameras.Space.VBO, AllCameras.Space.RDBO, av,
      Space.ViewProjectionMatrix, CRender.Space)
    end
    for ak=1,#AllCameras.Space.SoftwareCameras do
      local av = AllCameras.Space.SoftwareCameras[ak]
      UpdateCamera(av, lgsl, General, AllDevices)
      local CRender = CameraRender.Library.CameraRenders[av.CameraRenderer]
      CRender[av.Type].Render(av, Space.Renderer, CRender.Space)
      SDL.upperBlitScaled(Space.RendererSurface, nil, av.Surface, nil)
    end
  end
  function GiveBack.Start(Configurations)
    Space.LastCamera = 0
    Space.RendererSurface = SDL.createRGBSurface(0, 640, 480, 32, 0, 0, 0, 0)
    Space.Renderer = SDL.createSoftwareRenderer(Space.RendererSurface)
    Space.ViewProjectionMatrix = CTypes.Library.Types["float[?]"].Type(16)
  end
  function GiveBack.Stop()
    SDL.destroyRenderer(Space.Renderer)
    SDL.freeSurface(Space.RendererSurface)
  end
  return GiveBack
end
