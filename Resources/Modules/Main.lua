return function(args)
	local Physics = args[1]
	local GiveBack = {}

	function GiveBack.Reload(args)
		Physics = args[1]
  end

	function GiveBack.Main(Time)
		Physics.Library.Physics(Time)
		--[[
		local modulesta = {}
		modulesta[1] = {}
		modulesta[1].Path = "General"
		modulesta[1].Name = "General"
		if Tessst then
			Tessst = false
			return false, true, modulesta
			--body...
		end
		--]]
		return false
	end
	return GiveBack
end
