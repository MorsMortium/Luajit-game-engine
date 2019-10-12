return function(args)
	local Space, Power, AllDevices, Globals = args[1], args[2], args[3], args[4]
	local Globals = Globals.Library.Globals
	local Powers, Devices, remove = Power.Library.Powers, AllDevices.Space.Devices,
	Globals.remove

	local GiveBack = {}

	function GiveBack.Start()
		Space.ObjectsWithPowers = {}
	end
	function GiveBack.Stop()
	end
	--DataChecks every new Device's every Object
	--Needed because Summon's AllDevices dependency
	function GiveBack.AllPowersUpdate(Time)
		local DestroyedObjects = AllDevices.Space.DestroyedObjects
		for ak=1,#DestroyedObjects do
			local av = DestroyedObjects[ak]
			local Temp = Space.ObjectsWithPowers[av]
			if Temp then
				Space.ObjectsWithPowers[av] = nil
				if Temp == #Space.ObjectsWithPowers then
					Space.ObjectsWithPowers[Temp] = nil
				else
					Space.ObjectsWithPowers[Temp] =
					Space.ObjectsWithPowers[#Space.ObjectsWithPowers]
					Space.ObjectsWithPowers[#Space.ObjectsWithPowers] = nil
					Space.ObjectsWithPowers[Space.ObjectsWithPowers[Temp]] = Temp
				end
			end
		end
		local CreatedObjects = AllDevices.Space.CreatedObjects
		for ak=1,#CreatedObjects do
			local av, bk = CreatedObjects[ak], 1
			if #av.Powers > 0 then
				Space.ObjectsWithPowers[#Space.ObjectsWithPowers + 1] = av
				Space.ObjectsWithPowers[av] = #Space.ObjectsWithPowers
				while bk <= #av.Powers do
					local bv = av.Powers[bk]
					if Powers[bv.Type] then
						av.Powers[bk] =
						Powers[bv.Type].DataCheck(Devices, av.Parent, av, bv, Time)
						bk = bk + 1
					else
						remove(av.Powers, bk)
						if av.OnCollisionPowers[bk] then
							remove(av.OnCollisionPowers, bk)
						end
					end
				end
			end
		end
	end

	--Uses every Power that is active
	function GiveBack.UseAllPowers(Time)
		for ak=1,#Space.ObjectsWithPowers do
			local av = Space.ObjectsWithPowers[ak]
			local Exit
			for bk=1,#av.Powers do
				local bv = av.Powers[bk]
				if bv.Active then
					Exit = Powers[bv.Type].Use(Devices, av.Parent, av, bv, Time)
					bv.Device, bv.Object, bv.Contact = nil, nil, nil
				end
				if Exit then break end
			end
		end
	end
	return GiveBack
end
