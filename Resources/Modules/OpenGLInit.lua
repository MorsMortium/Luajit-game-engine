return function(args)
	local Space, SDL, SDLInit, OpenGL = args[1], args[2], args[3], args[4]
	local SDL, OpenGL = SDL.Library, OpenGL.Library
	local GiveBack = {}

	function GiveBack.Reload(args)
		Space, SDL, SDLInit, OpenGL = args[1], args[2], args[3], args[4]
		SDL, OpenGL = SDL.Library, OpenGL.Library
  end

	--Inits the OpenGL system, and glew, if needed.
	--Creates a dummy window, sets OpenGL version, and
	--Creates an OpenGL context
	function GiveBack.Start(Configurations)
		Space.OpenGLData = Configurations
		Space.DummyWindow = SDL.createWindow("", SDL.WINDOWPOS_UNDEFINED,
		SDL.WINDOWPOS_UNDEFINED, 64, 64, bit.bor(SDL.WINDOW_OPENGL, SDL.WINDOW_HIDDEN))
		if type(Space.OpenGLData) == "table" then
			if type(Space.OpenGLData.OpenGLVersion) == "table" and
			type(Space.OpenGLData.OpenGLVersion.Minor) == "number" and
			type(Space.OpenGLData.OpenGLVersion.Major) == "number" then
				SDL.GL_SetAttribute(SDL.GL_CONTEXT_MAJOR_VERSION,
				Space.OpenGLData.OpenGLVersion.Major)
				SDL.GL_SetAttribute(SDL.GL_CONTEXT_MINOR_VERSION,
				Space.OpenGLData.OpenGLVersion.Minor)
			end
		end
		Space.Context = SDL.GL_CreateContext(Space.DummyWindow)
		--SDL.GL_SetSwapInterval(1)
		if not Space.Context then
			Space.OpenGL = false
		else
			Space.OpenGL = true
		end
		if Space.OpenGLData.glew then
			local Error = OpenGL.glewInit()
			if (OpenGL.GLEW_OK ~= Error) then
				Space.glew = false
				error(Error)
			else
				Space.glew = true
			end
		else
			Space.glew = false
		end
		OpenGL.glEnable(OpenGL.GL_DEPTH_TEST)
	end

	--Destroys the dummy window
	function GiveBack.DeleteDummyWindow()
		if Space.DummyWindow then
			SDL.destroyWindow(Space.DummyWindow)
			Space.DummyWindow = nil
		end
	end

	--Destroys the dummy window if needed and the context
	function GiveBack.Stop()
		GiveBack.DeleteDummyWindow()
		SDL.GL_DeleteContext(Space.Context)
	end
	return GiveBack
end
