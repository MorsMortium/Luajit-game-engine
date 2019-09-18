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
		Space.SubSystems = {}
		if SDL.init(0) ~= 0 then
			error(ffi.string(SDL.getError()))
		elseif General.Library.GoodTypesOfTable(Space.SDLData, "string") then
			--Inits SDL subsystems, if none of them is specifies then it inits video
			for ak=1,#Space.SDLData do
				local av = Space.SDLData[ak]
				if SDL[av] then
					SDL.initSubSystem(SDL[av])
					local Error = ffi.string(SDL.getError())
					if Error ~= "" then
						print(Error)
					else
						Space.SubSystems[av] = true
					end
				end
			end
		else
			SDL.initSubSystem(SDL.INIT_VIDEO)
			Space.SubSystems["INIT_VIDEO"] = true
		end
	end

	--Quits SDL
	function GiveBack.Stop()
		SDL.quit()
	end
	return GiveBack
end
