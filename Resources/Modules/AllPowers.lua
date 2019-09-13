return function(args)
	local Space, Power, AllDevices = args[1], args[2], args[3]
	local Powers, Devices, remove = Power.Library.Powers, AllDevices.Space.Devices,
	table.remove
	local GiveBack = {}

	function GiveBack.Reload(args)
		Space, Power, AllDevices = args[1], args[2], args[3]
		Powers, Devices, remove = Power.Library.Powers, AllDevices.Space.Devices,
		table.remove
	end

	--Checks whether every Power has all it's functions, if not, it deletes it
	function GiveBack.Start(Configurations)
		for ak,av in pairs(Powers) do
			if type(av.DataCheck) ~= "function" or type(av.Use) ~= "function" then
				Powers[ak] = nil
			end
		end
		io.write("AllPowers Started\n")
	end

	--DataChecks every new Device's every Object, needed because Summon's AllDevices
	--dependency
	function GiveBack.DataCheckNewDevicesPowers(Time)
		local CreatedObjects = AllDevices.Space.CreatedObjects
		for bk=1,#CreatedObjects do
			local bv = CreatedObjects[bk]
			bv.PowerChecked = true
			local ck = 1
			while ck <= #bv.Powers do
				local cv = bv.Powers[ck]
				if Powers[cv.Type] then
					bv.Powers[ck] =
					Powers[cv.Type].DataCheck(Devices, bv.Parent, bv, cv, Time)
					ck = ck + 1
				else
					remove(bv.Powers, ck)
					if bv.OnCollisionPowers[ck] then
						remove(bv.OnCollisionPowers, ck)
					end
				end
			end
		end
	end

	--Uses every Power that is active
	function GiveBack.UseAllPowers(Time)
		local ak = 1
		while ak <= #Devices do
			local av = Devices[ak]
			local DExit
			local bk = 1
			while bk <= #av.Objects do
				local bv = av.Objects[bk]
				local OExit
				if bv.PowerChecked then
					for ck=1,#bv.Powers do
						local cv = bv.Powers[ck]
						if cv.Active then
							OExit, DExit = Powers[cv.Type].Use(Devices, av, bv, cv, Time)
						end
						if OExit then break end
					end
				end
				if DExit then break elseif not OExit then bk = bk + 1 end
			end
			if not DExit then ak = ak + 1 end
		end
	end
	function GiveBack.Stop()
		io.write("AllPowers Stopped\n")
	end
	return GiveBack
end
