local GiveBack = {}
function GiveBack.Start(Arguments)
	local Space, JSON, OpenGLInit, OpenGLInitGive, SDL, Window, WindowGive =
	Arguments[1], Arguments[2], Arguments[4], Arguments[5], Arguments[6],
	Arguments[10], Arguments[11]
	local Error
	local AllWindows = JSON.Library:DecodeFromFile("AllWindows.json")
	Space.Windows = {}
	if type(AllWindows) == "table" then
		for ak=1,#AllWindows do
			local av = AllWindows[ak]
			Space.Windows[ak] = Window.Library.Create(av, WindowGive)
			if av.Type == "OpenGL" then
				Space.OpenGLWindow = ak
				Space.Windows[ak].OpenGL = true
			end
		end
		if Space.OpenGLWindow then
			SDL.Library.GL_MakeCurrent(Space.Windows[Space.OpenGLWindow].WindowID,
			OpenGLInit.Space.Context)
		end
	else
		Space.Windows[1] = Window.Library.Create(nil, WindowGive)
	end
	OpenGLInit.Library.DeleteDummyWindow(OpenGLInitGive)
	SDL.Library.GL_SetSwapInterval(0)
	print("AllWindows Started")
end
function GiveBack.Stop(Arguments)
	local Space, SDL, Window, WindowGive = Arguments[1], Arguments[6],
	Arguments[10], Arguments[11]
	for ak=1,#Space.Windows do
		local av = Space.Windows[ak]
		SDL.Library.destroyRenderer(SDL.Library.getRenderer(av.WindowID))
		Window.Library.Destroy(av.WindowID, WindowGive)
	end
	for ak,av in pairs(Space) do
		Space[ak] = nil
	end
	print("AllWindows Stopped")
end
function GiveBack.Add(Window, Arguments)
	local Space, SDL, Window, WindowGive = Arguments[1], Arguments[6],
	Arguments[10], Arguments[11]
	if type(Window) == "table" then
		Space.Windows[#Space.Windows + 1] = Window.Library.Create(Window, WindowGive)
		if Window.Type == "OpenGL" then
			Space.Windows[#Space.Windows].OpenGL = true
			SDL.Library.GL_MakeCurrent(Space.Windows[#Space.Windows].WindowID,
			OpenGLInit.Space.Context)
		end
	else
		Space.Windows[#Space.Windows + 1] = Window.Library.Create(nil, WindowGive)
	end
end
function GiveBack.Remove(Number, Arguments)
	local Space, SDL, Window, WindowGive = Arguments[1], Arguments[6],
	Arguments[10], Arguments[11]
	local av = Space.Windows[#Space.Windows]
	local Index = #Space.Windows
	if type(Number) == "number" and Number < Index then
		Index = Number
	end
	local av = Space.Windows[Index]
	SDL.Library.destroyRenderer(SDL.Library.getRenderer(av.WindowID))
	Window.Library.Destroy(av.WindowID, WindowGive)
	table.remove(Space.Windows, Index)
end
GiveBack.Requirements = {"JSON", "OpenGLInit", "SDL", "SDLInit", "Window"}
return GiveBack
