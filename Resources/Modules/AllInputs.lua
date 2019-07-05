local GiveBack = {}

--Creates Requirements based on the needs of the inputs
local function NotInList(List, Object)
	for ak=1,#List do
		if List[ak] == Object then
			return false
		end
	end
	return true
end
local LON = require("./Resources/Modules/LON")
local Inputs = LON.DecodeFromFile("AllInputs.lon")
GiveBack.Requirements =
{"SDL", "SDLInit", "ffi", "Window", "AllWindows", "WindowRender", "AllDevices"}
if type(Inputs) == "table" then
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
end
Inputs = nil

--Sets up inputs based on button presses and releases
function GiveBack.Start(Configurations, Arguments)
	local Space, SDL, SDLInit, SDLInitGive, ffi, Window, WindowGive,
	AllWindows, AllWindowsGive, WindowRender, WindowRenderGive = Arguments[1],
	Arguments[2], Arguments[4], Arguments[5], Arguments[6], Arguments[8],
	Arguments[9], Arguments[10], Arguments[11], Arguments[12], Arguments[13]
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
	Space.Inputs = Configurations
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

--Takes inputs and runs commands if there is button for it
--TODO: Answer to every type of input
function GiveBack.Input(Arguments)
	local Space, SDL, ffi, Window, WindowGive, AllWindows, AllWindowsGive,
	AllDevices = Arguments[1], Arguments[2], Arguments[6], Arguments[8],
	Arguments[9],	Arguments[10], Arguments[11], Arguments[14]
	local ReturnValue
	while SDL.Library.pollEvent(Space.Event) ~=0 do
		if Space.Event.type == SDL.Library.QUIT then
			return true
		elseif Space.Event.type == SDL.Library.TEXTINPUT then
		Space.Text = Space.Text .. ffi.Library.string(Space.Event.text.text)
		print(Space.Text)
		elseif Space.Event.type == SDL.Library.WINDOWEVENT then
			if Space.Event.window.event == SDL.Library.WINDOWEVENT_CLOSE then
				local EventWindowID = Space.Event.window.windowID
				for ak=1,#AllWindows.Space.Windows do
					local av = AllWindows.Space.Windows[ak]
					if av.WindowID == SDL.Library.getWindowFromID(EventWindowID) then
						table.remove(AllWindows.Space.Windows, ak)
						Window.Library.Destroy(av, WindowGive)
						break
					end
				end
			elseif Space.Event.window.event == SDL.Library.WINDOWEVENT_RESIZED then
				local EventWindowID = Space.Event.window.windowID
				for ak=1,#AllWindows.Space.Windows do
					local av = AllWindows.Space.Windows[ak]
					if av.WindowID == SDL.Library.getWindowFromID(EventWindowID) then
						SDL.Library.GetWindowSize(SDL.Library.getWindowFromID(
						EventWindowID), av.Width, av.Height)
					end
				end
			end
		elseif Space.Event.type == SDL.Library.KEYDOWN then
			local Key = ffi.Library.string(
			SDL.Library.getKeyName(Space.Event.key.keysym.sym))
			if Space.ButtonsDown[Key] then
				local v = Space.ButtonsDown[Key]
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
			for ak=1,#AllDevices.Space.Devices do
				local av = AllDevices.Space.Devices[ak]
				if av.ButtonsDown[Key] then
					pcall(av.ButtonsDown[Key].Command, av)
				end
			end
		elseif Space.Event.type == SDL.Library.KEYUP then
			local Key = ffi.Library.string(
			SDL.Library.getKeyName(Space.Event.key.keysym.sym))
			if Space.ButtonsUp[Key] then
				local v = Space.ButtonsUp[Key]
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

--Removes an input
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
