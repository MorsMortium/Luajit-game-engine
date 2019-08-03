--Depends on: LON
io.output():setvbuf("no")
local Data, Order = {}, {}
Data.LON =
{Library = require("./Resources/Modules/LON")}
Data.LauncherUtilities =
{Library = require("./Resources/Modules/LauncherUtilities")}
local LauncherData =
Data.LON.Library.DecodeFromFile("Resources/Configurations/Launcher.lon")
local Requirements = LauncherData.Requirements
package.path = LauncherData.ModulePath .. package.path
Data.LON.Library.Path = LauncherData.ConfigurationPath
local function Start(Requirements, Data, Order)
	local LauncherUtilities = Data.LauncherUtilities.Library
	local Configurations = LauncherUtilities.RequireAll(Requirements, Data)
	local Pending = LauncherUtilities.StartAll(Data, Order, Configurations)
	if Pending then
		LauncherUtilities.PrintBadModules(Data)
		LauncherUtilities.PrintCauses(Data)
	end
end
local function Stop(Data, Order)
	local LauncherUtilities = Data.LauncherUtilities.Library
	LauncherUtilities.StopAll(Data, Order)
end
local function Game(Requirements, Data, Order)
	local Number, Time, MainExit, InputExit, LoadModule, Modules = 0, 0, false,
	false, false
	Start(Requirements, Data, Order)
	local LoadLibrary = Data.LauncherUtilities.Library.LoadLibrary
	local Input = {LoadLibrary("AllInputs", "Input", Data)}
	local Main = {LoadLibrary("Main", "Main", Data)}
	local WindowRender = {LoadLibrary("AllWindowRenders", "RenderAllWindows", Data)}
	local CameraRender = {LoadLibrary("AllCameraRenders", "RenderAllCameras", Data)}
	local SDL = Data.SDL.Library
	local LastTime = SDL.getTicks()
	while not (MainExit or InputExit) do
		Time = SDL.getTicks() - LastTime
		if 0 < Time then
			LastTime = SDL.getTicks()
			MainExit, LoadModule, Modules = Main[1](Time, Main[2])
			if LoadModule then
				LoadModules(Modules)
				LoadModule = false
			end
			CameraRender[1](CameraRender[2])
			WindowRender[1](Number, WindowRender[2])
			InputExit = Input[1](Input[2])
			Number = Number + 1
		end
	end
	Stop(Data, Order)
end
Game(Requirements, Data, Order)
