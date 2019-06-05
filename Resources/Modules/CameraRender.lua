local GiveBack = {}
GiveBack.CameraRenders = {}
GiveBack.CameraRenders.Default = {}
GiveBack.CameraRenders.Default.Software = {}
function GiveBack.CameraRenders.Default.Software.Start(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, ffi)
end
function GiveBack.CameraRenders.Default.Software.Stop(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, ffi)
end
function GiveBack.CameraRenders.Default.Software.Render(CameraObject, Renderer, Space, Arguments)
	local BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, ffi = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	SDL.Library.setRenderDrawColor(Renderer, 0, 255, 0, 255)
	SDL.Library.renderClear(Renderer)
end
GiveBack.CameraRenders.Default.OpenGL = {}
function GiveBack.CameraRenders.Default.OpenGL.Start(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, ffi)
end
function GiveBack.CameraRenders.Default.OpenGL.Stop(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, ffi)
end
function GiveBack.CameraRenders.Default.OpenGL.Render(VBO, RDBO, CameraObject, MVP, Space, Arguments)
	local BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, ffi = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	OpenGL.Library.glClearColor(1, 1, 0, 1)
	OpenGL.Library.glClear(OpenGL.Library.GL_COLOR_BUFFER_BIT)
end
GiveBack.CameraRenders.Test = {}
GiveBack.CameraRenders.Test.OpenGL = {}
function GiveBack.CameraRenders.Test.OpenGL.Start(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, ffi)
end
function GiveBack.CameraRenders.Test.OpenGL.Stop(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, ffi)
end
function GiveBack.CameraRenders.Test.OpenGL.Render(VBO, RDBO, CameraObject, MVP, Space, Arguments)
	local BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, ffi, AllDeviceRenders, AllDeviceRendersGive = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10], Arguments[12], Arguments[13]
	OpenGL.Library.glClearColor(0, 0, 0, 1)
	OpenGL.Library.glClear(bit.bor(OpenGL.Library.GL_COLOR_BUFFER_BIT, OpenGL.Library.GL_DEPTH_BUFFER_BIT))
	AllDeviceRenders.Library.RenderAllDevices(VBO, RDBO, CameraObject, MVP, AllDeviceRendersGive)
end
GiveBack.CameraRenders.Test.Software = {}
function GiveBack.CameraRenders.Test.Software.Start(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, ffi)
end
function GiveBack.CameraRenders.Test.Software.Stop(Space, BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, ffi)
end
function GiveBack.CameraRenders.Test.Software.Render(CameraObject, Renderer, Space, Arguments)
	local BigSpace, SDL, SDLInit, OpenGL, OpenGLInit, ffi, AllDevices, AllDevicesGive = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10], Arguments[12], Arguments[13]
	SDL.Library.setRenderDrawColor(Renderer, 0, 0, 0, 255)
	SDL.Library.renderClear(Renderer)
end
function GiveBack.Start(Arguments)
	local Space, SDL, SDLInit, OpenGL, OpenGLInit, ffi = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	Space.lasttime = 0
	for ak, av in pairs(GiveBack.CameraRenders) do
		if type(av.Software.Start) == "function" and
			type(av.Software.Stop) == "function" and
			type(av.Software.Render) == "function" and
			type(av.OpenGL.Start) == "function" and
			type(av.OpenGL.Stop) == "function" and
			type(av.OpenGL.Render) == "function" then
			av.Space = {}
			av.Software.Start(av.Space, Space, SDL, SDLInit, OpenGL, OpenGLInit, ffi)
			av.OpenGL.Start(av.Space, Space, SDL, SDLInit, OpenGL, OpenGLInit, ffi)
		else
			GiveBack.CameraRenders[ak] = nil
		end
	end
	print("WindowRender Started")
end
function GiveBack.Stop(Arguments)
	local Space, SDL, SDLInit, OpenGL, OpenGLInit, ffi = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	for ak, av in pairs(GiveBack.CameraRenders) do
		av.Software.Stop(av.Space, Space, SDL, SDLInit, OpenGL, OpenGLInit, ffi)
		av.OpenGL.Stop(av.Space, Space, SDL, SDLInit, OpenGL, OpenGLInit, ffi)
    av.Space = nil
	end
	print("WindowRender Stopped")
end
GiveBack.Requirements = {"SDL", "SDLInit", "OpenGL", "OpenGLInit", "ffi", "AllDeviceRenders"}
return GiveBack
