return function(args)
	local General, ffi, ObjectRender, Globals, Math, CTypes = args[1], args[2], args[3],
	args[4], args[5], args[6]
	local Globals, Math = Globals.Library.Globals, Math.Library
	local IsVector3, EulerToQuaternion, GoodTypesOfTable, UpdateObject, IsMatrix4,
	ObjectRenders, huge, type, SetIdentity, SetZero, copy, double, doublesize =
	Math.IsVector3, Math.EulerToQuaternion, General.Library.GoodTypesOfTable,
	General.Library.UpdateObject, Math.IsMatrix4,
	ObjectRender.Library.ObjectRenders, Globals.huge, Globals.type,
	Math.SetIdentity, Math.SetZero, ffi.Library.copy,
	CTypes.Library.Types["double[?]"].Type, CTypes.Library.Types["double[?]"].Size

	local GiveBack = {}

	--Creates and returns one Object. Objects are parts of a Device
	function GiveBack.Create(GotObject, Parent)
		--Creating the Object table
		local Object = {}

		--The parent Device of the Object
		Object.Parent = Parent
		--Default data for an Object
		--The coordinates of each Point, specifies the shape of the tetrahedron
		--Default shape: All Point is perpendicular to the last
		Object.Points = double(16)
		SetIdentity(Object.Points)
		Object.Points[3], Object.Points[7], Object.Points[11] = 1, 1, 1

		--The transformated points of the object, scaled, rotated and translated
		Object.Transformated = double(16)

		--The matrices that will contains the transformations
		--Init for less calculations
		Object.ScaleMatrix = double(16)
		SetZero(Object.ScaleMatrix)
		Object.ScaleMatrix[15] = 1
		Object.RotationMatrix = double(16)
		SetZero(Object.RotationMatrix)
		Object.RotationMatrix[15] = 1
		Object.TranslationMatrix = double(16)
		SetIdentity(Object.TranslationMatrix)

		--The BufferMatrix contains the multiplication of the first two transformations
		Object.BufferMatrix = double(16)

		--The ModelMatrix contains the final transformation matrix
		Object.ModelMatrix = double(16)

		--Flags for upgrading the matrices
		Object.ScaleCalc, Object.RotationCalc, Object.TranslationCalc = true, true,
		true
		Object.Min, Object.Max = {}, {}
		--The translation in the world, it will be the Object's center of mass too
		--Default: origin
		Object.Translation = double(3, 0, 0, 0)

		--The Direction of the shape, in a quaternion form
		Object.Rotation = double(4, 1, 0, 0, 0)

		--The scale of the shape on each axes
		Object.Scale = double(3, 1, 1, 1)

		--Flag if true, the Object is fixed
		Object.Fixed = false

		--The LinearVelocity of the Object on each axes
		Object.LinearVelocity = double(3, 0, 0, 0)

		--The AngularVelocity of the Object, in a quaternion form
		Object.AngularVelocity = double(4, 1, 0, 0, 0)

		--The LinearAcceleration of the Object on each axes
		Object.LinearAcceleration = double(3, 0, 0, 0)

		--The AngularAcceleration of the Object, in a quaternion form
		Object.AngularAcceleration = double(4, 1, 0, 0, 0)

		--Defines, which of the Cameras can see it, Default: All
		Object.VisualLayers = {}
		--Defines, which Other bodies, effects can affect it, Default: All
		Object.PhysicsLayers = {}
		--Defines the body's mass
		--Default: 1, if Object is fixed, then mass is infinite
		Object.Mass = 1

		--The type of the renderer, that will draw the Object
		Object.ObjectRenderer = "Default"

		--Powers, it contains mechanincs that aren't derived from physics
		--They are stored in Power.lua and managed by AllPowers.lua
		Object.Powers = {}

		--Powers, that are activetid on collision, they get the contact manifold
		--And the Object which they collided with
		--It's an array of booleans, the indices are the same as the Powers'
		Object.OnCollisionPowers = {}

		--RenderData contains Data which is necessary for drawing the Object
		Object.RenderData = {}
		local RenderData = {}

		--Creating the Object from the actual data
		if type(GotObject) == "table" then

			if IsVector3(GotObject.Translation) then
				Object.Translation[0], Object.Translation[1], Object.Translation[2] =
				GotObject.Translation[1], GotObject.Translation[2], GotObject.Translation[3]
			end

			--Rotation is stored as euler angles, so it is converted to quaternion
			if IsVector3(GotObject.Rotation) then
				EulerToQuaternion(GotObject.Rotation, Object.Rotation)
			end

			if IsVector3(GotObject.Scale) then
				Object.Scale[0], Object.Scale[1], Object.Scale[2] =
				GotObject.Scale[1], GotObject.Scale[2], GotObject.Scale[3]
			end

			if type(GotObject.Fixed) == "boolean" then
				Object.Fixed = GotObject.Fixed
			end

			if IsVector3(GotObject.LinearVelocity) then
				Object.LinearVelocity[0], Object.LinearVelocity[1], Object.LinearVelocity[2] =
				GotObject.LinearVelocity[1], GotObject.LinearVelocity[2], GotObject.LinearVelocity[3]
			end

			if IsVector3(GotObject.AngularVelocity) then
				EulerToQuaternion(GotObject.AngularVelocity, Object.AngularVelocity)
			end

			if IsVector3(GotObject.LinearAcceleration) then
				Object.LinearAcceleration[0], Object.LinearAcceleration[1], Object.LinearAcceleration[2] =
				GotObject.LinearAcceleration[1], GotObject.LinearAcceleration[2], GotObject.LinearAcceleration[3]
			end

			if IsVector3(GotObject.AngularAcceleration) then
				EulerToQuaternion(GotObject.AngularAcceleration, Object.AngularAcceleration)
			end

			--If the points it got is a 4x4 matrix, then it iterates through it, and
			--Copies it in a 1D matrix
			if IsMatrix4(GotObject.Points) then
				for ak=0,3 do
					for bk=0,3 do
						Object.Points[ak * 4 + bk] = GotObject.Points[ak + 1][bk + 1]
					end
				end
			end

			for ak=1,#GotObject.VisualLayers do
				local av = GotObject.VisualLayers[ak]
				Object.VisualLayers[av] = true
				Object.VisualLayers[ak] = av
			end

			if Object.VisualLayers[1] == nil then
				Object.VisualLayers.All = true
				Object.VisualLayers[1] = "All"
			end

			for ak=1,#GotObject.PhysicsLayers do
				local av = GotObject.PhysicsLayers[ak]
				Object.PhysicsLayers[av] = true
				Object.PhysicsLayers[ak] = av
			end

			if Object.PhysicsLayers[1] == nil then
				Object.PhysicsLayers.All = true
				Object.PhysicsLayers[1] = "All"
			end

			if Object.Fixed then
				Object.Mass = huge
			elseif type(GotObject.Mass) == "number" then
				Object.Mass = GotObject.Mass
			end

			--If the ObjectRender exist than it changes it from default
			if ObjectRenders[GotObject.ObjectRenderer] then
				Object.ObjectRenderer = GotObject.ObjectRenderer
			end

	  	if type(GotObject.Powers) == "table" then
				Object.Powers = GotObject.Powers
			end

			if GoodTypesOfTable(GotObject.OnCollisionPowers, "boolean") then
				for ak=1,#Object.Powers do
					Object.OnCollisionPowers[ak] = GotObject.OnCollisionPowers[ak]
				end
			end

			--RenderData is stored in a buffer, because it needs to be constructed
			--By the rendering function
			RenderData = GotObject.RenderData
		end

		--Construction of the RenderData
		local ORender = ObjectRenders[Object.ObjectRenderer]
		ORender.DataCheck(Object.RenderData, RenderData)

		--Making the origin the center of mass too
		--TODO: Putting this into General as function, which can be triggered
		--By a flag from UpdateObject
		for ak = 0, 2 do
			local center = (Object.Points[ak] +
			Object.Points[ak + 4] +
			Object.Points[ak + 8] +
			Object.Points[ak + 12])/4
			if center ~= 0 then
				for bk = 0, 3 do
					Object.Points[bk * 4 + ak] =
					Object.Points[bk * 4 + ak] - center
				end
			end
		end

		--Updating the Object, filling all the transformation matrices
		--Then multiplying them with the points into Transformated
		UpdateObject(Object)
		return Object
	end

	--Copies an Object, it's faster to copy a preloaded one, than making a new from
	--Scratch
	function GiveBack.Copy(GotObject, Parent)
		local Object = {}
		Object.Parent = Parent
		Object.Points = double(16)
		Object.ScaleMatrix = double(16)
		Object.RotationMatrix = double(16)
		Object.TranslationMatrix = double(16)
		Object.BufferMatrix = double(16)
		Object.ModelMatrix = double(16)
		Object.Transformated = double(16)
		copy(Object.Points, GotObject.Points, doublesize * 16)
		copy(Object.ScaleMatrix, GotObject.ScaleMatrix, doublesize * 16)
		copy(Object.RotationMatrix, GotObject.RotationMatrix, doublesize * 16)
		copy(Object.TranslationMatrix, GotObject.TranslationMatrix, doublesize * 16)
		copy(Object.Transformated, GotObject.Transformated, doublesize * 16)

		Object.ScaleCalc, Object.RotationCalc, Object.TranslationCalc = false, false,
		false

		Object.Translation = double(3)
		Object.Scale = double(3)
		Object.LinearVelocity = double(3)
		Object.LinearAcceleration = double(3)
		Object.Rotation = double(4)
		Object.AngularVelocity = double(4)
		Object.AngularAcceleration = double(4)
		copy(Object.Translation, GotObject.Translation, doublesize * 3)
		copy(Object.Scale, GotObject.Scale, doublesize * 3)
		copy(Object.LinearVelocity, GotObject.LinearVelocity, doublesize * 3)
		copy(Object.LinearAcceleration, GotObject.LinearAcceleration, doublesize * 3)
		copy(Object.Rotation, GotObject.Rotation, doublesize * 4)
		copy(Object.AngularVelocity, GotObject.AngularVelocity, doublesize * 4)
		copy(Object.AngularAcceleration, GotObject.AngularAcceleration, doublesize * 4)

		Object.Min =
		{GotObject.Min[1],
		GotObject.Min[2],
		GotObject.Min[3]}

		Object.Max =
		{GotObject.Max[1],
		GotObject.Max[2],
		GotObject.Max[3]}

		Object.Fixed = GotObject.Fixed

		Object.VisualLayers = {}
		for ak=1,#GotObject.VisualLayers do
			local av = GotObject.VisualLayers[ak]
			Object.VisualLayers[ak] = av
			Object.VisualLayers[av] = true
		end
		Object.PhysicsLayers = {}
		for ak=1,#GotObject.PhysicsLayers do
			local av = GotObject.PhysicsLayers[ak]
			Object.PhysicsLayers[ak] = av
			Object.PhysicsLayers[av] = true
		end

		Object.Powers = {}
		for ak=1,#GotObject.Powers do
			Object.Powers[ak] = GotObject.Powers[ak]
		end
		Object.OnCollisionPowers = {}
		for ak=1,#GotObject.OnCollisionPowers do
			Object.OnCollisionPowers[ak] = GotObject.OnCollisionPowers[ak]
		end
		Object.Mass = GotObject.Mass
		Object.ObjectRenderer = GotObject.ObjectRenderer
		Object.RenderData = ObjectRenders[Object.ObjectRenderer].CopyRenderData(GotObject.RenderData)
		return Object
	end

	return GiveBack
end
