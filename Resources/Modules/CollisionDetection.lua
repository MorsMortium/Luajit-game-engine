--Kevin's implementation of the Gilbert-Johnson-Keerthi intersection algorithm
--and the Expanding Polytope Algorithm
--Most useful references (Huge thanks to all the authors):
-- "Implementing GJK" by Casey Muratori:
-- The best description of the algorithm from the ground up
-- https://www.youtube.com/watch?v=Qupqu1xe7Io
-- "Implementing a GJK Intersection Query" by Phill Djonov
-- Interesting tips for implementing the algorithm
-- http:--vec3.ca/gjk/implementation/
-- "GJK Algorithm 3D" by Sergiu Craitoiu
-- Has nice diagrams to visualise the tetrahedral case
-- http://in2gpu.com/2014/05/18/gjk-algorithm-3d/
-- "GJK + Expanding Polytope Algorithm - Implementation and Visualization"
-- Good breakdown of EPA with demo for visualisation
-- https://www.youtube.com/watch?v=6rgiPrzqt9w
-------------------------------------------------------------------------------
local function MinusVector(a)
  return {-a[1], -a[2], -a[3]}
end
local function VectorCopy(c, o)
  c[1] = o[1]
  c[2] = o[2]
  c[3] = o[3]
end
local function VectorEqual(a, b)
  return a[1] == b[1] and a[2] == b[2] and a[3] == b[3]
end
local function Barycentric(p, a, b, c, General)
    local v0 = General.Library.VectorSubtraction(b, a)
    local v1 = General.Library.VectorSubtraction(c, a)
    local v2 = General.Library.VectorSubtraction(p, a)
    local d00 = General.Library.DotProduct(v0, v0)
    local d01 = General.Library.DotProduct(v0, v1)
    local d11 = General.Library.DotProduct(v1, v1)
    local d20 = General.Library.DotProduct(v2, v0)
    local d21 = General.Library.DotProduct(v2, v1)
    local denom = d00 * d11 - d01 * d01
    v = (d11 * d20 - d01 * d21) / denom
    w = (d00 * d21 - d01 * d20) / denom
    u = 1 - v - w
    return u, v, w
end
local function ExtrapolateContactInformation(aClosestFace, General)
	local distanceFromOrigin = General.Library.DotProduct(aClosestFace[4], aClosestFace[3]);
  local aContactData = {}
  aContactData[1] = General.Library.Normalise(aClosestFace[4])
	-- calculate the barycentric coordinates of the closest triangle with respect to
	-- the projection of the origin onto the triangle
	local bary_u, bary_v, bary_w = Barycentric(General.Library.VectorNumberMult(aClosestFace[4], distanceFromOrigin), aClosestFace[3], aClosestFace[2], aClosestFace[1], General);
	-- A Contact points
	local supportLocal1 = aClosestFace[3].supporta
	local supportLocal2 = aClosestFace[2].supporta
	local supportLocal3 = aClosestFace[1].supporta
	-- Contact point on object A in local space
	aContactData[2] = General.Library.VectorAddition(General.Library.VectorAddition(General.Library.VectorNumberMult(supportLocal1, bary_u), General.Library.VectorNumberMult(supportLocal2, bary_v)), General.Library.VectorNumberMult(supportLocal3, bary_w))
	-- B contact points
  supportLocal1 = aClosestFace[3].supportb
	supportLocal2 = aClosestFace[2].supportb
	supportLocal3 = aClosestFace[1].supportb
	-- Contact point on object B in local space
  aContactData[3] = General.Library.VectorAddition(General.Library.VectorAddition(General.Library.VectorNumberMult(supportLocal1, bary_u), General.Library.VectorNumberMult(supportLocal2, bary_v)), General.Library.VectorNumberMult(supportLocal3, bary_w))
  return aContactData;
end
local GiveBack = {}
--Internal functions used in the GJK algorithm
--Triangle case
local function update_simplex3(a, b, c, d, simp_dim, search_dir, General)
  -- Required winding order:
  --  b
  --  | \
  --  |   \
  --  |    a
  --  |   /
  --  | /
  --  c
  local n = General.Library.CrossProduct(General.Library.VectorSubtraction(b, a), General.Library.VectorSubtraction(c, a)); --triangle's normal
  local AO = MinusVector(a); --direction to origin
  --Determine which feature is closest to origin, make that the new simplex
  simp_dim[1] = 2;
  if(General.Library.DotProduct(General.Library.CrossProduct(General.Library.VectorSubtraction(b, a), n), AO)>0)then --Closest to edge AB
    VectorCopy(c, a);
    c.supporta = a.supporta
    c.supportb = a.supportb
    --simp_dim[1] = 2;
    VectorCopy(search_dir, General.Library.CrossProduct(General.Library.CrossProduct(General.Library.VectorSubtraction(b, a), AO), General.Library.VectorSubtraction(b, a)));
    return;
  end
  if(General.Library.DotProduct(General.Library.CrossProduct(n, General.Library.VectorSubtraction(c, a)), AO)>0)then --Closest to edge AC
    VectorCopy(b, a);
    b.supporta = a.supporta
    b.supportb = a.supportb
    --simp_dim[1] = 2;
    VectorCopy(search_dir, General.Library.CrossProduct(General.Library.CrossProduct(General.Library.VectorSubtraction(c, a), AO), General.Library.VectorSubtraction(c, a)));
    return;
  end
  simp_dim[1] = 3;
  if(General.Library.DotProduct(n, AO)>0)then --Above triangle
    VectorCopy(d, c);
    d.supporta = c.supporta
    d.supportb = c.supportb
    VectorCopy(c, b);
    c.supporta = b.supporta
    c.supportb = b.supportb
    VectorCopy(b, a);
    b.supporta = a.supporta
    b.supportb = a.supportb
    --simp_dim[1] = 3;
    VectorCopy(search_dir, n);
    return;
  end
  --else --Below triangle
  VectorCopy(d, b);
  d.supporta = b.supporta
  d.supportb = b.supportb
  VectorCopy(b, a);
  b.supporta = a.supporta
  b.supportb = a.supportb
  --simp_dim[1] = 3;
  VectorCopy(search_dir, MinusVector(n));
  return;
end
--Tetrahedral case
local function update_simplex4(a, b, c, d, simp_dim, search_dir, General)
  -- a is peak/tip of pyramid, BCD is the base (counterclockwise winding order)
	--We know a priori that origin is above BCD and below a
  --Get normals of three new faces
  local ABC = General.Library.CrossProduct(General.Library.VectorSubtraction(b, a), General.Library.VectorSubtraction(c, a));
  local ACD = General.Library.CrossProduct(General.Library.VectorSubtraction(c, a), General.Library.VectorSubtraction(d, a));
  local ADB = General.Library.CrossProduct(General.Library.VectorSubtraction(d, a), General.Library.VectorSubtraction(b, a));
  local AO = MinusVector(a); --dir to origin
  simp_dim[1] = 3; --hoisting this just cause
  --Plane-test origin with 3 faces
  -- Note: Kind of primitive approach used here; If origin is in front of a face, just use it as the new simplex.
  -- We just go through the faces sequentially and exit at the first one which satisfies dot product. Not sure this
  -- is optimal or if edges should be considered as possible simplices? Thinking this through in my head I feel like
  -- this method is good enough. Makes no difference for AABBS, should test with more complex colliders.
  if(General.Library.DotProduct(ABC, AO)>0)then --In front of ABC
  	VectorCopy(d, c);
    d.supporta = c.supporta
    d.supportb = c.supportb
  	VectorCopy(c, b);
    c.supporta = b.supporta
    c.supportb = b.supportb
  	VectorCopy(b, a);
    b.supporta = a.supporta
    b.supportb = a.supportb
    VectorCopy(search_dir, ABC);
  	return false;
  end
  if(General.Library.DotProduct(ACD, AO)>0)then --In front of ACD
  	VectorCopy(b, a);
    b.supporta = a.supporta
    b.supportb = a.supportb
    VectorCopy(search_dir, ACD);
  	return false;
  end
  if(General.Library.DotProduct(ADB, AO)>0)then --In front of ADB
  	VectorCopy(c, d);
    c.supporta = d.supporta
    c.supportb = d.supportb
  	VectorCopy(d, b);
    d.supporta = b.supporta
    d.supportb = b.supportb
  	VectorCopy(b, a);
    b.supporta = a.supporta
    b.supportb = a.supportb
    VectorCopy(search_dir, ADB);
  	return false;
  end
  --else inside tetrahedron; enclosed!
  return true;
  --Note: in the case where two of the faces have similar normals,
  --The origin could conceivably be closest to an edge on the tetrahedron
  --Right now I don't think it'll make a difference to limit our new simplices
  --to just one of the faces, maybe test it later.
end
local function Support(object, dir, General)
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
--Expanding Polytope Algorithm. Used to find the mtv of two intersecting
--colliders using the final simplex obtained with the GJK algorithm
--Expanding Polytope Algorithm
--Find minimum translation vector to resolve collision
local EPA_TOLERANCE = 0.0001
local EPA_MAX_NUM_FACES = 64
local EPA_MAX_NUM_LOOSE_EDGES = 32
local EPA_MAX_NUM_ITERATIONS = 64
function GiveBack.EPA(a, b, c, d, coll1, coll2, General)
  local faces = {}--[EPA_MAX_NUM_FACES][4]; --Array of faces, each with 3 verts and a normal
  --Init with final simplex from GJK
  faces[1] = {a, b, c, General.Library.Normalise(General.Library.CrossProduct(General.Library.VectorSubtraction(b, a), General.Library.VectorSubtraction(c, a)))}--ABC
  faces[2] = {a, c, d, General.Library.Normalise(General.Library.CrossProduct(General.Library.VectorSubtraction(c, a), General.Library.VectorSubtraction(d, a)))}--ACD
  faces[3] = {a, d, b, General.Library.Normalise(General.Library.CrossProduct(General.Library.VectorSubtraction(d, a), General.Library.VectorSubtraction(b, a)))}--ADB
  faces[4] = {b, d, c, General.Library.Normalise(General.Library.CrossProduct(General.Library.VectorSubtraction(d, b), General.Library.VectorSubtraction(c, b)))}--BDC
  for i=5,EPA_MAX_NUM_FACES do
    faces[i] = {} --[4]
  end
  local num_faces=4;
  local closest_face;
  for iterations=1, EPA_MAX_NUM_ITERATIONS do
    --Find face that's closest to origin
    local min_dist = General.Library.DotProduct(faces[1][1], faces[1][4]);
    closest_face = 1;
    for i=2, num_faces do
      local dist = General.Library.DotProduct(faces[i][1], faces[i][4]);
      if(dist<min_dist)then
        min_dist = dist;
        closest_face = i;
      end
    end
    --search normal to face that's closest to origin
    local search_dir = faces[closest_face][4];
    local p = General.Library.VectorSubtraction(Support(coll2, search_dir, General), Support(coll1, MinusVector(search_dir), General));
    p.supporta = Support(coll1, MinusVector(search_dir), General)
    p.supportb = Support(coll2, search_dir, General)
    if(General.Library.DotProduct(p, search_dir)-min_dist<EPA_TOLERANCE)then
      --Convergence (new point is not significantly further from origin)
      local contactdata = ExtrapolateContactInformation(faces[closest_face], General)
      return General.Library.VectorNumberMult(faces[closest_face][3], General.Library.DotProduct(p, search_dir)), contactdata[1], contactdata[2], contactdata[3] --dot vertex with normal to resolve collision along normal!
    end
    local loose_edges = {}--[EPA_MAX_NUM_LOOSE_EDGES][2]; --keep track of edges we need to fix after removing faces
    for i=1,EPA_MAX_NUM_LOOSE_EDGES do
      loose_edges[i] = {}--[2]
    end
    local num_loose_edges = 0;
    --Find all triangles that are facing p
    local i = 1
    while i <= num_faces do
      if(General.Library.DotProduct(faces[i][4], General.Library.VectorSubtraction(p, faces[i][1] ))>0) then--triangle i faces p, remove it
        --Add removed triangle's edges to loose edge list.
        --If it's already there, remove it (both triangles it belonged to are gone)
        for j=1, 3 do--Three edges per face
          local current_edge = {faces[i][j], faces[i][j%3 + 1]};
          local found_edge = false;
          local k = 1
          while k <= num_loose_edges do--Check if current edge is already in list
            if(VectorEqual(loose_edges[k][2],current_edge[1]) and VectorEqual(loose_edges[k][1], current_edge[2]))then
              --Edge is already in the list, remove it
              --THIS ASSUMES EDGE CAN ONLY BE SHARED BY 2 TRIANGLES (which should be true)
              --THIS ALSO ASSUMES SHARED EDGE WILL BE REVERSED IN THE TRIANGLES (which
              --should be true provided every triangle is wound CCW)
              loose_edges[k][1] = loose_edges[num_loose_edges][1]; --Overwrite current edge
              loose_edges[k][2] = loose_edges[num_loose_edges][2]; --with last edge in list
              num_loose_edges = num_loose_edges - 1;
              found_edge = true;
              k = num_loose_edges + 1; --exit loop because edge can only be shared once
            end
            k = k + 1
          end--endfor loose_edges
          k = nil
          if(not found_edge)then --add current edge to list
            -- assert(num_loose_edges<EPA_MAX_NUM_LOOSE_EDGES);
            if(num_loose_edges>=EPA_MAX_NUM_LOOSE_EDGES) then break; end
            num_loose_edges = num_loose_edges + 1;
            loose_edges[num_loose_edges][1] = current_edge[1];
            loose_edges[num_loose_edges][2] = current_edge[2];
          end
        end
        --Remove triangle i from list
        faces[i][1] = faces[num_faces][1];
        faces[i][2] = faces[num_faces][2];
        faces[i][3] = faces[num_faces][3];
        faces[i][4] = faces[num_faces][4];
        num_faces = num_faces - 1;
        i = i - 1
      end--endif p can see triangle i
      i = i + 1
    end--endfor num_faces
    i = nil
    --Reconstruct polytope with p added
    for i=1, num_loose_edges do
      -- assert(num_faces<EPA_MAX_NUM_FACES);
      if(num_faces>=EPA_MAX_NUM_FACES) then break; end
      num_faces = num_faces + 1;
      faces[num_faces][1] = loose_edges[i][1];
      faces[num_faces][2] = loose_edges[i][2];
      faces[num_faces][3] = p;
      faces[num_faces][4] = General.Library.Normalise(General.Library.CrossProduct(General.Library.VectorSubtraction(loose_edges[i][1], loose_edges[i][2]), General.Library.VectorSubtraction(loose_edges[i][1], p)));
      --Check for wrong normal to maintain CCW winding
      local bias = 0.000001; --in case dot result is only slightly < 0 (because origin is on face)
      if(General.Library.DotProduct(faces[num_faces][1], faces[num_faces][4])+bias < 0) then
        local temp = faces[num_faces][1];
        faces[num_faces][1] = faces[num_faces][2];
        faces[num_faces][2] = temp;
        faces[num_faces][4] = MinusVector(faces[num_faces][4]);
      end
    end
  end --End for iterations
    print("EPA did not converge");
    --Return most recent closest point
    local contactdata = ExtrapolateContactInformation(faces[closest_face], General)
    return General.Library.VectorNumberMult(faces[closest_face][3], General.Library.DotProduct(faces[closest_face][1], faces[closest_face][3])), contactdata[1], contactdata[2], contactdata[3], true
end
local GJK_MAX_NUM_ITERATIONS = 64
--Returns true if two colliders are intersecting. Has optional Minimum Translation Vector output param;
--If supplied the EPA will be used to find the vector to separate coll1 from coll2
function GiveBack.GJK(coll1, coll2, mtv, Arguments)--(Collider* coll1, Collider* coll2, vec3* mtv=NULL);
  local General = Arguments[1]
  local a, b, c, d = {}, {}, {}, {}; --Simplex: just a set of points (a is always most recently added)
  local search_dir = General.Library.VectorSubtraction(coll1.Translation, coll2.Translation); --initial search direction between colliders
  --Get initial point for simplex
  c = General.Library.VectorSubtraction(Support(coll2, search_dir, General), Support(coll1, MinusVector(search_dir), General))
  c.supporta = Support(coll1, MinusVector(search_dir), General)
  c.supportb = Support(coll2, search_dir, General)
  search_dir = MinusVector(c); --search in direction of origin
  --Get second point for a line segment simplex
  b = General.Library.VectorSubtraction(Support(coll2, search_dir, General), Support(coll1, MinusVector(search_dir), General))
  b.supporta = Support(coll1, MinusVector(search_dir), General)
  b.supportb = Support(coll2, search_dir, General)
  if(General.Library.DotProduct(b, search_dir)<0) then return false; end--we didn't reach the origin, won't enclose it
  search_dir = General.Library.CrossProduct(General.Library.CrossProduct(General.Library.VectorSubtraction(c, b),MinusVector(b)),General.Library.VectorSubtraction(c, b)); --search perpendicular to line segment towards origin
  if(search_dir=={0,0,0})then --origin is on this line segment
    --Apparently any normal search vector will do?
    search_dir = General.Library.CrossProduct(General.Library.VectorSubtraction(c, b), {1,0,0}); --normal with x-axis
    if(search_dir=={0,0,0}) then search_dir = General.Library.CrossProduct(General.Library.VectorSubtraction(c, b), {0,0,-1});end --normal with z-axis
  end
  local simp_dim = {2}; --simplex dimension
  for iterations=1, GJK_MAX_NUM_ITERATIONS do
    a = General.Library.VectorSubtraction(Support(coll2, search_dir, General), Support(coll1, MinusVector(search_dir), General))
    a.supporta = Support(coll1, MinusVector(search_dir), General)
    a.supportb = Support(coll2, search_dir, General)
    if(General.Library.DotProduct(a, search_dir)<0)then return false end--we didn't reach the origin, won't enclose it
    simp_dim[1] = simp_dim[1] + 1
    if(simp_dim[1]==3) then
      update_simplex3(a,b,c,d,simp_dim,search_dir, General);
    elseif(update_simplex4(a,b,c,d,simp_dim,search_dir, General)) then
      if mtv then
        local EPAFailed = false
        mtv[1], mtv[2], mtv[3], mtv[4], EPAFailed = GiveBack.EPA(a,b,c,d,coll1,coll2, General)
        if EPAFailed then
          return false
        end
      end
      return true;
    end
  end--endfor
  return false;
end
function GiveBack.CollisionSphere(FirstObject, SecondObject, General, IfEquals)
  local Distance = General.Library.VectorLength(General.Library.PointAToB(FirstObject.Translation, SecondObject.Translation))
  local SumRadius = FirstObject.Radius + SecondObject.Radius
  if IfEquals then
    return Distance <= SumRadius
  else
    return Distance < SumRadius
  end
end
local function SortX(Object1, Object2)
  if Object1.Translation[1] - Object1.Radius < Object2.Translation[1] - Object2.Radius then
    return true
  end
end
local function SortY(Object1, Object2)
  if Object1.Translation[2] - Object1.Radius < Object2.Translation[2] - Object2.Radius then
    return true
  end
end
local function SortZ(Object1, Object2)
  if Object1.Translation[3] - Object1.Radius < Object2.Translation[3] - Object2.Radius then
    return true
  end
end
local function SortByNumberOfElements(List1, List2)
  if #List1 < #List2 then
    return true
  end
end
function GiveBack.CheckForCollisions(AllDevices, BroadPhaseAxes, Arguments)
  local General, CollisionResponse, CollisionResponseGive = Arguments[1],
    Arguments[3], Arguments[4]
  for ak=1,#AllDevices.Space.CreatedDevices do
    local av = AllDevices.Space.CreatedDevices[ak]
    for bk=1,3 do
      local bv = BroadPhaseAxes[bk]
      bv[#bv + 1] = av
    end
  end
  for ak=1,#AllDevices.Space.DestroyedDevices do
    local av = AllDevices.Space.DestroyedDevices[ak]
    for bk=1,3 do
      local bv = BroadPhaseAxes[bk]
      for ck=1,#bv do
        local cv = bv[ck]
        if cv == av then
          table.remove(bv, ck)
        end
      end
    end
  end
  table.sort(BroadPhaseAxes[1], SortX)
  table.sort(BroadPhaseAxes[2], SortY)
  table.sort(BroadPhaseAxes[3], SortZ)
  local PossibleCollisions = {{}, {}, {}}
  for ak=1,3 do
    local ActiveList = {}
    local av = BroadPhaseAxes[ak]
    for bk=1,#av do
      local bv = av[bk]
      local ck = 1
    	while ck <= #ActiveList do
    		local cv = ActiveList[ck]
    		local Exit = false
        if cv.Translation[ak] + cv.Radius < bv.Translation[ak] - bv.Radius then
          table.remove(ActiveList, ck)
          Exit = true
        else
          if PossibleCollisions[ak][bv] then
            PossibleCollisions[ak][bv][cv] = true
          else
            PossibleCollisions[ak][bv] = {}
            PossibleCollisions[ak][bv][cv] = true
          end
        end
    		if not Exit then ck = ck + 1 end
    	end
      ActiveList[#ActiveList + 1] = bv
    end
  end
  table.sort(PossibleCollisions, SortByNumberOfElements)
  local RealCollisions = {}
  for ak,av in pairs(PossibleCollisions[1]) do
    for bk,bv in pairs(av) do
      if PossibleCollisions[2][ak] and PossibleCollisions[2][ak][bk]
        and PossibleCollisions[3][ak] and PossibleCollisions[3][ak][bk] then
        RealCollisions[#RealCollisions + 1] = {ak, bk}
      end
    end
  end
  for ak=1,#RealCollisions do
    local av = RealCollisions[ak]
    if General.Library.SameLayer(av[1].PhysicsLayers, av[2].PhysicsLayers) then
      for ck=1,#av[1].Objects do
        local cv = av[1].Objects[ck]
        for dk=1,#av[2].Objects do
          local dv = av[2].Objects[dk]
          local mtv = {}
          if (ak ~= bk or ck ~= dk)
          --[[and (not (ak == bk and Joint(av.FixedJoints, ck, dk)))--]] and
          GiveBack.CollisionSphere(cv, dv, General) and
          General.Library.SameLayer(cv.PhysicsLayers, dv.PhysicsLayers) and
          GiveBack.GJK(cv, dv, mtv, Arguments) then
            ---[[
            if (av[1].Name == "Bullet" and av[2].Name == "Asteroid") or
            (av[2].Name == "Bullet" and av[1].Name == "Asteroid") or
            (av[1].Name == "SpaceShip" and av[2].Name == "Asteroid") or
            (av[2].Name == "SpaceShip" and av[1].Name == "Asteroid") or
            (av[1].Name == "Asteroid" and av[2].Name == "Asteroid") then
              dv.Powers[1].Active = true
              cv.Powers[1].Active = true
              if (av[1].Name == "Bullet" and av[2].Name == "Asteroid") or
              (av[2].Name == "Bullet" and av[1].Name == "Asteroid") then
                Score = Score + 1
              end
            end
            --]]
            CollisionResponse.Library.ResponseWithoutTorque(cv, dv, mtv, CollisionResponseGive)
            --TODO
            --print(ak.." Device "..ck.." Object collided with "..bk.." Device "..dk.." Object")
          else
            --print(ak.." Device "..ck.." Object did not collided with "..bk.." Device "..dk.." Object")
          end
        end
      end
    end
  end
end
GiveBack.Requirements = {"General", "CollisionResponse"}
return GiveBack
