--Depends on: Physics
local GiveBack = {}
function GiveBack.Main(Time, Arguments)
	local Physics, PhysicsGive = Arguments[1], Arguments[2]
	Physics.Library.Physics(Time, PhysicsGive)
	--[[
	GiveBack.Exit = false
	GiveBack.LoadModule = false
	GiveBack.ModulesInMain = {}
	GiveBack.ModulesInMain[1] = "AllInputs"
	return GiveBack.LoadModule, GiveBack.ModulesInMain, GiveBack.Exit
	--]]
	return false
end
GiveBack.Requirements = {"Physics"}
return GiveBack
