local GiveBack = {}
local function VectorSubtraction(Solution, a, b)
  for i=0,2 do
    Solution.data[i] = a.data[i] - b.data[i]
  end
end
local function VectorAddition(Solution, a, b)
  for i=0,2 do
    Solution.data[i] = a.data[i] + b.data[i]
  end
end
--Gilbert-Johnson-Keerthi distance and intersection tests
--Tyler R. Hoyer
--11/20/2014

--May return early if no intersection if found. If it is primed, it will run in amortized constant time (untested).

--If the distance function is used between colliding objects, the program
--may loop a hundred times without finding a result. If this is the case,
--it will throw an error. The check is omited for speed. If the objects
--might intersect eachother, call the intersection method first.

--Objects must implement the :getFarthestPoint(dir) function which returns the
--farthest point in a given direction.

--Used Roblox's Vector3 userdata. Outside implementations will require a implementation of the methods of
--the Vector3's. :Dot, :Cross, .new, and .magnitude must be defined.
local function VectorSubtraction(a, b)
  return {a[1] - b[1], a[2] - b[2], a[3] - b[3]}
end
local function VectorAddition(a, b)
  return {a[1] + b[1], a[2] + b[2], a[3] + b[3]}
end
local function VectorNumberMult(v, n)
  return {v[1] * n, v[2] * n, v[3] * n}
end
local function CrossProduct(u, v)
  return {u[2] * v[3] - u[3] * v[2], u[3] * v[1] - u[1] * v[3], u[1] * v[2] - u[2] * v[1]}
end
local function unit(a, General)
  return {a[1]/General.Library.VectorLength(a), a[2]/General.Library.VectorLength(a), a[3]/General.Library.VectorLength(a)}
end
local abs = math.abs
local min = math.min
local huge = math.huge

local function loopRemoved(data, step)
	--We're on the next step
	step = step + 1

	--If we have completed the last cycle, stop
	if step > #data then
		return nil
	end

	--To be the combination without the value
	local copy = {}

	--Copy the data up to the missing value
	for i = 1, step - 1 do
		copy[i] = data[i]
	end

	--Copy the data on the other side of the missing value
	for i = step, #data - 1 do
		copy[i] = data[i + 1]
	end

	--return the step, combination, and missing value
	return step, copy, data[step]
end

--Finds the vector direction to search for the next point
--in the simplex.
local function getDir(points, to, General)
	--Single point, return vector
  --print(#points[1])
	if #points == 1 then
		return VectorSubtraction(to, points[1])

	--Line, return orthogonal line
	elseif #points == 2 then
		local v1 = VectorSubtraction(points[2], points[1])
		local v2 = {to[1] - points[1][1], to[2] - points[1][2], to[3] - points[1][3]}
		return CrossProduct(CrossProduct(v1, v2), v1)

	--Triangle, return normal
	else
		local v1 = VectorSubtraction(points[3], points[1])
		local v2 = VectorSubtraction(points[2], points[1])
		local v3 = VectorSubtraction(to, points[1])
		local n = CrossProduct(v1, v2)
		return General.Library.DotProduct(n, v3) < 0 and {-n[1], -n[2], -n[3]} or n
	end
end

--The function that finds the intersection between two sets
--of points, s1 and s2. s1 and s2 must return the point in
--the set that is furthest in a given direction when called.
--If the start direction sV is specified as the seperation
--vector, the program runs in constant time. (excluding the
--user implemented functions for finding the furthest point).
function intersection(s1, s2, sV, pointsa, pointsb, General)
	local points = {}

	-- find point
	local function support(dir)
		local a = s1(pointsa, dir)
		local b = s2(pointsb, {-dir[1], -dir[2], -dir[3]})
		points[#points + 1] = VectorSubtraction(a, b)
		return General.Library.DotProduct(dir, a) < General.Library.DotProduct(dir, b)
	end

	-- find all points forming a simplex
	if support(sV)
		or support(getDir(points, {0, 0, 0}, General))
		or support(getDir(points, {0, 0, 0}, General))
		or support(getDir(points, {0, 0, 0}, General))
	then
		return false
	end

	local step, others, removed = 0
	repeat
		step, others, removed = loopRemoved(points, step)
		local dir = getDir(others, removed, General)
		if General.Library.DotProduct(others[1], dir) > 0 then
			points = others
			if support({-dir[1], -dir[2], -dir[3]}) then
				return false
			end
			step = 0
		end
	until step == 4

	return true
end

--Checks if two vectors are equal
local function equals(p1, p2)
	return p1[1] == p2[1] and p1[2] == p2[2] and p1[3] == p2[3]
end

--Gets the mathematical scalar t of the parametrc line defined by
--o + t * v of a point p on the line (the magnitude of the projection).
local function getT(o, v, p, General)
	return General.Library.DotProduct(({p[1] - o[1], p[2] - o[2], p[3] - o[3]}), v) / General.Library.DotProduct(v, v)
end

--Returns the scalar of the closest point on a line to
--the {0, 0, 0}. Note that if the vector is a zero vector then
--it treats it as a point offset instead of a line.
local function lineToorigin(o, v, General)
	if equals(v, {0, 0, 0}) then
		return o
	end
	local t = getT(o, v, {0, 0, 0}, General)
	if t < 0 then
		t = 0
	elseif t > 1 then
		t = 1
	end
	return {o[1] + v[1] * t, o[2] + v[2] * t, o[3] + v[3] * t}
end

--Convoluted to deal with cases like points in the same place
local function closestPoint(a, b, c, General)
	--if abc is a line
	if c == nil then
		--get the scalar of the closest point
		local dir = {b[1] - a[1], b[2] - a[2], b[3] - a[3]}
		local t = getT(a, dir, {0, 0, 0}, General)
		if t < 0 then t = 0
		elseif t > 1 then t = 1
		end
		--and return the point
		return {a[1] + dir[1] * t, a[2] + dir[2] * t, a[3] + dir[3] * t}
	end

	--Otherwise it is a triangle.
	--Define all the lines of the triangle and the normal
	local vAB, vBC, vCA = {b[1] - a[1], b[2] - a[2], b[3] - a[3]}, {c[1] - b[1], c[2] - b[2], c[3] - b[3]}, {a[1] - c[1], a[2] - c[2], a[3] - c[3]}
	local normal = CrossProduct(vAB, vBC)

	--If two points are in the same place then
	if General.Library.VectorLength(normal) == 0 then

		--Find the closest line between ab and bc to the {0, 0, 0} (it cannot be ac)
		local ab = lineToorigin(a, vAB, General)
		local bc = lineToorigin(b, vBC, General)
		if General.Library.VectorLength(ab) < General.Library.VectorLength(bc) then
			return ab
		else
			return bc
		end

	--The following statements find the line which is closest to the {0, 0, 0}
	--by using voroni regions. If it is inside the triangle, it returns the
	--normal of the triangle.

  elseif General.Library.DotProduct(a, VectorSubtraction(VectorNumberMult(VectorAddition(a, vAB), getT(a, vAB, c, General)), c)) <= 0 then
		return lineToorigin(a, vAB, General)
	elseif General.Library.DotProduct(b, VectorSubtraction(VectorNumberMult(VectorAddition(b, vBC), getT(b, vBC, a, General)), a)) <= 0 then
		return lineToorigin(b, vBC, General)
	elseif General.Library.DotProduct(c, VectorSubtraction(VectorNumberMult(VectorAddition(c, vCA), getT(c, vCA, b, General)), b)) <= 0 then
		return lineToorigin(c, vCA, General)
	else
		return -normal * getT(a, normal, {0, 0, 0}, General)
	end
end

--The distance function. Works like the intersect function above. Returns
--the translation vector between the two closest points.
function distance(s1, s2, sV, pointsa, pointsb, General)
	local function support (dir)
    local vec1 = s1(pointsa, dir)
    local vec2 = s2(pointsb, {-dir[1], -dir[2], -dir[3]})
		return {vec1[1] - vec2[1], vec1[2] - vec2[2], vec1[3] - vec2[3]}
	end

	--Find the initial three points in the search direction, opposite of the
	--search direction, and in the orthoginal direction between those two
	--points to the {0, 0, 0}.
	local a = support(sV)
	local b = support({-a[1], -a[2], -a[3]})
  local buff = closestPoint(a, b, nil, General)
	local c = support({-buff[1], -buff[2], -buff[3]})

	--Setup maximum loops
	local i = 1
	while i < 100 do
		i = i + 1

		--Get the closest point on the triangle
		local p = closestPoint(a, b, c, General)

		--If it is the {0, 0, 0}, the objects are just touching,
		--return a zero vector.
		if equals(p, {0, 0, 0}) then
			return {0, 0, 0}
		end

		--Search in the direction from the closest point
		--to the {0, 0, 0} for a point.
		local dir = unit(p, General)
		local d = support(dir)
		local dd = General.Library.DotProduct(d, dir)
		local dm = math.min(
			General.Library.DotProduct(a, dir),
			General.Library.DotProduct(b, dir),
			General.Library.DotProduct(c, dir)
		)

		--If the new point is farther or equal to the closest
		--point on the triangle, then we have found the closest
		--point.
		if dd >= dm then
			--return the point on the minkowski difference as the
			--translation vector between the two closest point.
			return {-p[1], -p[2], -p[3]}
		end

		--Otherwise replace the point on the triangle furthest
		--from the {0, 0, 0} with the new point
		local ma, mb, mc = General.Library.DotProduct(a, dir), General.Library.DotProduct(b, dir), General.Library.DotProduct(c, dir)
		if ma > mb then
			if ma > mc then
				a = d
			else
				c = d
			end
		elseif mb > mc then
			b = d
		else
			c = d
		end
	end

	--Return an error if no point was found in the maximum
	--number of iterations
	error 'Unable to find distance, are they intersecting?'
end
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
function GiveBack.Start(Space, AllDevices, AllDevicesGive, SDL, SDLGive, SDLInit, SDLInitGive, lgsl, lgslGive, ffi, ffiGive, General, GeneralGive, Power, PowerGive)
  function Space.Support(Points, dir)
    local MaxDot = General.Library.DotProduct({Points.data[0], Points.data[1], Points.data[2]}, dir)
    local Index = 0
    for i=1,3 do
      local Dot = General.Library.DotProduct({Points.data[i * 4], Points.data[i * 4 + 1], Points.data[i * 4 + 2]}, dir)
      if MaxDot < Dot then
        MaxDot = Dot
        Index = i
      end
    end
    return {Points.data[Index * 4], Points.data[Index * 4 + 1], Points.data[Index * 4 + 2]}
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
function GiveBack.Stop(Space, AllDevices, AllDevicesGive, SDL, SDLGive, SDLInit, SDLInitGive, lgsl, lgslGive, ffi, ffiGive, General, GeneralGive, Power, PowerGive)
	Space.LastTime = nil
  for k,v in pairs(AllDevices.Space.Devices) do
    for i,n in pairs(v.Objects) do
      lgsl.Library.gsl.gsl_matrix_free(n.Transformated)
    end
  end
end
function GiveBack.Physics(Space, AllDevices, AllDevicesGive, SDL, SDLGive, SDLInit, SDLInitGive, lgsl, lgslGive, ffi, ffiGive, General, GeneralGive, Power, PowerGive)
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
              if (i ~= e or k ~= a) --[[and (not (i == e and Joint(n.FixedJoints, k, a)))--]] and General.Library.SameLayer(v.PhysicsLayers, b.PhysicsLayers) and --[[CollisionBox(v, b) and ]]intersection(Space.Support, Space.Support, {0, 0, 0}, v.Transformated, b.Transformated, General) then
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

GiveBack.Requirements = {"AllDevices", "SDL", "SDLInit", "lgsl", "ffi", "General", "Power"}
return GiveBack
