--Depends on: nothing
local GiveBack = {}
function GiveBack.Main(Arguments)
	local Physics, PhysicsGive = Arguments[1], Arguments[2]
	Physics.Library.Physics(PhysicsGive)
	--[[
	GiveBack.Exit = false
	GiveBack.LoadModule = false
	GiveBack.ModulesInMain = {}
	GiveBack.ModulesInMain[1] = "Input"
	return GiveBack.LoadModule, GiveBack.ModulesInMain, GiveBack.Exit
	--]]
	return false
end
GiveBack.Requirements = {"Physics"}
return GiveBack
