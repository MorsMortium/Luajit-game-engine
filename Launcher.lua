--Depends on: LON
io.output():setvbuf("no")
local require = require
local Data = {}
Data.LON =
{Library = require("./Resources/Modules/LON"), Started = true}
Data.LauncherUtilities =
{Library = require("./Resources/Modules/LauncherUtilities"), Started = true}
local LauncherData =
Data.LON.Library.DecodeFromFile("Resources/Configurations/Launcher.lon")
local Modules = LauncherData.Modules
package.path = LauncherData.ModulePath .. package.path
Data.LON.Library.SetPath(LauncherData.ConfigurationPath)
local function Start(Modules, Data)
	local LauncherUtilities = Data.LauncherUtilities.Library
	local Pending = LauncherUtilities.StartAll(Data, Modules)
	if Pending then
		LauncherUtilities.PrintBadModules(Data)
		LauncherUtilities.PrintCauses(Data)
	end
end
local function Stop(Data)
	local LauncherUtilities = Data.LauncherUtilities.Library
	LauncherUtilities.StopAll(Data)
end
local function Game(Modules, Data)
	local Number, Time, MainExit, InputExit, LoadModule, ModulesTable = 0, 0,
	false, false, false
	Start(Modules, Data)
	local LoadLibrary = Data.LauncherUtilities.Library.LoadLibrary
	local LoadModules = Data.LauncherUtilities.Library.LoadModules
	local Input = LoadLibrary("AllInputs", "Input", Data)
	local Main = LoadLibrary("Main", "Main", Data)
	local WindowRender = LoadLibrary("AllWindowRenders", "RenderAllWindows", Data)
	local CameraRender = LoadLibrary("AllCameraRenders", "RenderAllCameras", Data)
	local SDL = Data.SDL.Library
	local LastTime = SDL.getTicks()
	while not (MainExit or InputExit) do
		Time = SDL.getTicks() - LastTime
		if 0 < Time then
			LastTime = SDL.getTicks()
			MainExit, LoadModule, ModulesTable = Main(Time)
			if (not MainExit) and LoadModule then
				LoadModules(ModulesTable, Data)
				LoadModule = false
			end
			CameraRender()
			WindowRender(Number)
			InputExit = Input()
			Number = Number + 1
		end
	end
	Stop(Data)
end
Game(Modules, Data)
