local GiveBack = {}
local function ProjectionMatrix(FieldOfView, Aspect, MinimumDistance, MaximumDistance, lgsl)
  local D2R = math.pi / 180
  local YScale = 1 / math.tan(D2R * FieldOfView / 2)
  local XScale = YScale / Aspect
  local MinimumDistanceMinusMaximumDistance = MinimumDistance - MaximumDistance
  local ResultMatrix = lgsl.Library.matrix.def{
    {XScale, 0, 0, 0},
    {0, YScale, 0, 0},
    {0, 0, (MaximumDistance + MinimumDistance) / MinimumDistanceMinusMaximumDistance, -1},
    {0, 0, 2*MaximumDistance*MinimumDistance / MinimumDistanceMinusMaximumDistance, 0}}
  return ResultMatrix
end
local function ViewMatrix(Translation, Direction, UpVector, lgsl, General)
  local gsl = lgsl.Library.gsl
  local Z = General.Library.VectorSubtraction(Translation, Direction)
  Z = General.Library.Normalise(Z)
  local X = General.Library.CrossProduct(UpVector, Z)
  X = General.Library.Normalise(X)
  local Y = General.Library.CrossProduct(Z, X)
  local ResultMatrix = lgsl.Library.matrix.def{
    {X[1], Y[1], Z[1], 0},
    {X[2], Y[2], Z[2], 0},
    {X[3], Y[3], Z[3], 0},
    {-General.Library.DotProduct(X, Translation),
    -General.Library.DotProduct(Y, Translation),
    -General.Library.DotProduct(Z, Translation), 1}}
  gsl.gsl_matrix_transpose(ResultMatrix)
	return ResultMatrix
end
function GiveBack.Start(Arguments)
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
local function UpdateCamera(av, General, lgsl, AllDevices)
  if av.FollowDevice and AllDevices.Space.Devices[av.FollowDevice] and
  AllDevices.Space.Devices[av.FollowDevice].Objects[av.FollowObject] then
    local FollowObject = AllDevices.Space.Devices[av.FollowDevice].Objects[av.FollowObject]
    av.Direction = {FollowObject.Transformated.data[(av.FollowPoint-1) * 4], FollowObject.Transformated.data[(av.FollowPoint-1) * 4 + 1], FollowObject.Transformated.data[(av.FollowPoint-1) * 4 + 2]}
    local Translationv = {FollowObject.Points.data[(av.FollowPoint-1) * 4], FollowObject.Points.data[(av.FollowPoint-1) * 4 + 1], FollowObject.Points.data[(av.FollowPoint-1) * 4 + 2]}
    local Length = av.FollowDistance/General.Library.VectorLength(Translationv)
    local Center = FollowObject.Translation
    local PointUp = {FollowObject.Transformated.data[(av.FollowPointUp-1) * 4], FollowObject.Transformated.data[(av.FollowPointUp-1) * 4 + 1], FollowObject.Transformated.data[(av.FollowPointUp-1) * 4 + 2]}
    local CenterToPoint = General.Library.PointAToB(Center, av.Direction)
    av.UpVector = General.Library.PointAToB(Center, PointUp)
    av.Translation = General.Library.VectorAddition(av.Direction, General.Library.VectorNumberMult(CenterToPoint, Length))
    av.ViewMatrixCalc = true
  end
  if av.ViewMatrixCalc then
    av.ViewMatrix = ViewMatrix(av.Translation, av.Direction, av.UpVector, lgsl, General)
  end
  if av.ProjectionMatrixCalc then
    av.ProjectionMatrix = ProjectionMatrix(av.FieldOfView, av.HorizontalResolution/av.VerticalResolution, av.MinimumDistance, av.MaximumDistance, lgsl)
  end
  if av.ViewMatrixCalc or av.ProjectionMatrixCalc then
    av.ViewProjectionMatrix = av.ProjectionMatrix * av.ViewMatrix
    av.ViewMatrixCalc = false
    av.ProjectionMatrixCalc = false
  end
end
function GiveBack.RenderAllCameras(Arguments)
  local Space, OpenGL, AllDevices, lgsl, General, SDL, CameraRender,
  CameraRenderGive, AllCameras, AllCamerasGive = Arguments[1], Arguments[2], Arguments[4],
  Arguments[6], Arguments[8], Arguments[10], Arguments[12], Arguments[13],
  Arguments[14], Arguments[15]
  for ak=1,#AllCameras.Space.OpenGLCameras do
    local av = AllCameras.Space.OpenGLCameras[ak]
    UpdateCamera(av, General, lgsl, AllDevices)
    OpenGL.Library.glFramebufferRenderbuffer(OpenGL.Library.GL_FRAMEBUFFER, OpenGL.Library.GL_DEPTH_ATTACHMENT, OpenGL.Library.GL_RENDERBUFFER, av.DBO[0])
    OpenGL.Library.glBindFramebuffer(OpenGL.Library.GL_FRAMEBUFFER, AllCameras.Space.FBO[0])
    OpenGL.Library.glFramebufferTexture(OpenGL.Library.GL_FRAMEBUFFER, OpenGL.Library.GL_COLOR_ATTACHMENT0, av.Texture[0], 0)
    if Space.LastCamera ~= ak then
      OpenGL.Library.glViewport(0,0,av.HorizontalResolution,av.VerticalResolution)
    end
    Space.LastCamera = ak
    for bk=0,15 do
      Space.ViewProjectionMatrix[bk] = av.ViewProjectionMatrix.data[bk]
    end
    CameraRender.Library.CameraRenders[av.CameraRenderer][av.Type].Render(av, Space.ViewProjectionMatrix, CameraRender.Library.CameraRenders[av.CameraRenderer].Space, CameraRenderGive)
  end
  for ak=1,#AllCameras.Space.SoftwareCameras do
    local av = AllCameras.Space.SoftwareCameras[ak]
    UpdateCamera(av, General, lgsl, AllDevicesGive)
    CameraRender.Library.CameraRenders[av.CameraRenderer][av.Type].Render(av, Space.Renderer, CameraRender.Library.CameraRenders[av.CameraRenderer].Space, CameraRenderGive)
    SDL.Library.upperBlitScaled(Space.RendererSurface, nil, av.Surface, nil)
  end
end
GiveBack.Requirements = {"OpenGL", "AllDevices", "lgsl", "General", "SDL", "CameraRender", "AllCameras", "ffi"}
return GiveBack
