local GiveBack = {}
local function Joint(FixedJoints, k1, k2)
  for ak=1,#FixedJoints do
    local av = FixedJoints[ak]
    if (av[1] == k1 and av[3] == k2) or (av[3] == k1 and av[1] == k2) then
      return true
    end
  end
  return false
end
function GiveBack.Start(Arguments)
  local Space, lgsl = Arguments[1], Arguments[8]
  Space.BroadPhaseAxes = {{}, {}, {}}
  local gsl = lgsl.Library.gsl
  Space.AfterJointRotationSpeedMatrix1 = gsl.gsl_matrix_alloc(4, 4)
  Space.AfterJointRotationSpeedMatrix2 = gsl.gsl_matrix_alloc(4, 4)
end
function GiveBack.Stop(Arguments)
  local Space, lgsl = Arguments[1], Arguments[8]
  local gsl = lgsl.Library.gsl
  gsl.gsl_matrix_free(Space.AfterJointRotationSpeedMatrix1)
  gsl.gsl_matrix_free(Space.AfterJointRotationSpeedMatrix2)
  for ak,av in pairs(Space) do
    Space[ak] = nil
  end
end
function GiveBack.Physics(Time, Arguments)
  local Space, AllDevices, AllDevicesGive, SDL, SDLInit, lgsl, ffi, General,
  AllPowers, AllPowersGive, CollisionDetection, CollisionDetectionGive,
  CollisionResponse, CollisionResponseGive = Arguments[1], Arguments[2],
  Arguments[3], Arguments[4], Arguments[6], Arguments[8], Arguments[10],
  Arguments[12], Arguments[14], Arguments[15], Arguments[16], Arguments[17],
  Arguments[18], Arguments[19]
  local gsl = lgsl.Library.gsl
  local VectorAddition = General.Library.VectorAddition
  local VectorNumberMult = General.Library.VectorNumberMult
  local QuaternionMultiplication = General.Library.QuaternionMultiplication
  local RotationMatrix = General.Library.RotationMatrix
  local EulerToQuaternion = General.Library.EulerToQuaternion
  for ak=1,#AllDevices.Space.Devices do
    local av = AllDevices.Space.Devices[ak]
    for bk=1,#av.Objects do
      local bv = av.Objects[bk]
      if not bv.Fixed then
        if bv.Speed[1] ~= 0 or
        bv.Speed[2] ~= 0 or
        bv.Speed[3] ~= 0 then
          bv.Translation = VectorAddition(bv.Translation, VectorNumberMult(bv.Speed, Time))
          bv.MMcalc = true
        end
        if bv.RotationSpeed[1] ~= 0 or
        bv.RotationSpeed[2] ~= 0 or
        bv.RotationSpeed[3] ~= 0 then
          bv.Rotation = QuaternionMultiplication(bv.Rotation,
          EulerToQuaternion(VectorNumberMult(bv.RotationSpeed, Time)))
          bv.MMcalc = true
        end
        if bv.JointSpeed[1] ~= 0 or
        bv.JointSpeed[2] ~= 0 or
        bv.JointSpeed[3] ~= 0 then
          bv.Translation = VectorAddition(bv.Translation, VectorNumberMult(bv.JointSpeed, Time))
          bv.JointSpeed = {0, 0, 0}
          bv.MMcalc = true
        end
        if bv.JointRotationSpeed[1] ~= 1 or
        bv.JointRotationSpeed[2] ~= 0 or
        bv.JointRotationSpeed[3] ~= 0 or
         bv.JointRotationSpeed[4] ~= 0 then
          bv.Rotation = QuaternionMultiplication(bv.Rotation, bv.JointRotationSpeed)
          bv.JointRotationSpeed = {1, 0, 0, 0}
          bv.MMcalc = true
        end
        if bv.MMcalc then
          General.Library.UpdateObject(bv, false, lgsl, AllDevices.Space.HelperMatrices)
          bv.MMcalc = false
        end
      end
    end
  end
  for ak=1,#AllDevices.Space.Devices do
    local av = AllDevices.Space.Devices[ak]
    for bk=1,#av.FixedJoints do
      local bv = av.FixedJoints[bk]
      local c1 = av.Objects[bv[1]].Translation
      local c2 = av.Objects[bv[3]].Translation

      RotationMatrix(lgsl, av.Objects[bv[1]].JointRotationSpeed, c1, AllDevices.Space.HelperMatrices[1])
      RotationMatrix(lgsl, av.Objects[bv[3]].JointRotationSpeed, c2, AllDevices.Space.HelperMatrices[2])

      gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasTrans, 1, av.Objects[bv[1]].Transformated, AllDevices.Space.HelperMatrices[1], 0, Space.AfterJointRotationSpeedMatrix1)
      gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasTrans, 1, av.Objects[bv[3]].Transformated, AllDevices.Space.HelperMatrices[2], 0, Space.AfterJointRotationSpeedMatrix2)

      local p1 = {Space.AfterJointRotationSpeedMatrix1.data[(bv[2]-1) * 4], Space.AfterJointRotationSpeedMatrix1.data[(bv[2]-1) * 4 + 1], Space.AfterJointRotationSpeedMatrix1.data[(bv[2]-1) * 4 + 2]}
      local p2 = {Space.AfterJointRotationSpeedMatrix2.data[(bv[4]-1) * 4], Space.AfterJointRotationSpeedMatrix2.data[(bv[4]-1) * 4 + 1], Space.AfterJointRotationSpeedMatrix2.data[(bv[4]-1) * 4 + 2]}

      local VectorFromCenter1ToPoint1 = General.Library.PointAToB(c1, p1)
      local VectorFromCenter2ToPoint2 = General.Library.PointAToB(c2, p2)

      local MoveVector = General.Library.PointAToB(p1, p2)

      local FirstBodyAxis = General.Library.PerpendicularToBoth(MoveVector, VectorFromCenter1ToPoint1)
      local SecondBodyAxis = General.Library.PerpendicularToBoth(MoveVector, VectorFromCenter2ToPoint2)

      local SpeedSmaller = 80000000
      av.Objects[bv[1]].JointSpeed = VectorAddition(av.Objects[bv[1]].JointSpeed, VectorNumberMult(MoveVector, SpeedSmaller))
      av.Objects[bv[3]].JointSpeed = General.Library.VectorSubtraction(av.Objects[bv[3]].JointSpeed, VectorNumberMult(MoveVector, SpeedSmaller))
      local AngleSmaller = 80000000
      av.Objects[bv[1]].JointRotationSpeed = QuaternionMultiplication(av.Objects[bv[1]].JointRotationSpeed, General.Library.AxisAngleToQuaternion(FirstBodyAxis, General.Library.VectorLength(MoveVector) / AngleSmaller * Time))
      av.Objects[bv[3]].JointRotationSpeed = QuaternionMultiplication(av.Objects[bv[3]].JointRotationSpeed, General.Library.AxisAngleToQuaternion(SecondBodyAxis, -General.Library.VectorLength(MoveVector) / AngleSmaller * Time))
    end
  end
  AllPowers.Library.DataCheckNewDevicesPowers(AllPowersGive)
  CollisionDetection.Library.CheckForCollisions(AllDevices, Space.BroadPhaseAxes, CollisionDetectionGive)
  AllDevices.Library.ClearDeviceChanges(AllDevicesGive)
  AllPowers.Library.UseAllPowers(Time, AllPowersGive)
end

GiveBack.Requirements = {"AllDevices", "SDL", "SDLInit", "lgsl", "ffi", "General", "AllPowers", "CollisionDetection", "CollisionResponse"}
return GiveBack
