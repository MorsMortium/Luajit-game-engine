--Depends on: json
package.path = './Resources/Modules/?.lua;./Resources/Modules/?;' .. package.path
io.output():setvbuf("no")
local Order = {}
local Data = {}
Data.JSON = {Library = require("json")}
local Requirements = Data.JSON.Library:DecodeFromFile("./Resources/Configurations/Requirements.json")
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
	if type(Table) == "table" and type(Table.Library) == "table" and type(Table.Library.Requirements) == "table" then
		for ak=1,#Table.Library.Requirements do
			local av = Table.Library.Requirements[ak]
			if type(MainTable[av]) == "table" and type(MainTable[av].Library) == "table" and type(MainTable[av].Library.Requirements) == "table" then
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
				if type(av) == "table" and type(av.Library) == "table" and type(av.Library.Requirements) == "table" then
					for bk=1,#av.Library.Requirements do
						local bv = av.Library.Requirements[bk]
						if Data[bv] == nil or Data[bv].Started ~= true then
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
		if type(Data[av]) == "table" and type(Data[av].Library) == "table" and type(Data[av].Library.Stop) == "function" then
			Data[av].Library.Stop(RequCalc(Data, Data[av]))
		end
		Data[av] = nil
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
		LoadModule, Modules, MainExit = Main(MainGive)
		InputExit = Input(InputGive)
		if LoadModule then
			LoadModules(Modules)
			LoadModule = false
		end
		if LastScore < Score then
			LastScore = Score
			print("Score:", Score)
		end
		if Number % Niceness == 0 and Data.AllDevices.Space.Devices[1].Name == "SpaceShip" then
			Data.AllDevices.Space.Devices[1].Objects[1].Powers[9].Active = true
		end
		if Number % 1500 == 0 and Niceness ~= 1 and Data.AllDevices.Space.Devices[1].Name == "SpaceShip" then
			Niceness = Niceness - 1
			print("Niceness:", Niceness)
		end
		CameraRender(CameraRenderGive)
		WindowRender(Number, WindowRenderGive)
		Number = Number + 1
	end
	Stop()
end
Game()
