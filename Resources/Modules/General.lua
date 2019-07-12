local GiveBack = {}
--General functions used in various places
--Mostly vector functions
--TODO: Move vector stuff into different file, and use gsl where possible or
--Where it's faster

--Checks if a variable is a table, and all of it's values are of one type
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

--Checks if a variable is a table, and all of it's values are of one type (Hash)
function GiveBack.GoodTypesOfHashTable(Table, GoodType)
	if type(Table) == "table" then
		for ak,av in pairs(Table) do
			if type(av) ~= GoodType then
				return false
			end
		end
		return true
	end
	return false
end

--Recursive deep copy with support for C types
function GiveBack.DeepCopy(Original, ffi)
	local DeepCopy = GiveBack.DeepCopy
  local OriginalType = type(Original)
  local Copy
  if OriginalType == 'table' then
    Copy = {}
    for ak, av in next, Original, nil do
      Copy[DeepCopy(ak, ffi)] = DeepCopy(av, ffi)
    end
    setmetatable(Copy, DeepCopy(getmetatable(Original), ffi))
  elseif OriginalType == "cdata" then
		Copy = ffi.Library.new(ffi.Library.typeof(Original), Original)
	else -- number, string, boolean, etc
    Copy = Original
  end
  return Copy
end

--Checks if a variable is a vector containing 3 numbers
function GiveBack.IsVector3(Table)
	if(type(Table) == "table" and #Table == 3 and
    type(Table[1]) == "number" and type(Table[2]) == "number" and
    type(Table[3]) == "number") then
		return true
	end
	return false
end

--Checks if a variable is a vector containing 4 numbers
function GiveBack.IsVector4(Table)
	if(type(Table) == "table" and #Table == 4 and type(Table[1]) == "number" and
  type(Table[2]) == "number" and type(Table[3]) == "number" and
  type(Table[4]) == "number") then
		return true
	end
	return false
end

--Checks if a variable is a matrix containing 4 vectors which each contains 4 numbers
function GiveBack.IsMatrix4(Table)
	if(type(Table) == "table" and GiveBack.IsVector4(Table[1]) and
  GiveBack.IsVector4(Table[2]) and GiveBack.IsVector4(Table[3]) and
  GiveBack.IsVector4(Table[4])) then
		return true
	end
	return false
end

--Looks up values from a hashtable, and returns them in an array in the order of
--The keytable. Nil values are discarded
function GiveBack.DataFromKeys(DataTable, KeyTable)
	local ReturnTable = {}
	if type(DataTable) == "table" and type(KeyTable) == "table" then
    for ak=1,#KeyTable do
      local av = KeyTable[ak]
			if DataTable[av] ~= nil then
				ReturnTable[#ReturnTable + 1] = DataTable[av]
			end
		end
	end
	return ReturnTable
end

--Checks wether two physics or visual layers are overlapping
function GiveBack.SameLayer(Layers1, Layers2)
	if Layers1.AdminAll or Layers2.AdminAll then return true end
	if Layers1.None or Layers2.None then return false end
	if Layers1.All or Layers2.All then return true end
	for ak,av in pairs(Layers1) do
		if av and Layers2[ak] then
			return true
		end
	end
  return false
end

--Returns the length of a vector
function GiveBack.VectorLength(a)
   return math.sqrt(a[1] ^ 2 + a[2] ^ 2 + a[3] ^ 2)
end

--Calculates the dot product of two vectors with the length of 3
function GiveBack.DotProduct(a, b)
  return a[1] * b[1] + a[2] * b[2] + a[3] * b[3]
end

--Multiplies the values of a vector with a number
function GiveBack.VectorScale(v, n)
  return {v[1] * n, v[2] * n, v[3] * n}
end

--Calculates the cross product of two vectors
function GiveBack.CrossProduct(u, v)
  return {u[2] * v[3] - u[3] * v[2],
          u[3] * v[1] - u[1] * v[3],
          u[1] * v[2] - u[2] * v[1]}
end

--Returns the normal of a vector
function GiveBack.Normalise(a)
	local Length = GiveBack.VectorLength(a)
	return {a[1]/Length, a[2]/Length, a[3]/Length}
end

--Adds two vector together
function GiveBack.VectorAddition(a, b)
  return {a[1] + b[1], a[2] + b[2], a[3] + b[3]}
end

--Subtracts vector b from vector a
function GiveBack.VectorSubtraction(a, b)
  return {a[1] - b[1], a[2] - b[2], a[3] - b[3]}
end

--Returns 1 for numbers more than 0, -1 for less than 0, and 0 for 0
function GiveBack.Sign(n)
  if 0 < n then
  	return 1
  elseif n < 0 then
		return -1
	else
		return 0
	end
end

--Uses GiveBack.Sign on every value of the vector, and returns it
function GiveBack.VectorSign(v)
	local Sign = GiveBack.Sign
  return {Sign(v[1]), Sign(v[2]), Sign(v[3])}
end

--Converts an euler rotation into a quaternion
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

--Multiplies two quaternions
function GiveBack.QuaternionMultiplication(a, b)
    return {
        a[1] * b[1] - a[2] * b[2] - a[3] * b[3] - a[4] * b[4],
        a[1] * b[2] + a[2] * b[1] + a[3] * b[4] - a[4] * b[3],
        a[1] * b[3] - a[2] * b[4] + a[3] * b[1] + a[4] * b[2],
        a[1] * b[4] + a[2] * b[3] - a[3] * b[2] + a[4] * b[1]
    }
end

--Fills Matrix with a rotation matrix calculated from a quaternion and a center,
--If it exist
function GiveBack.RotationMatrix(q, Center, Matrix)
  local sqw, sqx, sqy, sqz = q[1]*q[1], q[2]*q[2], q[3]*q[3], q[4]*q[4]
	local m = Matrix.data
  m[0] = sqx - sqy - sqz + sqw --// since sqw + sqx + sqy + sqz =1
  m[5], m[10] = -sqx + sqy - sqz + sqw, -sqx - sqy + sqz + sqw
  local tmp1, tmp2 = q[2]*q[3], q[4]*q[1]
  m[1], m[4] = 2 * (tmp1 + tmp2), 2 * (tmp1 - tmp2)
  tmp1, tmp2 = q[2]*q[4], q[3]*q[1]
  m[2], m[8] = 2 * (tmp1 - tmp2), 2 * (tmp1 + tmp2)
  tmp1, tmp2 = q[3]*q[4], q[2]*q[1]
  m[6], m[9] = 2 * (tmp1 + tmp2), 2 * (tmp1 - tmp2)
	local a = {0, 0, 0}
  if Center then
    a = Center
	end
	m[3] = a[1] - a[1] * m[0] - a[2] * m[1] - a[3] * m[2]
	m[7] = a[2] - a[1] * m[4] - a[2] * m[5] - a[3] * m[6]
	m[11] = a[3] - a[1] * m[8] - a[2] * m[9] - a[3] * m[10]
	m[12], m[13], m[14], m[15] = 0, 0, 0, 1
end

--Fills Matrix with a translation matrix
function GiveBack.TranslationMatrix(Translation, Matrix)
	Matrix.data[3], Matrix.data[7], Matrix.data[11] =
	Translation[1], Translation[2], Translation[3]
end

--Fills Matrix with a scale matrix
function GiveBack.ScaleMatrix(Scale, Matrix)
	Matrix.data[0], Matrix.data[5], Matrix.data[10] =
	Scale[1], Scale[2], Scale[3]
end

--Checks whether an object needs updating its matrices and if so, it does it
function GiveBack.ModelMatrix(Object, gsl)
	if Object.ScaleCalc then
		GiveBack.ScaleMatrix(Object.Scale, Object.ScaleMatrix)
	end
	if Object.RotationCalc then
		GiveBack.RotationMatrix(Object.Rotation, nil, Object.RotationMatrix)
	end
	if Object.TranslationCalc then
		GiveBack.TranslationMatrix(Object.Translation, Object.TranslationMatrix)
	end
	gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasNoTrans, 1,
	Object.ScaleMatrix, Object.RotationMatrix, 0, Object.BufferMatrix)
	gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasNoTrans, 1,
	Object.TranslationMatrix, Object.BufferMatrix, 0, Object.ModelMatrix)
end

--Finds the farthest vertex from translation, and declares it's distance as
--The radius of the bounding sphere
function GiveBack.CreateCollisionSphere(Object)
	local Radius = 0
	local VectorLength, VectorSubtraction = GiveBack.VectorLength,
	GiveBack.VectorSubtraction
	for ak=0,3 do
		local NewRadius =
		VectorLength(VectorSubtraction({Object.Transformated.data[ak * 4],
																		Object.Transformated.data[ak * 4 + 1],
																		Object.Transformated.data[ak * 4 + 2]},
																		Object.Translation))
		if Radius < NewRadius then
			Radius = NewRadius
		end
	end
	Object.Radius = Radius
end

--Multiplies the values of a quaternion with a number
function GiveBack.QuaternionScale(q, n)
  return {q[1] * n, q[2] * n, q[3] * n, q[4] * n}
end

--Calculates the normal of a quaternion
function GiveBack.QuaternionNormal(q)
	return q[1] ^ 2 + q[2] ^ 2 + q[3] ^ 2 + q[4] ^ 2
end

--Scales a quaternions versor by a number
function GiveBack.VersorScale(q, n)
	return {q[1], q[2] * n, q[3] * n, q[4] * n}
end

--Calculates the inverse of a quaternion
function GiveBack.QuaternionInverse(q)
	local VersorScale, QuaternionScale, QuaternionNormal = GiveBack.VersorScale,
	GiveBack.QuaternionScale, GiveBack.QuaternionNormal
	return QuaternionScale(VersorScale(q, -1), 1 / QuaternionNormal(q))
end

--Normalises a quaternion
function GiveBack.QuaternionNormalise(q)
	local magnitude =
	math.sqrt(GiveBack.QuaternionNormal(q))
	return {q[1] / magnitude, q[2] / magnitude, q[3] / magnitude, q[4] / magnitude}
end

--Calculates the quaternion between left and right, if value equals 0.5 then
--The quaternion will be in the middle
function GiveBack.Slerp(left, right, value)
	local SLERP_TO_LERP_SWITCH_THRESHOLD  = 0.01
	local leftWeight, rightWeight, difference
	local difference = left[1] * right[1] + left[2] * right[2] + left[3] * right[3] + left[4] * right[4]
	if 1 - math.abs(difference) > SLERP_TO_LERP_SWITCH_THRESHOLD then
		local theta, oneOverSinTheta = math.acos(math.abs(difference))
		oneOverSinTheta = 1 / math.sin(theta)
		leftWeight = math.sin(theta * (1 - value)) * oneOverSinTheta
		rightWeight = math.sin(theta * value) * oneOverSinTheta
		if difference < 0 then
			leftWeight = -leftWeight
		end
	else
		leftWeight = 1 - value
		rightWeight = value
	end
	local result = {
	left[1] * leftWeight + right[1] * rightWeight,
	left[2] * leftWeight + right[2] * rightWeight,
	left[2] * leftWeight + right[3] * rightWeight,
	left[2] * leftWeight + right[4] * rightWeight}
	return GiveBack.QuaternionNormalise(result)
end

--Updates and object's Matrices, then calculates radius of the
--Bounding sphere and from that it creates bunding box, if needed
function GiveBack.UpdateObject(Object, Arguments)
	local gsl = Arguments[1].Library.gsl
	GiveBack.ModelMatrix(Object, gsl)
	gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasTrans, 1, Object.Points,
	Object.ModelMatrix, 0, Object.Transformated)
	if Object.ScaleCalc then
		GiveBack.CreateCollisionSphere(Object)
	end
	if Object.TranslationCalc or Object.ScaleCalc then
		Object.Min = {Object.Translation[1] - Object.Radius,
									Object.Translation[2] - Object.Radius,
									Object.Translation[3] - Object.Radius}
		Object.Max = {Object.Translation[1] + Object.Radius,
									Object.Translation[2] + Object.Radius,
									Object.Translation[3] + Object.Radius}
	end
	Object.ScaleCalc, Object.RotationCalc, Object.TranslationCalc = false, false,
	false
end

--Creates a new c array, and copies all c arrays from first argument into it
function GiveBack.ConcatenateCArrays(CArrays, ArrayLength, Type, ffi)
	local copy = ffi.Library.copy
  local ArraySize = ffi.Library.sizeof(ffi.Library.typeof(Type))
  local SizeOfAll = ArrayLength * #CArrays
  local NewCArray = ffi.Library.new(Type .. "[?]", SizeOfAll)
  for i=1,#CArrays do
  	copy(NewCArray + (i - 1) * ArrayLength, CArrays[i], ArraySize * ArrayLength)
  end
  return NewCArray
end

--Checks whether two vectors are equal
function GiveBack.VectorEqual(a, b)
  return a[1] == b[1] and a[2] == b[2] and a[3] == b[3]
end

function GiveBack.UpdateVelocities(Object, Time)
	local VectorEqual, VectorAddition, VectorScale, QuaternionMultiplication,
	VersorScale = GiveBack.VectorEqual, GiveBack.VectorAddition,
	GiveBack.VectorScale, GiveBack.QuaternionMultiplication,
	GiveBack.VersorScale
	if not VectorEqual(Object.LinearVelocity, {0, 0, 0}) then
		Object.Translation =
		VectorAddition(Object.Translation, VectorScale(Object.LinearVelocity, Time))
		Object.TranslationCalc = true
	end
	if (not VectorEqual(Object.AngularVelocity, {1, 0, 0})) or Object.AngularVelocity[4] ~= 0 then
		Object.Rotation = QuaternionMultiplication(Object.Rotation, VersorScale(Object.AngularVelocity, Time))
		Object.RotationCalc = true
	end
end

function GiveBack.UpdateAccelerations(Object, Time)
	local VectorEqual, VectorAddition, VectorScale, QuaternionMultiplication,
	VersorScale = GiveBack.VectorEqual, GiveBack.VectorAddition,
	GiveBack.VectorScale, GiveBack.QuaternionMultiplication,
	GiveBack.VersorScale
	if not VectorEqual(Object.LinearAcceleration, {0, 0, 0}) then
		Object.LinearVelocity =
		VectorAddition(Object.LinearVelocity, Object.LinearAcceleration)
		Object.LinearAcceleration = {0, 0, 0}
	end
	if (not VectorEqual(Object.AngularAcceleration, {1, 0, 0})) or Object.AngularAcceleration[4] ~= 0 then
		Object.AngularVelocity = QuaternionMultiplication(Object.AngularVelocity, Object.AngularAcceleration)
		Object.AngularAcceleration = {1, 0, 0, 0}
	end
end

--Updates every object's rotation and translation from every device and calls
--UpdateObject if needed
function GiveBack.UpdateDevices(Devices, Time, Arguments)
	local UpdateObject, UpdateVelocities, UpdateAccelerations = GiveBack.UpdateObject,
	GiveBack.UpdateVelocities, GiveBack.UpdateAccelerations
	for ak=1,#Devices do
		local av = Devices[ak]
		for bk=1,#av.Objects do
			local bv = av.Objects[bk]
			if not bv.Fixed then
				UpdateAccelerations(bv, Time)
				UpdateVelocities(bv, Time)
				if bv.TranslationCalc or bv.RotationCalc or bv.ScaleCalc then
					UpdateObject(bv, Arguments)
				end
			end
		end
	end
end
GiveBack.Requirements = {"lgsl", "ffi"}
return GiveBack
