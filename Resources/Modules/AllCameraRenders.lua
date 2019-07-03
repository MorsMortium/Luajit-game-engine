local GiveBack = {}

--Creates a Camera's projection matrix
--TODO:Better place for the matrix and update stuff
local function ProjectionMatrix(FieldOfView, Aspect, MinimumDistance, MaximumDistance, ProjectionMatrix, ffi)
  local D2R = math.pi / 180
  local YScale = 1 / math.tan(D2R * FieldOfView / 2)
  local XScale = YScale / Aspect
  local MDMMD = MinimumDistance - MaximumDistance
  local m = ffi.Library.new("double[16]", XScale, 0, 0, 0,
                                          0, YScale, 0, 0,
                                          0, 0, (MaximumDistance + MinimumDistance) / MDMMD, -1,
                                          0, 0, 2*MaximumDistance*MinimumDistance / MDMMD, 0)
  ffi.Library.copy(ProjectionMatrix.data, m, ffi.Library.sizeof(m))
end

--Creates a Camera's view matrix
local function ViewMatrix(Translation, Direction, UpVector, ViewMatrix, ffi, General)
  local DotProduct = General.Library.DotProduct
  local CrossProduct = General.Library.CrossProduct
  local Normalise = General.Library.Normalise
  local VectorSubtraction =  General.Library.VectorSubtraction
  local Z = Normalise(VectorSubtraction(Translation, Direction))
  local X = Normalise(CrossProduct(UpVector, Z))
  local Y = CrossProduct(Z, X)
  local m = ffi.Library.new("double[16]", X[1], X[2], X[3], -DotProduct(X, Translation),
                                          Y[1], Y[2], Y[3], -DotProduct(Y, Translation),
                                          Z[1], Z[2], Z[3], -DotProduct(Z, Translation),
                                          0, 0, 0, 1)
  ffi.Library.copy(ViewMatrix.data, m, ffi.Library.sizeof(m))
	return ResultMatrix
end

--Checks whether a Camera their matrices updating, and if so it does it
local function UpdateCamera(av, ffi, lgsl, General, AllDevices)
  local VectorSubtraction = General.Library.VectorSubtraction
  local VectorLength = General.Library.VectorLength
  local VectorAddition = General.Library.VectorAddition
  local VectorNumberMult = General.Library.VectorNumberMult
  local VectorEqual = General.Library.VectorEqual
  local gsl = lgsl.Library.gsl
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
    VectorAddition(NewDirection, VectorNumberMult(CenterToPoint, Length))
    if not VectorEqual(av.Translation, NewTranslation) then
      av.Translation = NewTranslation
      av.ViewMatrixCalc = true
    end
  end
  if av.ViewMatrixCalc then
    ViewMatrix(av.Translation, av.Direction, av.UpVector, av.ViewMatrix, ffi, General)
  end
  if av.ProjectionMatrixCalc then
    ProjectionMatrix(av.FieldOfView,
    av.HorizontalResolution/av.VerticalResolution, av.MinimumDistance,
    av.MaximumDistance, av.ProjectionMatrix, ffi)
  end
  if av.ViewMatrixCalc or av.ProjectionMatrixCalc then
    av.ViewProjectionMatrix = av.ProjectionMatrix * av.ViewMatrix
    gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasNoTrans, 1,
    av.ProjectionMatrix, av.ViewMatrix, 0, av.ViewProjectionMatrix)
    av.ViewMatrixCalc, av.ProjectionMatrixCalc = false, false
  end
end

--Renders every Camera
function GiveBack.RenderAllCameras(Arguments)
  local Space, OpenGL, AllDevices, lgsl, General, SDL, CameraRender,
  CameraRenderGive, AllCameras, ffi = Arguments[1], Arguments[2], Arguments[4],
  Arguments[6], Arguments[8], Arguments[10], Arguments[12], Arguments[13],
  Arguments[14], Arguments[16]
  local OpenGL = OpenGL.Library
  for ak=1,#AllCameras.Space.OpenGLCameras do
    local av = AllCameras.Space.OpenGLCameras[ak]
    UpdateCamera(av, ffi, lgsl, General, AllDevices)
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
    Space.ViewProjectionMatrix, CRender.Space, CameraRenderGive)
  end
  for ak=1,#AllCameras.Space.SoftwareCameras do
    local av = AllCameras.Space.SoftwareCameras[ak]
    UpdateCamera(av, ffi, lgsl, General, AllDevices)
    local CRender = CameraRender.Library.CameraRenders[av.CameraRenderer]
    CRender[av.Type].Render(av, Space.Renderer, CRender.Space, CameraRenderGive)
    SDL.Library.upperBlitScaled(Space.RendererSurface, nil, av.Surface, nil)
  end
end
function GiveBack.Start(Configurations, Arguments)
  local Space, SDL, ffi = Arguments[1], Arguments[10], Arguments[16]
  Space.LastCamera = 0
  Space.RendererSurface = SDL.Library.createRGBSurface(0, 640, 480, 32, 0, 0, 0, 0)
  Space.Renderer = SDL.Library.createSoftwareRenderer(Space.RendererSurface)
  Space.ViewProjectionMatrix = ffi.Library.new("float[16]")
	print("AllCameras Started")
end
function GiveBack.Stop(Arguments)
  local Space, SDL = Arguments[1], Arguments[10]
  SDL.Library.destroyRenderer(Space.Renderer)
  SDL.Library.freeSurface(Space.RendererSurface)
  for ak,av in pairs(Space) do
    Space[ak] = nil
  end
	print("AllCameras Stopped")
end
GiveBack.Requirements =
{"OpenGL", "AllDevices", "lgsl", "General", "SDL", "CameraRender", "AllCameras", "ffi"}
return GiveBack
