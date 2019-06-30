--Depends on: json
package.path = './Resources/Modules/?.lua;./Resources/Modules/?;' .. package.path
io.output():setvbuf("no")
local Order = {}
local Data = {}
Data.JSON = {Library = require("json")}
Data.JSON.Library:SetPath("./Resources/Configurations/")
local Requirements = Data.JSON.Library:DecodeFromFile("Requirements.json")
local function LoadModules(Modules)
	for ak=1,#Modules do
		local av = Modules[ak]
		Data[av.name].Library = nil
		Data[av.name].Library = require(av.Path)
	end
end
local function RequireAll()
	for ak=1,#Requirements do
		local av = Requirements[ak]
		Data[av.Name] = {}
		Data[av.Name].Library = require(av.Path)
		Data[av.Name].StartStopSpace = av.StartStopSpace
	end
end
local function RequCalc(MainTable, Table)
	local Give = {}
	if type(Table) == "table" and type(Table.Space) == "table" then
		Give[1] = Table.Space
	end
	if type(Table) == "table" and type(Table.Library) == "table" and
	type(Table.Library.Requirements) == "table" then
		for ak=1,#Table.Library.Requirements do
			local av = Table.Library.Requirements[ak]
			if type(MainTable[av]) == "table" and
			type(MainTable[av].Library) == "table" and
			type(MainTable[av].Library.Requirements) == "table" then
				Give[#Give + 1] = MainTable[av]
				Give[#Give + 1] = RequCalc(MainTable, MainTable[av])
			else
				Give[#Give + 1] = MainTable[av]
				Give[#Give + 1] = true
			end
		end
	end
	return Give
end
local function Start()
	RequireAll()
	local Pending
	local Change = true
	local turn = 0
	while Change do
		turn = turn + 1
		Pending = false
		Change = false
		for ak, av in pairs(Data) do
			if not av.Started then
				local Allrequisgood = true
				if type(av) == "table" and type(av.Library) == "table" and
				type(av.Library.Requirements) == "table" then
					for bk=1,#av.Library.Requirements do
						local bv = av.Library.Requirements[bk]
						if Data[bv] == nil or not Data[bv].Started then
							Allrequisgood = false
						end
					end
				end
				if Allrequisgood then
					Order[#Order + 1] = ak
					if av.StartStopSpace then
						Change = true
						av.Space = {}
						av.Library.Start(RequCalc(Data, av))
						av.Started = true
					else
						Change = true
						av.Started = true
					end
				else
					Pending = true
				end
			end
		end
	end
	if Pending then
		local NotLoaded = {}
		print("Error, not loaded Modules:")
		for ak, av in pairs(Data) do
			if av.Started == nil then
				NotLoaded[#NotLoaded + 1] = ak
				print(ak)
			end
		end
		print("Needed by:")
		for ak,av in pairs(Data) do
			if not av.Started then
				local Needs = false
				for bk=1,#NotLoaded do
					local bv = NotLoaded[bk]
					if ak == bv then
						Needs = true
						break
					end
				end
				if Needs then
					print(ak)
				end
			end
		end
	end
end
local function Stop()
	for ak=(#Order),1,-1 do
		local av = Order[ak]
		if type(Data[av]) == "table" and type(Data[av].Library) == "table" and
		type(Data[av].Library.Stop) == "function" then
			Data[av].Library.Stop(RequCalc(Data, Data[av]))
		end
		Data[av] = nil
	end
	Data = nil
end
local function LoadLibrary(Name, Command)
	if type(Data[Name]) == "table" and Data[Name].Started then
		return Data[Name].Library[Command], RequCalc(Data, Data[Name])
	end
	return loadstring("if not no" .. Name .. "print then print(" .. Name ..
	"' not found') no" .. Name .. "print = true end"), {}
end
local function Game()
	local Number, Time, MainExit, InputExit = 0, 0, false, false
	local LoadModule, Modules = false
	Start()
	local Input = {LoadLibrary("AllInputs", "Input")}
	local Main = {LoadLibrary("Main", "Main")}
	local WindowRender = {LoadLibrary("AllWindowRenders", "RenderAllWindows")}
	local CameraRender = {LoadLibrary("AllCameraRenders", "RenderAllCameras")}
	local SDL = Data.SDL.Library
	local LastTime = SDL.getTicks()
	while not (MainExit or InputExit) do
		Time = SDL.getTicks() - LastTime
		if 0 < Time then
			LastTime = SDL.getTicks()
			LoadModule, Modules, MainExit = Main[1](Time, Main[2])
			if LoadModule then
				LoadModules(Modules)
				LoadModule = false
			end
			CameraRender[1](CameraRender[2])
			WindowRender[1](Number, WindowRender[2])
			Number = Number + 1
		end
		InputExit = Input[1](Input[2])
	end
	Stop()
end
Game()
