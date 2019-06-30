local GiveBack = {}

--Creates and returns one Device. Devices contain multiple objects, take input
--from buttons and in the future contain constraints
function GiveBack.Create(GotDevice, Arguments)
  local Object, ObjectGive, General = Arguments[1], Arguments[2], Arguments[3]

  --Creating the Device table
  local Device = {}

  --The objects of the Device
  Device.Objects = {}

  --The name of the Device2
  Device.Name = "UnknownDevice"

  --Creating the Device from the actual data
  if type(GotDevice) == "table" then

    if GotDevice.Name then
      Device.Name = GotDevice.Name
    end

    --Creating the objects with Object.lua
    if type(GotDevice.Objects) == "table" then
      for ak=1,#GotDevice.Objects do
        local av = GotDevice.Objects[ak]
        Device.Objects[ak] =
        Object.Library.Create(av, Device, ObjectGive)
      end
    else
      Device.Objects[1] =
      Object.Library.Create(nil, Device, ObjectGive)
    end

    --Different commands for keypress and release
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

    --Default
    Device.Objects[1] =
    Object.Library.Create(nil, Device, ObjectGive)
  end
  return Device
end

--This function copies a Device with every data it has
function GiveBack.Copy(Device, Arguments)
  local Object, ObjectGive, General = Arguments[1], Arguments[2], Arguments[3]
  local NewDevice = {}
  NewDevice.Objects = {}
  NewDevice.Name = Device.Name
  for ak=1,#Device.Objects do
    local av = Device.Objects[ak]
    NewDevice.Objects[ak] =
    Object.Library.Copy(av, NewDevice, ObjectGive)
  end
  NewDevice.ButtonsUp = General.Library.DeepCopy(Device.ButtonsUp)
  NewDevice.ButtonsDown = General.Library.DeepCopy(Device.ButtonsDown)
  return NewDevice
end

--This function merges two devices together
--If there is a conflict in the taken input, the first Device will be accepted
--TODO:OnCollisionPowers
function GiveBack.Merge(Device1, Device2, Arguments)
  local Object, ObjectGive, General = Arguments[1], Arguments[2], Arguments[3]
  for ak=1,#Device2.Objects do
    local av = Device2.Objects[ak]
    av.Parent = Device1
    Device1.Objects[#Device1.Objects + 1] = av
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
end

--Destroys a Device
function GiveBack.Destroy(Device, Arguments)
  local Object, ObjectGive = Arguments[1], Arguments[2]
  for ak=1,#Device.Objects do
    local av = Device.Objects[ak]
    Object.Library.Destroy(av, ObjectGive)
  end
end
GiveBack.Requirements = {"Object", "General"}
return GiveBack
