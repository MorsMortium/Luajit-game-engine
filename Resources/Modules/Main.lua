--Depends on: nothing
local GiveBack = {}
function GiveBack.Main(Physics, PhysicsGive)
	Physics.Library.Physics(unpack(PhysicsGive))
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
