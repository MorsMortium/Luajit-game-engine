local GiveBack = {}
function GiveBack.Create(GotObject, Arguments)
	local General, ffi, ObjectRender, ObjectRenderGive, lgsl = Arguments[1], Arguments[3], Arguments[5], Arguments[6], Arguments[7]
	local Object = {}
	Object.Transformated = lgsl.Library.gsl.gsl_matrix_alloc(4, 4)
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
	Object.Points = lgsl.Library.matrix.def{
	{1, 0, 0, 1},
	{0, 1, 0, 1},
	{0, 0, 1, 1},
	{0, 0, 0, 1}}
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
			Object.Points = lgsl.Library.matrix.def{
			{GotObject.Points[1][1], GotObject.Points[1][2], GotObject.Points[1][3], GotObject.Points[1][4]},
			{GotObject.Points[2][1], GotObject.Points[2][2], GotObject.Points[2][3], GotObject.Points[2][4]},
			{GotObject.Points[3][1], GotObject.Points[3][2], GotObject.Points[3][3], GotObject.Points[3][4]},
			{GotObject.Points[4][1], GotObject.Points[4][2], GotObject.Points[4][3], GotObject.Points[4][4]}}
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
	General.Library.UpdateObject(Object, true, lgsl)
	return Object
end
function GiveBack.Destroy(Object, Arguments)
	local lgsl = Arguments[7]
	lgsl.Library.gsl.gsl_matrix_free(Object.Transformated)
	for ak,av in pairs(Object) do
		Object[ak] = nil
	end
end
GiveBack.Requirements = {"General", "ffi", "ObjectRender", "lgsl"}
return GiveBack
