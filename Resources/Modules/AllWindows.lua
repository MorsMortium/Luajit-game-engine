local GiveBack = {}
function GiveBack.Start(Arguments)
	local Space, JSON, OpenGL, OpenGLInit, OpenGLInitGive, SDL, SDLInit, Window, WindowGive, WindowRender = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[7], Arguments[8], Arguments[10], Arguments[12], Arguments[13], Arguments[14]
	local Error
	local AllWindows = JSON.Library:DecodeFromFile("./Resources/Configurations/AllWindows.json")
	Space.Windows = {}
	if type(AllWindows) == "table" then
		for ak=1,#AllWindows do
			local av = AllWindows[ak]
			Space.Windows[ak] = Window.Library.Create(av, WindowGive)
			if WindowRender.Library.WindowRenders[av.WindowRenderer] then
				Space.Windows[ak].WindowRenderer = av.WindowRenderer
			else
				Space.Windows[ak].WindowRenderer = "Default"
			end
			if av.Type == "OpenGL" then
				Space.OpenGLWindow = ak
				Space.Windows[ak].OpenGL = true
			end
		end
		if Space.OpenGLWindow then
			SDL.Library.GL_MakeCurrent(Space.Windows[Space.OpenGLWindow].WindowID, OpenGLInit.Space.Context)
		end
	else
		Space.Windows[1] = Window.Library.Create(nil, WindowGive)
	end
	OpenGLInit.Library.DeleteDummyWindow(OpenGLInitGive)
	SDL.Library.GL_SetSwapInterval(0)
	print("AllWindows Started")
end
function GiveBack.Stop(Arguments)
	local Space, Window, WindowGive = Arguments[1], Arguments[12], Arguments[13]
	for ak=1,#Space.Windows do
		local av = Space.Windows[ak]
		Window.Library.Destroy(av.WindowID, WindowGive)
	end
	for ak,av in pairs(Space) do
		Space[ak] = nil
	end
	print("AllWindows Stopped")
end
GiveBack.Requirements = {"JSON", "OpenGL", "OpenGLInit", "SDL", "SDLInit", "Window", "WindowRender"}
return GiveBack
