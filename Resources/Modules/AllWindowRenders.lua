local GiveBack = {}
function GiveBack.Start(Arguments)
	local Space = Arguments[1]
	Space.LastTime = 0
	print("AllWindowRenders Started")
end
function GiveBack.Stop(Arguments)
	local Space = Arguments[1]
	for ak,av in pairs(Space) do
		Space[ak] = nil
	end
	print("AllWindowRenders Stopped")
end

--Renders every Window
--Recalculates fps for every 30 frames
--TODO: Move fps out of here
function GiveBack.RenderAllWindows(Number, Arguments)
	local Space, SDL, AllWindows, WindowRender, WindowRenderGive, OpenGLInit =
	Arguments[1], Arguments[2], Arguments[6], Arguments[8], Arguments[9],
	Arguments[10]
	if Number % 30 == 0 then
		Space.FramesPerSecond = 30 / (SDL.Library.getTicks() - Space.LastTime) * 1000
		Space.LastTime = SDL.Library.getTicks()
	end
	for ak=1,#AllWindows.Space.Windows do
		local av = AllWindows.Space.Windows[ak]
		if ak ~= Space.LastWindow and av.Type == "OpenGL" then
			SDL.Library.GL_MakeCurrent(av.WindowID, OpenGLInit.Space.Context)
			Space.LastWindow = ak
		end
		local WRender = WindowRender.Library.Renders[av.WindowRenderer]
		WRender[av.Type].Render(av, WRender.Space, WindowRenderGive)
		if av.Type == "OpenGL" then
			SDL.Library.GL_SwapWindow(av.WindowID)
		else
			SDL.Library.renderPresent(av.Renderer)
		end
	end
end
GiveBack.Requirements =
{"SDL", "SDLInit", "AllWindows", "WindowRender", "OpenGLInit"}
return GiveBack
