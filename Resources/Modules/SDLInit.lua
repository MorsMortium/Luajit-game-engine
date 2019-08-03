local GiveBack = {}

--Inits the SDL system, and it's subsystems if needed
function GiveBack.Start(Configurations, Arguments)
	local Space, SDL, ffi, General = Arguments[1], Arguments[2], Arguments[4],
	Arguments[6]

	--Load data for subsystems
	Space.SDLData = Configurations
	local ffi = ffi.Library
	local SDL = SDL.Library

	--Inits SDL
	if SDL.init(0) ~= 0 then
		error(ffi.sring(SDL.getError()))
	else

		--Inits SDL subsystems, if none of them is specifies then it inits video
		if General.Library.GoodTypesOfTable(Space.SDLData, "string") then
			for ak=1,#Space.SDLData do
				local av = Space.SDLData[ak]
				SDL.initSubSystem(SDL[av])
			end
		else
			SDL.initSubSystem(SDL.INIT_VIDEO)
		end
	end
	io.write("SDLInit Started\n")
end

--Quits SDL
function GiveBack.Stop(Arguments)
	local Space, SDL = Arguments[1], Arguments[2]
	local SDL = SDL.Library
	SDL.quit()
	io.write("SDLInit Stopped\n")
end
GiveBack.Requirements = {"SDL", "ffi", "General"}
return GiveBack
