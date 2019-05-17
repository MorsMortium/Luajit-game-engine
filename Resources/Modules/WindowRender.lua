local GiveBack = {}
GiveBack.WindowRenders = {}
GiveBack.WindowRenders.Default = {}
GiveBack.WindowRenders.Default.OpenGL = false
function GiveBack.WindowRenders.Default.Start(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
end
function GiveBack.WindowRenders.Default.Stop(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
end
function GiveBack.WindowRenders.Default.Render(WindowObject, Space, Arguments)
	local BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10], Arguments[12]
	SDL.Library.setRenderDrawColor(WindowObject.Renderer, 0, 0, 0, 255)
	SDL.Library.renderClear(WindowObject.Renderer)
end
GiveBack.WindowRenders.DefaultOpenGL = {}
GiveBack.WindowRenders.DefaultOpenGL.OpenGL = true
function GiveBack.WindowRenders.DefaultOpenGL.Start(Space, Arguments)
end
function GiveBack.WindowRenders.DefaultOpenGL.Stop(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
end
function GiveBack.WindowRenders.DefaultOpenGL.Render(WindowObject, Space, Arguments)
	local BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10], Arguments[12]
	OpenGL.Library.glClearColor(0, 0, 0, 1)
	OpenGL.Library.glClear(OpenGL.Library.GL_COLOR_BUFFER_BIT)
end
GiveBack.WindowRenders.TestOpenGL = {}
GiveBack.WindowRenders.TestOpenGL.OpenGL = true
function GiveBack.WindowRenders.TestOpenGL.Start(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
end
function GiveBack.WindowRenders.TestOpenGL.Stop(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
end
function GiveBack.WindowRenders.TestOpenGL.Render(WindowObject, Space, Arguments)
	local OpenGL, AllCameras = Arguments[6], Arguments[10]
	--OpenGL.Library.glBindFramebuffer(OpenGL.Library.GL_FRAMEBUFFER, AllCameras.Space.FBO[0])
	if AllCameras.Space.Cameras[1] then
		OpenGL.Library.glFramebufferTexture(OpenGL.Library.GL_FRAMEBUFFER, OpenGL.Library.GL_COLOR_ATTACHMENT0, AllCameras.Space.Cameras[1].Texture[0], 0)
		OpenGL.Library.glBindFramebuffer(OpenGL.Library.GL_DRAW_FRAMEBUFFER, 0)
		OpenGL.Library.glBlitFramebuffer(0, 0, AllCameras.Space.Cameras[1].HorizontalResolution, AllCameras.Space.Cameras[1].VerticalResolution, 0, 0, WindowObject.Width[0], WindowObject.Height[0], OpenGL.Library.GL_COLOR_BUFFER_BIT, OpenGL.Library.GL_NEAREST)
	end
end
GiveBack.WindowRenders.DefaultOpenGL = {}
GiveBack.WindowRenders.DefaultOpenGL.OpenGL = true
function GiveBack.WindowRenders.DefaultOpenGL.Start(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
end
function GiveBack.WindowRenders.DefaultOpenGL.Stop(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
end
function GiveBack.WindowRenders.DefaultOpenGL.Render(WindowObject, Space, Arguments)
	local BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10], Arguments[12]
	OpenGL.Library.glClearColor(0, 0, 0, 1)
	OpenGL.Library.glClear(OpenGL.Library.GL_COLOR_BUFFER_BIT)
end
GiveBack.WindowRenders.TestOpenGL2 = {}
GiveBack.WindowRenders.TestOpenGL2.OpenGL = true
function GiveBack.WindowRenders.TestOpenGL2.Start(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
end
function GiveBack.WindowRenders.TestOpenGL2.Stop(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
end
function GiveBack.WindowRenders.TestOpenGL2.Render(WindowObject, Space, Arguments)
	local BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10], Arguments[12]
	OpenGL.Library.glBindFramebuffer(OpenGL.Library.GL_FRAMEBUFFER, AllCameras.Space.FBO[0])
	if AllCameras.Space.Cameras[2] then
		OpenGL.Library.glFramebufferTexture(OpenGL.Library.GL_FRAMEBUFFER, OpenGL.Library.GL_COLOR_ATTACHMENT0, AllCameras.Space.Cameras[2].Texture[0], 0)
		OpenGL.Library.glBindFramebuffer(OpenGL.Library.GL_DRAW_FRAMEBUFFER, 0)
		OpenGL.Library.glBlitFramebuffer(0, 0, AllCameras.Space.Cameras[2].HorizontalResolution, AllCameras.Space.Cameras[2].VerticalResolution, 0, 0, WindowObject.Width[0], WindowObject.Height[0], OpenGL.Library.GL_COLOR_BUFFER_BIT, OpenGL.Library.GL_NEAREST)
	end
end
function GiveBack.Start(Arguments)
	local Space, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10], Arguments[12]
	Space.lasttime = 0
	for ak, av in pairs(GiveBack.WindowRenders) do
		if type(av.Start) == "function" and
		type(av.Stop) == "function" and
		type(av.Render) == "function" then
			av.Space = {}
			av.Start(av.Space, Space, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
		else
			GiveBack.WindowRenders[ak] = nil
		end
	end
	print("WindowRender Started")
end
function GiveBack.Stop(Arguments)
	local Space, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10], Arguments[12]
	for ak, av in pairs(GiveBack.WindowRenders) do
		av.Stop(av.Space, Space, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
    av.Space = nil
	end
	print("WindowRender Stopped")
end
GiveBack.Requirements = {"SDL", "SDLInit", "OpenGL", "OpenGLInit", "AllCameras", "ffi"}
return GiveBack
