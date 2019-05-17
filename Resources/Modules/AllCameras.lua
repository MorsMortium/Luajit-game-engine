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
    {-General.Library.DotProduct(X, Translation), -General.Library.DotProduct(Y, Translation), -General.Library.DotProduct(Z, Translation), 1}}
  gsl.gsl_matrix_transpose(ResultMatrix)
	return ResultMatrix
end
function GiveBack.Start(Arguments)
  local Space, JSON, Camera, CameraGive, ffi, OpenGL = Arguments[1], Arguments[2], Arguments[4], Arguments[5], Arguments[6], Arguments[8]
	Space.Cameras = {}
	local Cameras = JSON.Library:DecodeFromFile("./Resources/Configurations/AllCameras.json")
	Space.VAO = ffi.Library.new("GLuint[1]")
	Space.VBO = ffi.Library.new("GLuint[1]")
	Space.EBO = ffi.Library.new("GLuint[1]")
	Space.FBO = ffi.Library.new("GLuint[1]")
	OpenGL.Library.glGenVertexArrays(1, Space.VAO)
	OpenGL.Library.glGenBuffers(1, Space.VBO)
	OpenGL.Library.glGenBuffers(1, Space.EBO)
	OpenGL.Library.glGenFramebuffers(1, Space.FBO)
	OpenGL.Library.glBindFramebuffer(OpenGL.Library.GL_FRAMEBUFFER, Space.FBO[0])
	OpenGL.Library.glBindVertexArray(Space.VAO[0])
	OpenGL.Library.glBindBuffer(OpenGL.Library.GL_ARRAY_BUFFER, Space.VBO[0])
	OpenGL.Library.glBindBuffer(OpenGL.Library.GL_ELEMENT_ARRAY_BUFFER, Space.EBO[0])
	if type(Cameras) ~= "table" then
		Space.Cameras[1] = Camera.Library.Create(nil, CameraGive)
		Space.Cameras[1].ViewMatrixCalc = true
		Space.Cameras[1].ProjectionMatrixCalc = true
		Space.Cameras[1].Texture = ffi.Library.new("GLuint[1]")
		Space.Cameras[1].DBO = ffi.Library.new("GLuint[1]")
		OpenGL.Library.glGenTextures(1, Space.Cameras[1].Texture);
		OpenGL.Library.glGenRenderbuffers(1, Space.Cameras[1].DBO)
	  OpenGL.Library.glBindTexture(OpenGL.Library.GL_TEXTURE_2D, Space.Cameras[1].Texture[0]);
		OpenGL.Library.glTexImage2D(OpenGL.Library.GL_TEXTURE_2D, 0, OpenGL.Library.GL_RGB, Space.Cameras[1].VerticalResolution, Space.Cameras[1].HorizontalResolution, 0, OpenGL.Library.GL_RGB, OpenGL.Library.GL_UNSIGNED_BYTE, nil)
		OpenGL.Library.glBindRenderbuffer(OpenGL.Library.GL_RENDERBUFFER, Space.Cameras[1].DBO[0])
		OpenGL.Library.glRenderbufferStorage(OpenGL.Library.GL_RENDERBUFFER, OpenGL.Library.GL_DEPTH_COMPONENT, Space.Cameras[1].VerticalResolution, Space.Cameras[1].HorizontalResolution)
		OpenGL.Library.glBindRenderbuffer(OpenGL.Library.GL_RENDERBUFFER, 0)
	else
    for ak=1,#Cameras do
      local av = Cameras[ak]
      Space.Cameras[ak] = Camera.Library.Create(av, CameraGive)
			Space.Cameras[ak].ViewMatrixCalc = true
			Space.Cameras[ak].ProjectionMatrixCalc = true
			Space.Cameras[ak].Texture = ffi.Library.new("GLuint[1]")
			Space.Cameras[ak].DBO = ffi.Library.new("GLuint[1]")
			OpenGL.Library.glGenTextures(1, Space.Cameras[ak].Texture);
			OpenGL.Library.glGenRenderbuffers(1, Space.Cameras[ak].DBO)
			OpenGL.Library.glBindTexture(OpenGL.Library.GL_TEXTURE_2D, Space.Cameras[ak].Texture[0]);
			OpenGL.Library.glTexImage2D(OpenGL.Library.GL_TEXTURE_2D, 0, OpenGL.Library.GL_RGB, Space.Cameras[ak].VerticalResolution, Space.Cameras[ak].HorizontalResolution, 0, OpenGL.Library.GL_RGB, OpenGL.Library.GL_UNSIGNED_BYTE, nil)
			OpenGL.Library.glBindRenderbuffer(OpenGL.Library.GL_RENDERBUFFER, Space.Cameras[ak].DBO[0])
			OpenGL.Library.glRenderbufferStorage(OpenGL.Library.GL_RENDERBUFFER, OpenGL.Library.GL_DEPTH_COMPONENT, Space.Cameras[ak].VerticalResolution, Space.Cameras[ak].HorizontalResolution)
			OpenGL.Library.glBindRenderbuffer(OpenGL.Library.GL_RENDERBUFFER, 0)
    end
	end
	--OpenGL.Library.glClearColor(0, 0, 0.4, 0)
	OpenGL.Library.glEnable(OpenGL.Library.GL_DEPTH_TEST)
	OpenGL.Library.glDepthFunc(OpenGL.Library.GL_LESS)
  Space.LastCamera = 0
	print("AllCameras Started")
end
function GiveBack.Stop(Arguments)
  local Space = Arguments[1]
  for ak,av in pairs(Space) do
    Space[ak] = nil
  end
	print("AllCameras Stopped")
end
function GiveBack.RenderAllCameras(Arguments)
  local Space, OpenGL, AllDevices, AllDevicesGive, lgsl, General = Arguments[1], Arguments[8], Arguments[10], Arguments[11], Arguments[12], Arguments[14]
  for ak=1,#Space.Cameras do
    local av = Space.Cameras[ak]
    if av.FollowDevice and AllDevicesGive[1].Devices[av.FollowDevice] and AllDevicesGive[1].Devices[av.FollowDevice].Objects[av.FollowObject] then
      local FollowObject = AllDevicesGive[1].Devices[av.FollowDevice].Objects[av.FollowObject]
      av.Direction = {FollowObject.Transformated.data[(av.FollowPoint-1) * 4], FollowObject.Transformated.data[(av.FollowPoint-1) * 4 + 1], FollowObject.Transformated.data[(av.FollowPoint-1) * 4 + 2]}
      local Translationv = {FollowObject.Points.data[(av.FollowPoint-1) * 4], FollowObject.Points.data[(av.FollowPoint-1) * 4 + 1], FollowObject.Points.data[(av.FollowPoint-1) * 4 + 2]}
      local Length = av.FollowDistance/General.Library.VectorLength(Translationv)
      local Center = FollowObject.Translation
      local PointUp = {FollowObject.Transformated.data[(av.FollowPointUpVector-1) * 4], FollowObject.Transformated.data[(av.FollowPointUpVector-1) * 4 + 1], FollowObject.Transformated.data[(av.FollowPointUpVector-1) * 4 + 2]}
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
    OpenGL.Library.glFramebufferRenderbuffer(OpenGL.Library.GL_FRAMEBUFFER, OpenGL.Library.GL_DEPTH_ATTACHMENT, OpenGL.Library.GL_RENDERBUFFER, av.DBO[0])
    OpenGL.Library.glBindFramebuffer(OpenGL.Library.GL_FRAMEBUFFER, Space.FBO[0])
    OpenGL.Library.glFramebufferTexture(OpenGL.Library.GL_FRAMEBUFFER, OpenGL.Library.GL_COLOR_ATTACHMENT0, av.Texture[0], 0)
    OpenGL.Library.glClear(bit.bor(OpenGL.Library.GL_COLOR_BUFFER_BIT, OpenGL.Library.GL_DEPTH_BUFFER_BIT))
    if Space.LastCamera ~= ak then
      OpenGL.Library.glViewport(0,0,Space.Cameras[ak].HorizontalResolution,Space.Cameras[ak].VerticalResolution)
    end
    Space.LastCamera = ak
    AllDevices.Library.RenderAllDevices(av, AllDevicesGive)
  end
end
GiveBack.Requirements = {"JSON", "Camera", "ffi", "OpenGL", "AllDevices", "lgsl", "General"}
return GiveBack
