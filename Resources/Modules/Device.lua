local GiveBack = {}
function GiveBack.Create(GotDevice, Name, Object, ObjectGive, General, GeneralGive)
  local Device = {}
  Device.Objects = {}
  if type(GotDevice.Objects) == "table" then
    for k,v in pairs(GotDevice.Objects) do
      Device.Objects[k] = Object.Library.Create(v, unpack(ObjectGive))
    end
  else
    --TODO
  end
  Device.FixedJoints = {}
  if General.Library.GoodTypesOfTable(GotDevice.FixedJoints, "table") then
    for k,v in pairs(GotDevice.FixedJoints) do
      if General.Library.GoodTypesOfTable(v, "number") then
        if #v == 4 and v[1] ~= v[3] and v[2] > 0 and v[2] < 5 and v[4] > 0 and v[4] < 5 then
          for e,f in pairs(Device.Objects) do
            if v[1] == e then
              for r,g in pairs(Device.Objects) do
                if v[3] == r then
                  Device.FixedJoints[k] = v
                end
              end
            end
          end
        end
      end
    end
  end
  Device.Name = Name
  return Device
end
function GiveBack.Destroy(Device, Object, ObjectGive, General, GeneralGive)
  for k,v in pairs(Device.Objects) do
    Object.Library.Destroy(v, unpack(ObjectGive))
  end
end
GiveBack.Requirements = {"Object", "General"}
return GiveBack
