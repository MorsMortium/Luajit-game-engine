local GiveBack = {}

--Inits the OpenGL system, and glew, if needed.
--Creates a dummy window, sets OpenGL version, and
--Creates an OpenGL context
function GiveBack.Start(Configurations, Arguments)
	local Space, SDL, SDLInit, OpenGL = Arguments[1], Arguments[2],
	Arguments[4], Arguments[6]
	local SDL = SDL.Library
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
		local Error = OpenGL.Library.glewInit()
		if (OpenGL.Library.GLEW_OK ~= Error) then
			Space.glew = false
			error(Error)
		else
			Space.glew = true
		end
	else
		Space.glew = false
	end
	OpenGL.Library.glEnable(OpenGL.Library.GL_DEPTH_TEST)
	io.write("openglinit Started\n")
end

--Destroys the dummy window
function GiveBack.DeleteDummyWindow(Arguments)
	local Space, SDL = Arguments[1], Arguments[2]
	local SDL = SDL.Library
	if Space.DummyWindow then
		SDL.destroyWindow(Space.DummyWindow)
		Space.DummyWindow = nil
	end
end

--Destroys the dummy window if needed and the context
function GiveBack.Stop(Arguments)
	local Space, SDL = Arguments[1], Arguments[2]
	local SDL = SDL.Library
	GiveBack.DeleteDummyWindow(Arguments)
	SDL.GL_DeleteContext(Space.Context)
	io.write("openglinit Stopped\n")
end
GiveBack.Requirements = {"SDL", "SDLInit", "OpenGL"}
return GiveBack
