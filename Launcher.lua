--Depends on: LON, LauncherUtilities
io.output():setvbuf("no")
local require = require
local Data, Modules = {}
local LON = require("./Resources/Modules/LON")
local LauncherData = LON.DecodeFromFile("Resources/Configurations/Launcher.lon")
package.path = LauncherData.ModulePath .. package.path
LON.SetPath(LauncherData.ConfigurationPath)
local LauncherUtilities = require("LauncherUtilities")
Data.LON = {Library = LON, Started = true}
Data.LauncherUtilities = {Library = LauncherUtilities, Started = true}
Modules = LauncherData.Modules
LON, LauncherData, LauncherUtilities = nil, nil, nil
local function Game(Modules, Data)
	local Number, Time, MainExit, InputExit, LoadModule, ModulesTable = 0, 0
	local LauncherUtilities = Data.LauncherUtilities.Library
	LauncherUtilities.StartAll(Data, Modules)
	local LoadLibrary = LauncherUtilities.LoadLibrary
	local LoadModules = LauncherUtilities.LoadModules
	local Input = LoadLibrary("AllInputs", "Input", Data)
	local Main = LoadLibrary("Main", "Main", Data)
	local SDL = Data.SDL.Library
	local LastTime = SDL.getTicks()
	while not (MainExit or InputExit) do
		Time = SDL.getTicks() - LastTime
		if 0 < Time then
			LastTime = SDL.getTicks()
			MainExit, LoadModule, ModulesTable = Main(Time, Number)
			if (not MainExit) and LoadModule then
				LoadModules(ModulesTable, Data)
				LoadModule = false
			end
			InputExit = Input()
			Number = Number + 1
		end
	end
	LauncherUtilities.StopAll(Data)
end
Game(Modules, Data)
