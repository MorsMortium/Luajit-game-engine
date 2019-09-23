return function(args)
	local Globals = args[1]
	local Globals = Globals.Library.Globals
	local abs, acos, sin, cos, type, sqrt = Globals.abs, Globals.acos,
	Globals.sin, Globals.cos, Globals.type, Globals.sqrt

	local GiveBack = {}

	function GiveBack.Reload(args)
		Globals = args[1]
		Globals = Globals.Library.Globals
		abs, acos, sin, cos, type, sqrt = Globals.abs, Globals.acos,
		Globals.sin, Globals.cos, Globals.type, Globals.sqrt
  end
	--Vector, Matrix, Quaternion and general math functions

	--Checks if a variable is a vector containing 3 numbers
	function GiveBack.IsVector3(Table)
		return type(Table) == "table" and #Table == 3 and type(Table[1]) == "number"
		and type(Table[2]) == "number" and type(Table[3]) == "number"
	end

	--Checks if a variable is a vector containing 4 numbers
	function GiveBack.IsVector4(Table)
		return type(Table) == "table" and #Table == 4 and type(Table[1]) == "number"
		and type(Table[2]) == "number" and type(Table[3]) == "number" and
  	type(Table[4]) == "number"
	end

	--Checks if a variable is a matrix containing 4 vectors which each contains 4 numbers
	function GiveBack.IsMatrix4(Table)
		return type(Table) == "table" and GiveBack.IsVector4(Table[1]) and
		GiveBack.IsVector4(Table[2]) and GiveBack.IsVector4(Table[3]) and
		GiveBack.IsVector4(Table[4])
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
		return
		{cy * cp * cr + sy * sp * sr,
		cy * cp * sr - sy * sp * cr,
		sy * cp * sr + cy * sp * cr,
		sy * cp * cr - cy * sp * sr}
	end

	--Multiplies two quaternions
	function GiveBack.QuaternionMultiplication(a, b)
    return
    {a[1] * b[1] - a[2] * b[2] - a[3] * b[3] - a[4] * b[4],
    a[1] * b[2] + a[2] * b[1] + a[3] * b[4] - a[4] * b[3],
    a[1] * b[3] - a[2] * b[4] + a[3] * b[1] + a[4] * b[2],
    a[1] * b[4] + a[2] * b[3] - a[3] * b[2] + a[4] * b[1]}
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
		sqrt(GiveBack.QuaternionNormal(q))
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
		local result =
		{left[1] * leftWeight + right[1] * rightWeight,
		left[2] * leftWeight + right[2] * rightWeight,
		left[2] * leftWeight + right[3] * rightWeight,
		left[2] * leftWeight + right[4] * rightWeight}
		return GiveBack.QuaternionNormalise(result)
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

	--Multiplies two 4x4 matrices
	function GiveBack.MatrixMultiplication4x4(a, b, m)
		m[0], m[1], m[2], m[3],
		m[4], m[5], m[6], m[7],
		m[8], m[9], m[10], m[11],
		m[12], m[13], m[14], m[15] =
  	a[0] * b[0] + a[1] * b[4] + a[2] * b[8] + a[3] * b[12],
  	a[0] * b[1] + a[1] * b[5] + a[2] * b[9] + a[3] * b[13],
  	a[0] * b[2] + a[1] * b[6] + a[2] * b[10] + a[3] * b[14],
  	a[0] * b[3] + a[1] * b[7] + a[2] * b[11] + a[3] * b[15],
  	a[4] * b[0] + a[5] * b[4] + a[6] * b[8] + a[7] * b[12],
  	a[4] * b[1] + a[5] * b[5] + a[6] * b[9] + a[7] * b[13],
  	a[4] * b[2] + a[5] * b[6] + a[6] * b[10] + a[7] * b[14],
  	a[4] * b[3] + a[5] * b[7] + a[6] * b[11] + a[7] * b[15],
  	a[8] * b[0] + a[9] * b[4] + a[10] * b[8] + a[11] * b[12],
  	a[8] * b[1] + a[9] * b[5] + a[10] * b[9] + a[11] * b[13],
  	a[8] * b[2] + a[9] * b[6] + a[10] * b[10] + a[11] * b[14],
  	a[8] * b[3] + a[9] * b[7] + a[10] * b[11] + a[11] * b[15],
  	a[12] * b[0] + a[13] * b[4] + a[14] * b[8] + a[15] * b[12],
  	a[12] * b[1] + a[13] * b[5] + a[14] * b[9] + a[15] * b[13],
  	a[12] * b[2] + a[13] * b[6] + a[14] * b[10] + a[15] * b[14],
  	a[12] * b[3] + a[13] * b[7] + a[14] * b[11] + a[15] * b[15]
	end

	--Sets a 4x4 matrix to zero
	function GiveBack.SetZero(m)
		m[0], m[1], m[2], m[3],
		m[4], m[5], m[6], m[7],
		m[8], m[9], m[10], m[11],
		m[12], m[13], m[14], m[15] =
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0
	end

	--Sets a 4x4 matrix to identity
	function GiveBack.SetIdentity(m)
		m[0], m[1], m[2], m[3],
		m[4], m[5], m[6], m[7],
		m[8], m[9], m[10], m[11],
		m[12], m[13], m[14], m[15] =
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
	end

	--Sets a 4x4 matrix to identity
	function GiveBack.MatrixCopy(m, n)
		m[0], m[1], m[2], m[3],
		m[4], m[5], m[6], m[7],
		m[8], m[9], m[10], m[11],
		m[12], m[13], m[14], m[15] =
		n[0], n[1], n[2], n[3],
		n[4], n[5], n[6], n[7],
		n[8], n[9], n[10], n[11],
		n[12], n[13], n[14], n[15]
	end

	--Transposes a 4x4 matrix
	function GiveBack.MatrixTranspose(m)
		local a = {m[0], m[1], m[2], m[3],
		m[4], m[5], m[6], m[7],
		m[8], m[9], m[10], m[11],
		m[12], m[13], m[14], m[15]}

		m[0], m[1], m[2], m[3],
		m[4], m[5], m[6], m[7],
		m[8], m[9], m[10], m[11],
		m[12], m[13], m[14], m[15] =
		a[1], a[5], a[9], a[13],
		a[2], a[6], a[10], a[14],
		a[3], a[7], a[11], a[15],
		a[4], a[8], a[12], a[16]
	end
	return GiveBack
end
