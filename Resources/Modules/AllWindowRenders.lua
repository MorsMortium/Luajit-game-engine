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
function GiveBack.Render(Number, Arguments)
	local Space, SDL, SDLInit, AllWindows, WindowRender, WindowRenderGive, OpenGLInit, ffi = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[9], Arguments[10], Arguments[12]
	if Number % 30 == 0 then
		Space.FramesPerSecond = (30 / (SDL.Library.getTicks() - Space.LastTime) * 1000) .. " FramesPerSecond"
		Space.LastTime = SDL.Library.getTicks()
	end
	for ak=1,#AllWindows.Space.Windows do
		local av = AllWindows.Space.Windows[ak]
		if ak ~= Space.LastWindow and av.OpenGL then
			SDL.Library.GL_MakeCurrent(av.WindowID, OpenGLInit.Space.Context)
			Space.LastWindow = ak
		end
		WindowRender.Library.WindowRenders[av.WindowRenderer].Render(av, WindowRender.Library.WindowRenders[av.WindowRenderer].Space, WindowRenderGive)
		if av.OpenGL then
			SDL.Library.GL_SwapWindow(av.WindowID)
		else
			SDL.Library.renderPresent(av.Renderer)
		end
	end
end
GiveBack.Requirements = {"SDL", "SDLInit", "AllWindows", "WindowRender", "OpenGLInit", "ffi"}
return GiveBack
