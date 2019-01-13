--Depends on: json
--[[
--Noerror
local function a(...)
	print(unpack({...}))
end
error = a
a = nil
--]]
package.path = './Resources/Modules/?.lua;./Resources/Modules/?;' .. package.path
io.output():setvbuf("no")
local Order = {}
local Data = {}
Data.JSON = {Library = require("json")}
local Requirements = Data.JSON.Library:DecodeFromFile("./Resources/Configurations/Requirements.json")
local function LoadModules(Modules)
	for k, v in pairs(Modules) do
		Data[v.Name].Library = nil
		Data[v.Name].Library = require(v.Path)
	end
end
local function RequireAll()
	for k, v in pairs(Requirements) do
		Data[v.Name] = {}
		Data[v.Name].Library = require(v.Path)
		Data[v.Name].StartStopSpace = v.StartStopSpace
	end
end
local function RequCalc(MainTable, Table)
	local Give = {}
	if type(Table) == "table" and type(Table.Space) == "table" then
		Give[1] = Table.Space
	end
	if type(Table) == "table" and type(Table.Library) == "table" and type(Table.Library.Requirements) == "table" then
		for k, v in pairs(Table.Library.Requirements) do
			if type(MainTable[v]) == "table" and type(MainTable[v].Library) == "table" and type(MainTable[v].Library.Requirements) == "table" then
				Give[#Give + 1] = MainTable[v]
				Give[#Give + 1] = RequCalc(MainTable, MainTable[v])
			else
				Give[#Give + 1] = MainTable[v]
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
		for k, v in pairs(Data) do
			if not v.Started then
				local Allrequisgood = true
				if type(v) == "table" and type(v.Library) == "table" and type(v.Library.Requirements) == "table" then
					for a,b in pairs(v.Library.Requirements) do
						if Data[b] == nil or Data[b].Started ~= true then
							Allrequisgood = false
						end
					end
				end
				if Allrequisgood then
					Order[#Order + 1] = k
					if v.StartStopSpace then
						Change = true
						v.Space = {}
						v.Library.Start(unpack(RequCalc(Data, v)))
						v.Started = true
					else
						Change = true
						v.Started = true
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
		for k, v in pairs(Data) do
			if v.Started == nil then
				NotLoaded[#NotLoaded + 1] = k
				print(k)
			end
		end
		print("Needed by:")
		for k,v in pairs(Data) do
			if not v.Started then
				local Needs = false
				for a,b in pairs(NotLoaded) do
					if k == b then
						Needs = true
						break
					end
				end
				if Needs then
					print(k)
				end
			end
		end
	end
end
local function Stop()
	for i=(#Order),1,-1 do
		if type(Data[Order[i]]) == "table" and type(Data[Order[i]].Library) == "table" and type(Data[Order[i]].Library.Stop) == "function" then
			Data[Order[i]].Library.Stop(unpack(RequCalc(Data, Data[Order[i]])))
		end
		Data[Order[i]] = nil
	end
	Data = nil
end
local function Game()
	local Number = 0
	local MainExit = false
	local InputExit = false
	local LoadModule = false
	local Modules
	local Input
	local CameraRender
	local CameraRenderGive
	local WindowRender
	local WindowRenderGive
	local Main
	local InputGive
	local MainGive
	Start()
	if type(Data.Main) == "table" and Data.Main.Started then
		Main = Data.Main.Library.Main
		MainGive = RequCalc(Data, Data.Main)
	else
		Main = loadstring("if not noMainprint then print('Main not found') noMainprint = true end")
		MainGive = {}
	end
	if type(Data.AllInputs) == "table" and Data.AllInputs.Started then
		Input = Data.AllInputs.Library.Input
		InputGive = RequCalc(Data, Data.AllInputs)
	else
		Input = loadstring("if not noInputprint then print('Input not found') noInputprint = true end")
		InputGive = {}
	end
	if type(Data.AllWindowRenders) == "table" and Data.AllWindowRenders.Started then
		WindowRender = Data.AllWindowRenders.Library.Render
		WindowRenderGive = RequCalc(Data, Data.AllWindowRenders)
	else
		WindowRender = loadstring("if not noRenderprint then print('Render not found') noRenderprint = true end")
		WindowRenderGive = {}
	end
	if type(Data.AllCameras) == "table" and Data.AllCameras.Started then
		CameraRender = Data.AllCameras.Library.RenderAllCameras
		CameraRenderGive = RequCalc(Data, Data.AllCameras)
	else
		CameraRender = loadstring("if not noRenderprint then print(\"Render not found\") noRenderprint = true end")
		CameraRenderGive = {}
	end
	Score = 0
	local LastScore = 0
	local Niceness = 100
	while not (MainExit or InputExit) do
		LoadModule, Modules, MainExit = Main(unpack(MainGive))
		InputExit = Input(unpack(InputGive))
		if LoadModule then
			LoadModules(Modules)
			LoadModule = false
		end
		if LastScore < Score then
			LastScore = Score
			print(Score)
		end
		if Number % Niceness == 0 and Data.AllDevices.Space.Devices[1].Name == "SpaceShip" then
			--Data.AllDevices.Space.Devices[1].Objects[1].Powers[9].Active = true
		end
		if Number % 1500 == 0 and Niceness ~= 1 and Data.AllDevices.Space.Devices[1].Name == "SpaceShip" then
			Niceness = Niceness - 1
			print("Niceness:", Niceness)
		end
		CameraRender(unpack(CameraRenderGive))
		WindowRender(Number, unpack(WindowRenderGive))
		Number = Number + 1
	end
	Stop()
end
Game()
