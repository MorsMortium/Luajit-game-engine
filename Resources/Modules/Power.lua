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
	if type(v.Force) == "number" then
		Data.Force = v.Force
	else
		Data.Force = 0.005
	end
	if type(v.Distance) == "number" then
		Data.Distance = v.Distance
	else
		Data.Distance = 100
	end
  if type(v.Active) == "boolean" then
    Data.Active = v.Active
  else
    Data.Active = false
  end
  return Data
end
function GiveBack.Powers.Gravity.Use(Devices, i, k, h, time, Arguments)
  local General = Arguments[1]
	local v = Devices[i].Objects[k]
	local j = v.Powers[h]
  if j.Active then
    --lmn
    for ak=1,#Devices do
      local av = Devices[ak]
      for bk=1,#av.Objects do
        local bv = av.Objects[bk]
        if v.PowerChecked[h][ak..bk] == nil then
  				if (i ~= ak or k ~= bk) and General.Library.SameLayer(v.PhysicsLayers, bv.PhysicsLayers) and
  				math.sqrt((bv.Translation[1] - v.Translation[1])^2 +
  									(bv.Translation[2] - v.Translation[2])^2 +
  									(bv.Translation[3] - v.Translation[3])^2) < j.Distance then
  					for ck=1,3 do
              if not bv.Fixed then
                if bv.Translation[ck] > v.Translation[ck] then
    							bv.Speed[ck] = bv.Speed[ck] - time * j.Force
    						elseif b.Translation[ck] < v.Translation[ck] then
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
  				v.PowerChecked[h][ak..bk] = true
  			end
      end
    end
  end
end
GiveBack.Powers.Thruster = {}
function GiveBack.Powers.Thruster.DataCheck(v)
	local Data = {}
	Data.Type = "Thruster"
	if type(v.Force) == "number" then
		Data.Force = v.Force
	else
		Data.Force = 0.005
	end
	if v.Point == 1 or v.Point == 2 or v.Point == 3 or v.Point == 4 then
		Data.Point = v.Point
	else
		Data.Point = 1
	end
  if type(v.Active) == "boolean" then
    Data.Active = v.Active
  else
    Data.Active = false
  end
	return Data
end
function GiveBack.Powers.Thruster.Use(Devices, i, k, h, time, Arguments)
  local General = Arguments[1]
	local v = Devices[i].Objects[k]
	local j = v.Powers[h]
  if j.Active and not v.Fixed then
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
	if type(v.Angle) == "number" then
		Data.Angle = v.Angle
	else
		Data.Angle = 0.005
	end
	if v.Point == 1 or v.Point == 2 or v.Point == 3 or v.Point == 4 then
		Data.Point = v.Point
	else
		Data.Point = 1
	end
  if type(v.Active) == "boolean" then
    Data.Active = v.Active
  else
    Data.Active = false
  end
	return Data
end
function GiveBack.Powers.SelfRotate.Use(Devices, i, k, h, time, Arguments)
  local General = Arguments[1]
  local v = Devices[i].Objects[k]
  local j = v.Powers[h]
  if j.Active and not v.Fixed then
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
	if type(v.Rate) == "number" then
		Data.Rate = v.Rate
	else
		Data.Rate = 2
	end
  if type(v.Active) == "boolean" then
    Data.Active = v.Active
  else
    Data.Active = false
  end
	return Data
end
function GiveBack.Powers.SelfSlow.Use(Devices, i, k, h, time, Arguments)
  local General = Arguments[1]
	local v = Devices[i].Objects[k]
	local j = v.Powers[h]
  if j.Active then
    v.Speed = General.Library.VectorNumberMult(v.Speed, 1/j.Rate ^ time)
    v.RotationSpeed = General.Library.VectorNumberMult(v.RotationSpeed, 1/j.Rate ^ time)
  end
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
  if v.Doo == "Object" or v.Doo == "Device" then
    Data.Doo = v.Doo
  else
    Data.Doo = "Device"
  end
  if type(v.Active) == "boolean" then
    Data.Active = v.Active
  else
    Data.Active = false
  end
	return Data
end
function GiveBack.Powers.Destroypara.Use(Devices, i, k, h, time, Arguments)
  local General = Arguments[1]
	local v = Devices[i].Objects[k]
	local j = v.Powers[h]
  if j.Active then
    local Ran, ifdestroy = pcall(j.Command, Devices, i, k, h, General)
    if Ran and ifdestroy then
      if j.Doo == "Object" then
        table.remove(Devices[i].Objects, k)
        return true
      else
        table.remove(Devices, i)
        return true
      end
    end
  end
end
GiveBack.Powers.Summon = {}
function GiveBack.Powers.Summon.DataCheck(v, Arguments)
  local General, JSON, Device, DeviceGive, lgsl = Arguments[1], Arguments[3], Arguments[5], Arguments[6], Arguments[7]
	local Data = {}
	Data.Type = "Summon"
	local DeviceObject
	if type(v.Name) == "string" and FileExists("./Resources/Configurations/AllDevices/" .. v.Name .. ".json") then
		Data.Name = v.Name
		local Devicecode = JSON.Library:DecodeFromFile("./Resources/Configurations/AllDevices/" .. v.Name .. ".json")
    if type(Devicecode) == "table" then
      DeviceObject = Device.Library.Create(Devicecode, Data.Name, DeviceGive)
    end
	else
		Data.Name = "Default"
		local Devicecode = JSON.Library:DecodeFromFile("./Resources/Configurations/AllDevices/Default.json")
    if type(Devicecode) == "table" then
      DeviceObject = Device.Library.Create(Devicecode, Data.Name, DeviceGive)
    end
  end
  local gsl = lgsl.Library.gsl
  for ak=1,#DeviceObject.Objects do
    local av = DeviceObject.Objects[ak]
    av.PowerChecked = {}
    if type(av.Powers) == "table" then
      for bk=1,#av.Powers do
        local bv = av.Powers[bk]
        if GiveBack.Powers[bv.Type] then
          av.Powers[bk] = GiveBack.Powers[bv.Type].DataCheck(bv, General, JSON, Device, DeviceGive, lgsl, lgslGive)
          av.PowerChecked[bk] = {}
        end
      end
    end
  end
  if v.String == nil then
    v.String = "local Created, Creator = ... for k=1,#Created.Objects do local v = Created.Objects[k] v.MMcalc = true for ak=1,3 do v.Translation[ak] = Creator.Translation[ak] end end print('Bad modifier function')"
  end
  Data.Command = loadstring(v.String)
  if not pcall(Data.Command, DeviceObject, DeviceObject.Objects[1], General) then
		Data.Command = loadstring("local Created, Creator = ... for k=1,#Created.Objects do local v = Created.Objects[k] v.MMcalc = true for ak=1,3 do v.Translation[ak] = Creator.Translation[ak] end end print('Bad modifier function')")
	end
  if type(v.Active) == "boolean" then
    Data.Active = v.Active
  else
    Data.Active = false
  end
  return Data
end
function GiveBack.Powers.Summon.Use(Devices, i, k, h, time, Arguments)
  local General, JSON, Device, DeviceGive, lgsl = Arguments[1], Arguments[3], Arguments[5], Arguments[6], Arguments[7]
	local v = Devices[i].Objects[k]
	local j = v.Powers[h]
  if j.Active then
    local gsl = lgsl.Library.gsl
    local Devicecode = JSON.Library:DecodeFromFile("./Resources/Configurations/AllDevices/" .. j.Name .. ".json")
    local DeviceObject
    if type(Devicecode) == "table" then
      DeviceObject = Device.Library.Create(Devicecode, j.Name, DeviceGive)
      for ak=1,#DeviceObject.Objects do
        local av = DeviceObject.Objects[ak]
        av.PowerChecked = {}
        if type(av.Powers) == "table" then
          for bk=1,#av.Powers do
            local bv = av.Powers[bk]
            if GiveBack.Powers[bv.Type] then
              av.Powers[bk] = GiveBack.Powers[bv.Type].DataCheck(bv, General, JSON, Device, DeviceGive, lgsl, lgslGive)
              av.PowerChecked[bk] = {}
            end
          end
        end
      end
      pcall(j.Command, DeviceObject, v, General)
      for ak=1,#DeviceObject.Objects do
        local av = DeviceObject.Objects[ak]
        av.ModelMatrix = General.Library.ModelMatrix(av.Translation, av.Rotation, av.Scale, lgsl)
        lgsl.Library.gsl.gsl_blas_dgemm(lgsl.Library.gsl.CblasNoTrans, lgsl.Library.gsl.CblasTrans, 1, av.ModelMatrix, av.Points, 0, av.Transformated)
        lgsl.Library.gsl.gsl_matrix_transpose(av.Transformated)
        General.Library.CreateCollisionSphere(av)
      end
      Devices[#Devices + 1] = DeviceObject
    end
		j.Active = false
  end
end
GiveBack.Requirements = {"General", "JSON", "Device", "lgsl"}
return GiveBack
