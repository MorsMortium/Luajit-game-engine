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
local function Check(Boolean)
  Boolean.Tested = true
  return Boolean.Value
end
function GiveBack.Start(Arguments)
  local Space, SDL, lgsl = Arguments[1], Arguments[4], Arguments[8]
  Space.LastTime = SDL.Library.getTicks()
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
function GiveBack.Physics(Arguments)
  local Space, AllDevices, SDL, SDLInit, lgsl, ffi, General, Power, PowerGive, CollisionDetection, CollisionDetectionGive, CollisionResponse, CollisionResponseGive = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10], Arguments[12], Arguments[14], Arguments[15], Arguments[16], Arguments[17], Arguments[18], Arguments[19]
  local gsl = lgsl.Library.gsl
  local Time = SDL.Library.getTicks() - Space.LastTime
	Space.LastTime = Space.LastTime + Time
  if Time == 0 then
    return
  end
  for ak=1,#AllDevices.Space.Devices do
    local av = AllDevices.Space.Devices[ak]
    for bk=1,#av.Objects do
      local bv = av.Objects[bk]
      if not bv.Fixed then
        for c=1,3 do
          if bv.Speed[c] ~= 0 then
            bv.Translation[c] = bv.Translation[c] + bv.Speed[c] * Time
            bv.MMcalc = true
          end
          if bv.JointSpeed[c] ~= 0 then
            bv.Translation[c] = bv.Translation[c] + bv.JointSpeed[c] * Time
            bv.JointSpeed[c] = 0
            bv.MMcalc = true
          end
          if bv.RotationSpeed[c] ~= 0 then
            local Axis = {0, 0, 0}
            Axis[c] = 1
            bv.Rotation = General.Library.QuaternionMultiplication(bv.Rotation,
              General.Library.AxisAngleToQuaternion(Axis,
                bv.RotationSpeed[c] * Time))
            bv.MMcalc = true
          end
        end
      end
      if bv.JointRotationSpeed ~= {1, 0, 0, 0} then
        bv.Rotation = General.Library.QuaternionMultiplication(bv.Rotation, bv.JointRotationSpeed)
        bv.JointRotationSpeed = {1, 0, 0, 0}
        bv.MMcalc = true
      end
      if bv.MMcalc then
        bv.ModelMatrix = General.Library.ModelMatrix(bv.Translation, bv.Rotation, bv.Scale, lgsl)
        gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasTrans, 1, bv.ModelMatrix, bv.Points, 0, bv.Transformated)
        gsl.gsl_matrix_transpose(bv.Transformated)
        bv.MMcalc = false
      end
    end
  end
  for ak=1,#AllDevices.Space.Devices do
    local av = AllDevices.Space.Devices[ak]
    for bk=1,#av.FixedJoints do
      local bv = av.FixedJoints[bk]
      local c1 = av.Objects[bv[1]].Translation
      local c2 = av.Objects[bv[3]].Translation

      local JointRotationSpeedMatrix1 = General.Library.RotationMatrix(lgsl, av.Objects[bv[1]].JointRotationSpeed, c1)
      local JointRotationSpeedMatrix2 = General.Library.RotationMatrix(lgsl, av.Objects[bv[3]].JointRotationSpeed, c2)

      gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasTrans, 1, JointRotationSpeedMatrix1, av.Objects[bv[1]].Transformated, 0, Space.AfterJointRotationSpeedMatrix1)
      gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasTrans, 1, JointRotationSpeedMatrix2, av.Objects[bv[3]].Transformated, 0, Space.AfterJointRotationSpeedMatrix2)

      gsl.gsl_matrix_transpose(Space.AfterJointRotationSpeedMatrix1)
      gsl.gsl_matrix_transpose(Space.AfterJointRotationSpeedMatrix2)

      local p1 = {Space.AfterJointRotationSpeedMatrix1.data[(bv[2]-1) * 4], Space.AfterJointRotationSpeedMatrix1.data[(bv[2]-1) * 4 + 1], Space.AfterJointRotationSpeedMatrix1.data[(bv[2]-1) * 4 + 2]}
      local p2 = {Space.AfterJointRotationSpeedMatrix2.data[(bv[4]-1) * 4], Space.AfterJointRotationSpeedMatrix2.data[(bv[4]-1) * 4 + 1], Space.AfterJointRotationSpeedMatrix2.data[(bv[4]-1) * 4 + 2]}

      local VectorFromCenter1ToPoint1 = General.Library.PointAToB(c1, p1)
      local VectorFromCenter2ToPoint2 = General.Library.PointAToB(c2, p2)

      local MoveVector = General.Library.PointAToB(p1, p2)

      local FirstBodyAxis = General.Library.PerpendicularToBoth(MoveVector, VectorFromCenter1ToPoint1)
      local SecondBodyAxis = General.Library.PerpendicularToBoth(MoveVector, VectorFromCenter2ToPoint2)

      local SpeedSmaller = 80
      av.Objects[bv[1]].JointSpeed = General.Library.VectorAddition(av.Objects[bv[1]].JointSpeed, General.Library.VectorNumberMult(MoveVector, SpeedSmaller))
      av.Objects[bv[3]].JointSpeed = General.Library.VectorSubtraction(av.Objects[bv[3]].JointSpeed, General.Library.VectorNumberMult(MoveVector, SpeedSmaller))
      local AngleSmaller = 80
      av.Objects[bv[1]].JointRotationSpeed = General.Library.QuaternionMultiplication(av.Objects[bv[1]].JointRotationSpeed, General.Library.AxisAngleToQuaternion(FirstBodyAxis, General.Library.VectorLength(MoveVector) / AngleSmaller * Time))
      av.Objects[bv[3]].JointRotationSpeed = General.Library.QuaternionMultiplication(av.Objects[bv[3]].JointRotationSpeed, General.Library.AxisAngleToQuaternion(SecondBodyAxis, -General.Library.VectorLength(MoveVector) / AngleSmaller * Time))
    end
  end
  for ak=1,#AllDevices.Space.Devices do
    local av = AllDevices.Space.Devices[ak]
    for bk=1,#av.Objects do
      local bv = av.Objects[bk]
      for ck=ak,#AllDevices.Space.Devices do
        local cv = AllDevices.Space.Devices[ck]
        for dk=1,#cv.Objects do
          local dv = cv.Objects[dk]
          local mtv = {}
          if bv.CollidedRecently[ck..dk] == nil then
            bv.CollidedRecently[ck..dk] = {Value = false, Tested = false}
          end
          if dv.CollidedRecently[ak..bk] == nil then
            dv.CollidedRecently[ak..bk] = {Value = false, Tested = false}
          end
          if (ak ~= ck or bk ~= dk) --[[and (not (ak == ck and Joint(av.FixedJoints, bk, dk)))--]] and General.Library.SameLayer(bv.PhysicsLayers, dv.PhysicsLayers) and (not Check(bv.CollidedRecently[ck..dk])) and (not Check(dv.CollidedRecently[ak..bk])) and CollisionDetection.Library.CollisionSphere(bv, dv, nil, General) and CollisionDetection.Library.GJK(bv, dv, mtv, CollisionDetectionGive) then
            bv.CollidedRecently[ck..dk].Value = true
            dv.CollidedRecently[ak..bk].Value = true
            if (av.Name == "Bullet" and cv.Name == "Asteroid") or (cv.Name == "Bullet" and av.Name == "Asteroid") then
              dv.Powers[1].Active = true
              bv.Powers[1].Active = true
              Score = Score + 1
            end
            if (av.Name == "SpaceShip" and cv.Name == "Asteroid") then
              dv.Powers[1].Active = true
              bv.Powers[8].Active = true
            elseif (cv.Name == "SpaceShip" and av.Name == "Asteroid") then
              dv.Powers[8].Active = true
              bv.Powers[1].Active = true
            end
            CollisionResponse.Library.ResponseWithoutTorque(bv, dv, mtv, CollisionResponseGive)
            --TODO
            --print(ak.." Device "..bk.." Object collided with "..ck.." Device "..dk.." Object")
          else
            if not bv.CollidedRecently[ck..dk].Tested then
              bv.CollidedRecently[ck..dk].Value = false
            end
            if not dv.CollidedRecently[ak..bk].Tested then
              dv.CollidedRecently[ak..bk].Value = false
            end
            --print(ak.." Device "..bk.." Object did not collided with "..ck.." Device "..dk.." Object")
          end
          bv.CollidedRecently[ck..dk].Tested = false
          dv.CollidedRecently[ak..bk].Tested = false
        end
      end
    end
  end
  for ak=1,#AllDevices.Space.Devices do
    local av = AllDevices.Space.Devices[ak]
    for bk=1,#av.Objects do
      local bv = av.Objects[bk]
      for ck=1,#bv.Powers do
        bv.PowerChecked[ck] = {}
      end
    end
  end
  for ak=1,#AllDevices.Space.Devices do
    if ak > #AllDevices.Space.Devices then break end
    local av = AllDevices.Space.Devices[ak]
    for bk=1,#av.Objects do
      local bv = av.Objects[bk]
      local Exit
      for ck=1,#bv.Powers do
        local cv = bv.Powers[ck]
        if Power.Library.Powers[cv.Type] then
          Exit = Power.Library.Powers[cv.Type].Use(AllDevices.Space.Devices, ak, bk, ck, Time, PowerGive)
          if Exit then break end
        end
      end
      if Exit then break end
    end

  end
end

GiveBack.Requirements = {"AllDevices", "SDL", "SDLInit", "lgsl", "ffi", "General", "Power", "CollisionDetection", "CollisionResponse"}
return GiveBack
