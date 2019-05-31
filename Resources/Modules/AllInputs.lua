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
local Inputs = JSON:DecodeFromFile("AllInputs.json")
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
	local Space, JSON, SDL, SDLInit, SDLInitGive, ffi, Window, WindowGive,
	AllWindows, AllWindowsGive, WindowRender, WindowRenderGive = Arguments[1],
	Arguments[2], Arguments[4], Arguments[6], Arguments[7], Arguments[8],
	Arguments[10], Arguments[11], Arguments[12], Arguments[13], Arguments[14],
	Arguments[15]
	Space.PlusRequ = {}
	Space.Pass = {}
	for ak=1, #GiveBack.Requirements do
		local av = GiveBack.Requirements[ak]
		Space.PlusRequ[av] = Arguments[2 * ak]
		Space.PlusRequ[av.."Give"] = Arguments[2 * ak + 1]
	end
	Space.PlusRequ["AllInputs"] = {}
	Space.PlusRequ["AllInputs"].Library = GiveBack
	Space.PlusRequ["AllInputs"].Space = Space
	Space.PlusRequ["AllInputsGive"] = Arguments
	Space.Inputs = JSON.Library:DecodeFromFile("AllInputs.json")
	Space.ButtonsDown = {}
	Space.ButtonsUp = {}
	if type(Space.Inputs) == "table" then
		for ak=1,#Space.Inputs do
			local av = Space.Inputs[ak]
			av.Command = loadstring(av.String)
			if av.Type == "Up" then
				Space.ButtonsUp[av.Button] = av
			else
				Space.ButtonsDown[av.Button] = av
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
	local Space, SDL, ffi, Window, WindowGive, AllWindows, AllWindowsGive =
	Arguments[1], Arguments[4], Arguments[8], Arguments[10], Arguments[11],
	Arguments[12], Arguments[13]
	local ReturnValue
	while SDL.Library.pollEvent(Space.Event) ~=0 do
		if Space.Event.type == SDL.Library.QUIT then
			return true
		elseif Space.Event.type == SDL.Library.TEXTINPUT then
		Space.Text = Space.Text .. ffi.Library.string(Space.Event.text.text)
		print(Space.Text)
		elseif Space.Event.type == SDL.Library.WINDOWEVENT then
			if Space.Event.window.event == SDL.Library.WINDOWEVENT_CLOSE then
				for ak=1,#AllWindows.Space.Windows do
					local av = AllWindows.Space.Windows[ak]
					if av.WindowID == SDL.Library.getWindowFromID(Space.Event.window.windowID) then
						table.remove(AllWindows.Space.Windows, ak)
						break
					end
				end
				SDL.Library.destroyRenderer(SDL.Library.getRenderer(SDL.Library.getWindowFromID(Space.Event.window.windowID)))
				--print(ffi.Library.string(SDL.Library.getError())) TODO
				Window.Library.Destroy(Space.Event.window.windowID, WindowGive)
			elseif Space.Event.window.event == SDL.Library.WINDOWEVENT_RESIZED then
				for ak=1,#AllWindows.Space.Windows do
					local av = AllWindows.Space.Windows[ak]
					if av.WindowID == SDL.Library.getWindowFromID(Space.Event.window.windowID) then
						SDL.Library.GetWindowSize(SDL.Library.getWindowFromID(Space.Event.window.windowID), av.Width, av.Height)
					end
				end
			end
		elseif Space.Event.type == SDL.Library.KEYDOWN and
		Space.ButtonsDown[ffi.Library.string(SDL.Library.getKeyName(Space.Event.key.keysym.sym))] then
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
		elseif Space.Event.type == SDL.Library.KEYUP and
		Space.ButtonsUp[ffi.Library.string(SDL.Library.getKeyName(Space.Event.key.keysym.sym))] then
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
	if #AllWindows.Space.Windows == 0 then
		return true
	end
end
function GiveBack.Add(Command, Arguments)
	local Space = Arguments[1]
	local Object = {}
	if type(Command) == "table" and type(Command.String) == "string" and
	type(Command.Button) == "string" then
		Object.Command = loadstring(Command.String)
		if Command.Type == "Up" then
			Space.ButtonsUp[Command.Button] = Object
			Space.ButtonsUp[Command.Button].Pass = Command.Pass
		else
			Space.ButtonsDown[Command.Button] = Object
			Space.ButtonsDown[Command.Button].Pass = Command.Pass
		end
	end
end
function GiveBack.Remove(Letter, Type,  Arguments)
	local Space = Arguments[1]
	if type(Letter) == "string" then
		if Type == "Up" then
			Space.ButtonsUp[Letter] = nil
		elseif Type == "Down" then
			Space.ButtonsDown[Letter] = nil
		end
	end
end
return GiveBack
