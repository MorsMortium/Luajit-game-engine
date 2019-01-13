local GiveBack = {}
function FileExists(Name)
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
	for i=1,3 do
		Axis[i] = Axis[i] / Magnitude
	end
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
function GiveBack.Powers.Gravity.Use(Devices, i, k, h, time, General, GeneralGive)
	local v = Devices[i].Objects[k]
	local j = v.Powers[h]
  if j.Active then
    for e,f in pairs(Devices) do
  		for a,b in pairs(f.Objects) do
  			if v.PowerChecked[h][e..a] == nil then
  				if (i ~= e or k ~= a) and General.Library.SameLayer(v.PhysicsLayers, b.PhysicsLayers) and
  				math.sqrt((b.Translation[0] - v.Translation[0])^2 +
  									(b.Translation[1] - v.Translation[1])^2 +
  									(b.Translation[2] - v.Translation[2])^2) < j.Distance then
  					for xx=0,2 do
  						if b.Translation[xx] > v.Translation[xx] then
  							if not b.Fixed then
  								b.Speed[xx + 1] = b.Speed[xx + 1] - j.Force
  							end
  							if not v.Fixed then
  								v.Speed[xx + 1] = v.Speed[xx + 1] + j.Force
  							end
  						elseif b.Translation[xx] < v.Translation[xx] then
  							if not b.Fixed then
  								b.Speed[xx + 1] = b.Speed[xx + 1] + j.Force
  							end
  							if not v.Fixed then
  								v.Speed[xx + 1] = v.Speed[xx + 1] - j.Force
  							end
  						end
  					end
  				end
  				v.PowerChecked[h][e..a] = true
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
function GiveBack.Powers.Thruster.Use(Devices, i, k, h, time, General, GeneralGive)
	local v = Devices[i].Objects[k]
	local j = v.Powers[h]
  if j.Active and not v.Fixed then
    local p1 = {v.Transformated.data[(j.Point-1) * 4], v.Transformated.data[(j.Point-1) * 4 + 1], v.Transformated.data[(j.Point-1) * 4 + 2]}
    local c1 = {v.Translation[0], v.Translation[1], v.Translation[2]}
    local vfc1tp1 = General.Library.PointAToB(c1, p1)
      for xx=1,3 do
        v.Speed[xx] = v.Speed[xx] + vfc1tp1[xx] * j.Force
      end
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
function GiveBack.Powers.SelfRotate.Use(Devices, i, k, h, time, General, GeneralGive)
  local v = Devices[i].Objects[k]
  local j = v.Powers[h]
  if j.Active and not v.Fixed then
		local p1 = {v.Transformated.data[(j.Point-1) * 4], v.Transformated.data[(j.Point-1) * 4 + 1], v.Transformated.data[(j.Point-1) * 4 + 2]}
		local c1 = {v.Translation[0], v.Translation[1], v.Translation[2]}
		local vfc1tp1 = General.Library.PointAToB(c1, p1)
		local euler = ToEuler(vfc1tp1, j.Angle, General)
		for i=1,3 do
			v.RotationSpeed[i] = v.RotationSpeed[i] + euler[i]
		end
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
function GiveBack.Powers.SelfSlow.Use(Devices, i, k, h, time, General, GeneralGive)
	local v = Devices[i].Objects[k]
	local j = v.Powers[h]
  if j.Active then
    for i=1,3 do
      v.Speed[i] = v.Speed[i] / j.Rate
			v.RotationSpeed[i] = v.RotationSpeed[i] / j.Rate
    end
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
function GiveBack.Powers.Destroypara.Use(Devices, i, k, h, time, General, GeneralGive)
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
function GiveBack.Powers.Summon.DataCheck(v, General, GeneralGive, JSON, JSONGive, Device, DeviceGive, lgsl, lgslGive)
	local Data = {}
	Data.Type = "Summon"
	local DeviceObject
	if type(v.Name) == "string" and FileExists("./Resources/Configurations/AllDevices/" .. v.Name .. ".json") then
		Data.Name = v.Name
		local Devicecode = JSON.Library:DecodeFromFile("./Resources/Configurations/AllDevices/" .. v.Name .. ".json")
    if type(Devicecode) == "table" then
      DeviceObject = Device.Library.Create(Devicecode, Data.Name, unpack(DeviceGive))
    end
	else
		Data.Name = "Default"
		local Devicecode = JSON.Library:DecodeFromFile("./Resources/Configurations/AllDevices/Default.json")
    if type(Devicecode) == "table" then
      DeviceObject = Device.Library.Create(Devicecode, Data.Name, unpack(DeviceGive))
    end
  end
  local gsl = lgsl.Library.gsl
  for i,n in pairs(DeviceObject.Objects) do
    n.PowerChecked = {}
    if type(n.Powers) == "table" then
      for x,y in pairs(n.Powers) do
        if GiveBack.Powers[y.Type] then
          n.Powers[x] = GiveBack.Powers[y.Type].DataCheck(y, General, GeneralGive, JSON, JSONGive, Device, DeviceGive, lgsl, lgslGive)
          n.PowerChecked[x] = {}
        end
      end
    end
    n.ModelMatrix = General.Library.ModelMatrix(n.Translation, n.Rotation, n.Scale, lgsl)
    n.Transformated = gsl.gsl_matrix_alloc(4, 4)
    gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasTrans, 1, n.ModelMatrix, n.Points, 0, n.Transformated)
    gsl.gsl_matrix_transpose(n.Transformated)
    n.MMcalc = false
    n.CollisionBoxMaximum = {}
    n.CollisionBoxMinimum = {}
    for e=0,2 do
      local Maximum = n.Transformated.data[e]
      local  Minimum = Maximum
      for f=0,3 do
        if Maximum < n.Transformated.data[f * 4 + e] then
          Maximum = n.Transformated.data[f * 4 + e]
        end
        if Minimum > n.Transformated.data[f * 4 + e] then
          Minimum = n.Transformated.data[f * 4 + e]
        end
      end
      n.CollisionBoxMaximum[e + 1] = Maximum
      n.CollisionBoxMinimum[e + 1] = Minimum
    end
  end
  if v.String == nil then
    v.String = "local Created, Creator = ... for k,v in pairs(Created.Objects) do v.MMcalc = true for i=0,2 do v.Translation[i] = Creator.Translation[i] end end print('Bad modifier function')"
  end
  Data.Command = loadstring(v.String)
  if not pcall(Data.Command, DeviceObject, DeviceObject.Objects[1], General) then
		Data.Command = loadstring("local Created, Creator = ... for k,v in pairs(Created.Objects) do v.MMcalc = true for i=0,2 do v.Translation[i] = Creator.Translation[i] end end print('Bad modifier function')")
	end
  if type(v.Active) == "boolean" then
    Data.Active = v.Active
  else
    Data.Active = false
  end
  return Data
end
function GiveBack.Powers.Summon.Use(Devices, i, k, h, time, General, GeneralGive, JSON, JSONGive, Device, DeviceGive, lgsl, lgslGive)
	local v = Devices[i].Objects[k]
	local j = v.Powers[h]
  if j.Active then
    local gsl = lgsl.Library.gsl
    local Devicecode = JSON.Library:DecodeFromFile("./Resources/Configurations/AllDevices/" .. j.Name .. ".json")
    local DeviceObject
    if type(Devicecode) == "table" then
      DeviceObject = Device.Library.Create(Devicecode, j.Name, unpack(DeviceGive))
      for i,n in pairs(DeviceObject.Objects) do
        n.PowerChecked = {}
        if type(n.Powers) == "table" then
          for x,y in pairs(n.Powers) do
            if GiveBack.Powers[y.Type] then
              n.Powers[x] = GiveBack.Powers[y.Type].DataCheck(y, General, GeneralGive, JSON, JSONGive, Device, DeviceGive, lgsl, lgslGive)
              n.PowerChecked[x] = {}
            end
          end
        end
      end
      pcall(j.Command, DeviceObject, v, General)
      for i,n in pairs(DeviceObject.Objects) do
        n.ModelMatrix = General.Library.ModelMatrix(n.Translation, n.Rotation, n.Scale, lgsl)
        n.Transformated = gsl.gsl_matrix_alloc(4, 4)
        gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasTrans, 1, n.ModelMatrix, n.Points, 0, n.Transformated)
        gsl.gsl_matrix_transpose(n.Transformated)
        n.MMcalc = false
        n.CollisionBoxMaximum = {}
        n.CollisionBoxMinimum = {}
        for e=0,2 do
          local Maximum = n.Transformated.data[e]
          local  Minimum = Maximum
          for f=0,3 do
            if Maximum < n.Transformated.data[f * 4 + e] then
              Maximum = n.Transformated.data[f * 4 + e]
            end
            if Minimum > n.Transformated.data[f * 4 + e] then
              Minimum = n.Transformated.data[f * 4 + e]
            end
          end
          n.CollisionBoxMaximum[e + 1] = Maximum
          n.CollisionBoxMinimum[e + 1] = Minimum
        end
      end
      table.insert(Devices, DeviceObject)
    end
		j.Active = false
  end
end
GiveBack.Requirements = {"General", "JSON", "Device", "lgsl"}
return GiveBack
