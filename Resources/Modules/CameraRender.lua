local GiveBack = {}

--Different Camera rendering scripts are stored here
GiveBack.CameraRenders = {}

--The default Camera fills the Camera with a color
GiveBack.CameraRenders.Default = {}
local Default = GiveBack.CameraRenders.Default
Default.Software = {}
function Default.Software.Render(CameraObject, Renderer, Space, Arguments)
	local SDL = Arguments[2].Library
	SDL.setRenderDrawColor(Renderer, 0, 255, 0, 255)
	SDL.renderClear(Renderer)
end
Default.OpenGL = {}
function Default.OpenGL.Render(VBO, RDBO, CameraObject, MVP, Space, Arguments)
	local OpenGL = Arguments[6].Library
	OpenGL.glClearColor(1, 1, 0, 1)
	OpenGL.glClear(OpenGL.GL_COLOR_BUFFER_BIT)
end

--The Test Camera render draws every Device onto the Camera
--TODO: Software support
GiveBack.CameraRenders.Test = {}
local Test = GiveBack.CameraRenders.Test
Test.OpenGL = {}
function Test.OpenGL.Render(VBO, RDBO, CameraObject, MVP, Space, Arguments)
	local OpenGL, AllDeviceRenders, AllDeviceRendersGive = Arguments[6].Library,
	Arguments[10].Library, Arguments[11]
	OpenGL.glClearColor(0, 0, 0, 1)
	OpenGL.glClear(bit.bor(OpenGL.GL_COLOR_BUFFER_BIT, OpenGL.GL_DEPTH_BUFFER_BIT))
	AllDeviceRenders.RenderAllDevices(VBO, RDBO, CameraObject, MVP,
	AllDeviceRendersGive)
end
Test.Software = {}
function Test.Software.Render(CameraObject, Renderer, Space, Arguments)
	local SDL = Arguments[2].Library
	SDL.setRenderDrawColor(Renderer, 0, 0, 0, 255)
	SDL.renderClear(Renderer)
end

--Check whether every renderer has both software and OpenGL counterpart.
--If it has, then it creates a space for it, that is persistent
--If not, it deletes it
function GiveBack.Start(Arguments)
	for ak, av in pairs(GiveBack.CameraRenders) do
		if type(av.Software.Render) == "function" and
			type(av.OpenGL.Render) == "function" then
			av.Space = {}
		else
			GiveBack.CameraRenders[ak] = nil
		end
	end
	print("WindowRender Started")
end

--Deletes the space it allocated for the renderers
function GiveBack.Stop(Arguments)
	for ak, av in pairs(GiveBack.CameraRenders) do
    av.Space = nil
	end
	print("WindowRender Stopped")
end
GiveBack.Requirements =
{"SDL", "SDLInit", "OpenGL", "OpenGLInit", "AllDeviceRenders"}
return GiveBack
