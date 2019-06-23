local GiveBack = {}
local function SDLNumberOrString(StringOrNumber, General, Library)
	local DataFromKeys = General.Library.DataFromKeys
	local Table = {}
	if type(StringOrNumber) == "table" then
		for ak=1,#StringOrNumber do
			local av = StringOrNumber[ak]
			if type(av) == "string" then
				Table[#Table + 1] = unpack(DataFromKeys(Library, {av}))
			elseif type(av) == "number" then
				Table[#Table + 1] = av
			end
		end
	end
	return Table
end
function GiveBack.Create(GotWindow, Arguments)
	local SDL, SDLInit, General, ffi, WindowRender = Arguments[1], Arguments[3],
	Arguments[5], Arguments[7], Arguments[9]
	local DataFromKeys = General.Library.DataFromKeys
	local ffi = ffi.Library
	local SDL = SDL.Library
	local Error
	local Window = {}
	Window.Title = "Default"
	Window.Width = ffi.new("int[1]", 256)
	Window.Height = ffi.new("int[1]", 256)
	Window.X = SDL.WINDOWPOS_UNDEFINED
	Window.Y = SDL.WINDOWPOS_UNDEFINED
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
		local X = unpack(SDLNumberOrString({GotWindow.X}, General, SDL))
		if X ~= nil then
			Window.X = X
		end
		local Y = unpack(SDLNumberOrString({GotWindow.Y}, General, SDL))
		if Y ~= nil then
			Window.Y = Y
		end
		local Flags = DataFromKeys(SDL, GotWindow.Flags)
		if Flags[1] ~= nil then
			Window.Flags = Flags
		end
		if GotWindow.Type == "OpenGL" then
			Window.Type = "OpenGL"
		end
		if WindowRender.Library.Renders[GotWindow.WindowRenderer] ~= nil then
			Window.WindowRenderer = GotWindow.WindowRenderer
		end
		if Window.Type == "OpenGL" then
			Window.Flags[#Window.Flags + 1] = SDL.WINDOW_OPENGL
		else
			for ak=1,#Window.Flags do
				local av = Window.Flags[ak]
				if(av == SDL.WINDOW_OPENGL) then
					table.remove(Window.Flags, ak)
				end
			end
		end
		if type(GotWindow.RendererFlags) == "table" then
			Window.RendererFlags = GotWindow.RendererFlags
		end
	end
	Window.WindowID, Error = SDL.createWindow(Window.Title, Window.X,
	Window.Y, Window.Width[0], Window.Height[0], bit.bor(unpack(Window.Flags)))
	if not Window.WindowID then
		error(Error)
	end
	if Window.Type ~= "OpenGL" then
		if type(Window.RendererFlags) ~= "table" then
			Window.Renderer = SDL.createRenderer(Window.WindowID, -1, 0)
		else
			Window.Renderer = SDL.createRenderer(Window.WindowID, -1,
			bit.bor(unpack(DataFromKeys(SDL, Window.RendererFlags))))
		end
	end
	return Window
end
function GiveBack.Destroy(WindowID, Arguments)
	local SDL, SDLInit, General, ffi = Arguments[1], Arguments[3], Arguments[5],
	Arguments[7]
	local SDL = SDL.Library
	if type(WindowID) == "number" then
		SDL.destroyWindow(SDL.getWindowFromID(WindowID))
	else
		SDL.destroyWindow(WindowID)
	end
end
GiveBack.Requirements = {"SDL", "SDLInit", "General", "ffi", "WindowRender"}
return GiveBack
