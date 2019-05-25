local GiveBack = {}
GiveBack.WindowRenders = {}
GiveBack.WindowRenders.Default = {}
GiveBack.WindowRenders.Default.Software = {}
function GiveBack.WindowRenders.Default.Software.Start(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
end
function GiveBack.WindowRenders.Default.Software.Stop(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
end
function GiveBack.WindowRenders.Default.Software.Render(WindowObject, Space, Arguments)
	local BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10], Arguments[12]
	SDL.Library.setRenderDrawColor(WindowObject.Renderer, 0, 0, 255, 255)
	SDL.Library.renderClear(WindowObject.Renderer)
end
GiveBack.WindowRenders.Default.OpenGL = {}
function GiveBack.WindowRenders.Default.OpenGL.Start(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
end
function GiveBack.WindowRenders.Default.OpenGL.Stop(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
end
function GiveBack.WindowRenders.Default.OpenGL.Render(WindowObject, Space, Arguments)
	local BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10], Arguments[12]
	OpenGL.Library.glBindFramebuffer(OpenGL.Library.GL_FRAMEBUFFER, 0)
	OpenGL.Library.glClearColor(1, 0, 0, 1)
	OpenGL.Library.glClear(OpenGL.Library.GL_COLOR_BUFFER_BIT)
end
GiveBack.WindowRenders.Test = {}
GiveBack.WindowRenders.Test.OpenGL = {}
function GiveBack.WindowRenders.Test.OpenGL.Start(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
end
function GiveBack.WindowRenders.Test.OpenGL.Stop(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
end
function GiveBack.WindowRenders.Test.OpenGL.Render(WindowObject, Space, Arguments)
	local OpenGL, AllCameras = Arguments[6], Arguments[10]
	local Camera1 = AllCameras.Space.OpenGLCameras[1]
	if Camera1 then
		OpenGL.Library.glFramebufferTexture(OpenGL.Library.GL_FRAMEBUFFER, OpenGL.Library.GL_COLOR_ATTACHMENT0, Camera1.Texture[0], 0)
		OpenGL.Library.glBindFramebuffer(OpenGL.Library.GL_DRAW_FRAMEBUFFER, 0)
		OpenGL.Library.glBlitFramebuffer(0, 0, Camera1.HorizontalResolution, Camera1.VerticalResolution, 0, 0, WindowObject.Width[0], WindowObject.Height[0], OpenGL.Library.GL_COLOR_BUFFER_BIT, OpenGL.Library.GL_NEAREST)
	end
end
GiveBack.WindowRenders.Test.Software = {}
function GiveBack.WindowRenders.Test.Software.Start(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
end
function GiveBack.WindowRenders.Test.Software.Stop(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
end
function GiveBack.WindowRenders.Test.Software.Render(WindowObject, Space, Arguments)
	local BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10], Arguments[12]
	local Camera1 = AllCameras.Space.SoftwareCameras[1]
	if Camera1 then
		local WindowSurface = SDL.Library.getWindowSurface(WindowObject.WindowID)
		SDL.Library.upperBlitScaled(Camera1.Surface, nil, WindowSurface, nil)
	end
end
function GiveBack.Start(Arguments)
	local Space, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10], Arguments[12]
	Space.lasttime = 0
	for ak, av in pairs(GiveBack.WindowRenders) do
		if type(av.Software.Start) == "function" and
			type(av.Software.Stop) == "function" and
			type(av.Software.Render) == "function" and
			type(av.OpenGL.Start) == "function" and
			type(av.OpenGL.Stop) == "function" and
			type(av.OpenGL.Render) == "function" then
			av.Space = {}
			av.Software.Start(av.Space, Space, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
			av.OpenGL.Start(av.Space, Space, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
		else
			GiveBack.WindowRenders[ak] = nil
		end
	end
	print("WindowRender Started")
end
function GiveBack.Stop(Arguments)
	local Space, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10], Arguments[12]
	for ak, av in pairs(GiveBack.WindowRenders) do
		av.Software.Stop(av.Space, Space, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
		av.OpenGL.Stop(av.Space, Space, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras, ffi)
    av.Space = nil
	end
	print("WindowRender Stopped")
end
GiveBack.Requirements = {"SDL", "SDLInit", "OpenGL", "OpenGLInit", "AllCameras", "ffi"}
return GiveBack
