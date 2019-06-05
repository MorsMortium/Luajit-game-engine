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
			if type(bv.Powers) == "table" then
				for ck=1,#bv.Powers do
					if #bv.Powers < ck then break end
					local cv = bv.Powers[ck]
					if Power.Library.Powers[cv.Type] then
						bv.Powers[ck] = Power.Library.Powers[cv.Type].DataCheck(cv, PowerGive)
					else
						table.remove(bv.Powers, ck)
					end
				end
			end
		end
	end
	print("AllPowers Started")
end
function GiveBack.UseAllPowers(Time, Arguments)
	local Space, Power, PowerGive, AllDevices = Arguments[1], Arguments[2], Arguments[3], Arguments[4]
	for ak=1,#AllDevices.Space.Devices do
    if ak > #AllDevices.Space.Devices then break end
    local av = AllDevices.Space.Devices[ak]
    for bk=1,#av.Objects do
      local bv = av.Objects[bk]
      local Exit = false
      for ck=1,#bv.Powers do
        local cv = bv.Powers[ck]
				if bv.Powers[ck].Active then
					Exit = Power.Library.Powers[cv.Type].Use(AllDevices.Space.Devices, ak, bk, ck, Time, PowerGive)
				end
        if Exit then break end
      end
      if Exit then break end
    end
  end
end
function GiveBack.Stop(Arguments)
	print("AllPowers Stopped")
end
GiveBack.Requirements = {"Power", "AllDevices"}
return GiveBack
