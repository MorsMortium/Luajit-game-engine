local GiveBack = {}
function GiveBack.Start(Space, JSON, JSONGive, SDL, SDLGive, ffi, ffiGive, General, GeneralGive)
	Space.SDLData = JSON.Library:DecodeFromFile("./Resources/Configurations/SDLData.json")
	if SDL.Library.init(0) ~= 0 then
		error(ffi.Library.sring(SDL.Library.getError()))
	else
		if General.Library.GoodTypesOfTable(Space.SDLData, "string") then
			for k, v in pairs(Space.SDLData) do
				SDL.Library.initSubSystem(SDL.Library[v])
			end
		else
			SDL.Library.initSubSystem(SDL.Library.INIT_VIDEO)
		end
	end
	print("SDLInit Started")
end
function GiveBack.Stop(Space, JSON, JSONGive, SDL, SDLGive, ffi, ffiGive, General, GeneralGive)
	SDL.Library.quit()
	print("SDLInit Stopped")
end
GiveBack.Requirements = {"JSON", "SDL", "ffi", "General"}
return GiveBack
