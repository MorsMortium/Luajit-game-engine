local GiveBack = {}
function GiveBack.Start(Arguments)
  local Space, JSON, Camera, CameraGive, ffi, OpenGL, SDL = Arguments[1], Arguments[2], Arguments[4], Arguments[5], Arguments[6], Arguments[8], Arguments[16]
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
  Space.OpenGLCameras = {}
  Space.SoftwareCameras = {}
  if type(Cameras) ~= "table" then
    local CameraObject = Camera.Library.Create(nil, CameraGive)
    CameraObject.Surface = SDL.Library.createRGBSurface(0, CameraObject.HorizontalResolution, CameraObject.VerticalResolution, 32, 0, 0, 0, 0)
    Space.SoftwareCameras[#Space.SoftwareCameras + 1] = CameraObject
  else
    for ak=1,#Cameras do
      local av = Cameras[ak]
      local CameraObject = Camera.Library.Create(av, CameraGive)
      if CameraObject.Type == "OpenGL" then
        CameraObject.Texture = ffi.Library.new("GLuint[1]")
        CameraObject.DBO = ffi.Library.new("GLuint[1]")
        OpenGL.Library.glGenTextures(1, CameraObject.Texture);
        OpenGL.Library.glGenRenderbuffers(1, CameraObject.DBO)
        OpenGL.Library.glBindTexture(OpenGL.Library.GL_TEXTURE_2D, CameraObject.Texture[0]);
        OpenGL.Library.glTexImage2D(OpenGL.Library.GL_TEXTURE_2D, 0, OpenGL.Library.GL_RGB, CameraObject.VerticalResolution, CameraObject.HorizontalResolution, 0, OpenGL.Library.GL_RGB, OpenGL.Library.GL_UNSIGNED_BYTE, nil)
        OpenGL.Library.glBindRenderbuffer(OpenGL.Library.GL_RENDERBUFFER, CameraObject.DBO[0])
        OpenGL.Library.glRenderbufferStorage(OpenGL.Library.GL_RENDERBUFFER, OpenGL.Library.GL_DEPTH_COMPONENT, CameraObject.VerticalResolution, CameraObject.HorizontalResolution)
        OpenGL.Library.glBindRenderbuffer(OpenGL.Library.GL_RENDERBUFFER, 0)
        Space.OpenGLCameras[#Space.OpenGLCameras + 1] = CameraObject
      elseif CameraObject.Type == "Software" then
        CameraObject.Surface = SDL.Library.createRGBSurface(0, CameraObject.HorizontalResolution, CameraObject.VerticalResolution, 32, 0, 0, 0, 0)
        Space.SoftwareCameras[#Space.SoftwareCameras + 1] = CameraObject
      end
    end
  end
	OpenGL.Library.glEnable(OpenGL.Library.GL_DEPTH_TEST)
	OpenGL.Library.glDepthFunc(OpenGL.Library.GL_LESS)
	print("AllCameras Started")
end
function GiveBack.Stop(Arguments)
  local Space, OpenGL, SDL = Arguments[1], Arguments[8], Arguments[16]
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
GiveBack.Requirements = {"JSON", "Camera", "ffi", "OpenGL", "AllDevices", "lgsl", "General", "SDL", "CameraRender"}
return GiveBack
