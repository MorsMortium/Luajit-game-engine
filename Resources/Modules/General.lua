local GiveBack = {}
function GiveBack.Swap(ATable, AName, Btable, BName, ffi)
  local temp = GiveBack.DeepCopy(ATable[AName], ffi)
  ATable[AName] = Btable[BName]
  Btable[BName] = temp
end
function GiveBack.Sign(Number)
	if type(Number) == "number" then
		if Number < 0 then
			return "minus"
		elseif Number > 0 then
			return "plus"
		else
			return "zero"
		end
	end
end
function GiveBack.stackoverflow()
	stackoverflow()
end
function GiveBack.Outofmemory()--~ig
	local Tab = {}
	while true do
		Tab[1] = {}
		Tab = Tab[1]
	end
end
function GiveBack.tableoverflow(ffi)
	local i = 1
  local Tab
	while true do
		Tab = ffi.Library.new("int["..i.."]")
		i = i + 1
	end
end
function GiveBack.fullmemory()
	while true do
		print(1)
	end
end
function GiveBack.IdentityMatrix(size)
	local Matrix = {}
	for i = 1, size * size do
		Matrix[i] = 0
	end
	for i = 1, size do
		Matrix[i + (i - 1) * size] = 1
	end
	return Matrix
end
function GiveBack.PrintTable(Table, IfRec)
	if type(Table) == "table" then
		for k,v in pairs(Table) do
			if IfRec and type(v) == "table" then
				print(k .. ": ")
				GiveBack.PrintTable(v, true)
			else
				print(k, v)
			end
		end
	else
		print(Table)
	end
end
function GiveBack.GoodTypesOfTable(Table, GoodType)
	if type(Table) == "table" then
		for k, v in pairs(Table) do
			if type(v) ~= GoodType then
				return false
			end
		end
		return true
	else
		return false
	end
end
function GiveBack.IsVector3(Table)
	if(type(Table) == "table" and (#Table == 3 or #Table == 4) and type(Table[1]) == "number" and type(Table[2]) == "number" and type(Table[3]) == "number") then
		if(#Table == 4) then
			Table[4] = nil
		end
		return true
	else
		return false
	end
end
function GiveBack.IsVector4(Table)
	if(type(Table) == "table" and #Table == 4 and type(Table[1]) == "number" and type(Table[2]) == "number" and type(Table[3]) == "number" and type(Table[4]) == "number") then
		return true
	else
		return false
	end
end
function GiveBack.IsMatrix4(Table)
	if(type(Table) == "table" and GiveBack.IsVector4(Table[1]) and GiveBack.IsVector4(Table[2]) and GiveBack.IsVector4(Table[3]) and GiveBack.IsVector4(Table[4])) then
		return true
	else
		return false
	end
end
function GiveBack.DataFromKeys(DataTable, KeyTable)
	local ReturnTable = {}
	if type(DataTable) == "table" and type(KeyTable) == "table" then
		for k, v in pairs(KeyTable) do
			if type(DataTable[v]) ~= nil then
				table.insert(ReturnTable, DataTable[v])
			end
		end
	end
	return ReturnTable
end
function GiveBack.TableLength(Table)
	local Count = 0
	for k, v in pairs(Table) do
		Count = Count + 1
	end
	return Count
end
function GiveBack.Log(Text, ErrorFlag, LogFilePathName)
	local LogFile = io.open(LogFilePathName, "a")
	LogFile:write(os.date("%c : ")..Text.."\n")
	LogFile:close()
	if ErrorFlag then
		Error(os.date("%c : ")..Text)
	end
end
function GiveBack.DeepCopy(Original, ffi, ffiGive)
    local Original_Type = type(Original)
    local Copy
    if Original_Type == "table" then
        Copy = {}
        for Original_key, Original_value in pairs(Original) do
            Copy[GiveBack.DeepCopy(Original_key, ffi, ffiGive)] = GiveBack.DeepCopy(Original_value, ffi, ffiGive)
        end
        setmetatable(Copy, GiveBack.DeepCopy(getmetatable(Original), ffi, ffiGive))
    elseif Original_Type == "cdata" then
      Copy = ffi.Library.new(ffi.Library.typeof(Original), Original)
    else -- Number, String, boolean, etc
        Copy = Original
    end
    return Copy
end
function GiveBack.SameLayer(Layers1, Layers2)
  for i=1,#Layers1 do
    if Layers1[i] == "AdminAll" then
      return true
    end
  end
  for i=1,#Layers2 do
    if Layers2[i] == "AdminAll" then
      return true
    end
  end
  for i=1,#Layers1 do
    if Layers1[i] == "None" then
      return false
    end
  end
  for i=1,#Layers2 do
    if Layers2[i] == "None" then
      return false
    end
  end
  for i=1,#Layers1 do
    if Layers1[i] == "All" then
      return true
    end
  end
  for i=1,#Layers2 do
    if Layers2[i] == "All" then
      return true
    end
  end
  for i=1,#Layers1 do
    for e=1,#Layers2 do
      if Layers1[i] == Layers2[e] then
        return true
      end
    end
  end
  return false
end
function GiveBack.VectorLength(a)
   return math.sqrt(a[1]*a[1] + a[2]*a[2] + a[3]*a[3])
end
function GiveBack.PointAToB(a, b)
  return {b[1] - a[1], b[2] - a[2], b[3] - a[3]}
end
function GiveBack.DotProduct(a, b)
  local result = 0
  if type(a) == "table" and type(b) == "table" then
    for i=1,3 do
      result = result + a[i] * b[i]
    end
  elseif type(a) == "cdata" and type(b) == "cdata" then
    for i=0,2 do
      result = result + a.data[i] * b.data[i]
    end
  elseif type(a) == "cdata" and type(b) == "table" then
    for i=0,2 do
      result = result + a.data[i] * b[i + 1]
    end
  end
  return result
end
function GiveBack.AngleAB(a, b)
  return math.acos(GiveBack.DotProduct(a,b)/(GiveBack.VectorLength(a) * GiveBack.VectorLength(b))) * 180/math.pi
end
function GiveBack.PerpendicularToBoth(a, b)
  local Unit = {
    a[2] * b[3] - a[3] * b[2],
    a[3] * b[1] - a[1] * b[3],
    a[1] * b[2] - a[2] * b[1]}
  local Length = GiveBack.VectorLength(Unit)
  for i=1,3 do
    Unit[i] = Unit[i]/Length
  end
  return Unit
end
function GiveBack.AxisAngleToQuaternion(Axis, Angle)
  return {math.cos(Angle / 2), Axis[1] * math.sin(Angle/2), Axis[2] * math.sin(Angle/2), Axis[3] * math.sin(Angle/2)}
end
function GiveBack.QuaternionMultiplication(a, b)
    return {
        a[1] * b[1] - a[2] * b[2] - a[3] * b[3] - a[4] * b[4],
        a[1] * b[2] + a[2] * b[1] + a[3] * b[4] - a[4] * b[3],
        a[1] * b[3] - a[2] * b[4] + a[3] * b[1] + a[4] * b[2],
        a[1] * b[4] + a[2] * b[3] - a[3] * b[2] + a[4] * b[1]
    }
end
function GiveBack.CrossProduct(u, v)
  return {u[2] * v[3] - u[3] * v[2], u[3] * v[1] - u[1] * v[3], u[1] * v[2] - u[2] * v[1]}
end
function GiveBack.RotationMatrix(lgsl, q, Center)
  local sqw = q[1]*q[1]
  local sqx = q[2]*q[2]
  local sqy = q[3]*q[3]
  local sqz = q[4]*q[4]
  m00 = sqx - sqy - sqz + sqw --// since sqw + sqx + sqy + sqz =1
  m11 = -sqx + sqy - sqz + sqw
  m22 = -sqx - sqy + sqz + sqw
  local tmp1 = q[2]*q[3]
  local tmp2 = q[4]*q[1]
  m01 = 2 * (tmp1 + tmp2)
  m10 = 2 * (tmp1 - tmp2)
  tmp1 = q[2]*q[4]
  tmp2 = q[3]*q[1]
  m02 = 2 * (tmp1 - tmp2)
  m20 = 2 * (tmp1 + tmp2)
  tmp1 = q[3]*q[4]
  tmp2 = q[2]*q[1]
  m12 = 2 * (tmp1 + tmp2)
  m21 = 2 * (tmp1 - tmp2)
  local a1 = 0
  local a2 = 0
  local a3 = 0
  if Center ~= nil then
    a1 = Center[1]
    a2 = Center[2]
    a3 = Center[3]
	end
	m03 = a1 - a1 * m00 - a2 * m01 - a3 * m02
	m13 = a2 - a1 * m10 - a2 * m11 - a3 * m12
	m23 = a3 - a1 * m20 - a2 * m21 - a3 * m22
  return lgsl.Library.matrix.def{
  {m00, m01, m02, m03},
  {m10, m11, m12, m13},
  {m20, m21, m22, m23},
  {0, 0, 0, 1}}
end
function GiveBack.TranslationMatrix(lgsl, Translation)
  return lgsl.Library.matrix.def{
  {1, 0, 0, Translation[0]},
  {0, 1, 0, Translation[1]},
  {0, 0, 1, Translation[2]},
  {0, 0, 0, 1}}
end
function GiveBack.ScaleMatrix(lgsl, Scale)
  return lgsl.Library.matrix.def{
  {Scale[0], 0, 0, 0},
  {0, Scale[1], 0, 0},
  {0, 0, Scale[2], 0},
  {0, 0, 0, 1}}
end
function GiveBack.ModelMatrix(Translation, Rotation, Scale, lgsl)
  return GiveBack.TranslationMatrix(lgsl, Translation) * GiveBack.RotationMatrix(lgsl, Rotation) * GiveBack.ScaleMatrix(lgsl, Scale)
end
function GiveBack.Normalise(a)
    return {a[1]/GiveBack.VectorLength(a), a[2]/GiveBack.VectorLength(a), a[3]/GiveBack.VectorLength(a)}
end
GiveBack.Requirements = {"ffi", "lgsl"}
return GiveBack
