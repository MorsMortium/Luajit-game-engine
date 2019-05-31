local GiveBack = {}
function GiveBack.Create(GotDevice, Arguments)
  local Object, ObjectGive, General = Arguments[1], Arguments[2], Arguments[3]
  local Device = {}
  Device.Objects = {}
  Device.FixedJoints = {}
  Device.Name = "UnknownDevice"
  if type(GotDevice) == "table" then
    if type(GotDevice.Objects) == "table" then
      for ak=1,#GotDevice.Objects do
        local av = GotDevice.Objects[ak]
        Device.Objects[ak] = Object.Library.Create(av, ObjectGive)
      end
      if General.Library.GoodTypesOfTable(GotDevice.FixedJoints, "table") then
        for ak=1,#GotDevice.FixedJoints do
          local av = GotDevice.FixedJoints[ak]
          if General.Library.GoodTypesOfTable(av, "number") then
            if #av == 4 and av[1] ~= av[3] and 0 < av[2] and av[2] < 5 and 0 < av[4] and av[4] < 5 and av[1] <= #Device.Objects and av[3] <= #Device.Objects then
              Device.FixedJoints[ak] = av
            end
          end
        end
      end
    else
      Device.Objects[1] = Object.Library.Create(nil, ObjectGive)
    end
    if GotDevice.Name then
      Device.Name = GotDevice.Name
    end
  else
    Device.Objects[1] = Object.Library.Create(nil, ObjectGive)
  end
  return Device
end
function GiveBack.Destroy(Device, Arguments)
  local Object, ObjectGive = Arguments[1], Arguments[2]
  for ak=1,#Device.Objects do
    local av = Device.Objects[ak]
    Object.Library.Destroy(av, ObjectGive)
  end
  for ak,av in pairs(Device) do
    Device[ak] = nil
  end
end
GiveBack.Requirements = {"Object", "General"}
return GiveBack
