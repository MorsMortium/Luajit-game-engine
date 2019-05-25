local GiveBack = {}
function GiveBack.GoodTypesOfTable(Table, GoodType)
	if type(Table) == "table" then
    for ak=1,#Table do
			local av = Table[ak]
      if type(av) ~= GoodType then
        return false
      end
    end
		return true
	end
	return false
end
function GiveBack.IsVector3(Table)
	if(type(Table) == "table" and (#Table == 3 or #Table == 4) and
    type(Table[1]) == "number" and type(Table[2]) == "number" and
    type(Table[3]) == "number") then
		if(#Table == 4) then
			Table[4] = nil
		end
		return true
	end
	return false
end
function GiveBack.IsVector4(Table)
	if(type(Table) == "table" and #Table == 4 and type(Table[1]) == "number" and
  type(Table[2]) == "number" and type(Table[3]) == "number" and
  type(Table[4]) == "number") then
		return true
	end
	return false
end
function GiveBack.IsMatrix4(Table)
	if(type(Table) == "table" and GiveBack.IsVector4(Table[1]) and
  GiveBack.IsVector4(Table[2]) and GiveBack.IsVector4(Table[3]) and
  GiveBack.IsVector4(Table[4])) then
		return true
	end
	return false
end
function GiveBack.DataFromKeys(DataTable, KeyTable)
	local ReturnTable = {}
	if type(DataTable) == "table" and type(KeyTable) == "table" then
    for ak=1,#KeyTable do
      local av = KeyTable[ak]
			if type(DataTable[av]) ~= nil then
				ReturnTable[#ReturnTable + 1] = DataTable[av]
			end
		end
	end
	return ReturnTable
end
function GiveBack.SameLayer(Layers1, Layers2)
  for ak=1,#Layers1 do
		local av = Layers1[ak]
    if av == "AdminAll" then
      return true
    end
  end
  for ak=1,#Layers2 do
		local av = Layers2[ak]
    if av == "AdminAll" then
      return true
    end
  end
  for ak=1,#Layers1 do
		local av = Layers1[ak]
    if av == "None" then
      return false
    end
  end
  for ak=1,#Layers2 do
		local av = Layers2[ak]
    if av == "None" then
      return false
    end
  end
  for ak=1,#Layers1 do
		local av = Layers1[ak]
    if av == "All" then
      return true
    end
  end
  for ak=1,#Layers2 do
		local av = Layers2[ak]
    if av == "All" then
      return true
    end
  end
  for ak=1,#Layers1 do
		local av = Layers1[ak]
    for bk=1,#Layers2 do
			local bv = Layers2[bk]
      if av == bv then
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
  for ak=1,3 do
    result = result + a[ak] * b[ak]
  end
  return result
end
function GiveBack.VectorNumberMult(v, n)
  return {v[1] * n, v[2] * n, v[3] * n}
end
function GiveBack.PerpendicularToBoth(a, b)
  local Unit = {
    a[2] * b[3] - a[3] * b[2],
    a[3] * b[1] - a[1] * b[3],
    a[1] * b[2] - a[2] * b[1]}
  local Length = GiveBack.VectorLength(Unit)
  return GiveBack.VectorNumberMult(Unit, 1/Length)
end
function GiveBack.AxisAngleToQuaternion(Axis, Angle)
  return {math.cos(Angle / 2),
          Axis[1] * math.sin(Angle/2),
          Axis[2] * math.sin(Angle/2),
          Axis[3] * math.sin(Angle/2)}
end
function GiveBack.EulerToQuaternion(Euler)
	local cy, sy, cp, sp, cr, sr =
		math.cos(Euler[3] / 2), math.sin(Euler[3] / 2), math.cos(Euler[2] / 2),
		math.sin(Euler[2] / 2), math.cos(Euler[1] / 2), math.sin(Euler[1] / 2)
	return {
		cy * cp * cr + sy * sp * sr,
		cy * cp * sr - sy * sp * cr,
		sy * cp * sr + cy * sp * cr,
		sy * cp * cr - cy * sp * sr}
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
  return {u[2] * v[3] - u[3] * v[2],
          u[3] * v[1] - u[1] * v[3],
          u[1] * v[2] - u[2] * v[1]}
end
function GiveBack.RotationMatrix(lgsl, q, Center)
  local sqw, sqx, sqy, sqz = q[1]*q[1], q[2]*q[2], q[3]*q[3], q[4]*q[4]
  local m00 = sqx - sqy - sqz + sqw --// since sqw + sqx + sqy + sqz =1
  local m11 = -sqx + sqy - sqz + sqw
  local m22 = -sqx - sqy + sqz + sqw
  local tmp1, tmp2 = q[2]*q[3], q[4]*q[1]
  local m01, m10 = 2 * (tmp1 + tmp2), 2 * (tmp1 - tmp2)
  tmp1, tmp2 = q[2]*q[4], q[3]*q[1]
  local m02, m20 = 2 * (tmp1 - tmp2), 2 * (tmp1 + tmp2)
  tmp1, tmp2 = q[3]*q[4], q[2]*q[1]
  local m12, m21 = 2 * (tmp1 + tmp2), 2 * (tmp1 - tmp2)
  local a1, a2, a3
	a1, a2, a3 = 0, 0, 0
  if Center then
    a1, a2, a3 = Center[1], Center[2], Center[3]		
	end
	local m03 = a1 - a1 * m00 - a2 * m01 - a3 * m02
	local m13 = a2 - a1 * m10 - a2 * m11 - a3 * m12
	local m23 = a3 - a1 * m20 - a2 * m21 - a3 * m22
  return lgsl.Library.matrix.def{
  {m00, m01, m02, m03},
  {m10, m11, m12, m13},
  {m20, m21, m22, m23},
  {0, 0, 0, 1}}
end
function GiveBack.TranslationMatrix(lgsl, Translation)
  return lgsl.Library.matrix.def{
  {1, 0, 0, Translation[1]},
  {0, 1, 0, Translation[2]},
  {0, 0, 1, Translation[3]},
  {0, 0, 0, 1}}
end
function GiveBack.ScaleMatrix(lgsl, Scale)
  return lgsl.Library.matrix.def{
  {Scale[1], 0, 0, 0},
  {0, Scale[2], 0, 0},
  {0, 0, Scale[3], 0},
  {0, 0, 0, 1}}
end
function GiveBack.ModelMatrix(Translation, Rotation, Scale, lgsl)
  return GiveBack.TranslationMatrix(lgsl, Translation) *
          GiveBack.RotationMatrix(lgsl, Rotation) *
          GiveBack.ScaleMatrix(lgsl, Scale)
end
function GiveBack.Normalise(a)
    return {a[1]/GiveBack.VectorLength(a),
            a[2]/GiveBack.VectorLength(a),
            a[3]/GiveBack.VectorLength(a)}
end
function GiveBack.CreateCollisionSphere(Object)
	local Radius = 0
	for f=0,3 do
		local NewRadius = GiveBack.VectorLength({
		Object.Transformated.data[f * 4],
		Object.Transformated.data[f * 4 + 1],
		Object.Transformated.data[f * 4 + 2]})
		if Radius < NewRadius then
			Radius = NewRadius
		end
	end
	Object.Radius = Radius
end
function GiveBack.VectorAddition(a, b)
  return {a[1] + b[1], a[2] + b[2], a[3] + b[3]}
end
function GiveBack.VectorSubtraction(a, b)
  return {a[1] - b[1], a[2] - b[2], a[3] - b[3]}
end
GiveBack.Requirements = {}
return GiveBack
