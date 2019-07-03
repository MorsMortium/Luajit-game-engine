local GiveBack = {}

--Adds one Camera to the Game
function GiveBack.Add(CameraData, Arguments)
  local Space, Camera, CameraGive, ffi, OpenGL, SDL = Arguments[1],
  Arguments[2], Arguments[3], Arguments[4], Arguments[6], Arguments[8]
  local NewCamera = Camera.Library.Create(CameraData, CameraGive)
  if NewCamera.Type == "OpenGL" then
    NewCamera.Texture = ffi.Library.new("GLuint[1]")
    NewCamera.DBO = ffi.Library.new("GLuint[1]")
    OpenGL.Library.glGenTextures(1, NewCamera.Texture)
    OpenGL.Library.glGenRenderbuffers(1, NewCamera.DBO)
    OpenGL.Library.glBindTexture(OpenGL.Library.GL_TEXTURE_2D, NewCamera.Texture[0])
    OpenGL.Library.glTexImage2D(OpenGL.Library.GL_TEXTURE_2D, 0,
    OpenGL.Library.GL_RGB, NewCamera.HorizontalResolution,
    NewCamera.VerticalResolution, 0, OpenGL.Library.GL_RGB,
    OpenGL.Library.GL_UNSIGNED_BYTE, nil)
    OpenGL.Library.glBindRenderbuffer(OpenGL.Library.GL_RENDERBUFFER, NewCamera.DBO[0])
    OpenGL.Library.glRenderbufferStorage(OpenGL.Library.GL_RENDERBUFFER,
    OpenGL.Library.GL_DEPTH_COMPONENT, NewCamera.HorizontalResolution,
    NewCamera.VerticalResolution)
    OpenGL.Library.glBindRenderbuffer(OpenGL.Library.GL_RENDERBUFFER, 0)
    Space.OpenGLCameras[#Space.OpenGLCameras + 1] = NewCamera
  elseif NewCamera.Type == "Software" then
    NewCamera.Surface =
    SDL.Library.createRGBSurface(0, NewCamera.HorizontalResolution,
    NewCamera.VerticalResolution, 32, 0, 0, 0, 0)
    Space.SoftwareCameras[#Space.SoftwareCameras + 1] = NewCamera
  end
end

--Adds every starting Camera to the Game
function GiveBack.Start(Configurations, Arguments)
  local Space, Camera, CameraGive, ffi, OpenGL, SDL = Arguments[1],
  Arguments[2], Arguments[3], Arguments[4], Arguments[6], Arguments[8]
	local Cameras = Configurations
	Space.VAO = ffi.Library.new("GLuint[1]")
	Space.VBO = ffi.Library.new("GLuint[1]")
  Space.RDBO = ffi.Library.new("GLuint[1]") --Render Data Buffer Object
	Space.EBO = ffi.Library.new("GLuint[1]")
	Space.FBO = ffi.Library.new("GLuint[1]")
	OpenGL.Library.glGenVertexArrays(1, Space.VAO)
	OpenGL.Library.glGenBuffers(1, Space.VBO)
  OpenGL.Library.glGenBuffers(1, Space.RDBO)
	OpenGL.Library.glGenBuffers(1, Space.EBO)
	OpenGL.Library.glGenFramebuffers(1, Space.FBO)
	OpenGL.Library.glBindFramebuffer(OpenGL.Library.GL_FRAMEBUFFER, Space.FBO[0])
	OpenGL.Library.glBindVertexArray(Space.VAO[0])
	OpenGL.Library.glBindBuffer(OpenGL.Library.GL_ELEMENT_ARRAY_BUFFER, Space.EBO[0])
  Space.OpenGLCameras = {}
  Space.SoftwareCameras = {}
  if type(Cameras) ~= "table" then
    GiveBack.Add(nil, Arguments)
  else
    for ak=1,#Cameras do
      local av = Cameras[ak]
      GiveBack.Add(av, Arguments)
    end
  end
	print("AllCameras Started")
end

--Deletes every Camera
function GiveBack.Stop(Arguments)
  local Space, OpenGL, SDL = Arguments[1], Arguments[6], Arguments[8]
  for ak=1,#Space.OpenGLCameras do
    OpenGL.Library.glDeleteRenderbuffers(1, Space.OpenGLCameras[ak].DBO)
    OpenGL.Library.glDeleteTextures(1, Space.OpenGLCameras[ak].Texture)
  end
  for ak=1,#Space.SoftwareCameras do
    SDL.Library.freeSurface(Space.SoftwareCameras[ak].Surface)
  end
  for ak,av in pairs(Space) do
    Space[ak] = nil
  end
	print("AllCameras Stopped")
end

--Deletes one Camera
function GiveBack.Remove(Number, Type, Arguments)
  local Space, OpenGL, SDL = Arguments[1], Arguments[6], Arguments[8]
  if Type == "OpenGL" then
    local Index = #Space.OpenGLCameras
    if type(Number) == "number" and Number < Index then
      Index = Number
    end
    OpenGL.Library.glDeleteRenderbuffers(1, Space.OpenGLCameras[Index].DBO)
    OpenGL.Library.glDeleteTextures(1, Space.OpenGLCameras[Index].Texture)
    table.remove(Space.OpenGLCameras, Index)
  else
    local Index = #Space.SoftwareCameras
    if type(Number) == "number" and Number < Index then
      Index = Number
    end
    SDL.Library.freeSurface(Space.SoftwareCameras[Index].Surface)
    table.remove(Space.SoftwareCameras, Index)
  end
end
GiveBack.Requirements =
{"Camera", "ffi", "OpenGL", "SDL"}
return GiveBack
