local GiveBack = {}
function GiveBack.Start(Space, SDL, SDLGive, SDLInit, SDLInitGive, AllWindows, AllWindowsGive, WindowRender, WindowRenderGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive)
	Space.LastTime = 0
	print("AllWindowRenders Started")
end
function GiveBack.Stop(Space, SDL, SDLGive, SDLInit, SDLInitGive, AllWindows, AllWindowsGive, WindowRender, WindowRenderGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive)
	Space.LastTime = nil
	print("AllWindowRenders Stopped")
end
function GiveBack.Render(number, Space, SDL, SDLGive, SDLInit, SDLInitGive, AllWindows, AllWindowsGive, WindowRender, WindowRenderGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive)
	if number % 30 == 0 then
		Space.FramesPerSecond = (30 / (SDL.Library.getTicks() - Space.LastTime) * 1000) .. " FramesPerSecond"
		Space.LastTime = SDL.Library.getTicks()
	end
	for k, v in pairs(AllWindows.Space.Windows) do
		if k ~= Space.LastWindow and v.OpenGL then
			SDL.Library.GL_MakeCurrent(v.WindowID, OpenGLInit.Space.Context)
			Space.LastWindow = k
		end
		WindowRender.Library.WindowRenders[v.WindowRenderer].Render(v, WindowRender.Library.WindowRenders[v.WindowRenderer].Space, unpack(WindowRenderGive))
		if v.OpenGL then
			SDL.Library.GL_SwapWindow(v.WindowID)
		else
			SDL.Library.renderPresent(v.Renderer)
		end
	end
end
GiveBack.Requirements = {"SDL", "SDLInit", "AllWindows", "WindowRender", "OpenGLInit", "ffi"}
return GiveBack
