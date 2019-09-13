return function(args)
	local Space, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras = args[1], args[2], args[3], args[4], args[5], args[6]
	local OpenGL, SDL = OpenGL.Library, SDL.Library

	local GiveBack = {}

	function GiveBack.Reload(args)
		Space, SDL, SDLInit, OpenGL, OpenGLInit, AllCameras = args[1], args[2], args[3], args[4], args[5], args[6]
		OpenGL, SDL = OpenGL.Library, SDL.Library
  end

	--Different Window rendering scripts are stored here
	GiveBack.WindowRenders = {}

	--The default Window render fills the Window with a color
	GiveBack.WindowRenders.Default = {}
	GiveBack.WindowRenders.Default.Software = {}
	function GiveBack.WindowRenders.Default.Software.Render(WindowObject, Space)
		SDL.setRenderDrawColor(WindowObject.Renderer, 0, 0, 255, 255)
		SDL.renderClear(WindowObject.Renderer)
	end
	GiveBack.WindowRenders.Default.OpenGL = {}
	function GiveBack.WindowRenders.Default.OpenGL.Render(WindowObject, Space)
		OpenGL.glBindFramebuffer(OpenGL.GL_FRAMEBUFFER, 0)
		OpenGL.glClearColor(1, 0, 0, 1)
		OpenGL.glClear(OpenGL.GL_COLOR_BUFFER_BIT)
	end

	--The Test Window render draws the first camera onto the Window
	GiveBack.WindowRenders.Test = {}
	GiveBack.WindowRenders.Test.OpenGL = {}
	function GiveBack.WindowRenders.Test.OpenGL.Render(WindowObject, Space)
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
	GiveBack.WindowRenders.Test.Software = {}
	function GiveBack.WindowRenders.Test.Software.Render(WindowObject, Space)
		local Camera1 = AllCameras.Space.SoftwareCameras[1]
		if Camera1 then
			local WindowSurface = SDL.getWindowSurface(WindowObject.WindowID)
			SDL.upperBlitScaled(Camera1.Surface, nil, WindowSurface, nil)
		end
	end

	--Check whether every renderer has both software and OpenGL counterpart.
	--If it has, then it creates a space for it, that is persistent
	--If not, it deletes it
	function GiveBack.Start(Configurations)
		Space.lasttime = 0
		for ak, av in pairs(GiveBack.WindowRenders) do
			if type(av.Software.Render) == "function" and
			type(av.OpenGL.Render) == "function" then
				av.Space = {}
			else
				GiveBack.WindowRenders[ak] = nil
			end
		end
		io.write("WindowRender Started\n")
	end

	--Deletes the space it allocated for the renderers
	function GiveBack.Stop()
		for ak, av in pairs(GiveBack.WindowRenders) do
    	av.Space = nil
		end
		io.write("WindowRender Stopped\n")
	end
	return GiveBack
end
