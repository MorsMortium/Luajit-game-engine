local GiveBack = {}
GiveBack.WindowRenders = {}
GiveBack.WindowRenders.Default = {}
GiveBack.WindowRenders.Default.OpenGL = false
function GiveBack.WindowRenders.Default.Start(Space, BigSpace, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
end
function GiveBack.WindowRenders.Default.Stop(Space, BigSpace, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
end
function GiveBack.WindowRenders.Default.Render(WindowObject, Space, BigSpace, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
	SDL.Library.setRenderDrawColor(WindowObject.Renderer, 0, 0, 0, 255)
	SDL.Library.renderClear(WindowObject.Renderer)
end
GiveBack.WindowRenders.DefaultOpenGL = {}
GiveBack.WindowRenders.DefaultOpenGL.OpenGL = true
function GiveBack.WindowRenders.DefaultOpenGL.Start(Space, BigSpace, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
end
function GiveBack.WindowRenders.DefaultOpenGL.Stop(Space, BigSpace, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
end
function GiveBack.WindowRenders.DefaultOpenGL.Render(WindowObject, Space, BigSpace, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
	OpenGL.Library.glClearColor(0, 0, 0, 1)
	OpenGL.Library.glClear(OpenGL.Library.GL_COLOR_BUFFER_BIT)
end
GiveBack.WindowRenders.TestOpenGL = {}
GiveBack.WindowRenders.TestOpenGL.OpenGL = true
function GiveBack.WindowRenders.TestOpenGL.Start(Space, BigSpace, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
end
function GiveBack.WindowRenders.TestOpenGL.Stop(Space, BigSpace, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
end
function GiveBack.WindowRenders.TestOpenGL.Render(WindowObject, Space, BigSpace, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
	--OpenGL.Library.glBindFramebuffer(OpenGL.Library.GL_FRAMEBUFFER, AllCameras.Space.FBO[0])
	if AllCameras.Space.Cameras[1] then
		OpenGL.Library.glFramebufferTexture(OpenGL.Library.GL_FRAMEBUFFER, OpenGL.Library.GL_COLOR_ATTACHMENT0, AllCameras.Space.Cameras[1].Texture[0], 0)
		OpenGL.Library.glBindFramebuffer(OpenGL.Library.GL_DRAW_FRAMEBUFFER, 0)
		OpenGL.Library.glBlitFramebuffer(0, 0, AllCameras.Space.Cameras[1].HorizontalResolution, AllCameras.Space.Cameras[1].VerticalResolution, 0, 0, WindowObject.Width[0], WindowObject.Height[0], OpenGL.Library.GL_COLOR_BUFFER_BIT, OpenGL.Library.GL_NEAREST)
	end
end
GiveBack.WindowRenders.DefaultOpenGL = {}
GiveBack.WindowRenders.DefaultOpenGL.OpenGL = true
function GiveBack.WindowRenders.DefaultOpenGL.Start(Space, BigSpace, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
end
function GiveBack.WindowRenders.DefaultOpenGL.Stop(Space, BigSpace, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
end
function GiveBack.WindowRenders.DefaultOpenGL.Render(WindowObject, Space, BigSpace, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
	OpenGL.Library.glClearColor(0, 0, 0, 1)
	OpenGL.Library.glClear(OpenGL.Library.GL_COLOR_BUFFER_BIT)
end
GiveBack.WindowRenders.TestOpenGL2 = {}
GiveBack.WindowRenders.TestOpenGL2.OpenGL = true
function GiveBack.WindowRenders.TestOpenGL2.Start(Space, BigSpace, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
end
function GiveBack.WindowRenders.TestOpenGL2.Stop(Space, BigSpace, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
end
function GiveBack.WindowRenders.TestOpenGL2.Render(WindowObject, Space, BigSpace, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
	OpenGL.Library.glBindFramebuffer(OpenGL.Library.GL_FRAMEBUFFER, AllCameras.Space.FBO[0])
	if AllCameras.Space.Cameras[2] then
		OpenGL.Library.glFramebufferTexture(OpenGL.Library.GL_FRAMEBUFFER, OpenGL.Library.GL_COLOR_ATTACHMENT0, AllCameras.Space.Cameras[2].Texture[0], 0)
		OpenGL.Library.glBindFramebuffer(OpenGL.Library.GL_DRAW_FRAMEBUFFER, 0)
		OpenGL.Library.glBlitFramebuffer(0, 0, AllCameras.Space.Cameras[2].HorizontalResolution, AllCameras.Space.Cameras[2].VerticalResolution, 0, 0, WindowObject.Width[0], WindowObject.Height[0], OpenGL.Library.GL_COLOR_BUFFER_BIT, OpenGL.Library.GL_NEAREST)
	end
end
function GiveBack.Start(Space, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
	Space.lasttime = 0
	for k, v in pairs(GiveBack.WindowRenders) do
		if type(v.Start) == "function" and
		type(v.Stop) == "function" and
		type(v.Render) == "function" then
			v.Space = {}
			v.Start(v.Space, Space, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
		else
			GiveBack.WindowRenders[k] = nil
		end
	end
	print("WindowRender Started")
end
function GiveBack.Stop(Space, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
	for k, v in pairs(GiveBack.WindowRenders) do
		v.Stop(v.Space, Space, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, AllCameras, AllCamerasGive, ffi, ffiGive)
    v.Space = nil
	end
	print("WindowRender Stopped")
end
GiveBack.Requirements = {"SDL", "SDLInit", "OpenGL", "OpenGLInit", "AllCameras", "ffi"}
return GiveBack
