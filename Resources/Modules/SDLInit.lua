return function(args)
	local Space, SDL, ffi, General = args[1], args[2], args[3], args[4]
	local ffi, SDL = ffi.Library, SDL.Library
	local GiveBack = {}

	function GiveBack.Reload(args)
		Space, SDL, ffi, General = args[1], args[2], args[3], args[4]
		ffi, SDL = ffi.Library, SDL.Library
  end

	--Inits the SDL system, and it's subsystems if needed
	function GiveBack.Start(Configurations)

		--Load data for subsystems
		Space.SDLData = Configurations

		--Inits SDL
		if SDL.init(0) ~= 0 then
			error(ffi.sring(SDL.getError()))
		elseif General.Library.GoodTypesOfTable(Space.SDLData, "string") then
			--Inits SDL subsystems, if none of them is specifies then it inits video
			for ak=1,#Space.SDLData do
				local av = Space.SDLData[ak]
				SDL.initSubSystem(SDL[av])
			end
		else
			SDL.initSubSystem(SDL.INIT_VIDEO)
		end
		io.write("SDLInit Started\n")
	end

	--Quits SDL
	function GiveBack.Stop()
		SDL.quit()
		io.write("SDLInit Stopped\n")
	end
	return GiveBack
end
