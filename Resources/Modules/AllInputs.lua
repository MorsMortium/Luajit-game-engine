return function(args)
	local Space, SDL, SDLInit, ffi, Window, AllWindows, AllDevices, Input, CTypes =
	args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9]
	local SDL, Inputs, Types = SDL.Library, Input.Library.Inputs, CTypes.Library.Types
	local SDL_Event = Types["SDL_Event"].Type
	local GiveBack = {}

	function GiveBack.Reload(args)
		Space, SDL, SDLInit, ffi, Window, AllWindows, AllDevices, Input, CTypes =
		args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9]
		SDL, Inputs, Types = SDL.Library, Input.Library.Inputs, CTypes.Library.Types
		SDL_Event = Types["SDL_Event"].Type
	end

	--Sets up inputs based on button presses and releases
	function GiveBack.Start(Configurations)
		Space.Event = SDL_Event()
		Space.Text = ""
		io.write("AllInputs Started\n")
	end
	function GiveBack.Stop()
		io.write("AllInputs Stopped\n")
	end

	--Takes inputs and runs commands if there is button for it
	--TODO: Answer to every type of input
	function GiveBack.Input()
		while SDL.pollEvent(Space.Event) ~=0 do
			if Space.Event.type == SDL.QUIT then
				return true
			elseif Space.Event.type == SDL.TEXTINPUT then
				Space.Text = Space.Text .. ffi.Library.string(Space.Event.text.text)
				io.write(Space.Text, "\n")
			elseif Space.Event.type == SDL.WINDOWEVENT then
				if Space.Event.window.event == SDL.WINDOWEVENT_CLOSE then
					local EventWindowID = Space.Event.window.windowID
					for ak=1,#AllWindows.Space.Windows do
						local av = AllWindows.Space.Windows[ak]
						if av.WindowID == SDL.getWindowFromID(EventWindowID) then
							table.remove(AllWindows.Space.Windows, ak)
							Window.Library.Destroy(av)
							break
						end
					end
				elseif Space.Event.window.event == SDL.WINDOWEVENT_RESIZED then
					local EventWindowID = Space.Event.window.windowID
					for ak=1,#AllWindows.Space.Windows do
						local av = AllWindows.Space.Windows[ak]
						if av.WindowID == SDL.getWindowFromID(EventWindowID) then
							SDL.GetWindowSize(SDL.getWindowFromID(
							EventWindowID), av.Width, av.Height)
						end
					end
				end
			elseif Space.Event.type == SDL.KEYDOWN then
				local Key = ffi.Library.string(
				SDL.getKeyName(Space.Event.key.keysym.sym))
				if Inputs.Down[Key] then
					if Inputs.Down[Key](Space) then
						return true
					end
				end
				for ak=1,#AllDevices.Space.Devices do
					local av = AllDevices.Space.Devices[ak]
					if av.ButtonsDown[Key] then
						pcall(av.ButtonsDown[Key].Command, av)
					end
				end
			elseif Space.Event.type == SDL.KEYUP then
				local Key = ffi.Library.string(
				SDL.getKeyName(Space.Event.key.keysym.sym))
				if Inputs.Up[Key] then
					if Inputs.Up[Key](Space) then
						return true
					end
				end
				for ak=1,#AllDevices.Space.Devices do
					local av = AllDevices.Space.Devices[ak]
					if av.ButtonsUp[Key] then
						pcall(av.ButtonsUp[Key].Command, av)
					end
				end
			end
		end
		if #AllWindows.Space.Windows == 0 then
			return true
		end
	end

	--Adds a new input
	function GiveBack.Add(Command)
		local Object = {}
		if type(Command) == "table" and type(Command.String) == "string" and
		type(Command.Button) == "string" then
			Object.Command = loadstring(Command.String)
			if Command.Type == "Up" then
				Inputs.Up[Command.Button] = Object
			else
				Inputs.Down[Command.Button] = Object
			end
		end
	end

	--Removes an input
	function GiveBack.Remove(Letter, Type)
		if type(Letter) == "string" then
			if Type == "Up" then
				Inputs.Up[Letter] = nil
			elseif Type == "Down" then
				Inputs.Down[Letter] = nil
			end
		end
	end
	return GiveBack
end
