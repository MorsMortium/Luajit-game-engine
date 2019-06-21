local GiveBack = {}
function GiveBack.Create(GotObject, Parent, Arguments, HelperMatrices)
	local General, ffi, ObjectRender, ObjectRenderGive, lgsl = Arguments[1], Arguments[3], Arguments[5], Arguments[6], Arguments[7]
	local gsl = lgsl.Library.gsl
	local Object = {}
	Object.Parent = Parent
	Object.Transformated = gsl.gsl_matrix_alloc(4, 4)
	-- The Translation in the world, it will be the Object's center of Mass too, Default: center
	Object.Translation = {0, 0, 0}
	-- The Direction of the shape, it will come from the Translation, and will go to the Angle of the last three lines, Default: Up
	Object.Rotation = {1, 0, 0, 0}
	Object.Scale = {1, 1, 1}
	Object.Fixed = false
	Object.Speed = {0, 0, 0}
	Object.RotationSpeed = {0, 0, 0}
	Object.JointSpeed = {0, 0, 0}
	Object.JointRotationSpeed = {1, 0, 0, 0}
	-- The coordinates of each Point, specifies the shape of the tetrahedron, Default shape: All Point is perpendicular to the first
	Object.Points = gsl.gsl_matrix_alloc(4, 4)
	gsl.gsl_matrix_set_identity(Object.Points)
	Object.Points.data[3], Object.Points.data[7], Object.Points.data[11] = 1, 1, 1
	-- Defines, which of the Cameras can see it, Default: All
	Object.VisualLayers = {"All"}
	-- Defines, which Other bodies, effects can affect it, Default: All
	Object.PhysicsLayers = {"All"}
	-- Defines the body's Mass, Default: 1, if Object is fixed, then Mass is infinite
	Object.Mass = 1
	Object.ObjectRenderer = "Default"
	Object.CollisionDecay = 0
	Object.CollisionReaction = {0.5, 0.5}
	Object.Powers = {}
	Object.MMcalc = false
	Object.RenderData = {}
	if type(GotObject) == "table" then
		if General.Library.IsVector3(GotObject.Translation) then
			Object.Translation = GotObject.Translation
		end
		if General.Library.IsVector3(GotObject.Rotation) then
			Object.Rotation = General.Library.EulerToQuaternion(GotObject.Rotation)
		end
		if General.Library.IsVector3(GotObject.Scale) then
			Object.Scale = GotObject.Scale
		end
		if type(GotObject.Fixed) == "boolean" then
			Object.Fixed = GotObject.Fixed
		end
		if General.Library.IsVector3(GotObject.Speed) then
			Object.Speed = GotObject.Speed
		end
		if General.Library.IsVector3(GotObject.RotationSpeed) then
			Object.RotationSpeed = GotObject.RotationSpeed
		end
		if General.Library.IsVector3(GotObject.JointSpeed) then
			Object.JointSpeed = GotObject.JointSpeed
		end
		if General.Library.IsVector3(GotObject.JointRotationSpeed) then
	    Object.JointRotationSpeed = General.Library.EulerToQuaternion(GotObject.JointRotationSpeed)
	  end
		if General.Library.IsMatrix4(GotObject.Points) then
			for ak=0,3 do
				for bk=0,3 do
					Object.Points.data[ak * 4 + bk] = GotObject.Points[ak + 1][bk + 1]
				end
			end
		end
		if General.Library.GoodTypesOfTable(Object.VisualLayers, "string") then
			Object.VisualLayers = GotObject.VisualLayers
		end
		if General.Library.GoodTypesOfTable(Object.PhysicsLayers, "string") then
			Object.PhysicsLayers = GotObject.PhysicsLayers
		end
		if Object.Fixed then
			Object.Mass = math.huge
		elseif type(GotObject.Mass) == "number" then
			Object.Mass = GotObject.Mass
		end
		if ObjectRender.Library.ObjectRenders[GotObject.ObjectRenderer] then
			Object.ObjectRenderer = GotObject.ObjectRenderer
		end
		if type(GotObject.CollisionDecay) == "number" and 0 <= GotObject.CollisionDecay and GotObject.CollisionDecay <= 1 then
			Object.CollisionDecay = GotObject.CollisionDecay
		end
		if General.Library.GoodTypesOfTable(GotObject.CollisionReaction, "number") and #GotObject.CollisionReaction == 2 then
			Object.CollisionReaction = GotObject.CollisionReaction
		end
		if Object.CollisionReaction[1] + Object.CollisionReaction[2] > 1 then
			Object.CollisionReaction[1] = 0.5
			Object.CollisionReaction[2] = 0.5
		end
	  if type(GotObject.Powers) == "table" then
			Object.Powers = GotObject.Powers
	  else
			Object.Powers = {}
		end
		if General.Library.GoodTypesOfTable(GotObject.OnCollisionPowers, "boolean") then
			Object.OnCollisionPowers = GotObject.OnCollisionPowers
		else
			Object.OnCollisionPowers = {}
		end
		ObjectRender.Library.ObjectRenders[Object.ObjectRenderer].DataCheck(Object.RenderData, GotObject.RenderData, ObjectRenderGive)
	else
		ObjectRender.Library.ObjectRenders[Object.ObjectRenderer].DataCheck(Object.RenderData, nil, ObjectRenderGive)
	end
	for ak = 0, 2 do
		local center = (Object.Points.data[ak] + Object.Points.data[ak + 4] + Object.Points.data[ak + 8] + Object.Points.data[ak + 12])/4
		if center ~= 0 then
			for bk = 0, 3 do
				Object.Points.data[bk * 4 + ak] = Object.Points.data[bk * 4 + ak] - center
			end
		end
	end
	General.Library.UpdateObject(Object, true, lgsl, HelperMatrices)
	return Object
end
function GiveBack.Copy(GotObject, Parent, Arguments, HelperMatrices)
	local General, ffi, ObjectRender, ObjectRenderGive, lgsl = Arguments[1], Arguments[3], Arguments[5], Arguments[6], Arguments[7]
	local gsl = lgsl.Library.gsl
	local Object = {}
	Object.Parent = Parent
	Object.Transformated = gsl.gsl_matrix_alloc(4, 4)
	Object.Translation = {GotObject.Translation[1], GotObject.Translation[2], GotObject.Translation[3]}
	Object.Rotation = {GotObject.Rotation[1],
										GotObject.Rotation[2],
										GotObject.Rotation[3],
										GotObject.Rotation[4]}
	Object.Scale = {GotObject.Scale[1], GotObject.Scale[2], GotObject.Scale[3]}
	Object.Fixed = GotObject.Fixed
	Object.Speed = {GotObject.Speed[1], GotObject.Speed[2], GotObject.Speed[3]}
	Object.RotationSpeed = {GotObject.RotationSpeed[1], GotObject.RotationSpeed[2], GotObject.RotationSpeed[3]}
	Object.JointSpeed = {GotObject.JointSpeed[1], GotObject.JointSpeed[2], GotObject.JointSpeed[3]}
	Object.JointRotationSpeed = {GotObject.JointRotationSpeed[1],
															GotObject.JointRotationSpeed[2],
															GotObject.JointRotationSpeed[3],
															GotObject.JointRotationSpeed[4]}
	Object.Points = gsl.gsl_matrix_alloc(4, 4)
	gsl.gsl_matrix_memcpy(Object.Points, GotObject.Points)
	Object.VisualLayers = {}
	for ak=1,#GotObject.VisualLayers do
		Object.VisualLayers[ak] = GotObject.VisualLayers[ak]
	end
	Object.PhysicsLayers = {}
	for ak=1,#GotObject.PhysicsLayers do
		Object.PhysicsLayers[ak] = GotObject.PhysicsLayers[ak]
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
	Object.CollisionDecay = GotObject.CollisionDecay
	Object.CollisionReaction = {GotObject.CollisionReaction[1], GotObject.CollisionReaction[2]}
	Object.RenderData = General.Library.DeepCopy(GotObject.RenderData, ffi)
	General.Library.UpdateObject(Object, true, lgsl, HelperMatrices)
	return Object
end
function GiveBack.Destroy(Object, Arguments)
	local lgsl = Arguments[7]
	local gsl = lgsl.Library.gsl
	gsl.gsl_matrix_free(Object.Transformated)
	gsl.gsl_matrix_free(Object.Points)
	for ak,av in pairs(Object) do
		Object[ak] = nil
	end
end
GiveBack.Requirements = {"General", "ffi", "ObjectRender", "lgsl"}
return GiveBack
