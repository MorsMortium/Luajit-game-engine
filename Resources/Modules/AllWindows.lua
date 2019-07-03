local GiveBack = {}

--This script manages Windows

--Loads data for every Window and creates them
function GiveBack.Start(Configurations, Arguments)
	local Space, OpenGLInit, OpenGLInitGive, SDL, Window, WindowGive =
	Arguments[1], Arguments[2], Arguments[3], Arguments[4], Arguments[8],
	Arguments[9]
	local AllWindows = Configurations
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

--Deletes every Window
function GiveBack.Stop(Arguments)
	local Space, SDL, Window, WindowGive = Arguments[1], Arguments[4],
	Arguments[8], Arguments[9]
	for ak=1,#Space.Windows do
		local av = Space.Windows[ak]
		SDL.Library.destroyRenderer(SDL.Library.getRenderer(av.WindowID))
		Window.Library.Destroy(av, WindowGive)
	end
	for ak,av in pairs(Space) do
		Space[ak] = nil
	end
	print("AllWindows Stopped")
end

--Adds one Window
function GiveBack.Add(Window, Arguments)
	local Space, SDL, Window, WindowGive = Arguments[1], Arguments[4],
	Arguments[8], Arguments[9]
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

--Removes one Window
function GiveBack.Remove(Number, Arguments)
	local Space, SDL, Window, WindowGive = Arguments[1], Arguments[4],
	Arguments[8], Arguments[9]
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
GiveBack.Requirements = {"OpenGLInit", "SDL", "SDLInit", "Window"}
return GiveBack
