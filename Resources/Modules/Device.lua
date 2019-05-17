local GiveBack = {}
function GiveBack.Create(GotDevice, Name, Arguments)
  local Object, ObjectGive, General = Arguments[1], Arguments[2], Arguments[3]
  local Device = {}
  Device.Objects = {}
  if type(GotDevice.Objects) == "table" then
    for ak=1,#GotDevice.Objects do
      local av = GotDevice.Objects[ak]
      Device.Objects[ak] = Object.Library.Create(av, ObjectGive)
    end
  else
    --TODO
  end
  Device.FixedJoints = {}
  if General.Library.GoodTypesOfTable(GotDevice.FixedJoints, "table") then
    for ak=1,#GotDevice.FixedJoints do
      local av = GotDevice.FixedJoints[ak]
      if General.Library.GoodTypesOfTable(av, "number") then
        if #av == 4 and av[1] ~= av[3] and av[2] > 0 and av[2] < 5 and av[4] > 0 and av[4] < 5 then
          for bk=1,#Device.Objects do
            if av[1] == bk then
              for ck=1,#Device.Objects do
                if av[3] == ck then
                  Device.FixedJoints[ak] = av
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
