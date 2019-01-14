local GiveBack = {}
local function CollisionBox(FirstObject, SecondObject, IfEquals)
  if IfEquals then
    return (FirstObject.CollisionBoxMinimum[1] <= SecondObject.CollisionBoxMaximum[1] and FirstObject.CollisionBoxMaximum[1] >= SecondObject.CollisionBoxMinimum[1]) and
             (FirstObject.CollisionBoxMinimum[2] <= SecondObject.CollisionBoxMaximum[2] and FirstObject.CollisionBoxMaximum[2] >= SecondObject.CollisionBoxMinimum[2]) and
             (FirstObject.CollisionBoxMinimum[3] <= SecondObject.CollisionBoxMaximum[3] and FirstObject.CollisionBoxMaximum[3] >= SecondObject.CollisionBoxMinimum[3])
  else
    return (FirstObject.CollisionBoxMinimum[1] < SecondObject.CollisionBoxMaximum[1] and FirstObject.CollisionBoxMaximum[1] > SecondObject.CollisionBoxMinimum[1]) and
           (FirstObject.CollisionBoxMinimum[2] < SecondObject.CollisionBoxMaximum[2] and FirstObject.CollisionBoxMaximum[2] > SecondObject.CollisionBoxMinimum[2]) and
           (FirstObject.CollisionBoxMinimum[3] < SecondObject.CollisionBoxMaximum[3] and FirstObject.CollisionBoxMaximum[3] > SecondObject.CollisionBoxMinimum[3])
  end
end
local function Joint(FixedJoints, k1, k2)
  for k,v in pairs(FixedJoints) do
    if (v[1] == k1 and v[3] == k2) or (v[3] == k1 and v[1] == k2) then
      return true
    end
  end
  return false
end
function GiveBack.Start(Space, AllDevices, AllDevicesGive, SDL, SDLGive, SDLInit, SDLInitGive, lgsl, lgslGive, ffi, ffiGive, General, GeneralGive, Power, PowerGive, Collision, CollisionGive)
  function Space.Support(object, dir)
    local maxdot = General.Library.DotProduct({object.Transformated.data[0], object.Transformated.data[1], object.Transformated.data[2]}, dir)
    local index = 0
    for i=1,3 do
      local dot = General.Library.DotProduct({object.Transformated.data[i * 4], object.Transformated.data[i * 4 + 1], object.Transformated.data[i * 4 + 2]}, dir)
      if maxdot < dot then
        maxdot = dot
        index = i
      end
    end
    return {object.Transformated.data[index * 4], object.Transformated.data[index * 4 + 1], object.Transformated.data[index * 4 + 2]}
  end
  Space.LastTime = SDL.Library.getTicks()
  local gsl = lgsl.Library.gsl
  for k,v in pairs(AllDevices.Space.Devices) do
    for i,n in pairs(v.Objects) do
      n.ModelMatrix = General.Library.ModelMatrix(n.Translation, n.Rotation, n.Scale, lgsl)
      n.Transformated = gsl.gsl_matrix_alloc(4, 4)
      gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasTrans, 1, n.ModelMatrix, n.Points, 0, n.Transformated)
      gsl.gsl_matrix_transpose(n.Transformated)
      n.MMcalc = false
      n.CollisionBoxMaximum = {}
      n.CollisionBoxMinimum = {}
    	for e=0,2 do
    		local Maximum = n.Transformated.data[e]
        local  Minimum = Maximum
    		for f=0,3 do
    			if Maximum < n.Transformated.data[f * 4 + e] then
    				Maximum = n.Transformated.data[f * 4 + e]
    			end
          if Minimum > n.Transformated.data[f * 4 + e] then
            Minimum = n.Transformated.data[f * 4 + e]
          end
    		end
        n.CollisionBoxMaximum[e + 1] = Maximum
        n.CollisionBoxMinimum[e + 1] = Minimum
      end
    end
  end
end
function GiveBack.Stop(Space, AllDevices, AllDevicesGive, SDL, SDLGive, SDLInit, SDLInitGive, lgsl, lgslGive, ffi, ffiGive, General, GeneralGive, Power, PowerGive, Collision, CollisionGive)
	Space.LastTime = nil
  for k,v in pairs(AllDevices.Space.Devices) do
    for i,n in pairs(v.Objects) do
      lgsl.Library.gsl.gsl_matrix_free(n.Transformated)
    end
  end
end
function GiveBack.Physics(Space, AllDevices, AllDevicesGive, SDL, SDLGive, SDLInit, SDLInitGive, lgsl, lgslGive, ffi, ffiGive, General, GeneralGive, Power, PowerGive, Collision, CollisionGive)
  local gsl = lgsl.Library.gsl
  local Time = SDL.Library.getTicks() - Space.LastTime
	Space.LastTime = Space.LastTime + Time
  for k,v in pairs(AllDevices.Space.Devices) do
    for i,n in pairs(v.Objects) do
      for p=1,3 do
        if type(n.Speed[p]) == "number" and n.Speed[p] ~= 0 then
          n.Translation[p - 1] = n.Translation[p - 1] + n.Speed[p] * Time
          n.MMcalc = true
        end
        if type(n.JointSpeed[p]) == "number" and n.JointSpeed[p] ~= 0 then
          n.Translation[p - 1] = n.Translation[p - 1] + n.JointSpeed[p] * Time
          n.JointSpeed[p] = 0
          n.MMcalc = true
        end
      end
      for p=1,3 do
        if type(n.RotationSpeed[p]) == "number" and n.RotationSpeed[p] ~= 0 then
          local Axis = {0, 0, 0}
          Axis[p] = 1
          n.Rotation = General.Library.QuaternionMultiplication(n.Rotation, General.Library.AxisAngleToQuaternion(Axis, n.RotationSpeed[p] * Time))
          n.MMcalc = true
        end
      end
      if n.JointRotationSpeed ~= {1, 0, 0, 0} then
        n.Rotation = General.Library.QuaternionMultiplication(n.Rotation, n.JointRotationSpeed)
        n.JointRotationSpeed = {1, 0, 0, 0}
        n.MMcalc = true
      end
    end
  end
  for k,v in pairs(AllDevices.Space.Devices) do
    for i,n in pairs(v.Objects) do
      if n.MMcalc then
        n.ModelMatrix = General.Library.ModelMatrix(n.Translation, n.Rotation, n.Scale, lgsl)
        gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasTrans, 1, n.ModelMatrix, n.Points, 0, n.Transformated)
        gsl.gsl_matrix_transpose(n.Transformated)
        n.MMcalc = false
        for e=0,2 do
          local Maximum = n.Transformated.data[e]
          local  Minimum = Maximum
          for f=0,3 do
            if Maximum < n.Transformated.data[f * 4 + e] then
              Maximum = n.Transformated.data[f * 4 + e]
            end
            if Minimum > n.Transformated.data[f * 4 + e] then
              Minimum = n.Transformated.data[f * 4 + e]
            end
          end
          n.CollisionBoxMaximum[e + 1] = Maximum
          n.CollisionBoxMinimum[e + 1] = Minimum
        end
      end
    end
    for i,n in pairs(v.FixedJoints) do
      local c1 = {v.Objects[n[1]].Translation[0], v.Objects[n[1]].Translation[1], v.Objects[n[1]].Translation[2]}

      --local AfterJointRotationSpeedMatrix1 = gsl.gsl_matrix_alloc(4, 4)
      --local JointRotationSpeedMatrix1 = General.Library.RotationMatrix(lgsl, n.Objects[v[1]].JointRotationSpeed, c1)
      --gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasTrans, 1, JointRotationSpeedMatrix1, n.Objects[v[1]].Transformated, 0, AfterJointRotationSpeedMatrix1)
      --gsl.gsl_matrix_transpose(AfterJointRotationSpeedMatrix1)
      local AfterJointRotationSpeedMatrix1 = v.Objects[n[1]].Transformated

      local p1 = {AfterJointRotationSpeedMatrix1.data[(n[2]-1) * 4], AfterJointRotationSpeedMatrix1.data[(n[2]-1) * 4 + 1], AfterJointRotationSpeedMatrix1.data[(n[2]-1) * 4 + 2]}
      local c2 = {v.Objects[n[3]].Translation[0], v.Objects[n[3]].Translation[1], v.Objects[n[3]].Translation[2]}

      --local AfterJointRotationSpeedMatrix2 = gsl.gsl_matrix_alloc(4, 4)
      --local JointRotationSpeedMatrix2 = General.Library.RotationMatrix(lgsl, n.Objects[v[3]].JointRotationSpeed, c2)
      --gsl.gsl_blas_dgemm(gsl.CblasNoTrans, gsl.CblasTrans, 1, JointRotationSpeedMatrix2, n.Objects[v[3]].Transformated, 0, AfterJointRotationSpeedMatrix2)
      --gsl.gsl_matrix_transpose(AfterJointRotationSpeedMatrix2)

      local AfterJointRotationSpeedMatrix2 = v.Objects[n[3]].Transformated

      local p2 = {AfterJointRotationSpeedMatrix2.data[(n[4]-1) * 4], AfterJointRotationSpeedMatrix2.data[(n[4]-1) * 4 + 1], AfterJointRotationSpeedMatrix2.data[(n[4]-1) * 4 + 2]}
      local VectorFromCenter1ToPoint1 = General.Library.PointAToB(c1, p1)
      local VectorFromCenter2ToPoint2 = General.Library.PointAToB(c2, p2)
      local MoveVector = General.Library.PointAToB(p1, p2)
      local FirstBodyAxis = General.Library.PerpendicularToBoth(MoveVector, VectorFromCenter1ToPoint1)
      local SecondBodyAxis = General.Library.PerpendicularToBoth(MoveVector, VectorFromCenter2ToPoint2)
      local FirstBodyAxis = General.Library.PerpendicularToBoth(MoveVector, VectorFromCenter1ToPoint1)
      local SecondBodyAxis = General.Library.PerpendicularToBoth(MoveVector, VectorFromCenter2ToPoint2)
      local SpeedSmaller = 80
      for xxx=1,3 do
        v.Objects[n[1]].JointSpeed[xxx] = v.Objects[n[1]].JointSpeed[xxx] + MoveVector[xxx] / SpeedSmaller
        v.Objects[n[3]].JointSpeed[xxx] = v.Objects[n[3]].JointSpeed[xxx] - MoveVector[xxx] / SpeedSmaller
      end
      local AngleSmaller = 80
      v.Objects[n[1]].JointRotationSpeed = General.Library.QuaternionMultiplication(v.Objects[n[1]].JointRotationSpeed, General.Library.AxisAngleToQuaternion(FirstBodyAxis, General.Library.VectorLength(MoveVector) / AngleSmaller * Time))
      v.Objects[n[3]].JointRotationSpeed = General.Library.QuaternionMultiplication(v.Objects[n[3]].JointRotationSpeed, General.Library.AxisAngleToQuaternion(SecondBodyAxis, -General.Library.VectorLength(MoveVector) / AngleSmaller * Time))
      --lgsl.Library.gsl.gsl_matrix_free(AfterJointRotationSpeedMatrix1)
      --lgsl.Library.gsl.gsl_matrix_free(AfterJointRotationSpeedMatrix2)
    end
  end
  for i,n in pairs(AllDevices.Space.Devices) do
    for k,v in pairs(n.Objects) do
      for e,f in pairs(AllDevices.Space.Devices) do
        for a,b in pairs(f.Objects) do
          if v.CollisionChecked[e..a] == nil then
              if (i ~= e or k ~= a) --[[and (not (i == e and Joint(n.FixedJoints, k, a)))--]] and General.Library.SameLayer(v.PhysicsLayers, b.PhysicsLayers) and CollisionBox(v, b) and Collision.Library.GJK(v, b, Space.Support, Space.Support, mtv, unpack(CollisionGive)) then
                if (n.Name == "Bullet" and f.Name == "Asteroid") or (f.Name == "Bullet" and n.Name == "Asteroid") then
                  b.Powers[1].Active = true
                  v.Powers[1].Active = true
                  Score = Score + 1
                end
                if (n.Name == "SpaceShip" and f.Name == "Asteroid") then
                  b.Powers[1].Active = true
                  v.Powers[8].Active = true
                elseif (f.Name == "SpaceShip" and n.Name == "Asteroid") then
                  b.Powers[8].Active = true
                  v.Powers[1].Active = true
                end
              --[[
              if b.Fixed and not v.Fixed then
                for jjj=1,3 do
                  v.Speed[jjj] = - v.Speed[jjj] * b.CollisionReaction[2]
                end
              elseif v.Fixed and not b.Fixed then
                for jjj=1,3 do
                  b.Speed[jjj] = - b.Speed[jjj] * v.CollisionReaction[2]
                end
              elseif v.Fixed and b.Fixed then
                b.Speed = {0, 0, 0}
                v.Speed = {0, 0, 0}
              elseif not (v.Fixed or b.Fixed) then
                for jjj=1,3 do
                  b.Speed[jjj] = - b.Speed[jjj] * v.CollisionReaction[2]
                  v.Speed[jjj] = - v.Speed[jjj] * b.CollisionReaction[2]
                end
              end
              --]]
              --TODO
              --print(i.." Device "..k.." Object collided with "..e.." Device "..a.." Object")
            else
              --print(i.." Device "..k.." Object did not collided with "..e.." Device "..a.." Object")
            end
            v.CollisionChecked[e..a] = true
            b.CollisionChecked[i..k] = true
          end
        end
      end
      for h,j in pairs(v.Powers) do
        local exit
        if Power.Library.Powers[j.Type] then
          exit = Power.Library.Powers[j.Type].Use(AllDevices.Space.Devices, i, k, h, Time, unpack(PowerGive))
        end
        if exit then break end
      end
    end
    for i,n in pairs(AllDevices.Space.Devices) do
      for k,v in pairs(n.Objects) do
        v.CollisionChecked = {}
        for p,q in pairs(v.Powers) do
          v.PowerChecked[p] = {}
        end
      end
    end
  end
end

GiveBack.Requirements = {"AllDevices", "SDL", "SDLInit", "lgsl", "ffi", "General", "Power", "Collision"}
return GiveBack
