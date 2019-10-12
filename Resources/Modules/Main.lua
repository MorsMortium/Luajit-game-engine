return function(args)
	local Physics, AllCameraRenders, AllWindowRenders, AllDevices = args[1],
	args[2], args[3], args[4]
	local Physics, RenderAllCameras, RenderAllWindows, ClearObjectChanges =
	Physics.Library.Physics, AllCameraRenders.Library.RenderAllCameras,
	AllWindowRenders.Library.RenderAllWindows,
	AllDevices.Library.ClearObjectChanges

	local GiveBack = {}

	function GiveBack.Main(Time, Number)
		Physics(Time)
		RenderAllCameras()
		if RenderAllWindows(Number) then
			--return true --Performance benchmark
		end
		ClearObjectChanges()
		--[[
		local Modules = {}
		Modules[1] = {}
		Modules[1].Path = "General"
		Modules[1].Name = "General"
		if Test then
			Test = nil
			return false, true, Modules
		end
		--]]
		return false
	end
	return GiveBack
end
