local GiveBack = {}
function GiveBack.Start(Space, JSON, JSONGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, SDL, SDLGive, SDLInit, SDLInitGive, Window, WindowGive, WindowRender, WindowRenderGive, General, GeneralGive)
	local Error
	local AllWindows = JSON.Library:DecodeFromFile("./Resources/Configurations/AllWindows.json")
	Space.Windows = {}
	if type(AllWindows) == "table" then
		for k, v in pairs(AllWindows) do
			Space.Windows[k] = Window.Library.Create(v, unpack(WindowGive))
			if WindowRender.Library.WindowRenders[v.WindowRenderer].Start and WindowRender.Library.WindowRenders[v.WindowRenderer].Render and v.OpenGLWindow == WindowRender.Library.WindowRenders[v.WindowRenderer].OpenGL then
				Space.Windows[k].WindowRenderer = v.WindowRenderer
			else
				if v.OpenGLWindow then
					Space.Windows[k].WindowRenderer = "DefaultOpenGL"
				else
					Space.Windows[k].WindowRenderer = "Default"
				end
			end
			if v.OpenGLWindow then
				Space.OpenGLWindow = k
				Space.Windows[k].OpenGL = true
			end
		end
		if Space.OpenGLWindow then
			SDL.Library.GL_MakeCurrent(Space.Windows[Space.OpenGLWindow].WindowID, OpenGLInit.Space.Context)
		end
	else
		Space.Windows[1] = Window.Library.Create(nil, unpack(WindowGive))
	end
	OpenGLInit.Library.DeleteDummyWindow(unpack(OpenGLInitGive))
	SDL.Library.GL_SetSwapInterval(0)
	print("AllWindows Started")
end
function GiveBack.Stop(Space, JSON, JSONGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, SDL, SDLGive, SDLInit, SDLInitGive, Window, WindowGive, WindowRender, WindowRenderGive, General, GeneralGive)
	for k,v in pairs(Space.Windows) do
		Window.Library.Destroy(v.WindowID, unpack(WindowGive))
	end
	print("AllWindows Stopped")
end
GiveBack.Requirements = {"JSON", "OpenGL", "OpenGLInit", "SDL", "SDLInit", "Window", "WindowRender", "General"}
return GiveBack
