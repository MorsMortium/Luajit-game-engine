return function(args)
	local Globals, CTypes = args[1], args[2]
	local Globals, CTypes = Globals.Library.Globals, CTypes.Library.Types
	local abs, acos, sin, cos, type, sqrt, double = Globals.abs, Globals.acos,
	Globals.sin, Globals.cos, Globals.type, Globals.sqrt, CTypes["double[?]"].Type

	local GiveBack = {}

	GiveBack.BuffVect, GiveBack.BuffQuat = double(3), double(4)

	--Vector, Matrix, Quaternion and general Math functions

	--Checks if a variable is a Vector containing 3 numbers
	function GiveBack.IsVector3(Table)
		return type(Table) == "table" and #Table == 3 and type(Table[1]) == "number"
		and type(Table[2]) == "number" and type(Table[3]) == "number"
	end

	--Checks if a variable is a Vector containing 4 numbers
	function GiveBack.IsVector4(Table)
		return type(Table) == "table" and #Table == 4 and type(Table[1]) == "number"
		and type(Table[2]) == "number" and type(Table[3]) == "number" and
  	type(Table[4]) == "number"
	end

	--Checks if a variable is a matrix containing 4 Vectors which each contains 4 numbers
	function GiveBack.IsMatrix4(Table)
		return type(Table) == "table" and GiveBack.IsVector4(Table[1]) and
		GiveBack.IsVector4(Table[2]) and GiveBack.IsVector4(Table[3]) and
		GiveBack.IsVector4(Table[4])
	end


	--Copies Vector a to Vector b
	function GiveBack.VectorCopy(a, b)
		b[0], b[1], b[2] = a[0], a[1], a[2]
	end

	--Returns the length of a Vector
	function GiveBack.VectorLength(a)
		return sqrt(a[0] ^ 2 + a[1] ^ 2 + a[2] ^ 2)
	end

	--Calculates the dot product of two Vectors with the length of 3
	function GiveBack.VectorDot(a, b)
		return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]
	end

	--Calculates the cross product of two Vectors
	function GiveBack.VectorCross(a, b, c)
		c[0], c[1], c[2] =
		a[1] * b[2] - a[2] * b[1],
		a[2] * b[0] - a[0] * b[2],
		a[0] * b[1] - a[1] * b[0]
	end

	--Multiplies the values of a Vector with a number
	function GiveBack.VectorScale(a, b, c)
		c[0], c[1], c[2] = a[0] * b, a[1] * b, a[2] * b
	end

	--Returns the normal of a Vector
	function GiveBack.Normalise(a, b)
		local Length = GiveBack.VectorLength(a)
		b[0], b[1], b[2] = a[0] / Length, a[1] / Length, a[2] / Length
	end

	--Subtracts Vector b from Vector a
	function GiveBack.VectorSub(a, b, c)
		c[0], c[1], c[2] = a[0] - b[0], a[1] - b[1], a[2] - b[2]
	end

	--Adds two Vector together
	function GiveBack.VectorAdd(a, b, c)
		c[0], c[1], c[2] = a[0] + b[0], a[1] + b[1], a[2] + b[2]
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

	--Uses GiveBack.Sign on every value of a, and fill b with it
	function GiveBack.VectorSign(a, b)
		b[0], b[1], b[2] = GiveBack.Sign(a[0]), GiveBack.Sign(a[1]), GiveBack.Sign(a[2])
	end

	--Checks whether two Vectors are equal
	function GiveBack.VectorEqual(a, b)
		return a[0] == b[0] and a[1] == b[1] and a[2] == b[2]
	end

	--Checks whether a Vectors is zero
	function GiveBack.VectorZero(a)
		return a[0] == 0 and a[1] == 0 and a[2] == 0
	end

	--Converts an Euler rotation into a Quaternion
	function GiveBack.EulerToQuaternion(a, b)
		local cy, sy, cp, sp, cr, sr = cos(a[3] / 2), sin(a[3] / 2),
		cos(a[2] / 2), sin(a[2] / 2), cos(a[1] / 2), sin(a[1] / 2)
		b[0], b[1], b[2], b[3] =
		cy * cp * cr + sy * sp * sr,
		cy * cp * sr - sy * sp * cr,
		sy * cp * sr + cy * sp * cr,
		sy * cp * cr - cy * sp * sr
	end

	--Multiplies two quaternions
	function GiveBack.QuaternionMultiplication(a, b, c)
		local a1, a2, a3, a4, b1, b2, b3, b4 = a[0], a[1], a[2], a[3], b[0], b[1], b[2], b[3]
		c[0] = a1 * b1 - a2 * b2 - a3 * b3 - a4 * b4
		c[1] = a1 * b2 + a2 * b1 + a3 * b4 - a4 * b3
		c[2] = a1 * b3 - a2 * b4 + a3 * b1 + a4 * b2
		c[3] = a1 * b4 + a2 * b3 - a3 * b2 + a4 * b1
	end

	--Multiplies the values of a quaternion with a number
	function GiveBack.QuaternionScale(a, b, c)
		c[0], c[1], c[2], c[3] = a[0] * b, a[1] * b, a[2] * b, a[3] * b
	end

	--Calculates the normal of a quaternion
	function GiveBack.QuaternionNormal(q)
		return q[0] ^ 2 + q[1] ^ 2 + q[2] ^ 2 + q[3] ^ 2
	end

	--Scales a quaternions versor by a number
	function GiveBack.VersorScale(a, b, c)
		c[0], c[1], c[2], c[3] = a[0], a[1] * b, a[2] * b, a[3] * b
	end

	--Calculates the inverse of a quaternion
	function GiveBack.QuaternionInverse(a, b)
		GiveBack.VersorScale(a, -1, b)
		GiveBack.QuaternionScale(b, 1 / GiveBack.QuaternionNormal(b), b)
	end

	--Normalises a quaternion
	function GiveBack.QuaternionNormalise(a, b)
		local Length = sqrt(GiveBack.QuaternionNormal(a))
		b[0], b[1], b[2], b[3] =
		a[0] / Length, a[1] / Length, a[2] / Length, a[3] / Length
	end

	--Calculates the quaternion between left and right, if value equals 0.5 then
	--The quaternion will be in the middle
	function GiveBack.Slerp(left, right, value, Result)
		local SLERP_TO_LERP_SWITCH_THRESHOLD  = 0.01
		local leftWeight, rightWeight, difference
		local difference = left[0] * right[0] + left[1] * right[1] + left[2] * right[2] + left[3] * right[3]
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
		Result[0], Result[1], Result[2], Result[3] =
		left[0] * leftWeight + right[0] * rightWeight,
		left[1] * leftWeight + right[1] * rightWeight,
		left[1] * leftWeight + right[2] * rightWeight,
		left[1] * leftWeight + right[3] * rightWeight
		GiveBack.QuaternionNormalise(Result, Result)
	end

	--Checks whether a quaternion rotation is zero
	function GiveBack.QuaternionZeroRotation(a)
		return a[0] == 1 and a[1] == 0 and a[2] == 0 and a[3] == 0
	end

	--Multiplies two 4x4 matrices
	function GiveBack.MatrixMul(a, b, m)
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
