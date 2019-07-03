local GiveBack = {}

--Different Window rendering scripts are stored here
GiveBack.Renders = {}

--The default Window render fills the Window with a color
GiveBack.Renders.Default = {}
GiveBack.Renders.Default.Software = {}
function GiveBack.Renders.Default.Software.Render(WindowObject, Space, Arguments)
	local SDL = Arguments[2]
	local SDL = SDL.Library
	SDL.setRenderDrawColor(WindowObject.Renderer, 0, 0, 255, 255)
	SDL.renderClear(WindowObject.Renderer)
end
GiveBack.Renders.Default.OpenGL = {}
function GiveBack.Renders.Default.OpenGL.Render(WindowObject, Space, Arguments)
	local OpenGL = Arguments[6]
	local OpenGL = OpenGL.Library
	OpenGL.glBindFramebuffer(OpenGL.GL_FRAMEBUFFER, 0)
	OpenGL.glClearColor(1, 0, 0, 1)
	OpenGL.glClear(OpenGL.GL_COLOR_BUFFER_BIT)
end

--The Test Window render draws the first camera onto the Window
GiveBack.Renders.Test = {}
GiveBack.Renders.Test.OpenGL = {}
function GiveBack.Renders.Test.OpenGL.Render(WindowObject, Space, Arguments)
	local OpenGL, AllCameras = Arguments[6], Arguments[10]
	local OpenGL = OpenGL.Library
	local Camera1 = AllCameras.Space.OpenGLCameras[1]
	if Camera1 then
		OpenGL.glFramebufferTexture(OpenGL.GL_FRAMEBUFFER,
		OpenGL.GL_COLOR_ATTACHMENT0, Camera1.Texture[0], 0)
		OpenGL.glBindFramebuffer(OpenGL.GL_DRAW_FRAMEBUFFER, 0)
		OpenGL.glBlitFramebuffer(0, 0, Camera1.HorizontalResolution,
		Camera1.VerticalResolution, 0, 0, WindowObject.Width[0],
		WindowObject.Height[0], OpenGL.GL_COLOR_BUFFER_BIT, OpenGL.GL_NEAREST)
	end
end
GiveBack.Renders.Test.Software = {}
function GiveBack.Renders.Test.Software.Render(WindowObject, Space, Arguments)
	local SDL, AllCameras = Arguments[2], Arguments[10]
	local SDL = SDL.Library
	local Camera1 = AllCameras.Space.SoftwareCameras[1]
	if Camera1 then
		local WindowSurface = SDL.getWindowSurface(WindowObject.WindowID)
		SDL.upperBlitScaled(Camera1.Surface, nil, WindowSurface, nil)
	end
end

--Check whether every renderer has both software and OpenGL counterpart.
--If it has, then it creates a space for it, that is persistent
--If not, it deletes it
function GiveBack.Start(Configurations, Arguments)
	local Space = Arguments[1]
	Space.lasttime = 0
	for ak, av in pairs(GiveBack.Renders) do
		if type(av.Software.Render) == "function" and
		type(av.OpenGL.Render) == "function" then
			av.Space = {}
		else
			GiveBack.Renders[ak] = nil
		end
	end
	print("WindowRender Started")
end

--Deletes the space it allocated for the renderers
function GiveBack.Stop(Arguments)
	local Space = Arguments[1]
	for ak, av in pairs(GiveBack.Renders) do
    av.Space = nil
	end
	print("WindowRender Stopped")
end
GiveBack.Requirements = {"SDL", "SDLInit", "OpenGL", "OpenGLInit", "AllCameras"}
return GiveBack
