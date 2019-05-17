local GiveBack = {}
function GiveBack.Start(Arguments)
	local Space, JSON, SDL, SDLInit, OpenGL, Window, WindowGive, ffi = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10], Arguments[11], Arguments[12]
	Space.OpenGLData = JSON.Library:DecodeFromFile("./Resources/Configurations/OpenGLData.json")
	Space.DummyWindow = Window.Library.Create({OpenGLWindow = true}, WindowGive)
	if type(Space.OpenGLData) == "table" then
		if type(Space.OpenGLData.OpenGLVersion) == "table" and type(Space.OpenGLData.OpenGLVersion.Minor) == "number" and type(Space.OpenGLData.OpenGLVersion.Major) == "number" then
			SDL.Library.GL_SetAttribute(SDL.Library.GL_CONTEXT_MAJOR_VERSION,Space.OpenGLData.OpenGLVersion.Major)
			SDL.Library.GL_SetAttribute(SDL.Library.GL_CONTEXT_MINOR_VERSION,Space.OpenGLData.OpenGLVersion.Minor)
		end
	end
	Space.Context = SDL.Library.GL_CreateContext(Space.DummyWindow.WindowID)
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
	print("openglinit Started")
end
function GiveBack.DeleteDummyWindow(Arguments)
	local Space, Window, WindowGive = Arguments[1], Arguments[10], Arguments[11]
	if Space.DummyWindow then
		Window.Library.Destroy(Space.DummyWindow.WindowID, WindowGive)
	end
end
function GiveBack.Stop(Arguments)
	local Space, SDL = Arguments[1], Arguments[4]
	SDL.Library.GL_DeleteContext(Space.Context)
	for ak,av in pairs(Space) do
		Space[ak] = nil
	end
	print("openglinit Stopped")
end
GiveBack.Requirements = {"JSON", "SDL", "SDLInit", "OpenGL", "Window", "ffi"}
return GiveBack
