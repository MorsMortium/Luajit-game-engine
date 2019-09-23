return function(args)
  local Space, Camera, CTypes, OpenGL, SDL, Globals = args[1], args[2], args[3],
  args[4], args[5], args[6]
  local OpenGL, SDL, Types, Globals = OpenGL.Library, SDL.Library,
  CTypes.Library.Types, Globals.Library.Globals
  local GLuint, remove, type = Types["GLuint[?]"].Type, Globals.remove,
  Globals.type
  local GiveBack = {}

  function GiveBack.Reload(args)
    Space, Camera, CTypes, OpenGL, SDL, Globals = args[1], args[2], args[3],
    args[4], args[5], args[6]
    OpenGL, SDL, Types, Globals = OpenGL.Library, SDL.Library,
    CTypes.Library.Types, Globals.Library.Globals
    GLuint, remove, type = Types["GLuint[?]"].Type, Globals.remove,
    Globals.type
  end

  --Adds one Camera to the Game
  function GiveBack.Add(CameraData)
    local NewCamera = Camera.Library.Create(CameraData)
    if NewCamera.Type == "OpenGL" then
      NewCamera.Texture = GLuint(1)
      NewCamera.DBO = GLuint(1)
      OpenGL.glGenTextures(1, NewCamera.Texture)
      OpenGL.glGenRenderbuffers(1, NewCamera.DBO)
      OpenGL.glBindTexture(OpenGL.GL_TEXTURE_2D, NewCamera.Texture[0])
      OpenGL.glTexImage2D(OpenGL.GL_TEXTURE_2D, 0, OpenGL.GL_RGB,
      NewCamera.HorizontalResolution, NewCamera.VerticalResolution, 0,
      OpenGL.GL_RGB, OpenGL.GL_UNSIGNED_BYTE, nil)
      OpenGL.glBindRenderbuffer(OpenGL.GL_RENDERBUFFER, NewCamera.DBO[0])
      OpenGL.glRenderbufferStorage(OpenGL.GL_RENDERBUFFER,
      OpenGL.GL_DEPTH_COMPONENT, NewCamera.HorizontalResolution,
      NewCamera.VerticalResolution)
      OpenGL.glBindRenderbuffer(OpenGL.GL_RENDERBUFFER, 0)
      Space.OpenGLCameras[#Space.OpenGLCameras + 1] = NewCamera
    elseif NewCamera.Type == "Software" then
      NewCamera.Surface =
      SDL.createRGBSurface(0, NewCamera.HorizontalResolution,
      NewCamera.VerticalResolution, 32, 0, 0, 0, 0)
      Space.SoftwareCameras[#Space.SoftwareCameras + 1] = NewCamera
    end
  end

  --Adds every starting Camera to the Game
  function GiveBack.Start(Configurations)
    Space.VAO = GLuint(1)
    Space.VBO = GLuint(1)
    Space.RDBO = GLuint(1) --Render Data Buffer Object
    Space.EBO = GLuint(1)
    Space.FBO = GLuint(1)
    OpenGL.glGenVertexArrays(1, Space.VAO)
    OpenGL.glGenBuffers(1, Space.VBO)
    OpenGL.glGenBuffers(1, Space.RDBO)
    OpenGL.glGenBuffers(1, Space.EBO)
    OpenGL.glGenFramebuffers(1, Space.FBO)
    OpenGL.glBindFramebuffer(OpenGL.GL_FRAMEBUFFER, Space.FBO[0])
    OpenGL.glBindVertexArray(Space.VAO[0])
    OpenGL.glBindBuffer(OpenGL.GL_ELEMENT_ARRAY_BUFFER, Space.EBO[0])
    Space.OpenGLCameras = {}
    Space.SoftwareCameras = {}
    if type(Configurations) ~= "table" then
      GiveBack.Add(nil)
    else
      for ak=1,#Configurations do
        local av = Configurations[ak]
        GiveBack.Add(av)
      end
    end
  end

  --Deletes every Camera
  function GiveBack.Stop()
    for ak=1,#Space.OpenGLCameras do
      local av = Space.OpenGLCameras[ak]
      OpenGL.glDeleteRenderbuffers(1, av.DBO)
      OpenGL.glDeleteTextures(1, av.Texture)
    end
    for ak=1,#Space.SoftwareCameras do
      SDL.freeSurface(Space.SoftwareCameras[ak].Surface)
    end
  end

  --Deletes one Camera
  function GiveBack.Remove(Number, Type)
    if Type == "OpenGL" then
      local Index = #Space.OpenGLCameras
      if type(Number) == "number" and Number < Index then
        Index = Number
      end
      OpenGL.glDeleteRenderbuffers(1, Space.OpenGLCameras[Index].DBO)
      OpenGL.glDeleteTextures(1, Space.OpenGLCameras[Index].Texture)
      remove(Space.OpenGLCameras, Index)
    else
      local Index = #Space.SoftwareCameras
      if type(Number) == "number" and Number < Index then
        Index = Number
      end
      SDL.freeSurface(Space.SoftwareCameras[Index].Surface)
      remove(Space.SoftwareCameras, Index)
    end
  end
  return GiveBack
end
