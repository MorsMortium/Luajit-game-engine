local GiveBack = {}
function GiveBack.Start(Arguments)
	local Space, JSON, SDL, SDLInit, OpenGL, ffi = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	Space.OpenGLData = JSON.Library:DecodeFromFile("OpenGLData.json")
	Space.DummyWindow = SDL.Library.createWindow("Default", SDL.Library.WINDOWPOS_UNDEFINED, SDL.Library.WINDOWPOS_UNDEFINED, 256, 256, bit.bor(SDL.Library.WINDOW_OPENGL, SDL.Library.WINDOW_HIDDEN))

	if type(Space.OpenGLData) == "table" then
		if type(Space.OpenGLData.OpenGLVersion) == "table" and type(Space.OpenGLData.OpenGLVersion.Minor) == "number" and type(Space.OpenGLData.OpenGLVersion.Major) == "number" then
			SDL.Library.GL_SetAttribute(SDL.Library.GL_CONTEXT_MAJOR_VERSION,Space.OpenGLData.OpenGLVersion.Major)
			SDL.Library.GL_SetAttribute(SDL.Library.GL_CONTEXT_MINOR_VERSION,Space.OpenGLData.OpenGLVersion.Minor)
		end
	end
	Space.Context = SDL.Library.GL_CreateContext(Space.DummyWindow)
	--SDL.Library.GL_SetSwapInterval(1)
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
	print("openglinit Started")
end
function GiveBack.DeleteDummyWindow(Arguments)
	local Space, SDL = Arguments[1], Arguments[4]
	if Space.DummyWindow then
		SDL.Library.destroyWindow(Space.DummyWindow)
		Space.DummyWindow = nil
	end
end
function GiveBack.Stop(Arguments)
	local Space, SDL = Arguments[1], Arguments[4]
	GiveBack.DeleteDummyWindow(Arguments)
	SDL.Library.GL_DeleteContext(Space.Context)
	for ak,av in pairs(Space) do
		Space[ak] = nil
	end
	print("openglinit Stopped")
end
GiveBack.Requirements = {"JSON", "SDL", "SDLInit", "OpenGL", "ffi"}
return GiveBack
