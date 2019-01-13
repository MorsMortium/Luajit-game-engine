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
  local Z = gsl.gsl_vector_calloc(3)
  for i=1,3 do
    Z.data[i - 1] = Translation[i]-Direction[i]
  end
  gsl.gsl_vector_scale(Z, 1 / gsl.gsl_blas_dnrm2(Z))
  local X = gsl.gsl_vector_calloc(3)
  General.Library.CrossProduct(UpVector, Z, X)
  gsl.gsl_vector_scale(X, 1 / gsl.gsl_blas_dnrm2(X))
  local Y = gsl.gsl_vector_calloc(3)
  General.Library.CrossProduct(Z, X, Y)
  local ResultMatrix = lgsl.Library.matrix.def{
    {X.data[0], Y.data[0], Z.data[0], 0},
    {X.data[1], Y.data[1], Z.data[1], 0},
    {X.data[2], Y.data[2], Z.data[2], 0},
    {-General.Library.DotProduct(X, Translation), -General.Library.DotProduct(Y, Translation), -General.Library.DotProduct(Z, Translation), 1}}
  gsl.gsl_vector_free(X)
  gsl.gsl_vector_free(Y)
  gsl.gsl_vector_free(Z)
  gsl.gsl_matrix_transpose(ResultMatrix)
	return ResultMatrix
end
function GiveBack.Start(Space, AllObjectRenders, AllObjectRendersGive, JSON, JSONGive, Camera, CameraGive, ffi, ffiGive, OpenGL, OpenGLGive, AllDevices, AllDevicesGive, lgsl, lgslGive, General, GeneralGive)
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
		Space.Cameras[1] = Camera.Library.Create(nil, unpack(CameraGive))
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
		for k, v in pairs(Cameras) do
			Space.Cameras[k] = Camera.Library.Create(v, unpack(CameraGive))
			Space.Cameras[k].ViewMatrixCalc = true
			Space.Cameras[k].ProjectionMatrixCalc = true
			Space.Cameras[k].Texture = ffi.Library.new("GLuint[1]")
			Space.Cameras[k].DBO = ffi.Library.new("GLuint[1]")
			OpenGL.Library.glGenTextures(1, Space.Cameras[k].Texture);
			OpenGL.Library.glGenRenderbuffers(1, Space.Cameras[k].DBO)
			OpenGL.Library.glBindTexture(OpenGL.Library.GL_TEXTURE_2D, Space.Cameras[k].Texture[0]);
			OpenGL.Library.glTexImage2D(OpenGL.Library.GL_TEXTURE_2D, 0, OpenGL.Library.GL_RGB, Space.Cameras[k].VerticalResolution, Space.Cameras[k].HorizontalResolution, 0, OpenGL.Library.GL_RGB, OpenGL.Library.GL_UNSIGNED_BYTE, nil)
			OpenGL.Library.glBindRenderbuffer(OpenGL.Library.GL_RENDERBUFFER, Space.Cameras[k].DBO[0])
			OpenGL.Library.glRenderbufferStorage(OpenGL.Library.GL_RENDERBUFFER, OpenGL.Library.GL_DEPTH_COMPONENT, Space.Cameras[k].VerticalResolution, Space.Cameras[k].HorizontalResolution)
			OpenGL.Library.glBindRenderbuffer(OpenGL.Library.GL_RENDERBUFFER, 0)
		end
	end
	--OpenGL.Library.glClearColor(0, 0, 0.4, 0)
	OpenGL.Library.glEnable(OpenGL.Library.GL_DEPTH_TEST)
	OpenGL.Library.glDepthFunc(OpenGL.Library.GL_LESS)
	print("AllCameras Started")
end
function GiveBack.Stop(Space)
	for k,v in pairs(Space.Cameras) do
		Space.Cameras[k] = nil
	end
	print("AllCameras Stopped")
end
function GiveBack.RenderAllCameras(Space, AllObjectRenders, AllObjectRendersGive, JSON, JSONGive, Camera, CameraGive, ffi, ffiGive, OpenGL, OpenGLGive, AllDevices, AllDevicesGive, lgsl, lgslGive, General, GeneralGive)
	for k, v in pairs(Space.Cameras) do
    if v.FollowDevice and AllDevicesGive[1].Devices[v.FollowDevice] and AllDevicesGive[1].Devices[v.FollowDevice].Objects[v.FollowObject] then
      local FollowObject = AllDevicesGive[1].Devices[v.FollowDevice].Objects[v.FollowObject]
      v.Direction = {FollowObject.Transformated.data[(v.FollowPoint-1) * 4], FollowObject.Transformated.data[(v.FollowPoint-1) * 4 + 1], FollowObject.Transformated.data[(v.FollowPoint-1) * 4 + 2]}
      local Translationv = {FollowObject.Points.data[(v.FollowPoint-1) * 4], FollowObject.Points.data[(v.FollowPoint-1) * 4 + 1], FollowObject.Points.data[(v.FollowPoint-1) * 4 + 2]}
      local Length = v.FollowDistance/General.Library.VectorLength(Translationv)
      local Center = {FollowObject.Translation[0], FollowObject.Translation[1], FollowObject.Translation[2]}
      local PointUp = {FollowObject.Transformated.data[(v.FollowPointUpVector-1) * 4], FollowObject.Transformated.data[(v.FollowPointUpVector-1) * 4 + 1], FollowObject.Transformated.data[(v.FollowPointUpVector-1) * 4 + 2]}
      local CenterToPoint = General.Library.PointAToB(Center, v.Direction)
      local CenterToPointUp = General.Library.PointAToB(Center, PointUp)
      for i=1,3 do
        v.Translation[i] = v.Direction[i] + CenterToPoint[i] * Length
        v.UpVector.data[i - 1] = CenterToPointUp[i]
      end
      v.ViewMatrixCalc = true
    end
		if v.ViewMatrixCalc then
			Space.Cameras[k].ViewMatrix = ViewMatrix(v.Translation, v.Direction, v.UpVector, lgsl, General)
		end
		if v.ProjectionMatrixCalc then
			Space.Cameras[k].ProjectionMatrix = ProjectionMatrix(v.FieldOfView, v.HorizontalResolution/v.VerticalResolution, v.MinimumDistance, v.MaximumDistance, lgsl)
		end
		if v.ViewMatrixCalc or v.ProjectionMatrixCalc then
			Space.Cameras[k].ViewProjectionMatrix = Space.Cameras[k].ProjectionMatrix * Space.Cameras[k].ViewMatrix
			v.ViewMatrixCalc = false
			v.ProjectionMatrixCalc = false
		end
		OpenGL.Library.glFramebufferRenderbuffer(OpenGL.Library.GL_FRAMEBUFFER, OpenGL.Library.GL_DEPTH_ATTACHMENT, OpenGL.Library.GL_RENDERBUFFER, v.DBO[0])
		OpenGL.Library.glBindFramebuffer(OpenGL.Library.GL_FRAMEBUFFER, Space.FBO[0])
		OpenGL.Library.glFramebufferTexture(OpenGL.Library.GL_FRAMEBUFFER, OpenGL.Library.GL_COLOR_ATTACHMENT0, v.Texture[0], 0)
		OpenGL.Library.glClear(bit.bor(OpenGL.Library.GL_COLOR_BUFFER_BIT, OpenGL.Library.GL_DEPTH_BUFFER_BIT))
		OpenGL.Library.glViewport(0,0,v.HorizontalResolution,v.VerticalResolution)
		AllDevices.Library.RenderAllDevices(v, unpack(AllDevicesGive))
	end
end
GiveBack.Requirements = {"AllObjectRenders", "JSON", "Camera", "ffi", "OpenGL", "AllDevices", "lgsl", "General"}
return GiveBack
