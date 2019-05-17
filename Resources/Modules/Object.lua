local GiveBack = {}
function GiveBack.Create(GotObject, Arguments)
	local General, ffi, ObjectRender, ObjectRenderGive, lgsl = Arguments[1], Arguments[3], Arguments[5], Arguments[6], Arguments[7]
	local Object = {}
	Object.Transformated = lgsl.Library.gsl.gsl_matrix_alloc(4, 4)
	-- The Translation in the world, it will be the Object's center of Mass too, Default: center
	Object.Translation = {0, 0, 0}
	if General.Library.IsVector3(GotObject.Translation) then
		Object.Translation = GotObject.Translation
	end
	-- The Direction of the shape, it will come from the Translation, and will go to the Angle of the last three lines, Default: Up
	Object.Rotation = {1, 0, 0, 0}
	if General.Library.IsVector3(GotObject.Rotation) then
		Object.Rotation = General.Library.AxisAngleToQuaternion({1, 0, 0}, GotObject.Rotation[1])
		Object.Rotation = General.Library.QuaternionMultiplication(Object.Rotation, General.Library.AxisAngleToQuaternion({0, 1, 0}, GotObject.Rotation[2]))
		Object.Rotation = General.Library.QuaternionMultiplication(Object.Rotation, General.Library.AxisAngleToQuaternion({0, 0, 1}, GotObject.Rotation[3]))
	end
	Object.Scale = {1, 1, 1}
	if General.Library.IsVector3(GotObject.Scale) then
		Object.Scale = GotObject.Scale
	end
	if type(GotObject.Fixed) == "boolean" then
		Object.Fixed = GotObject.Fixed
	else
		Object.Fixed = false
	end
	Object.Speed = {0, 0, 0}
	if General.Library.IsVector3(GotObject.Speed) then
		Object.Speed = GotObject.Speed
	end
	Object.RotationSpeed = {0, 0, 0}
	if General.Library.IsVector3(GotObject.RotationSpeed) then
		Object.RotationSpeed = GotObject.RotationSpeed
	end
	Object.JointSpeed = {0, 0, 0}
	if General.Library.IsVector3(GotObject.JointSpeed) then
		Object.JointSpeed = GotObject.JointSpeed
	end
	Object.JointRotationSpeed = {1, 0, 0, 0}
	if General.Library.IsVector3(GotObject.JointRotationSpeed) then
    Object.JointRotationSpeed = General.Library.AxisAngleToQuaternion({1, 0, 0}, GotObject.JointRotationSpeed[1])
    Object.JointRotationSpeed = General.Library.QuaternionMultiplication(Object.JointRotationSpeed, General.Library.AxisAngleToQuaternion({0, 1, 0}, GotObject.JointRotationSpeed[2]))
    Object.JointRotationSpeed = General.Library.QuaternionMultiplication(Object.JointRotationSpeed, General.Library.AxisAngleToQuaternion({0, 0, 1}, GotObject.JointRotationSpeed[3]))
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
	-- Defines the body's Mass, Default: 1, if Object is fixed, then Mass is infinite
	if Object.Fixed then
		Object.Mass = math.huge
	elseif type(Object.Mass) ~= "number" then
		Object.Mass = 1
	else
		Object.Mass = GotObject.Mass
	end
	Object.ObjectRenderer = GotObject.ObjectRenderer
	if type(GotObject.ObjectRenderer) ~= "string" or GotObject.ObjectRenderer == nil or ObjectRender.Library.ObjectRenders[GotObject.ObjectRenderer] == nil then
		Object.ObjectRenderer = "Default"
	end
	Object.CollisionDecay = GotObject.CollisionDecay
	if type(GotObject.CollisionDecay) ~= "number" or GotObject.CollisionDecay < 0 or GotObject.CollisionDecay > 1 then
		Object.CollisionDecay = 0
	end
	Object.RenderData = {}
	ObjectRender.Library.ObjectRenders[Object.ObjectRenderer].DataCheck(Object.RenderData, GotObject.RenderData, ObjectRenderGive)
	for ak = 0, 2 do
		local center = (Object.Points.data[ak] + Object.Points.data[ak + 4] + Object.Points.data[ak + 8] + Object.Points.data[ak + 12])/4
		if center ~= 0 then
			for bk = 0, 3 do
				Object.Points.data[bk * 4 + ak] = Object.Points.data[bk * 4 + ak] - center
			end
		end
	end
	--Use, return
	--first: get
	--second: GiveBack
	if type(GotObject.CollisionReaction)=="table" and #GotObject.CollisionReaction==2 and General.Library.GoodTypesOfTable(Object.CollisionReaction, "number") then
		Object.CollisionReaction = GotObject.CollisionReaction
	else
		Object.CollisionReaction = {0.5, 0.5}
	end
	if Object.CollisionReaction[1] + Object.CollisionReaction[2] > 1 then
		Object.CollisionReaction[1] = 0.5
		Object.CollisionReaction[2] = 0.5
	end
	Object.Powers = GotObject.Powers
  if Object.Powers == nil then
    Object.Powers = {}
  end
	Object.CollidedRecently = {}
	Object.CollisionBoxMaximum = {}
	Object.CollisionBoxMinimum = {}
	Object.ModelMatrix = General.Library.ModelMatrix(Object.Translation, Object.Rotation, Object.Scale, lgsl)
	lgsl.Library.gsl.gsl_blas_dgemm(lgsl.Library.gsl.CblasNoTrans, lgsl.Library.gsl.CblasTrans, 1, Object.ModelMatrix, Object.Points, 0, Object.Transformated)
	lgsl.Library.gsl.gsl_matrix_transpose(Object.Transformated)
	Object.MMcalc = false
	General.Library.CreateCollisionSphere(Object)
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
