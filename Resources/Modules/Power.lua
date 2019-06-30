local GiveBack = {}
--This script is responsible for mechanics that aren't derived from physics
--DataCheck functions convert data stored in json into data the power uses
--Use functions evaluate the power

--Converts an axis-angle rotatiton into a quaternion rotatiton
local function AxisAngleToQuaternion(Axis, Angle)
  return {math.cos(Angle / 2),
          Axis[1] * math.sin(Angle/2),
          Axis[2] * math.sin(Angle/2),
          Axis[3] * math.sin(Angle/2)}
end
GiveBack.Powers = {}

--Gravity pulls or pushes every object within Distance with a constant force
--In the direction of the Object using it
--TODO: dependency on mass, Distance
GiveBack.Powers.Gravity = {}
local Gravity = GiveBack.Powers.Gravity
function Gravity.DataCheck(Devices, Device, Object, Power, Time)
	local Data = {}
	Data.Type = "Gravity"
  Data.Force = 0.005
	if type(Power.Force) == "number" then
		Data.Force = Power.Force
	end
  Data.Distance = 100
	if type(Power.Distance) == "number" then
		Data.Distance = Power.Distance
	end
  Data.Active = false
  if type(Power.Active) == "boolean" then
    Data.Active = Power.Active
  end
  return Data
end
function Gravity.Use(Devices, Device, Object, Power, Time, Arguments)
  local General = Arguments[1]
  local SameLayer, VectorLength, VectorSubtraction, Normalise, VectorSign,
  VectorAddition, VectorNumberMult, MinusVector = General.Library.SameLayer,
  General.Library.VectorLength, General.Library.VectorSubtraction,
  General.Library.Normalise, General.Library.VectorSign,
  General.Library.VectorAddition, General.Library.VectorNumberMult,
  General.Library.MinusVector
  for ak=1,#Devices do
    local av = Devices[ak]
    for bk=1,#av.Objects do
      local bv = av.Objects[bk]
  		if (Device ~= ak or Object ~= bk) and
      SameLayer(Object.PhysicsLayers, bv.PhysicsLayers) and
      VectorLength(VectorSubtraction(Object.Translation, bv.Translation))
      < Power.Distance then
        local Direction = Normalise(VectorSubtraction(Object.Translation, bv.Translation))
        if true then
          Direction = VectorSign(Direction)
        end
        if not bv.Fixed then
          bv.Speed =
          VectorAddition(bv.Speed, VectorNumberMult(Direction, Time * Power.Force))
        end
        Direction = MinusVector(Direction)
        if not Object.Fixed then
          Object.Speed =
          VectorAddition(Object.Speed, VectorNumberMult(Direction, Time * Power.Force))
  			end
  		end
    end
  end
end

--Thruster pulls or pushes the object using it with a constant force
--In the direction of one of its points
GiveBack.Powers.Thruster = {}
local Thruster = GiveBack.Powers.Thruster
function Thruster.DataCheck(Devices, Device, Object, Power, Time)
	local Data = {}
	Data.Type = "Thruster"
  Data.Force = 0.005
	if type(Power.Force) == "number" then
		Data.Force = Power.Force
	end
  Data.Point = 1
	if Power.Point == 1 or Power.Point == 2 or Power.Point == 3 or
  Power.Point == 4 then
		Data.Point = Power.Point
	end
  Data.Active = false
  if type(Power.Active) == "boolean" then
    Data.Active = Power.Active
  end
	return Data
end
function Thruster.Use(Devices, Device, Object, Power, Time, Arguments)
  local General = Arguments[1]
  local VectorAddition = General.Library.VectorAddition
  local VectorNumberMult = General.Library.VectorNumberMult
  if not Object.Fixed then
    local p = {Object.Transformated.data[(Power.Point-1) * 4],
                Object.Transformated.data[(Power.Point-1) * 4 + 1],
                Object.Transformated.data[(Power.Point-1) * 4 + 2]}
    local c = Object.Translation
    local vfctp = General.Library.VectorSubtraction(p, c)
    Object.Speed =
    VectorAddition(Object.Speed, VectorNumberMult(vfctp, Time*Power.Force))
  end
end

--SelfRotate rotates the object using it with a constant angle
--Around one of its points
GiveBack.Powers.SelfRotate = {}
local SelfRotate = GiveBack.Powers.SelfRotate
function SelfRotate.DataCheck(Devices, Device, Object, Power, Time)
	local Data = {}
	Data.Type = "SelfRotate"
  Data.Angle = 0.005
	if type(Power.Angle) == "number" then
		Data.Angle = Power.Angle
	end
  Data.Point = 1
	if Power.Point == 1 or Power.Point == 2 or Power.Point == 3 or
  Power.Point == 4 then
		Data.Point = Power.Point
	end
  Data.Active = false
  if type(Power.Active) == "boolean" then
    Data.Active = Power.Active
  end
	return Data
end
function SelfRotate.Use(Devices, Device, Object, Power, Time, Arguments)
  local General = Arguments[1]
  local VectorAddition = General.Library.VectorAddition
  local VectorNumberMult = General.Library.VectorNumberMult
	local QuaternionMultiplication = General.Library.QuaternionMultiplication
  if not Object.Fixed then
		local p = {Object.Transformated.data[(Power.Point-1) * 4],
                Object.Transformated.data[(Power.Point-1) * 4 + 1],
                Object.Transformated.data[(Power.Point-1) * 4 + 2]}
		local c = Object.Translation
		local vfctp = General.Library.VectorSubtraction(p, c)
		local Quaternion = AxisAngleToQuaternion(vfctp, Power.Angle * Time)
    Object.RotationSpeed =
		QuaternionMultiplication(Object.RotationSpeed, Quaternion)
  end
end

--SelfSlow slows the object using it with a constant rate on every axes
GiveBack.Powers.SelfSlow = {}
local SelfSlow = GiveBack.Powers.SelfSlow
function SelfSlow.DataCheck(Devices, Device, Object, Power, Time)
	local Data = {}
	Data.Type = "SelfSlow"
  Data.Rate = 2
	if type(Power.Rate) == "number" then
		Data.Rate = Power.Rate
	end
  Data.Active = false
  if type(Power.Active) == "boolean" then
    Data.Active = Power.Active
  end
	return Data
end
function SelfSlow.Use(Devices, Device, Object, Power, Time, Arguments)
  local General = Arguments[1]
  local VectorNumberMult = General.Library.VectorNumberMult
	local Slerp = General.Library.Slerp
  Object.Speed = VectorNumberMult(Object.Speed, 1 / Power.Rate ^ Time)
	Object.RotationSpeed =
	Slerp({1, 0, 0, 0}, Object.RotationSpeed, 1 / Power.Rate ^ Time)
end
local function DefaultDestroypara(...)
  return false
end

--Destroypara destroys the object using it if it's command returns true
GiveBack.Powers.Destroypara = {}
local Destroypara = GiveBack.Powers.Destroypara
function Destroypara.DataCheck(Devices, Device, Object, Power, Time)
	local Data = {}
	Data.Type = "Destroypara"
  if Power.String == nil then
    Data.Command = DefaultDestroypara
  else
    Data.Command = loadstring(Power.String)
    if not pcall(Data.Command) then
      Data.Command = DefaultDestroypara
    end
  end
  Data.IfObject = false
  if type(Power.IfObject) == "boolean" then
    Data.IfObject = Power.IfObject
  end
  Data.Active = false
  if type(Power.Active) == "boolean" then
    Data.Active = Power.Active
  end
	return Data
end
function Destroypara.Use(Devices, Device, Object, Power, Time, Arguments)
  local General, AllDevices, AllDevicesGive = Arguments[1], Arguments[9], Arguments[10]
  local Ran, IfDestroy =
  pcall(Power.Command, Devices, Device, Object, Power, General)
  if Ran and IfDestroy then
    if Power.IfObject then
      local DeviceID = 1
      for ak=1,#Devices do
        local av = Devices[ak]
        if av == Device then
          DeviceID = ak
          break
        end
      end
      if 1 < #Device.Objects then
        local ObjectID = 1
        for ak=1,#Device.Objects do
          local av = Device.Objects[ak]
          if av == Object then
            ObjectID = ak
            break
          end
        end
        AllDevices.Library.RemoveObject(DeviceID, ObjectID, AllDevicesGive)
      else
        AllDevices.Library.RemoveDevice(DeviceID, AllDevicesGive)
      end
    else
      local DeviceID = 1
      for ak=1,#Devices do
        local av = Devices[ak]
        if av == Device then
          DeviceID = ak
          break
        end
      end
      AllDevices.Library.RemoveDevice(DeviceID, AllDevicesGive)
    end
    return true
  end
end

--Command runs small script which can be custom mechanics for the object/device
--Or all devices
local function DefaultCommand(...)
  return false
end
GiveBack.Powers.Command = {}
local Command = GiveBack.Powers.Command
function Command.DataCheck(Devices, Device, Object, Power, Time)
	local Data = {}
	Data.Type = "Command"
  if Power.String == nil then
    Data.Command = DefaultCommand
  else
    Data.Command = loadstring(Power.String)
    if not pcall(Data.Command, Devices, Device, Object, Power, Time) then
      Data.Command = DefaultCommand
    end
  end
  Data.Active = false
  if type(Power.Active) == "boolean" then
    Data.Active = Power.Active
  end
	return Data
end
function Command.Use(Devices, Device, Object, Power, Time)
  pcall(Power.Command, Devices, Device, Object, Power, Time)
end
local function DefaultSummon(...)
  local Created, Creator = ...
    for ak=1,#Created.Objects do
      local av = Created.Objects[ak]
      for bk=1,3 do
        av.Translation[bk] = Creator.Translation[bk]
        av.Rotation[bk] = Creator.Rotation[bk]
      end
      av.Rotation[4] = Creator.Rotation[4]
    end
    print('Bad modifier function')
end

--Summon adds an object or device, then modifies it with it's command
GiveBack.Powers.Summon = {}
local Summon = GiveBack.Powers.Summon
function Summon.DataCheck(Devices, Device, Object, Power, Time, Arguments)
  local General, Devicel, DeviceGive, AllDevices = Arguments[1], Arguments[5],
  Arguments[6], Arguments[9]
	local Data = {}
	Data.Type = "Summon"
  Data.Name = "Default"
  Data.Active = false
  if type(Power.Name) == "string" and
  AllDevices.Space.DeviceTypes[Power.Name] then
    Data.Name = Power.Name
  end
  local NewDevice =
  Devicel.Library.Copy(AllDevices.Space.DeviceTypes[Data.Name], DeviceGive)
  if Power.String == nil then
    Data.Command = DefaultSummon
  else
    Data.Command = loadstring(Power.String)
    if not pcall(Data.Command, NewDevice, NewDevice.Objects[1], General) then
		  Data.Command = DefaultSummon
	  end
  end
  Data.IfObject = false
  if type(Power.IfObject) == "boolean" then
    Data.IfObject = Power.IfObject
  end
  if type(Power.Active) == "boolean" then
    Data.Active = Power.Active
  end
  return Data
end
function Summon.Use(Devices, Device, Object, Power, Time, Arguments)
  local AllDevices, AllDevicesGive = Arguments[9], Arguments[10]
  if Power.IfObject then
    local DeviceID = 1
    for ak=1,#Devices do
      local av = Devices[ak]
      if av == Device then
        DeviceID = ak
        break
      end
    end
    AllDevices.Library.AddObject(DeviceID, Power.Name,
    {Command = Power.Command, Creator = Object}, AllDevicesGive)
  else
    AllDevices.Library.AddDevice(Power.Name,
    {Command = Power.Command, Creator = Object}, AllDevicesGive)
  end
	Power.Active = false
end
GiveBack.Requirements =
{"General", "JSON", "Device", "lgsl", "AllDevices", "ffi"}
return GiveBack
