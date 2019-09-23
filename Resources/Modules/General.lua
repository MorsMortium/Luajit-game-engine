return function(args)
	local ffi, CTypes, Globals, Math = args[1], args[2], args[3], args[4]
	local Types, ffi, Globals = CTypes.Library.Types, ffi.Library,
	Globals.Library.Globals
	local sin, type, min, max, VectorZero, VectorAdd, VectorScale,
	QuaternionZeroRotation, QuaternionMult, VersorScale, MatrixMultiplication4x4,
	MatrixTranspose = Globals.sin, Globals.type, Globals.min, Globals.max,
	Math.Library.VectorZero, Math.Library.VectorAdd, Math.Library.VectorScale,
	Math.Library.QuaternionZeroRotation, Math.Library.QuaternionMult,
	Math.Library.VersorScale, Math.Library.MatrixMultiplication4x4,
	Math.Library.MatrixTranspose

	local GiveBack = {}

	function GiveBack.Reload(args)
		ffi, CTypes, Globals, Math = args[1], args[2], args[3], args[4]
		Types, ffi, Globals = CTypes.Library.Types, ffi.Library,
		Globals.Library.Globals
		sin, type, min, max, VectorZero, VectorAdd, VectorScale,
		QuaternionZeroRotation, QuaternionMult, VersorScale, MatrixMultiplication4x4,
		MatrixTranspose = Globals.sin, Globals.type, Globals.min, Globals.max,
		Math.Library.VectorZero, Math.Library.VectorAdd, Math.Library.VectorScale,
		Math.Library.QuaternionZeroRotation, Math.Library.QuaternionMult,
		Math.Library.VersorScale, Math.Library.MatrixMultiplication4x4,
		Math.Library.MatrixTranspose
  end
	--General functions used in various places

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

	--Looks up values from a hashtable, and returns them in an array in the order of
	--The keytable. Nil values are discarded
	function GiveBack.DataFromKeys(DataTable, KeyTable)
		local ReturnTable = {}
		if type(DataTable) == "table" and type(KeyTable) == "table" then
    	for ak=1,#KeyTable do
				local av = DataTable[KeyTable[ak]]
				if av ~= nil then
					ReturnTable[#ReturnTable + 1] = av
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

	--Creates a new C array, and copies all C arrays from first argument into it
	function GiveBack.ConcatenateCArrays(CArrays, ArrayLength, Type)
		local ElementSize = Types[Type].Size
		local LengthOfAll = ArrayLength * #CArrays
		local NewCArray = Types[Type].Type(LengthOfAll)
		local BlockSize = ElementSize * ArrayLength
		for i=0,#CArrays - 1 do
			ffi.copy(NewCArray + i * ArrayLength, CArrays[i + 1], BlockSize)
		end
		return NewCArray
	end

	--Fills Matrix with a rotation matrix calculated from a quaternion
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
			GiveBack.ScaleMatrix(Object.Scale, Object.ScaleMatrix)
		end
		if Object.RotationCalc then
			GiveBack.RotationMatrix(Object.Rotation, Object.RotationMatrix)
		end
		if Object.TranslationCalc then
			GiveBack.TranslationMatrix(Object.Translation, Object.TranslationMatrix)
		end
	end

	--Multiplies an object's matrices into a modelmatrix then transformated points
	function GiveBack.Transformate(Object)
		if Object.TranslationCalc or Object.ScaleCalc or Object.RotationCalc then
			MatrixMultiplication4x4(Object.ScaleMatrix, Object.RotationMatrix, Object.BufferMatrix)
			MatrixMultiplication4x4(Object.TranslationMatrix, Object.BufferMatrix, Object.ModelMatrix)
			MatrixTranspose(Object.ModelMatrix)
			MatrixMultiplication4x4(Object.Points, Object.ModelMatrix, Object.Transformated)
		end
	end

	--Creates bounding box
	function GiveBack.BoundingBox(Object)
		if Object.TranslationCalc or Object.ScaleCalc or Object.RotationCalc then
			for ak=0,2 do
				Object.Min[ak + 1] = min(Object.Transformated[ak], Object.Transformated[4 + ak], Object.Transformated[8 + ak], Object.Transformated[12 + ak])
				Object.Max[ak + 1] = max(Object.Transformated[ak], Object.Transformated[4 + ak], Object.Transformated[8 + ak], Object.Transformated[12 + ak])
			end
		end
	end

	function GiveBack.UpdateObject(Object)
		GiveBack.ModelMatrix(Object)
		GiveBack.Transformate(Object)
		GiveBack.BoundingBox(Object)
		Object.ScaleCalc, Object.RotationCalc, Object.TranslationCalc = false, false,
		false
	end

	function GiveBack.UpdateVelocities(Object, Time)
		if not VectorZero(Object.LinearVelocity) then
			VectorAdd(Object.Translation, VectorScale(Object.LinearVelocity, Time))
			Object.TranslationCalc = true
		end
		if not QuaternionZeroRotation(Object.AngularVelocity) then
			QuaternionMult(Object.Rotation, VersorScale(Object.AngularVelocity, Time))
			Object.RotationCalc = true
		end
	end

	function GiveBack.UpdateAccelerations(Object, Time)
		if not VectorZero(Object.LinearAcceleration) then
			VectorAdd(Object.LinearVelocity, Object.LinearAcceleration)
			Object.LinearAcceleration[1],
			Object.LinearAcceleration[2],
			Object.LinearAcceleration[3] = 0, 0, 0
		end
		if not QuaternionZeroRotation(Object.AngularAcceleration) then
			QuaternionMult(Object.AngularVelocity, Object.AngularAcceleration)
			Object.AngularAcceleration[1],
			Object.AngularAcceleration[2],
			Object.AngularAcceleration[3],
			Object.AngularAcceleration[4] = 1, 0, 0, 0
		end
	end

	--Updates every object's rotation and translation from every device if needed
	function GiveBack.UpdateObjects(Objects, Time)
		for ak=1,#Objects do
			local av = Objects[ak]
			if not av.Fixed then
				GiveBack.UpdateAccelerations(av, Time)
				GiveBack.UpdateVelocities(av, Time)
				if av.TranslationCalc or av.RotationCalc or av.ScaleCalc then
					GiveBack.UpdateObject(av)
				end
			end
		end
	end
	return GiveBack
end
