local ffi = {}
ffi.Library = require "ffi"
local GiveBack = {}
local function SDLNumberOrString(StringOrNumber, General, Library)
	local ReturnTable = {}
	if type(StringOrNumber) == "table" then
		for ak=1,#StringOrNumber do
			local av = StringOrNumber[ak]
			if type(av) == "string" then
				ReturnTable[#ReturnTable + 1] = unpack(General.Library.DataFromKeys(Library, {av}))
			elseif type(av) == "number" then
				ReturnTable[#ReturnTable + 1] = av
			end
		end
	end
	return ReturnTable
end
function GiveBack.Create(GotWindow, Arguments)
	local SDL, SDLInit, General, ffi, WindowRender = Arguments[1], Arguments[3],
	Arguments[5], Arguments[7], Arguments[9]
	local Error
	local Window = {}
	Window.Title = "Default"
	Window.Width = ffi.Library.new("int[1]", 256)
	Window.Height = ffi.Library.new("int[1]", 256)
	Window.X = SDL.Library.WINDOWPOS_UNDEFINED
	Window.Y = SDL.Library.WINDOWPOS_UNDEFINED
	Window.Flags = {0}
	Window.Type = "Software"
	Window.WindowRenderer = "Default"
	Window.RendererFlags = {"RENDERER_SOFTWARE"}
	if type(GotWindow) == "table" then
		if type(GotWindow.Title) == "string" then
			Window.Title = GotWindow.Title
		end
		if type(GotWindow.Width) == "number" then
			Window.Width[0] = GotWindow.Width
		end
		if type(GotWindow.Height) == "number" then
			Window.Height[0] = GotWindow.Height
		end
		local X = unpack(SDLNumberOrString({GotWindow.X}, General, SDL.Library))
		if X ~= nil then
			Window.X = X
		end
		local Y = unpack(SDLNumberOrString({GotWindow.Y}, General, SDL.Library))
		if Y ~= nil then
			Window.Y = Y
		end
		local Flags = General.Library.DataFromKeys(SDL.Library, GotWindow.Flags)
		if Flags[1] ~= nil then
			Window.Flags = Flags
		end
		if GotWindow.Type == "OpenGL" then
			Window.Type = "OpenGL"
		end
		if WindowRender.Library.WindowRenders[GotWindow.WindowRenderer] ~= nil then
			Window.WindowRenderer = GotWindow.WindowRenderer
		end
		if Window.Type == "OpenGL" then
			Window.Flags[#Window.Flags + 1] = SDL.Library.WINDOW_OPENGL
		else
			for ak=1,#Window.Flags do
				local av = Window.Flags[ak]
				if(av == SDL.Library.WINDOW_OPENGL) then
					table.remove(Window.Flags, ak)
				end
			end
		end
		if type(GotWindow.RendererFlags) == "table" then
			Window.RendererFlags = GotWindow.RendererFlags
		end
	end
	Window.WindowID, Error = SDL.Library.createWindow(Window.Title, Window.X,
	Window.Y, Window.Width[0], Window.Height[0], bit.bor(unpack(Window.Flags)))
	if not Window.WindowID then
		error(Error)
	end
	if Window.Type ~= "OpenGL" then
		if type(Window.RendererFlags) ~= "table" then
			Window.Renderer = SDL.Library.createRenderer(Window.WindowID, -1, 0)
		else
			Window.Renderer = SDL.Library.createRenderer(Window.WindowID, -1,
			bit.bor(unpack(General.Library.DataFromKeys(SDL.Library, Window.RendererFlags))))
		end
	end
	return Window
end
function GiveBack.Destroy(WindowID, Arguments)
	local SDL, SDLInit, General, ffi = Arguments[1], Arguments[3], Arguments[5],
	Arguments[7]
	if type(WindowID) == "number" then
		SDL.Library.destroyWindow(SDL.Library.getWindowFromID(WindowID))
	else
		SDL.Library.destroyWindow(WindowID)
	end
end
GiveBack.Requirements = {"SDL", "SDLInit", "General", "ffi", "WindowRender"}
return GiveBack
