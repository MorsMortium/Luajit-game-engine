local GiveBack = {}
function GiveBack.Create(GotDevice, Arguments, HelperMatrices)
  local Object, ObjectGive, General = Arguments[1], Arguments[2], Arguments[3]
  local Device = {}
  Device.Objects = {}
  Device.FixedJoints = {}
  Device.Name = "UnknownDevice"
  if type(GotDevice) == "table" then
    if type(GotDevice.Objects) == "table" then
      for ak=1,#GotDevice.Objects do
        local av = GotDevice.Objects[ak]
        Device.Objects[ak] =
        Object.Library.Create(av, Device, ObjectGive, HelperMatrices)
      end
      if General.Library.GoodTypesOfTable(GotDevice.FixedJoints, "table") then
        for ak=1,#GotDevice.FixedJoints do
          local av = GotDevice.FixedJoints[ak]
          if General.Library.GoodTypesOfTable(av, "number") then
            if #av == 4 and av[1] ~= av[3] and 0 < av[2] and av[2] < 5 and
            0 < av[4] and av[4] < 5 and av[1] <= #Device.Objects and
            av[3] <= #Device.Objects then
              Device.FixedJoints[ak] = av
            end
          end
        end
      end
    else
      Device.Objects[1] =
      Object.Library.Create(nil, Device, ObjectGive, HelperMatrices)
    end
    if GotDevice.Name then
      Device.Name = GotDevice.Name
    end
    Device.ButtonsUp = {}
    Device.ButtonsDown = {}
    if type(GotDevice.Inputs) == "table" then
      for ak=1,#GotDevice.Inputs do
        local av = GotDevice.Inputs[ak]
        av.Command = loadstring(av.String)
        if av.Type == "Up" then
          Device.ButtonsUp[av.Button] = av
        else
          Device.ButtonsDown[av.Button] = av
        end
      end
    end
  else
    Device.Objects[1] =
    Object.Library.Create(nil, Device, ObjectGive, HelperMatrices)
  end
  return Device
end
function GiveBack.Copy(Device, Arguments, HelperMatrices)
  local Object, ObjectGive, General = Arguments[1], Arguments[2], Arguments[3]
  local NewDevice = {}
  NewDevice.Objects = {}
  NewDevice.Name = Device.Name
  for ak=1,#Device.Objects do
    local av = Device.Objects[ak]
    NewDevice.Objects[ak] =
    Object.Library.Copy(av, NewDevice, ObjectGive, HelperMatrices)
  end
  NewDevice.FixedJoints = General.Library.DeepCopy(Device.FixedJoints)
  NewDevice.ButtonsUp = General.Library.DeepCopy(Device.ButtonsUp)
  NewDevice.ButtonsDown = General.Library.DeepCopy(Device.ButtonsDown)
  return NewDevice
end
function GiveBack.Merge(Device1, Device2, Arguments, HelperMatrices)
  local Object, ObjectGive, General = Arguments[1], Arguments[2], Arguments[3]
  for ak=1,#Device2.Objects do
    local av = Device2.Objects[ak]
    Device1.Objects[#Device1.Objects + 1] = Device2.Objects[ak]
  end
  for ak=1,#Device1.Objects do
    local av = Device1.Objects[ak]
    av.Parent = Device1
  end
  local NewButtonsUp = {}
  local NewButtonsDown = {}
  for ak,av in pairs(Device2.ButtonsUp) do
    NewButtonsUp[ak] = av
  end
  for ak,av in pairs(Device2.ButtonsDown) do
    NewButtonsDown[ak] = av
  end
  for ak,av in pairs(Device1.ButtonsUp) do
    NewButtonsUp[ak] = av
  end
  for ak,av in pairs(Device1.ButtonsDown) do
    NewButtonsDown[ak] = av
  end
  Device1.ButtonsUp = NewButtonsUp
  Device1.ButtonsDown = NewButtonsDown
  --Device.FixedJoints = General.Library.DeepCopy(GotDevice.FixedJoints)
end
function GiveBack.Destroy(Device, Arguments)
  local Object, ObjectGive = Arguments[1], Arguments[2]
  for ak=1,#Device.Objects do
    local av = Device.Objects[ak]
    Object.Library.Destroy(av, ObjectGive)
  end
end
GiveBack.Requirements = {"Object", "General"}
return GiveBack
