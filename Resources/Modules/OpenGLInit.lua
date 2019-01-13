local GiveBack = {}
function GiveBack.Start(Space, JSON, JSONGive, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, Window, WindowGive, ffi, ffiGive)
	Space.OpenGLData = JSON.Library:DecodeFromFile("./Resources/Configurations/OpenGLData.json")
	Space.DummyWindow = Window.Library.Create({OpenGLWindow = true}, unpack(WindowGive))
	if type(Space.OpenGLData) == "table" then
		if type(Space.OpenGLData.OpenGLVersion) == "table" and type(Space.OpenGLData.OpenGLVersion.Minor) == "number" and type(Space.OpenGLData.OpenGLVersion.Major) == "number" then
			SDL.Library.GL_SetAttribute(SDL.Library.GL_CONTEXT_MAJOR_VERSION,Space.OpenGLData.OpenGLVersion.Major)
			SDL.Library.GL_SetAttribute(SDL.Library.GL_CONTEXT_MINOR_VERSION,Space.OpenGLData.OpenGLVersion.Minor)
		end
	end
	Space.Context = SDL.Library.GL_CreateContext(Space.DummyWindow.WindowID)
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
function GiveBack.DeleteDummyWindow(Space, JSON, JSONGive, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, Window, WindowGive, ffi, ffiGive)
	if Space.DummyWindow then
		Window.Library.Destroy(Space.DummyWindow.WindowID, unpack(WindowGive))
	end
end
function GiveBack.Stop(Space, JSON, JSONGive, SDL, SDLGive, SDLInit, SDLInitGive, OpenGL, OpenGLGive, Window, WindowGive, ffi, ffiGive)
	SDL.Library.GL_DeleteContext(Space.Context)
	print("openglinit Stopped")
end
GiveBack.Requirements = {"JSON", "SDL", "SDLInit", "OpenGL", "Window", "ffi"}
return GiveBack
