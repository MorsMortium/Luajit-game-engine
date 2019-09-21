return function(args)
	local Space, OpenGLInit, SDL, SDLInit, Window, Globals = args[1], args[2],
	args[3], args[4], args[5], args[6]
	local Globals = Globals.Library.Globals
	local SDL, Create, Destroy, remove, type = SDL.Library, Window.Library.Create,
	Window.Library.Destroy, Globals.remove, Globals.type
	local GiveBack = {}

	function GiveBack.Reload(args)
		Space, OpenGLInit, SDL, SDLInit, Window, Globals = args[1], args[2],
		args[3], args[4], args[5], args[6]
		Globals = Globals.Library.Globals
		SDL, Create, Destroy, remove, type = SDL.Library, Window.Library.Create,
		Window.Library.Destroy, Globals.remove, Globals.type
  end

	--This script manages Windows
	--Loads data for every Window and creates them
	function GiveBack.Start(Configurations)
		Space.Windows = {}
		if type(Configurations) == "table" then
			for ak=1,#Configurations do
				local av = Configurations[ak]
				Space.Windows[ak] = Create(av)
				if av.Type == "OpenGL" then
					Space.OpenGLWindow = ak
					Space.Windows[ak].OpenGL = true
				end
			end
			if Space.OpenGLWindow then
				SDL.GL_MakeCurrent(Space.Windows[Space.OpenGLWindow].WindowID,
				OpenGLInit.Space.Context)
			end
		else
			Space.Windows[1] = Create(nil)
		end
		OpenGLInit.Library.DeleteDummyWindow()
		SDL.GL_SetSwapInterval(0)
	end

	--Deletes every Window
	function GiveBack.Stop()
		for ak=1,#Space.Windows do
			local av = Space.Windows[ak]
			SDL.destroyRenderer(SDL.getRenderer(av.WindowID))
			Destroy(av)
		end
	end

	--Adds one Window
	function GiveBack.Add(Window)
		if type(Window) == "table" then
			Space.Windows[#Space.Windows + 1] = Create(Window)
			if Window.Type == "OpenGL" then
				Space.Windows[#Space.Windows].OpenGL = true
				SDL.GL_MakeCurrent(Space.Windows[#Space.Windows].WindowID,
				OpenGLInit.Space.Context)
			end
		else
			Space.Windows[#Space.Windows + 1] = Create(nil)
		end
	end

	--Removes one Window
	function GiveBack.Remove(Number)
		local av = Space.Windows[#Space.Windows]
		local Index = #Space.Windows
		if type(Number) == "number" and Number < Index then
			Index = Number
		end
		local av = Space.Windows[Index]
		SDL.destroyRenderer(SDL.getRenderer(av.WindowID))
		Destroy(av.WindowID)
		remove(Space.Windows, Index)
	end
	return GiveBack
end
