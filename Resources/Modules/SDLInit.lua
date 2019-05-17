local GiveBack = {}
function GiveBack.Start(Arguments)
	local Space, JSON, SDL, ffi, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8]
	Space.SDLData = JSON.Library:DecodeFromFile("./Resources/Configurations/SDLData.json")
	if SDL.Library.init(0) ~= 0 then
		error(ffi.Library.sring(SDL.Library.getError()))
	else
		if General.Library.GoodTypesOfTable(Space.SDLData, "string") then
			for ak=1,#Space.SDLData do
				local av = Space.SDLData[ak]
				SDL.Library.initSubSystem(SDL.Library[av])
			end
		else
			SDL.Library.initSubSystem(SDL.Library.INIT_VIDEO)
		end
	end
	print("SDLInit Started")
end
function GiveBack.Stop(Arguments)
	local Space, SDL = Arguments[1], Arguments[4]
	SDL.Library.quit()
	for ak,av in pairs(Space) do
		Space[ak] = nil
	end
	print("SDLInit Stopped")
end
GiveBack.Requirements = {"JSON", "SDL", "ffi", "General"}
return GiveBack
