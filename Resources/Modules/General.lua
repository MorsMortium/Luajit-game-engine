local GiveBack = {}
--General functions used in various places
--Mostly vector functions
--TODO: Move vector stuff into different file, and use gsl where possible or
--Where it's faster
local abs, acos, sin, cos, type, sqrt, min, max =
math.abs, math.acos, math.sin, math.cos, type, math.sqrt, math.min, math.max

--Checks if a variable is a table, and all of it's values are of one type
function GiveBack.GoodTypesOfTable(Table, GoodType)
	if type(Table) == "table" then
    for ak=1,#Table do
      if type(Table[ak]) ~= GoodType then
        return false
      end
    end
		return true
	end
	return false
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
	if type(Table) == "table" and GiveBack.IsVector4(Table[1]) and GiveBack.IsVector4(Table[2]) and
	GiveBack.IsVector4(Table[3]) and GiveBack.IsVector4(Table[4]) then
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
			if DataTable[KeyTable[ak]] ~= nil then
				ReturnTable[#ReturnTable + 1] = DataTable[KeyTable[ak]]
			end
		end
	end
	return ReturnTable
end

--Checks wether two physics or visual layers are overlapping
function GiveBack.SameLayer(Layers1, LayerKeys1, Layers2, LayerKeys2)
	if Layers1.AdminAll or Layers2.AdminAll then return true end
	if Layers1.None or Layers2.None then return false end
	if Layers1.All or Layers2.All then return true end
	for ak=1,#LayerKeys1 do
		if Layers2[LayerKeys1[ak]] then
			return true
		end
	end
  return false
end

--Returns the length of a vector
function GiveBack.VectorLength(a)
   return sqrt(a[1] ^ 2 + a[2] ^ 2 + a[3] ^ 2)
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
	return {a[1] / Length, a[2] / Length, a[3] / Length}
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
  return {GiveBack.Sign(v[1]), GiveBack.Sign(v[2]), GiveBack.Sign(v[3])}
end

--Converts an euler rotation into a quaternion
function GiveBack.EulerToQuaternion(Euler)
	local cy, sy, cp, sp, cr, sr = cos(Euler[3] / 2), sin(Euler[3] / 2),
	cos(Euler[2] / 2), sin(Euler[2] / 2), cos(Euler[1] / 2), sin(Euler[1] / 2)
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
	return GiveBack.QuaternionScale(GiveBack.VersorScale(q, -1), 1 / GiveBack.QuaternionNormal(q))
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
	if 1 - abs(difference) > SLERP_TO_LERP_SWITCH_THRESHOLD then
		local theta, oneOverSinTheta = acos(abs(difference))
		oneOverSinTheta = 1 / sin(theta)
		leftWeight = sin(theta * (1 - value)) * oneOverSinTheta
		rightWeight = sin(theta * value) * oneOverSinTheta
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

--Fills Matrix with a rotation matrix calculated from a quaternion and a center,
--If it exist
function GiveBack.RotationMatrix(q, Matrix)
  local sqw, sqx, sqy, sqz = q[1]*q[1], q[2]*q[2], q[3]*q[3], q[4]*q[4]
	local m = Matrix
  m[0] = sqx - sqy - sqz + sqw --// since sqw + sqx + sqy + sqz =1
  m[5], m[10] = -sqx + sqy - sqz + sqw, -sqx - sqy + sqz + sqw
  local tmp1, tmp2 = q[2]*q[3], q[4]*q[1]
  m[1], m[4] = 2 * (tmp1 + tmp2), 2 * (tmp1 - tmp2)
  tmp1, tmp2 = q[2]*q[4], q[3]*q[1]
  m[2], m[8] = 2 * (tmp1 - tmp2), 2 * (tmp1 + tmp2)
  tmp1, tmp2 = q[3]*q[4], q[2]*q[1]
  m[6], m[9] = 2 * (tmp1 + tmp2), 2 * (tmp1 - tmp2)
	m[15] = 1
end

--Fills Matrix with a translation matrix
function GiveBack.TranslationMatrix(Translation, Matrix)
	Matrix[3], Matrix[7], Matrix[11] = Translation[1], Translation[2], Translation[3]
end

--Fills Matrix with a scale matrix
function GiveBack.ScaleMatrix(Scale, Matrix)
	Matrix[0], Matrix[5], Matrix[10] = Scale[1], Scale[2], Scale[3]
end

--Checks whether an object needs updating its matrices and if so, it does it
function GiveBack.ModelMatrix(Object)
	if Object.ScaleCalc then
		GiveBack.ScaleMatrix(Object.Scale, Object.ScaleMatrix.data)
	end
	if Object.RotationCalc then
		GiveBack.RotationMatrix(Object.Rotation, Object.RotationMatrix.data)
	end
	if Object.TranslationCalc then
		GiveBack.TranslationMatrix(Object.Translation, Object.TranslationMatrix.data)
	end
end

--Multiplies an object's matrices into a modelmatrix then transformated points
function GiveBack.Transformate(Object, gsl)
	if Object.TranslationCalc or Object.ScaleCalc or Object.RotationCalc then
		gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasNoTrans, 1,
		Object.ScaleMatrix, Object.RotationMatrix, 0, Object.BufferMatrix)
		gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasNoTrans, 1,
		Object.TranslationMatrix, Object.BufferMatrix, 0, Object.ModelMatrix)
		gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasTrans, 1, Object.Points,
		Object.ModelMatrix, 0, Object.Transformated)
	end
end

--Creates bounding box
function GiveBack.BoundingBox(Object)
	if Object.TranslationCalc or Object.ScaleCalc or Object.RotationCalc then
		for ak=0,2 do
			Object.Min[ak + 1] = min(Object.Transformated.data[ak], Object.Transformated.data[4 + ak], Object.Transformated.data[8 + ak], Object.Transformated.data[12 + ak])
			Object.Max[ak + 1] = max(Object.Transformated.data[ak], Object.Transformated.data[4 + ak], Object.Transformated.data[8 + ak], Object.Transformated.data[12 + ak])
		end
	end
end

function GiveBack.UpdateObject(Object, Arguments)
	local gsl = Arguments[1].Library.gsl
	GiveBack.ModelMatrix(Object)
	GiveBack.Transformate(Object, gsl)
	GiveBack.BoundingBox(Object)
	Object.ScaleCalc, Object.RotationCalc, Object.TranslationCalc = false, false,
	false
end
--Creates a new c array, and copies all c arrays from first argument into it
function GiveBack.ConcatenateCArrays(CArrays, ArrayLength, Type, ffi)
  local ArraySize = ffi.Library.sizeof(Type)
  local SizeOfAll = ArrayLength * #CArrays
  local NewCArray = ffi.Library.new(Type .. "[?]", SizeOfAll)
	local blocksize = ArraySize * ArrayLength
  for i=1,#CArrays do
  	ffi.Library.copy(NewCArray + (i - 1) * ArrayLength, CArrays[i], blocksize)
  end
  return NewCArray
end

--Checks whether two vectors are equal
function GiveBack.VectorEqual(a, b)
  return a[1] == b[1] and a[2] == b[2] and a[3] == b[3]
end

--Checks whether a vectors is zero
function GiveBack.VectorZero(a)
  return a[1] == 0 and a[2] == 0 and a[3] == 0
end

--Checks whether a quaternion rotation is zero
function GiveBack.QuaternionZeroRotation(a)
  return a[1] == 1 and a[2] == 0 and a[3] == 0 and a[4] == 0
end

--Adds two vector together
function GiveBack.VectorAdd(a, b)
  a[1], a[2], a[3] = a[1] + b[1], a[2] + b[2], a[3] + b[3]
end

--Multiplies two quaternions
function GiveBack.QuaternionMult(a, b)
	local a1, a2, a3, a4, b1, b2, b3, b4 = a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4]
	a[1] = a1 * b1 - a2 * b2 - a3 * b3 - a4 * b4
	a[2] = a1 * b2 + a2 * b1 + a3 * b4 - a4 * b3
	a[3] = a1 * b3 - a2 * b4 + a3 * b1 + a4 * b2
	a[4] = a1 * b4 + a2 * b3 - a3 * b2 + a4 * b1
end

function GiveBack.UpdateVelocities(Object, Time)
	if not GiveBack.VectorZero(Object.LinearVelocity) then
		GiveBack.VectorAdd(Object.Translation, GiveBack.VectorScale(Object.LinearVelocity, Time))
		Object.TranslationCalc = true
	end
	if not GiveBack.QuaternionZeroRotation(Object.AngularVelocity) then
		GiveBack.QuaternionMult(Object.Rotation, GiveBack.VersorScale(Object.AngularVelocity, Time))
		Object.RotationCalc = true
	end
end

function GiveBack.UpdateAccelerations(Object, Time)
	if not GiveBack.VectorZero(Object.LinearAcceleration) then
		GiveBack.VectorAdd(Object.LinearVelocity, Object.LinearAcceleration)
		Object.LinearAcceleration[1],
		Object.LinearAcceleration[2],
		Object.LinearAcceleration[3] = 0, 0, 0
	end
	if not GiveBack.QuaternionZeroRotation(Object.AngularAcceleration) then
		GiveBack.QuaternionMult(Object.AngularVelocity, Object.AngularAcceleration)
		Object.AngularAcceleration[1],
		Object.AngularAcceleration[2],
		Object.AngularAcceleration[3],
		Object.AngularAcceleration[4] = 1, 0, 0, 0
	end
end

--Updates every object's rotation and translation from every device if needed
function GiveBack.UpdateObjects(Objects, Time, Arguments)
	for ak=1,#Objects do
		local av = Objects[ak]
		if not av.Fixed then
			GiveBack.UpdateAccelerations(av, Time)
			GiveBack.UpdateVelocities(av, Time)
			if av.TranslationCalc or av.RotationCalc or av.ScaleCalc then
				GiveBack.UpdateObject(av, Arguments)
			end
		end
	end
end
GiveBack.Requirements = {"lgsl", "ffi"}
return GiveBack
