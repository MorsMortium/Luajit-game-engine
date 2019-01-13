local GiveBack = {}
function GiveBack.Start(Space, Power, PowerGive, AllDevices, AllDevicesGive)
	for k, v in pairs(Power.Library.Powers) do
		if not (type(v.DataCheck) == "function" and type(v.Use) == "function") then
			Power.Library.Powers[k] = nil
		end
	end
  for k,v in pairs(AllDevices.Space.Devices) do
    for a,b in pairs(v.Objects) do
      b.PowerChecked = {}
      if type(b.Powers) == "table" then
    		for x,y in pairs(b.Powers) do
          if Power.Library.Powers[y.Type] then
            b.Powers[x] = Power.Library.Powers[y.Type].DataCheck(y, unpack(PowerGive))
            b.PowerChecked[x] = {}
          end
    		end
    	end
    end
  end
	print("AllPowers Started")
end
function GiveBack.Stop(Space, Power, PowerGive, AllDevices, AllDevicesGive)
	print("AllPowers Stopped")
end
GiveBack.Requirements = {"Power", "AllDevices"}
return GiveBack
