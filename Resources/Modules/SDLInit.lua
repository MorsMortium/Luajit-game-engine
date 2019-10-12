return function(args)
	local Space, SDL, ffi, General, Globals = args[1], args[2], args[3], args[4],
	args[5]
	local ffi, SDL, write = ffi.Library, SDL.Library,
	Globals.Library.Globals.write

	local GiveBack = {}

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
						write(Error, "\n")
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
