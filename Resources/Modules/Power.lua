local GiveBack = {}
local function FileExists(Name)
   local f=io.open(Name,"r")
   if f~=nil then io.close(f) return true else return false end
end
local function ToEuler(Axis, Angle, General)
	local s = math.sin(Angle)
	local c = math.cos(Angle)
	local t = 1 - c
	--  if Axis is not already normalised then uncomment this
	local Magnitude = General.Library.VectorLength(Axis)
	--// if (Magnitude==0) throw error;
  General.Library.VectorNumberMult(Axis, 1/Magnitude)
	local X
	local Y
	local Z
	if (Axis[1]*Axis[2] * t + Axis[3] * s) > 0.998 then --north pole singularity detected
		X = 2 * math.atan2(Axis[1] * math.sin(Angle / 2), math.cos(Angle / 2))
		Y = math.pi / 2
		Z = 0
	elseif (Axis[1]*Axis[2] * t + Axis[3] * s) < -0.998 then --south pole singularity detected
		X = -2 * math.atan2(Axis[1] * math.sin(Angle / 2), math.cos(Angle / 2))
		Y = -math.pi / 2
		Z = 0
	else
		X = math.atan2(Axis[2] * s - Axis[1] * Axis[3] * t, 1 - (Axis[2] * Axis[2] + Axis[3] * Axis[3] ) * t)
		Y = math.asin(Axis[1] * Axis[2] * t + Axis[3] * s)
		Z = math.atan2(Axis[1] * s - Axis[2] * Axis[3] * t, 1 - (Axis[1] * Axis[1] + Axis[3] * Axis[3]) * t)
	end
	return {Z, X, Y}
end
GiveBack.Powers = {}
GiveBack.Powers.Gravity = {}
function GiveBack.Powers.Gravity.DataCheck(Devices, Device, Object, Power, Time, Arguments)
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
function GiveBack.Powers.Gravity.Use(Devices, Device, Object, Power, Time, Arguments)
  local General = Arguments[1]
  for ak=1,#Devices do
    local av = Devices[ak]
    for bk=1,#av.Objects do
      local bv = av.Objects[bk]
  		if (Device ~= ak or Object ~= bk) and General.Library.SameLayer(Object.PhysicsLayers, bv.PhysicsLayers) and
  		math.sqrt((bv.Translation[1] - Object.Translation[1])^2 +
  							(bv.Translation[2] - Object.Translation[2])^2 +
  							(bv.Translation[3] - Object.Translation[3])^2) < Power.Distance then
  			for ck=1,3 do
          if not bv.Fixed then
            if bv.Translation[ck] > Object.Translation[ck] then
  						bv.Speed[ck] = bv.Speed[ck] - Time * Power.Force
  					elseif bv.Translation[ck] < Object.Translation[ck] then
  						bv.Speed[ck] = bv.Speed[ck] + Time * Power.Force
  					end
          end
          if not Object.Fixed then
            if bv.Translation[ck] > Object.Translation[ck] then
    					Object.Speed[ck] = Object.Speed[ck] + Time * Power.Force
    				elseif bv.Translation[ck] < Object.Translation[ck] then
    					Object.Speed[ck] = Object.Speed[ck] - Time * Power.Force
    				end
  				end
  			end
  		end
    end
  end
end
GiveBack.Powers.Thruster = {}
function GiveBack.Powers.Thruster.DataCheck(Devices, Device, Object, Power, Time, Arguments)
	local Data = {}
	Data.Type = "Thruster"
  Data.Force = 0.005
	if type(Power.Force) == "number" then
		Data.Force = Power.Force
	end
  Data.Point = 1
	if Power.Point == 1 or Power.Point == 2 or Power.Point == 3 or Power.Point == 4 then
		Data.Point = Power.Point
	end
  Data.Active = false
  if type(Power.Active) == "boolean" then
    Data.Active = Power.Active
  end
	return Data
end
function GiveBack.Powers.Thruster.Use(Devices, Device, Object, Power, Time, Arguments)
  local General = Arguments[1]
  if not Object.Fixed then
    local p1 = {Object.Transformated.data[(Power.Point-1) * 4], Object.Transformated.data[(Power.Point-1) * 4 + 1], Object.Transformated.data[(Power.Point-1) * 4 + 2]}
    local c1 = Object.Translation
    local vfc1tp1 = General.Library.PointAToB(c1, p1)
    Object.Speed = General.Library.VectorAddition(Object.Speed, General.Library.VectorNumberMult(vfc1tp1, Time*Power.Force))
  end
end
GiveBack.Powers.SelfRotate = {}
function GiveBack.Powers.SelfRotate.DataCheck(Devices, Device, Object, Power, Time, Arguments)
	local Data = {}
	Data.Type = "SelfRotate"
  Data.Angle = 0.005
	if type(Power.Angle) == "number" then
		Data.Angle = Power.Angle
	end
  Data.Point = 1
	if Power.Point == 1 or Power.Point == 2 or Power.Point == 3 or Power.Point == 4 then
		Data.Point = Power.Point
	end
  Data.Active = false
  if type(Power.Active) == "boolean" then
    Data.Active = Power.Active
  end
	return Data
end
function GiveBack.Powers.SelfRotate.Use(Devices, Device, Object, Power, Time, Arguments)
  local General = Arguments[1]
  if not Object.Fixed then
		local p1 = {Object.Transformated.data[(Power.Point-1) * 4], Object.Transformated.data[(Power.Point-1) * 4 + 1], Object.Transformated.data[(Power.Point-1) * 4 + 2]}
		local c1 = Object.Translation
		local vfc1tp1 = General.Library.PointAToB(c1, p1)
		local euler = ToEuler(vfc1tp1, Power.Angle, General)
    Object.RotationSpeed = General.Library.VectorAddition(Object.RotationSpeed, General.Library.VectorNumberMult(euler, Time))
  end
end
GiveBack.Powers.SelfSlow = {}
function GiveBack.Powers.SelfSlow.DataCheck(Devices, Device, Object, Power, Time, Arguments)
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
function GiveBack.Powers.SelfSlow.Use(Devices, Device, Object, Power, Time, Arguments)
  local General = Arguments[1]
  Object.Speed = General.Library.VectorNumberMult(Object.Speed, 1/Power.Rate ^ Time)
  Object.RotationSpeed = General.Library.VectorNumberMult(Object.RotationSpeed, 1/Power.Rate ^ Time)
end
GiveBack.Powers.Destroypara = {}
function GiveBack.Powers.Destroypara.DataCheck(Devices, Device, Object, Power, Time, Arguments)
	local Data = {}
	Data.Type = "Destroypara"
  if Power.String == nil then
    Power.String = "return false"
  end
  Data.Command = loadstring(Power.String)
  if not pcall(Data.Command) then
    Data.Command = loadstring("return false")
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
function GiveBack.Powers.Destroypara.Use(Devices, Device, Object, Power, Time, Arguments)
  local General, AllDevices, AllDevicesGive = Arguments[1], Arguments[9], Arguments[10]
  local Ran, IfDestroy = pcall(Power.Command, Devices, Device, Object, Power, General)
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
GiveBack.Powers.Command = {}
function GiveBack.Powers.Command.DataCheck(Devices, Device, Object, Power, Time, Arguments)
	local Data = {}
	Data.Type = "Command"
  if Power.String == nil then
    Power.String = "return false"
  end
  Data.Command = loadstring(Power.String)
  if not pcall(Data.Command, Devices, Device, Object, Power, Time) then
    Data.Command = loadstring("return false")
  end
  Data.Active = false
  if type(Power.Active) == "boolean" then
    Data.Active = Power.Active
  end
	return Data
end
function GiveBack.Powers.Command.Use(Devices, Device, Object, Power, Time, Arguments)
  local General, AllDevices, AllDevicesGive = Arguments[1], Arguments[9], Arguments[10]
  pcall(Power.Command, Devices, Device, Object, Power, Time)
end
GiveBack.Powers.Summon = {}
function GiveBack.Powers.Summon.DataCheck(Devices, Device, Object, Power, Time, Arguments)
  local General, JSON, Device, DeviceGive, lgsl, AllDevices, ffi = Arguments[1], Arguments[3], Arguments[5], Arguments[6], Arguments[7], Arguments[9], Arguments[11]
	local Data = {}
	Data.Type = "Summon"
  Data.Name = "Default"
  Data.Active = false
  if type(Power.Name) == "string" and AllDevices.Space.DeviceTypes[Power.Name] then
    Data.Name = Power.Name
  end
  local NewDevice = Device.Library.Copy(AllDevices.Space.DeviceTypes[Data.Name], DeviceGive, AllDevices.Space.HelperMatrices)
  if Power.String == nil then
    Power.String = "local Created, Creator = ... for ak=1,#Created.Objects do local av = Created.Objects[ak] av.MMcalc = true for bk=1,3 do av.Translation[bk] = Creator.Translation[bk] end end print('Bad modifier function')"
  end
  Data.Command = loadstring(Power.String)
  if not pcall(Data.Command, NewDevice, NewDevice.Objects[1], General) then
		Data.Command = loadstring("local Created, Creator = ... for ak=1,#Created.Objects do local av = Created.Objects[ak] av.MMcalc = true for bk=1,3 do av.Translation[bk] = Creator.Translation[bk] end end print('Bad modifier function')")
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
function GiveBack.Powers.Summon.Use(Devices, Device, Object, Power, Time, Arguments)
  local General, JSON, Device, DeviceGive, lgsl, AllDevices, AllDevicesGive, ffi = Arguments[1], Arguments[3], Arguments[5], Arguments[6], Arguments[7], Arguments[9], Arguments[10], Arguments[11]
  if Power.IfObject then
    local DeviceID = 1
    for ak=1,#Devices do
      local av = Devices[ak]
      if av == Device then
        DeviceID = ak
        break
      end
    end
    AllDevices.Library.AddObject(DeviceID, Power.Name, {Command = Power.Command, Creator = Object}, AllDevicesGive)
  else
    AllDevices.Library.AddDevice(Power.Name, {Command = Power.Command, Creator = Object}, AllDevicesGive)
  end
	Power.Active = false
end
GiveBack.Requirements = {"General", "JSON", "Device", "lgsl", "AllDevices", "ffi"}
return GiveBack
