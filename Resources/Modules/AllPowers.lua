local GiveBack = {}

--Checks whether every Power has all it's functions, if not, it deletes it
function GiveBack.Start(Configurations, Arguments)
	local Space, Power, PowerGive, AllDevices = Arguments[1], Arguments[2],
	Arguments[3], Arguments[4]
	local Powers = Power.Library.Powers
	for ak,av in pairs(Powers) do
		if type(av.DataCheck) ~= "function" or type(av.Use) ~= "function" then
			Powers[ak] = nil
		end
	end
	io.write("AllPowers Started\n")
end

--DataChecks every new Device's every Object, needed because Summon's AllDevices
--dependency
function GiveBack.DataCheckNewDevicesPowers(Time, Arguments)
	local Space, Power, PowerGive, AllDevices = Arguments[1], Arguments[2],
	Arguments[3], Arguments[4]
	local Powers, CreatedObjects, Devices, remove = Power.Library.Powers,
	AllDevices.Space.CreatedObjects, AllDevices.Space.Devices, table.remove
	for bk=1,#CreatedObjects do
		local bv = CreatedObjects[bk]
		bv.PowerChecked = true
		local ck = 1
		while ck <= #bv.Powers do
			local cv = bv.Powers[ck]
			if Powers[cv.Type] then
				bv.Powers[ck] =
				Powers[cv.Type].DataCheck(Devices, bv.Parent, bv, cv, Time, PowerGive)
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
function GiveBack.UseAllPowers(Time, Arguments)
	local Space, Power, PowerGive, AllDevices = Arguments[1], Arguments[2],
	Arguments[3], Arguments[4]
	local Powers, Devices = Power.Library.Powers, AllDevices.Space.Devices
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
						OExit, DExit = Powers[cv.Type].Use(Devices, av, bv, cv, Time, PowerGive)
					end
					if OExit then break end
				end
			end
			if DExit then break elseif not OExit then bk = bk + 1 end
		end
		if not DExit then ak = ak + 1 end
	end
end
function GiveBack.Stop(Arguments)
	io.write("AllPowers Stopped\n")
end
GiveBack.Requirements = {"Power", "AllDevices"}
return GiveBack
