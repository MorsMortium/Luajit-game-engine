local ffi = {}
ffi.Library = require "ffi"
local GiveBack = {}
local function SDLNumberOrString(StringOrNumber, General, Library)
	local ReturnTable = {}
	if type(StringOrNumber) == "table" then
		for k, v in pairs(StringOrNumber) do
			if type(v) == "string" then
				ReturnTable[#ReturnTable + 1] = unpack(General.Library.DataFromKeys(Library, {v}))
			elseif type(v) == "number" then
				ReturnTable[#ReturnTable + 1] = v
			end
		end
	end
	return ReturnTable
end
function GiveBack.Create(GotWindow, SDL, SDLGive, SDLInit, SDLInitGive, General, GeneralGive, ffi, ffiGive)
	local Error
	local Window = {}
	if type(GotWindow) == "table" then
		Window.RendererFlags = GotWindow.RendererFlags
		Window.Title = GotWindow.Title
		if type(Window.Title) ~= "string" then
			Window.Title = "Default"
		end
		if type(GotWindow.Width) ~= "number" then
			GotWindow.Width = 256
		end
		Window.Width = ffi.Library.new("int[1]", GotWindow.Width)
		if type(GotWindow.Height) ~= "number" then
			GotWindow.Height = 256
		end
		Window.Height = ffi.Library.new("int[1]", GotWindow.Height)
		Window.X = unpack(SDLNumberOrString({GotWindow.X}, General, SDL.Library))
		if Window.X == nil then
			Window.X = SDL.Library.WINDOWPOS_UNDEFINED
		end
		Window.X = unpack(SDLNumberOrString({GotWindow.X}, General, SDL.Library))
		if Window.X == nil then
			Window.X = SDL.Library.WINDOWPOS_UNDEFINED
		end
		Window.Flags = General.Library.DataFromKeys(SDL.Library, GotWindow.Flags)
		if Window.Flags[1] == nil then
			Window.Flags = {0}
		end
		if GotWindow.OpenGLWindow then
			Window.Flags[#Window.Flags + 1] = SDL.Library.WINDOW_OPENGL
		else
			for i=1,#Window.Flags do
				if(Window.Flags[i] == SDL.Library.WINDOW_OPENGL) then
					table.remove(Window.Flags, i)
				end
			end
			if type(Window.RendererFlags) ~= "table" then
				Window.RendererFlags = {"RENDERER_SOFTWARE"}
			end
		end
		Window.WindowID, Error = SDL.Library.createWindow(Window.Title, Window.X, Window.X, Window.Width[0], Window.Height[0], bit.bor(unpack(Window.Flags)))
	else
		Window.WindowID, Error = SDL.Library.createWindow("Default", SDL.Library.WINDOWPOS_UNDEFINED, SDL.Library.WINDOWPOS_UNDEFINED, 256, 256, 0)
	end
	if not Window.WindowID then
		error(Error)
	end
	if not GotWindow.OpenGLWindow then
		if type(Window.RendererFlags) ~= "table" then
			Window.Renderer = SDL.Library.CreateRenderer(Window.WindowID, -1, 0)
		else
			Window.Renderer = SDL.Library.CreateRenderer(Window.WindowID, -1, bit.bor(unpack(General.Library.DataFromKeys(SDL.Library, Window.RendererFlags))))
		end
	end
	return Window
end
function GiveBack.Destroy(WindowID, SDL, SDLGive, SDLInit, SDLInitGive, General, GeneralGive)
	if type(WindowID) == "number" then
		SDL.Library.destroyWindow(SDL.Library.getWindowFromID(WindowID))
	else
		SDL.Library.destroyWindow(WindowID)
	end
end
GiveBack.Requirements = {"SDL", "SDLInit", "General", "ffi"}
return GiveBack
