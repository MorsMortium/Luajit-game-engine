local GiveBack = {}
local function NotInList(List, Object)
	for ak=1,#List do
		if List[ak] == Object then
			return false
		end
	end
	return true
end
local JSON = require("json")
local Inputs = JSON:DecodeFromFile("./Resources/Configurations/AllInputs.json")
GiveBack.Requirements = {"JSON", "SDL", "SDLInit", "ffi", "Window", "AllWindows", "WindowRender"}
for ak=1,#Inputs do
	local av = Inputs[ak]
	if type(av.Pass) == "table" then
		for bk=1,#av.Pass do
			local bv = av.Pass[bk]
			if bv ~= "AllInputs" and NotInList(GiveBack.Requirements, bv) then
				GiveBack.Requirements[#GiveBack.Requirements + 1] = bv
			end
		end
	end
end
Inputs = nil
function GiveBack.Start(Arguments)
	local Space = Arguments[1]
	local JSON = Arguments[2]
	local SDL = Arguments[4]
	local SDLInit = Arguments[6]
	local SDLInitGive = Arguments[7]
	local ffi = Arguments[8]
	local Window = Arguments[10]
	local WindowGive = Arguments[11]
	local AllWindows = Arguments[12]
	local AllWindowsGive = Arguments[13]
	local WindowRender = Arguments[14]
	local WindowRenderGive = Arguments[15]
	Space.PlusRequ = {}
	Space.Pass = {}
	for ak=7, #GiveBack.Requirements do
		local av = GiveBack.Requirements[ak]
		Space.PlusRequ[av] = Arguments[2 * ak]
		Space.PlusRequ[av.."Give"] = Arguments[2 * ak + 1]
	end
	Space.PlusRequ["AllInputs"] = {}
	Space.PlusRequ["AllInputs"].Library = GiveBack
	Space.PlusRequ["AllInputs"].Space = Space
	Space.PlusRequ["AllInputsGive"] = {Space, JSON, nil, SDL, nil, SDLInit, SDLInitGive, ffi, nil, Window, WindowGive, AllWindows, AllWindowsGive}
	Space.Inputs = JSON.Library:DecodeFromFile("./Resources/Configurations/AllInputs.json")
	Space.ButtonsDown = {}
	Space.ButtonsUp = {}
	if type(Space.Inputs) == "table" then
		for ak=1,#Space.Inputs do
			local av = Space.Inputs[ak]
			av.Command = loadstring(av.String)
			if av.Type == "Down" then
				Space.ButtonsDown[av.Button] = av
			end
			if av.Type == "Up" then
				Space.ButtonsUp[av.Button] = av
			end
		end
	end
	Space.Inputs = nil
	Space.Event = ffi.Library.new("SDL_Event")
	Space.Text = ""
	print("AllInputs Started")
end
function GiveBack.Stop(Arguments)
	local Space = Arguments[1]
	for ak,av in pairs(Space) do
		Space[ak] = nil
	end
	print("AllInputs Stopped")
end
function GiveBack.Input(Arguments)
	local Space, SDL, ffi, Window, WindowGive, AllWindows = Arguments[1], Arguments[4], Arguments[8], Arguments[10], Arguments[11], Arguments[12]
	local ReturnValue
	while SDL.Library.pollEvent(Space.Event) ~=0 do
		if Space.Event.type == SDL.Library.QUIT then
			return true
		elseif Space.Event.type == SDL.Library.TEXTINPUT then
		Space.Text = Space.Text .. ffi.Library.string(Space.Event.text.text)
		print(Space.Text)
		elseif Space.Event.type == SDL.Library.WINDOWEVENT then
			if Space.Event.window.event == SDL.Library.WINDOWEVENT_CLOSE then
				Window.Library.Destroy(Space.Event.window.windowID, WindowGive)
				for ak=1,#AllWindows.Space.Windows do
					local av = AllWindows.Space.Windows[ak]
					if av.WindowID == SDL.Library.getWindowFromID(Space.Event.window.windowID) then
						table.remove(AllWindows.Space.Windows, ak)
					end
				end
			elseif Space.Event.window.event == SDL.Library.WINDOWEVENT_RESIZED then
				for ak=1,#AllWindows.Space.Windows do
					local av = AllWindows.Space.Windows[ak]
					if av.WindowID == SDL.Library.getWindowFromID(Space.Event.window.windowID) then
						SDL.Library.GetWindowSize(SDL.Library.getWindowFromID(Space.Event.window.windowID), av.Width, av.Height)
					end
				end
			end
		elseif Space.Event.type == SDL.Library.KEYDOWN and Space.ButtonsDown[ffi.Library.string(SDL.Library.getKeyName(Space.Event.key.keysym.sym))] then
			local v = Space.ButtonsDown[ffi.Library.string(SDL.Library.getKeyName(Space.Event.key.keysym.sym))]
			if type(v.Pass) == "table" then
				for ak=1,#v.Pass do
					local av = v.Pass[ak]
					Space.Pass[#Space.Pass + 1] = Space.PlusRequ[av]
					Space.Pass[#Space.Pass + 1] = Space.PlusRequ[av.."Give"]
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
				for ak=1,#v.Pass do
					local av = v.Pass[ak]
					Space.Pass[#Space.Pass + 1] = Space.PlusRequ[av]
					Space.Pass[#Space.Pass + 1] = Space.PlusRequ[av.."Give"]
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
