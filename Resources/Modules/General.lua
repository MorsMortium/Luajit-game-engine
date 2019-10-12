return function(args)
	local ffi, CTypes, Globals, Math = args[1], args[2], args[3], args[4]
	local CTypes, ffi, Globals, Math = CTypes.Library.Types, ffi.Library,
	Globals.Library.Globals, Math.Library
	local type, min, max, VectorZero, VectorAdd, VectorScale,
	QuaternionZeroRotation, QuaternionMultiplication, VersorScale,
	MatrixMul, MatrixTranspose, double = Globals.type, Globals.min,
	Globals.max, Math.VectorZero, Math.VectorAdd, Math.VectorScale,
	Math.QuaternionZeroRotation, Math.QuaternionMultiplication, Math.VersorScale,
	Math.MatrixMul, Math.MatrixTranspose, CTypes["double[?]"].Type

	local GiveBack = {}

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

	--TODO:Optimize for loop, for only checking the shorter array
	--Checks whether two physics or visual layers are overlapping

	function GiveBack.SameLayer(Layers1, Layers2)
		if Layers1.AdminAll or Layers2.AdminAll then return true end
		if Layers1.None or Layers2.None then return false end
		if Layers1.All or Layers2.All then return true end
		for ak=1,#Layers1 do
			if Layers2[Layers1[ak]] then return true end
		end
  	return false
	end

	--Creates a new C array, and copies all C arrays from first argument into it
	function GiveBack.ConcatCArrays(CArrays, ArrayLength, Type)
		local ElementSize = CTypes[Type].Size
		local LengthOfAll = ArrayLength * #CArrays
		local NewCArray = CTypes[Type].Type(LengthOfAll)
		local BlockSize = ElementSize * ArrayLength
		for i=0,#CArrays - 1 do
			ffi.copy(NewCArray + i * ArrayLength, CArrays[i + 1], BlockSize)
		end
		return NewCArray
	end

	--Fills Matrix with a rotation matrix calculated from a quaternion
	function GiveBack.RotationMatrix(q, Matrix)
  	local sqw, sqx, sqy, sqz = q[0]*q[0], q[1]*q[1], q[2]*q[2], q[3]*q[3]
		local m = Matrix
  	m[0] = sqx - sqy - sqz + sqw --// since sqw + sqx + sqy + sqz =1
  	m[5], m[10] = -sqx + sqy - sqz + sqw, -sqx - sqy + sqz + sqw
  	local tmp1, tmp2 = q[1]*q[2], q[3]*q[0]
  	m[1], m[4] = 2 * (tmp1 + tmp2), 2 * (tmp1 - tmp2)
  	tmp1, tmp2 = q[1]*q[3], q[2]*q[0]
  	m[2], m[8] = 2 * (tmp1 - tmp2), 2 * (tmp1 + tmp2)
  	tmp1, tmp2 = q[2]*q[3], q[1]*q[0]
  	m[6], m[9] = 2 * (tmp1 + tmp2), 2 * (tmp1 - tmp2)
	end

	--Fills Matrix with a translation matrix
	function GiveBack.TranslationMatrix(Translation, Matrix)
		Matrix[3], Matrix[7], Matrix[11] = Translation[0], Translation[1], Translation[2]
	end

	--Fills Matrix with a scale matrix
	function GiveBack.ScaleMatrix(Scale, Matrix)
		Matrix[0], Matrix[5], Matrix[10] = Scale[0], Scale[1], Scale[2]
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
			MatrixMul(Object.ScaleMatrix, Object.RotationMatrix, Object.BufferMatrix)
			MatrixMul(Object.TranslationMatrix, Object.BufferMatrix, Object.ModelMatrix)
			MatrixTranspose(Object.ModelMatrix)
			MatrixMul(Object.Points, Object.ModelMatrix, Object.Transformated)
		end
	end

	--Creates bounding box
	function GiveBack.BoundingBox(Object)
		if Object.TranslationCalc or Object.ScaleCalc or Object.RotationCalc then
			local Transformated = Object.Transformated
			Object.Min[1] = min(Transformated[0], Transformated[4], Transformated[8], Transformated[12])
			Object.Max[1] = max(Transformated[0], Transformated[4], Transformated[8], Transformated[12])
			Object.Min[2] = min(Transformated[1], Transformated[5], Transformated[9], Transformated[13])
			Object.Max[2] = max(Transformated[1], Transformated[5], Transformated[9], Transformated[13])
			Object.Min[3] = min(Transformated[2], Transformated[6], Transformated[10], Transformated[14])
			Object.Max[3] = max(Transformated[2], Transformated[6], Transformated[10], Transformated[14])
		end
	end

	function GiveBack.UpdateObject(Object)
		GiveBack.ModelMatrix(Object)
		GiveBack.Transformate(Object)
		GiveBack.BoundingBox(Object)
		Object.ScaleCalc, Object.RotationCalc, Object.TranslationCalc = false, false,
		false
	end

	local PlusLinVel, PlusAngVel = double(3), double(4)

	function GiveBack.UpdateVelocities(Object, Time)
		if not VectorZero(Object.LinearVelocity) then
			VectorScale(Object.LinearVelocity, Time, PlusLinVel)
			VectorAdd(Object.Translation, PlusLinVel, Object.Translation)
			Object.TranslationCalc = true
		end
		if not QuaternionZeroRotation(Object.AngularVelocity) then
			VersorScale(Object.AngularVelocity, Time, PlusAngVel)
			QuaternionMultiplication(Object.Rotation, PlusAngVel, Object.Rotation)
			Object.RotationCalc = true
		end
	end

	function GiveBack.UpdateAccelerations(Object, Time)
		if not VectorZero(Object.LinearAcceleration) then
			VectorAdd(Object.LinearVelocity, Object.LinearAcceleration, Object.LinearVelocity)
			Object.LinearAcceleration[0],
			Object.LinearAcceleration[1],
			Object.LinearAcceleration[2] = 0, 0, 0
		end
		if not QuaternionZeroRotation(Object.AngularAcceleration) then
			QuaternionMultiplication(Object.AngularVelocity, Object.AngularAcceleration, Object.AngularVelocity)
			Object.AngularAcceleration[0],
			Object.AngularAcceleration[1],
			Object.AngularAcceleration[2],
			Object.AngularAcceleration[3] = 1, 0, 0, 0
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
