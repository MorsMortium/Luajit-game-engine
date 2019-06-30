local GiveBack = {}

--Checks whether every Power has all it's functions, if not, it deletes it
function GiveBack.Start(Arguments)
	local Space, Power, PowerGive, AllDevices = Arguments[1], Arguments[2],
	Arguments[3], Arguments[4]
	for ak,av in pairs(Power.Library.Powers) do
		if type(av.DataCheck) ~= "function" or type(av.Use) ~= "function" then
			Power.Library.Powers[ak] = nil
		end
	end
	print("AllPowers Started")
end

--DataChecks every new Device's every Object, needed because Summon's AllDevices
--dependency
function GiveBack.DataCheckNewDevicesPowers(Time, Arguments)
	local Space, Power, PowerGive, AllDevices = Arguments[1], Arguments[2],
	Arguments[3], Arguments[4]
	for bk=1,#AllDevices.Space.CreatedObjects do
		local bv = AllDevices.Space.CreatedObjects[bk]
		local DeletedPowers = {}
		for ck=1,#bv.Powers do
			if #bv.Powers < ck then break end
			local cv = bv.Powers[ck]
			if Power.Library.Powers[cv.Type] then
				bv.Powers[ck] = Power.Library.Powers[cv.Type].DataCheck(
				AllDevices.Space.Devices, bv.Parent, bv, cv, Time, PowerGive)
			else
				table.remove(bv.Powers, ck)
				DeletedPowers[#DeletedPowers + 1] = ck
			end
		end
		for ck=1,#DeletedPowers do
			local cv = DeletedPowers[ck]
			if bv.OnCollisionPowers[cv] then
				bv.OnCollisionPowers[cv] = false
			end
		end
	end
end

--Uses every Power that is active
function GiveBack.UseAllPowers(Time, Arguments)
	local Space, Power, PowerGive, AllDevices = Arguments[1], Arguments[2],
		Arguments[3], Arguments[4]
	local ak = 1
	while ak <= #AllDevices.Space.Devices do
		local av = AllDevices.Space.Devices[ak]
		local Exit = false
    for bk=1,#av.Objects do
      local bv = av.Objects[bk]
      for ck=1,#bv.Powers do
        local cv = bv.Powers[ck]
				if cv.Active then
					Exit = Exit or Power.Library.Powers[cv.Type].Use(
						AllDevices.Space.Devices, av, bv, cv, Time, PowerGive)
				end
        if Exit then break end
      end
      if Exit then break end
    end
		if not Exit then ak = ak + 1 end
	end
end
function GiveBack.Stop(Arguments)
	print("AllPowers Stopped")
end
GiveBack.Requirements = {"Power", "AllDevices"}
return GiveBack
