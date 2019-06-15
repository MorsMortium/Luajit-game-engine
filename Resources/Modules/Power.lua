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
function GiveBack.Powers.Gravity.DataCheck(v)
	local Data = {}
	Data.Type = "Gravity"
  Data.Force = 0.005
	if type(v.Force) == "number" then
		Data.Force = v.Force
	end
  Data.Distance = 100
	if type(v.Distance) == "number" then
		Data.Distance = v.Distance
	end
  Data.Active = false
  if type(v.Active) == "boolean" then
    Data.Active = v.Active
  end
  return Data
end
function GiveBack.Powers.Gravity.Use(Devices, i, k, h, time, Arguments)
  local General = Arguments[1]
	local v = Devices[i].Objects[k]
	local j = v.Powers[h]
  for ak=1,#Devices do
    local av = Devices[ak]
    for bk=1,#av.Objects do
      local bv = av.Objects[bk]
  		if (i ~= ak or k ~= bk) and General.Library.SameLayer(v.PhysicsLayers, bv.PhysicsLayers) and
  		math.sqrt((bv.Translation[1] - v.Translation[1])^2 +
  							(bv.Translation[2] - v.Translation[2])^2 +
  							(bv.Translation[3] - v.Translation[3])^2) < j.Distance then
  			for ck=1,3 do
          if not bv.Fixed then
            if bv.Translation[ck] > v.Translation[ck] then
  						bv.Speed[ck] = bv.Speed[ck] - time * j.Force
  					elseif bv.Translation[ck] < v.Translation[ck] then
  						bv.Speed[ck] = bv.Speed[ck] + time * j.Force
  					end
          end
          if not v.Fixed then
            if bv.Translation[ck] > v.Translation[ck] then
    					v.Speed[ck] = v.Speed[ck] + time * j.Force
    				elseif bv.Translation[ck] < v.Translation[ck] then
    					v.Speed[ck] = v.Speed[ck] - time * j.Force
    				end
  				end
  			end
  		end
    end
  end
end
GiveBack.Powers.Thruster = {}
function GiveBack.Powers.Thruster.DataCheck(v)
	local Data = {}
	Data.Type = "Thruster"
  Data.Force = 0.005
	if type(v.Force) == "number" then
		Data.Force = v.Force
	end
  Data.Point = 1
	if v.Point == 1 or v.Point == 2 or v.Point == 3 or v.Point == 4 then
		Data.Point = v.Point
	end
  Data.Active = false
  if type(v.Active) == "boolean" then
    Data.Active = v.Active
  end
	return Data
end
function GiveBack.Powers.Thruster.Use(Devices, i, k, h, time, Arguments)
  local General = Arguments[1]
	local v = Devices[i].Objects[k]
	local j = v.Powers[h]
  if not v.Fixed then
    local p1 = {v.Transformated.data[(j.Point-1) * 4], v.Transformated.data[(j.Point-1) * 4 + 1], v.Transformated.data[(j.Point-1) * 4 + 2]}
    local c1 = v.Translation
    local vfc1tp1 = General.Library.PointAToB(c1, p1)
    v.Speed = General.Library.VectorAddition(v.Speed, General.Library.VectorNumberMult(vfc1tp1, time*j.Force))
  end
end
GiveBack.Powers.SelfRotate = {}
function GiveBack.Powers.SelfRotate.DataCheck(v)
	local Data = {}
	Data.Type = "SelfRotate"
  Data.Angle = 0.005
	if type(v.Angle) == "number" then
		Data.Angle = v.Angle
	end
  Data.Point = 1
	if v.Point == 1 or v.Point == 2 or v.Point == 3 or v.Point == 4 then
		Data.Point = v.Point
	end
  Data.Active = false
  if type(v.Active) == "boolean" then
    Data.Active = v.Active
  end
	return Data
end
function GiveBack.Powers.SelfRotate.Use(Devices, i, k, h, time, Arguments)
  local General = Arguments[1]
  local v = Devices[i].Objects[k]
  local j = v.Powers[h]
  if not v.Fixed then
		local p1 = {v.Transformated.data[(j.Point-1) * 4], v.Transformated.data[(j.Point-1) * 4 + 1], v.Transformated.data[(j.Point-1) * 4 + 2]}
		local c1 = v.Translation
		local vfc1tp1 = General.Library.PointAToB(c1, p1)
		local euler = ToEuler(vfc1tp1, j.Angle, General)
    v.RotationSpeed = General.Library.VectorAddition(v.RotationSpeed, General.Library.VectorNumberMult(euler, time))
  end
end
GiveBack.Powers.SelfSlow = {}
function GiveBack.Powers.SelfSlow.DataCheck(v)
	local Data = {}
	Data.Type = "SelfSlow"
  Data.Rate = 2
	if type(v.Rate) == "number" then
		Data.Rate = v.Rate
	end
  Data.Active = false
  if type(v.Active) == "boolean" then
    Data.Active = v.Active
  end
	return Data
end
function GiveBack.Powers.SelfSlow.Use(Devices, i, k, h, time, Arguments)
  local General = Arguments[1]
	local v = Devices[i].Objects[k]
	local j = v.Powers[h]
  v.Speed = General.Library.VectorNumberMult(v.Speed, 1/j.Rate ^ time)
  v.RotationSpeed = General.Library.VectorNumberMult(v.RotationSpeed, 1/j.Rate ^ time)
end
GiveBack.Powers.Destroypara = {}
function GiveBack.Powers.Destroypara.DataCheck(v)
	local Data = {}
	Data.Type = "Destroypara"
  if v.String == nil then
    v.String = "return false"
  end
  Data.Command = loadstring(v.String)
  if not pcall(Data.Command) then
    Data.Command = loadstring("return false")
  end
  Data.IfObject = false
  if type(v.IfObject) == "boolean" then
    Data.IfObject = v.IfObject
  end
  Data.Active = false
  if type(v.Active) == "boolean" then
    Data.Active = v.Active
  end
	return Data
end
function GiveBack.Powers.Destroypara.Use(Devices, i, k, h, time, Arguments)
  local General, AllDevices, AllDevicesGive = Arguments[1], Arguments[9], Arguments[10]
	local v = Devices[i].Objects[k]
	local j = v.Powers[h]
  local Ran, IfDestroy = pcall(j.Command, Devices, i, k, h, General)
  if Ran and IfDestroy then
    if j.IfObject then
      AllDevices.Library.RemoveObject(i, k, AllDevicesGive)
    else
      AllDevices.Library.RemoveDevice(i, AllDevicesGive)
    end
    return true
  end
end
GiveBack.Powers.Summon = {}
function GiveBack.Powers.Summon.DataCheck(v, Arguments)
  local General, JSON, Device, DeviceGive, lgsl, AllDevices, ffi = Arguments[1], Arguments[3], Arguments[5], Arguments[6], Arguments[7], Arguments[9], Arguments[11]
	local Data = {}
	Data.Type = "Summon"
  Data.Name = "Default"
  Data.Active = false
  if type(v.Name) == "string" and AllDevices.Space.DeviceTypes[v.Name] then
    Data.Name = v.Name
  end
  local NewDevice = Device.Library.Copy(AllDevices.Space.DeviceTypes[Data.Name], DeviceGive, AllDevices.Space.HelperMatrices)
  if v.String == nil then
    v.String = "local Created, Creator = ... for k=1,#Created.Objects do local v = Created.Objects[k] v.MMcalc = true for ak=1,3 do v.Translation[ak] = Creator.Translation[ak] end end print('Bad modifier function')"
  end
  Data.Command = loadstring(v.String)
  if not pcall(Data.Command, NewDevice, NewDevice.Objects[1], General) then
		Data.Command = loadstring("local Created, Creator = ... for k=1,#Created.Objects do local v = Created.Objects[k] v.MMcalc = true for ak=1,3 do v.Translation[ak] = Creator.Translation[ak] end end print('Bad modifier function')")
	end
  if type(v.Active) == "boolean" then
    Data.Active = v.Active
  end
  return Data
end
function GiveBack.Powers.Summon.Use(Devices, i, k, h, time, Arguments)
  local General, JSON, Device, DeviceGive, lgsl, AllDevices, AllDevicesGive, ffi = Arguments[1], Arguments[3], Arguments[5], Arguments[6], Arguments[7], Arguments[9], Arguments[10], Arguments[11]
  local v = Devices[i].Objects[k]
  local j = v.Powers[h]
  AllDevices.Library.AddDevice(j.Name, {Command = j.Command, Creator = v}, AllDevicesGive)
	j.Active = false
end
GiveBack.Requirements = {"General", "JSON", "Device", "lgsl", "AllDevices", "ffi"}
return GiveBack
