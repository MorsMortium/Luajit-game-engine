return function(args)
	local SDL, SDLInit, General, CTypes, WindowRender, Globals = args[1], args[2],
	args[3], args[4], args[5], args[6]
	local Globals = Globals.Library.Globals
	local Types, SDL, DataFromKeys, remove, bor, type, unpack =
	CTypes.Library.Types, SDL.Library, General.Library.DataFromKeys,
	Globals.remove, Globals.bor, Globals.type, Globals.unpack
	local int = Types["int[?]"].Type
	
	local GiveBack = {}

	--This script creates a Window
	--Gets a library and an array of strings or numbers.
	--It checks each value, if its a string, it puts the value of the library with
	--The string as a key into a new table, if its a number, it puts that into the
	--Table. Then it returns the table
	--Only used with SDL
	local function SDLNumberOrString(StringOrNumber, Library)
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

	--The creation of the Window
	function GiveBack.Create(GotWindow)
		local Error

		--Creating the Window table
		local Window = {}

		--Default data for a Window
		--Title of the Window
		Window.Title = "Default"

		--Sizes of the Window
		Window.Width = int(1, 256)
		Window.Height = int(1, 256)

		--Positions of the Window
		Window.X = SDL.WINDOWPOS_UNDEFINED
		Window.Y = SDL.WINDOWPOS_UNDEFINED

		--Flags to pass SDL for the actual creation of the Window
		Window.Flags = {0}

		--Rendering type of the Window
		Window.Type = "Software"

		--Renderer of the Window
		Window.WindowRenderer = "Default"

		--Flags to pass SDL for the creation of the software renderer
		Window.RendererFlags = {"RENDERER_SOFTWARE"}

		--Creating the Window from the actual data
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

			--Positions can be numbers or SDL constants, hence the function
			local X = unpack(SDLNumberOrString({GotWindow.X}, SDL))
			if X then
				Window.X = X
			end
			local Y = unpack(SDLNumberOrString({GotWindow.Y}, SDL))
			if Y then
				Window.Y = Y
			end

			--These flags are always SDL constants
			local Flags = DataFromKeys(SDL, GotWindow.Flags)
			if Flags[1] then
				Window.Flags = Flags
			end

			if GotWindow.Type == "OpenGL" then
				Window.Type = "OpenGL"
			end

			--If the WindowRender exist than it changes it from default
			if WindowRender.Library.WindowRenders[GotWindow.WindowRenderer] then
				Window.WindowRenderer = GotWindow.WindowRenderer
			end

			--The Window mustn't have the SDL OpenGL flag, if it's not an OpenGL Window
			if Window.Type == "OpenGL" then
				Window.Flags[#Window.Flags + 1] = SDL.WINDOW_OPENGL
			else
				for ak=1,#Window.Flags do
					local av = Window.Flags[ak]
					if(av == SDL.WINDOW_OPENGL) then
						remove(Window.Flags, ak)
					end
				end
			end
			if type(GotWindow.RendererFlags) == "table" then
				Window.RendererFlags = GotWindow.RendererFlags
			end
		end

		--Creation of the Window, with SDL
		Window.WindowID, Error = SDL.createWindow(Window.Title, Window.X,
		Window.Y, Window.Width[0], Window.Height[0], bor(unpack(Window.Flags)))
		if not Window.WindowID then
			error(Error)
		end

		--If the Window isn't OpenGL, then the renderer is created here too
		if Window.Type ~= "OpenGL" then
			if type(Window.RendererFlags) ~= "table" then
				Window.Renderer = SDL.createRenderer(Window.WindowID, -1, 0)
			else
				Window.Renderer = SDL.createRenderer(Window.WindowID, -1,
				bor(unpack(DataFromKeys(SDL, Window.RendererFlags))))
			end
		end

		return Window
	end

	--Destroys a Window and it's renderer if it has one
	function GiveBack.Destroy(Window)
		if Window.Type == "Software" then
			SDL.destroyRenderer(SDL.getRenderer(Window.WindowID))
		end
		SDL.destroyWindow(Window.WindowID)
	end
	return GiveBack
end
