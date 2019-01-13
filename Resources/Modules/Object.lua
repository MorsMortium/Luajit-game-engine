local GiveBack = {}
function GiveBack.Create(GotObject, General, GeneralGive, ffi, ffiGive, ObjectRender, ObjectRenderGive, lgsl, lgslGive, Power, PowerGive)
	local Object = {}
	Object.Translation = ffi.Library.new("float[3]")
	Object.Rotation = {}
	Object.Scale = ffi.Library.new("float[3]")
	-- The Translation in the world, it will be the Object's center of Mass too, Default: center
	if General.Library.IsVector3(GotObject.Translation) then
		for i=1,3 do
			Object.Translation[i - 1] = GotObject.Translation[i]
		end
	else
		for i=1,3 do
			Object.Translation[i - 1] = 0
		end
	end
	-- The Direction of the shape, it will come from the Translation, and will go to the Angle of the last three lines, Default: Up
	if General.Library.IsVector3(GotObject.Rotation) then
		Object.Rotation = General.Library.AxisAngleToQuaternion({1, 0, 0}, GotObject.Rotation[1])
		Object.Rotation = General.Library.QuaternionMultiplication(Object.Rotation, General.Library.AxisAngleToQuaternion({0, 1, 0}, GotObject.Rotation[2]))
		Object.Rotation = General.Library.QuaternionMultiplication(Object.Rotation, General.Library.AxisAngleToQuaternion({0, 0, 1}, GotObject.Rotation[3]))
	else
		Object.Rotation = {1, 0, 0, 0}
	end
	Object.Speed = {0, 0, 0}
	if General.Library.IsVector3(GotObject.Speed) then
		for i=1,3 do
			Object.Speed[i] = GotObject.Speed[i]
		end
	end
	Object.RotationSpeed = {0, 0, 0}
	if General.Library.IsVector3(GotObject.RotationSpeed) then
		for i=1,3 do
			Object.RotationSpeed[i] = GotObject.RotationSpeed[i]
		end
	end
	Object.JointSpeed = {0, 0, 0}
	if General.Library.IsVector3(GotObject.JointSpeed) then
		for i=1,3 do
			Object.JointSpeed[i] = GotObject.JointSpeed[i]
		end
	end
	Object.JointRotationSpeed = {1, 0, 0, 0}
	if General.Library.IsVector3(GotObject.JointRotationSpeed) then
    Object.JointRotationSpeed = General.Library.AxisAngleToQuaternion({1, 0, 0}, GotObject.JointRotationSpeed[1])
    Object.JointRotationSpeed = General.Library.QuaternionMultiplication(Object.JointRotationSpeed, General.Library.AxisAngleToQuaternion({0, 1, 0}, GotObject.JointRotationSpeed[2]))
    Object.JointRotationSpeed = General.Library.QuaternionMultiplication(Object.JointRotationSpeed, General.Library.AxisAngleToQuaternion({0, 0, 1}, GotObject.JointRotationSpeed[3]))
  end
	if General.Library.IsVector3(GotObject.Scale) then
		for i=1,3 do
			Object.Scale[i - 1] = GotObject.Scale[i]
		end
	else
		for i=1,3 do
			Object.Scale[i - 1] = 1
		end
	end
	-- The coordinates of each Point, specifies the shape of the tetrahedron, Default shape: All Point is perpendicular to the first
	if General.Library.IsMatrix4(GotObject.Points) then
		Object.Points = lgsl.Library.matrix.def{
		{GotObject.Points[1][1], GotObject.Points[1][2], GotObject.Points[1][3], GotObject.Points[1][4]},
		{GotObject.Points[2][1], GotObject.Points[2][2], GotObject.Points[2][3], GotObject.Points[2][4]},
		{GotObject.Points[3][1], GotObject.Points[3][2], GotObject.Points[3][3], GotObject.Points[3][4]},
		{GotObject.Points[4][1], GotObject.Points[4][2], GotObject.Points[4][3], GotObject.Points[4][4]}}
	else
		Object.Points = lgsl.Library.matrix.def{
	  {1, 0, 0, 1},
	  {0, 1, 0, 1},
	  {0, 0, 1, 1},
	  {0, 0, 0, 1}}
	end
	-- Defines, which of the Cameras can see it, Default: All
	Object.VisualLayers = GotObject.VisualLayers
	if not General.Library.GoodTypesOfTable(Object.VisualLayers, "string") then
		Object.VisualLayers = {"All"}
	end
	-- Defines, which Other bodies, effects can affect it, Default: All
	Object.PhysicsLayers = GotObject.PhysicsLayers
	if not General.Library.GoodTypesOfTable(Object.PhysicsLayers, "string") then
		Object.PhysicsLayers = {"All"}
	end
	-- Defines the body's Mass, Default: 1
	Object.Mass = GotObject.Mass
	if type(Object.Mass) ~= "number" then
		Object.Mass = 1
	end
	Object.ObjectRenderer = GotObject.ObjectRenderer
	if type(GotObject.ObjectRenderer) ~= "string" or GotObject.ObjectRenderer == nil or ObjectRender.Library.ObjectRenders[GotObject.ObjectRenderer] == nil then
		Object.ObjectRenderer = "Default"
	end
	Object.RenderData = {}
	ObjectRender.Library.ObjectRenders[Object.ObjectRenderer].DataCheck(Object.RenderData, GotObject.RenderData, unpack(ObjectRenderGive))
	---[[
	for i = 0, 2 do
		local center = (Object.Points.data[i] + Object.Points.data[i + 4] + Object.Points.data[i + 8] + Object.Points.data[i + 12])/4
		if center ~= 0 then
			for e = 0, 3 do
				Object.Points.data[e * 4 + i] = Object.Points.data[e * 4 + i] - center
			end
		end
	end
	--]]
	--Use, return
	Object.CollisionReaction = {}
	--first: get
	--second: GiveBack
	if type(GotObject.CollisionReaction)=="table" and #GotObject.CollisionReaction==2 and General.Library.GoodTypesOfTable(Object.CollisionReaction, "number") then
		for i=1,2 do
			Object.CollisionReaction[i] = GotObject.CollisionReaction[i]
		end
	else
		for i=1,2 do
			Object.CollisionReaction[i] = 0.5
		end
	end
	if Object.CollisionReaction[1] + Object.CollisionReaction[2] > 1 then
		Object.CollisionReaction[1] = 0.5
		Object.CollisionReaction[2] = 0.5
	end
	Object.CollisionChecked = {}
	if type(GotObject.Fixed) == "boolean" then
		Object.Fixed = GotObject.Fixed
	else
		Object.Fixed = false
	end
	Object.Powers = GotObject.Powers
  if Object.Powers == nil then
    Object.Powers = {}
  end
	return Object
end
function GiveBack.Destroy(Object, General, GeneralGive, ffi, ffiGive, ObjectRender, ObjectRenderGive, lgsl, lgslGive, Power, PowerGive)

end
GiveBack.Requirements = {"General", "ffi", "ObjectRender", "lgsl"}
return GiveBack
