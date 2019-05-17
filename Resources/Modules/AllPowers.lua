local GiveBack = {}
function GiveBack.Start(Arguments)
	local Space, Power, PowerGive, AllDevices = Arguments[1], Arguments[2], Arguments[3], Arguments[4]
	for ak=1,#Power.Library.Powers do
		local av = Power.Library.Powers[ak]
		if not (type(av.DataCheck) == "function" and type(av.Use) == "function") then
			Power.Library.Powers[ak] = nil
		end
	end
	for ak=1,#AllDevices.Space.Devices do
		local av = AllDevices.Space.Devices[ak]
		for bk=1,#av.Objects do
			local bv = av.Objects[bk]
			bv.PowerChecked = {}
			if type(bv.Powers) == "table" then
				for ck=1,#bv.Powers do
					local cv = bv.Powers[ck]
					if Power.Library.Powers[cv.Type] then
						bv.Powers[ck] = Power.Library.Powers[cv.Type].DataCheck(cv, PowerGive)
						bv.PowerChecked[ck] = {}
					end
				end
			end
		end
	end
	print("AllPowers Started")
end
function GiveBack.Stop(Arguments)
	print("AllPowers Stopped")
end
GiveBack.Requirements = {"Power", "AllDevices"}
return GiveBack
