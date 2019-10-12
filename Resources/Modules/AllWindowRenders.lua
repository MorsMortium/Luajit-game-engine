return function(args)
	local Space, SDL, SDLInit, AllWindows, WindowRender, OpenGLInit = args[1],
	args[2], args[3], args[4], args[5], args[6]
	local SDL, WindowRenders = SDL.Library, WindowRender.Library.WindowRenders

	local GiveBack = {}

	function GiveBack.Start(Configurations)
		Space.LastTime = 0
	end
	function GiveBack.Stop()
	end

	--Renders every Window
	--Recalculates fps for every 30 frames
	--TODO: Move fps out of here
	function GiveBack.RenderAllWindows(Number)
		if Number % 30 == 0 then
			Space.FramesPerSecond = 30 / (SDL.getTicks() - Space.LastTime) * 1000
			Space.LastTime = SDL.getTicks()
		end
		for ak=1,#AllWindows.Space.Windows do
			local av = AllWindows.Space.Windows[ak]
			if ak ~= Space.LastWindow and av.Type == "OpenGL" then
				SDL.GL_MakeCurrent(av.WindowID, OpenGLInit.Space.Context)
				Space.LastWindow = ak
			end
			local WRender = WindowRenders[av.WindowRenderer]
			WRender[av.Type].Render(av, WRender.Space)
			if av.Type == "OpenGL" then
				SDL.GL_SwapWindow(av.WindowID)
			else
				SDL.renderPresent(av.Renderer)
			end
		end
		if Space.FramesPerSecond < 24 and Number > 1000 then return true end
	end
	return GiveBack
end
