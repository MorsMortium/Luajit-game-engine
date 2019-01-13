local GiveBack = {}
local function NotInList(List, Object)
	for k,v in pairs(List) do
		if v == Object then
			return false
		end
	end
	return true
end
local JSON = require("json")
local Inputs = JSON:DecodeFromFile("./Resources/Configurations/AllInputs.json")
GiveBack.Requirements = {"JSON", "SDL", "SDLInit", "ffi", "Window", "AllWindows", "WindowRender"}
for k,v in pairs(Inputs) do
	if type(v.Pass) == "table" then
		for a,b in pairs(v.Pass) do
			if b ~= "AllInputs" and NotInList(GiveBack.Requirements, b) then
				GiveBack.Requirements[#GiveBack.Requirements + 1] = b
			end
		end
	end
end
Inputs = nil
function GiveBack.Start(...)
	local Arguments = {...}
	local Space = Arguments[1]
	local JSON = Arguments[2]
	local JSONGive = Arguments[3]
	local SDL = Arguments[4]
	local SDLGive = Arguments[5]
	local SDLInit = Arguments[6]
	local SDLInitGive = Arguments[7]
	local ffi = Arguments[8]
	local ffiGive = Arguments[9]
	local Window = Arguments[10]
	local WindowGive = Arguments[11]
	local AllWindows = Arguments[12]
	local AllWindowsGive = Arguments[13]
	local WindowRender = Arguments[14]
	local WindowRenderGive = Arguments[15]
	Space.PlusRequ = {}
	Space.Pass = {}
	for i=7, #GiveBack.Requirements do
		Space.PlusRequ[GiveBack.Requirements[i]] = Arguments[2 * i]
		Space.PlusRequ[GiveBack.Requirements[i].."Give"] = Arguments[2 * i + 1]
	end
	Space.PlusRequ["AllInputs"] = {}
	Space.PlusRequ["AllInputs"].Library = GiveBack
	Space.PlusRequ["AllInputs"].Space = Space
	Space.PlusRequ["AllInputsGive"] = {Space, JSON, JSONGive, SDL, SDLGive, SDLInit, SDLInitGive, ffi, ffiGive, Window, WindowGive, AllWindows, AllWindowsGive}
	Space.Inputs = JSON.Library:DecodeFromFile("./Resources/Configurations/AllInputs.json")
	if type(Space.Inputs) == "table" then
		for k,v in pairs(Space.Inputs) do
			v.Command = loadstring(v.String)
		end
	end
	Space.ButtonsDown = {}
	Space.ButtonsUp = {}
	for k,v in pairs(Space.Inputs) do
		if v.Type == "Down" then
			Space.ButtonsDown[v.Button] = v
		end
		if v.Type == "Up" then
			Space.ButtonsUp[v.Button] = v
		end
	end
	Space.Inputs = nil
	Space.Event = ffi.Library.new("SDL_Event")
	Space.Text = ""
	print("AllInputs Started")
end
function GiveBack.Stop(Space, JSON, JSONGive, SDL, SDLGive, SDLInit, SDLInitGive, ffi, ffiGive, Window, WindowGive, AllWindows, AllWindowsGive, WindowRender, WindowRenderGive)
	print("AllInputs Stopped")
end
function GiveBack.Input(Space, JSON, JSONGive, SDL, SDLGive, SDLInit, SDLInitGive, ffi, ffiGive, Window, WindowGive, AllWindows, AllWindowsGive, WindowRender, WindowRenderGive)
	local ReturnValue
	while SDL.Library.pollEvent(Space.Event) ~=0 do
		if Space.Event.type == SDL.Library.QUIT then
			return true
		elseif Space.Event.type == SDL.Library.TEXTINPUT then
		Space.Text = Space.Text .. ffi.Library.string(Space.Event.text.text)
		print(Space.Text)
		elseif Space.Event.type == SDL.Library.WINDOWEVENT then
			if Space.Event.window.event == SDL.Library.WINDOWEVENT_CLOSE then
				Window.Library.Destroy(Space.Event.window.windowID, unpack(WindowGive))
				for k,v in pairs(AllWindows.Space.Windows) do
					if v.WindowID == SDL.Library.getWindowFromID(Space.Event.window.windowID) then
						table.remove(AllWindows.Space.Windows, k)
					end
				end
			elseif Space.Event.window.event == SDL.Library.WINDOWEVENT_RESIZED then
				for k,v in pairs(AllWindows.Space.Windows) do
					if v.WindowID == SDL.Library.getWindowFromID(Space.Event.window.windowID) then
						SDL.Library.GetWindowSize(SDL.Library.getWindowFromID(Space.Event.window.windowID), v.Width, v.Height)
					end
				end
			end
		elseif Space.Event.type == SDL.Library.KEYDOWN and Space.ButtonsDown[ffi.Library.string(SDL.Library.getKeyName(Space.Event.key.keysym.sym))] then
			local v = Space.ButtonsDown[ffi.Library.string(SDL.Library.getKeyName(Space.Event.key.keysym.sym))]
			if type(v.Pass) == "table" then
				for a,b in pairs(v.Pass) do
					table.insert(Space.Pass, Space.PlusRequ[b])
					table.insert(Space.Pass, Space.PlusRequ[b.."Give"])
				end
			end
			local Ran, Buffer = pcall(v.Command, unpack(Space.Pass))
			Space.Pass = {}
			ReturnValue = ReturnValue or Buffer
			if Ran and ReturnValue then
				return ReturnValue
			end
		elseif Space.Event.type == SDL.Library.KEYUP and Space.ButtonsUp[ffi.Library.string(SDL.Library.getKeyName(Space.Event.key.keysym.sym))] then
			local v = Space.ButtonsUp[ffi.Library.string(SDL.Library.getKeyName(Space.Event.key.keysym.sym))]
			if type(v.Pass) == "table" then
				for a,b in pairs(v.Pass) do
					table.insert(Space.Pass, Space.PlusRequ[b])
					table.insert(Space.Pass, Space.PlusRequ[b.."Give"])
				end
			end
			local Ran, Buffer = pcall(v.Command, unpack(Space.Pass))
			Space.Pass = {}
			ReturnValue = ReturnValue or Buffer
			if Ran and ReturnValue then
				return ReturnValue
			end
		end
	end
end
return GiveBack
