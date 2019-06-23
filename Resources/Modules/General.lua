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
function GiveBack.DeepCopy(Original, ffi)
  local OriginalType = type(Original)
  local Copy
  if OriginalType == 'table' then
    Copy = {}
    for ak, av in next, Original, nil do
      Copy[GiveBack.DeepCopy(ak, ffi)] = GiveBack.DeepCopy(av, ffi)
    end
    setmetatable(Copy, GiveBack.DeepCopy(getmetatable(Original), ffi))
  elseif OriginalType == "cdata" then
		Copy = ffi.Library.new(ffi.Library.typeof(Original), Original)
	else -- number, string, boolean, etc
    Copy = Original
  end
  return Copy
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
function GiveBack.RotationMatrix(q, Center, Matrix, gsl, ffi)
  local sqw, sqx, sqy, sqz = q[1]*q[1], q[2]*q[2], q[3]*q[3], q[4]*q[4]
	local m = ffi.Library.new("double[16]")
  m[0] = sqx - sqy - sqz + sqw --// since sqw + sqx + sqy + sqz =1
  m[5], m[10] = -sqx + sqy - sqz + sqw, -sqx - sqy + sqz + sqw
  local tmp1, tmp2 = q[2]*q[3], q[4]*q[1]
  m[1], m[4] = 2 * (tmp1 + tmp2), 2 * (tmp1 - tmp2)
  tmp1, tmp2 = q[2]*q[4], q[3]*q[1]
  m[2], m[8] = 2 * (tmp1 - tmp2), 2 * (tmp1 + tmp2)
  tmp1, tmp2 = q[3]*q[4], q[2]*q[1]
  m[6], m[9] = 2 * (tmp1 + tmp2), 2 * (tmp1 - tmp2)
  local a1, a2, a3 = 0, 0, 0
  if Center then
    a1, a2, a3 = Center[1], Center[2], Center[3]
	end
	m[3] = a1 - a1 * m[0] - a2 * m[1] - a3 * m[2]
	m[7] = a2 - a1 * m[4] - a2 * m[5] - a3 * m[6]
	m[11] = a3 - a1 * m[8] - a2 * m[9] - a3 * m[10]
	m[12], m[13], m[14], m[15] = 0, 0, 0, 1
	Matrix.data = m
end
function GiveBack.TranslationMatrix(gsl, Translation, Matrix)
	gsl.gsl_matrix_set_identity(Matrix)
	Matrix.data[3], Matrix.data[7], Matrix.data[11] =
	Translation[1], Translation[2], Translation[3]
end
function GiveBack.ScaleMatrix(gsl, Scale, Matrix)
	gsl.gsl_matrix_set_zero(Matrix)
	Matrix.data[0], Matrix.data[5], Matrix.data[10], Matrix.data[15] =
	Scale[1], Scale[2], Scale[3], 1
end
function GiveBack.ModelMatrix(Object, HelperMatrices, gsl, ffi)
	GiveBack.ScaleMatrix(gsl, Object.Scale, HelperMatrices[1])
	GiveBack.RotationMatrix(Object.Rotation, nil, HelperMatrices[2], gsl, ffi)
	gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasTrans, 1, HelperMatrices[1],
	HelperMatrices[2], 0, HelperMatrices[3])
	GiveBack.TranslationMatrix(gsl, Object.Translation, HelperMatrices[2])
	gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasTrans, 1, HelperMatrices[2],
	HelperMatrices[3], 0, HelperMatrices[1])
end
function GiveBack.Normalise(a)
	local Length = GiveBack.VectorLength(a)
	return {a[1]/Length, a[2]/Length, a[3]/Length}
end
function GiveBack.CreateCollisionSphere(Object)
	local Radius = 0
	for ak=0,3 do
		local NewRadius = GiveBack.VectorLength({
		Object.Transformated.data[ak * 4],
		Object.Transformated.data[ak * 4 + 1],
		Object.Transformated.data[ak * 4 + 2]})
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
function GiveBack.UpdateObject(Object, IfSphere, HelperMatrices, Arguments)
	local lgsl, ffi = Arguments[1], Arguments[3]
	local gsl = lgsl.Library.gsl
	GiveBack.ModelMatrix(Object, HelperMatrices, gsl, ffi)
	gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasTrans, 1, Object.Points,
	HelperMatrices[1], 0, Object.Transformated)
	if IfSphere then
		GiveBack.CreateCollisionSphere(Object)
	end
	Object.Min = {Object.Translation[1] - Object.Radius,
								Object.Translation[2] - Object.Radius,
								Object.Translation[3] - Object.Radius}
	Object.Max = {Object.Translation[1] + Object.Radius,
								Object.Translation[2] + Object.Radius,
								Object.Translation[3] + Object.Radius}
end
function GiveBack.ConcatenateCArrays(CArrays, ArrayLength, Type, ffi)
  local ArraySize = ffi.Library.sizeof(ffi.Library.typeof(Type))
  local SizeOfAll = ArrayLength * #CArrays
  local NewCArray = ffi.Library.new(Type .. "[?]", SizeOfAll)
  for i=1,#CArrays do
    ffi.Library.copy(NewCArray + (i - 1) * ArrayLength, CArrays[i],
		ArraySize * ArrayLength)
  end
  return NewCArray
end
GiveBack.Requirements = {"lgsl", "ffi"}
return GiveBack
