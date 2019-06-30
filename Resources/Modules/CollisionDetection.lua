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
local function VectorCopy(c, o)
  c[1] = o[1]
  c[2] = o[2]
  c[3] = o[3]
end
local function Barycentric(p, a, b, c, General)
  local VectorSubtraction = General.Library.VectorSubtraction
  local DotProduct = General.Library.DotProduct
  local v0 = VectorSubtraction(b, a)
  local v1 = VectorSubtraction(c, a)
  local v2 = VectorSubtraction(p, a)
  local d00 = DotProduct(v0, v0)
  local d01 = DotProduct(v0, v1)
  local d11 = DotProduct(v1, v1)
  local d20 = DotProduct(v2, v0)
  local d21 = DotProduct(v2, v1)
  local denom = d00 * d11 - d01 * d01
  local v = (d11 * d20 - d01 * d21) / denom
  local w = (d00 * d21 - d01 * d20) / denom
  local u = 1 - v - w
  return u, v, w
end
local function ExtrapolateContactInformation(aClosestFace, General)
  local DotProduct = General.Library.DotProduct
  local VectorNumberMult = General.Library.VectorNumberMult
  local VectorAddition = General.Library.VectorAddition
	local distanceFromOrigin = DotProduct(aClosestFace[4], aClosestFace[1]);
  local aContactData = {}
  aContactData[1] = General.Library.Normalise(aClosestFace[4])
	-- calculate the barycentric coordinates of the closest triangle with respect to
	-- the projection of the origin onto the triangle
	local bary_u, bary_v, bary_w = Barycentric(VectorNumberMult(aClosestFace[4], distanceFromOrigin), aClosestFace[1], aClosestFace[2], aClosestFace[3], General);
  -- A Contact points
	local supportLocal1 = aClosestFace[1].supporta
	local supportLocal2 = aClosestFace[2].supporta
	local supportLocal3 = aClosestFace[3].supporta
	-- Contact point on object A in local space
	aContactData[2] = VectorAddition(VectorAddition(VectorNumberMult(supportLocal1, bary_u), VectorNumberMult(supportLocal2, bary_v)), VectorNumberMult(supportLocal3, bary_w))
	-- B contact points
  supportLocal1 = aClosestFace[1].supportb
	supportLocal2 = aClosestFace[2].supportb
	supportLocal3 = aClosestFace[3].supportb
	-- Contact point on object B in local space
  aContactData[3] = VectorAddition(VectorAddition(VectorNumberMult(supportLocal1, bary_u), VectorNumberMult(supportLocal2, bary_v)), VectorNumberMult(supportLocal3, bary_w))
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
  local CrossProduct = General.Library.CrossProduct
  local VectorSubtraction = General.Library.VectorSubtraction
  local DotProduct = General.Library.DotProduct
  local MinusVector = General.Library.MinusVector
  --triangle's normal
  local n = CrossProduct(VectorSubtraction(b, a), VectorSubtraction(c, a))
  local AO = MinusVector(a) --direction to origin
  --Determine which feature is closest to origin, make that the new simplex
  simp_dim[1] = 2
   --Closest to edge AB
  if DotProduct(CrossProduct(VectorSubtraction(b, a), n), AO) > 0 then
    VectorCopy(c, a)
    c.supporta = a.supporta
    c.supportb = a.supportb
    --simp_dim[1] = 2
    VectorCopy(search_dir, CrossProduct(CrossProduct(VectorSubtraction(b, a), AO), VectorSubtraction(b, a)))
    return
  end
  --Closest to edge AC
  if DotProduct(CrossProduct(n, VectorSubtraction(c, a)), AO) > 0 then
    VectorCopy(b, a)
    b.supporta = a.supporta
    b.supportb = a.supportb
    --simp_dim[1] = 2
    VectorCopy(search_dir, CrossProduct(CrossProduct(VectorSubtraction(c, a), AO), VectorSubtraction(c, a)))
    return
  end
  simp_dim[1] = 3
  if DotProduct(n, AO) > 0 then --Above triangle
    VectorCopy(d, c)
    d.supporta = c.supporta
    d.supportb = c.supportb
    VectorCopy(c, b)
    c.supporta = b.supporta
    c.supportb = b.supportb
    VectorCopy(b, a)
    b.supporta = a.supporta
    b.supportb = a.supportb
    --simp_dim[1] = 3
    VectorCopy(search_dir, n)
    return
  end
  --else --Below triangle
  VectorCopy(d, b)
  d.supporta = b.supporta
  d.supportb = b.supportb
  VectorCopy(b, a)
  b.supporta = a.supporta
  b.supportb = a.supportb
  --simp_dim[1] = 3
  VectorCopy(search_dir, MinusVector(n))
  return
end
--Tetrahedral case
local function update_simplex4(a, b, c, d, simp_dim, search_dir, General)
  -- a is peak/tip of pyramid, BCD is the base (counterclockwise winding order)
	--We know a priori that origin is above BCD and below a
  --Get normals of three new faces
  local CrossProduct = General.Library.CrossProduct
  local VectorSubtraction = General.Library.VectorSubtraction
  local DotProduct = General.Library.DotProduct
  local MinusVector = General.Library.MinusVector
  local ABC = CrossProduct(VectorSubtraction(b, a), VectorSubtraction(c, a))
  local ACD = CrossProduct(VectorSubtraction(c, a), VectorSubtraction(d, a))
  local ADB = CrossProduct(VectorSubtraction(d, a), VectorSubtraction(b, a))
  local AO = MinusVector(a) --dir to origin
  simp_dim[1] = 3 --hoisting this just cause
  --Plane-test origin with 3 faces
  -- Note: Kind of primitive approach used here; If origin is in front of a face, just use it as the new simplex.
  -- We just go through the faces sequentially and exit at the first one which satisfies dot product. Not sure this
  -- is optimal or if edges should be considered as possible simplices? Thinking this through in my head I feel like
  -- this method is good enough. Makes no difference for AABBS, should test with more complex colliders.
  if DotProduct(ABC, AO) > 0 then --In front of ABC
  	VectorCopy(d, c)
    d.supporta = c.supporta
    d.supportb = c.supportb
  	VectorCopy(c, b)
    c.supporta = b.supporta
    c.supportb = b.supportb
  	VectorCopy(b, a)
    b.supporta = a.supporta
    b.supportb = a.supportb
    VectorCopy(search_dir, ABC)
  	return false
  end
  if DotProduct(ACD, AO) > 0 then --In front of ACD
  	VectorCopy(b, a)
    b.supporta = a.supporta
    b.supportb = a.supportb
    VectorCopy(search_dir, ACD)
  	return false
  end
  if DotProduct(ADB, AO) > 0 then --In front of ADB
  	VectorCopy(c, d)
    c.supporta = d.supporta
    c.supportb = d.supportb
  	VectorCopy(d, b)
    d.supporta = b.supporta
    d.supportb = b.supportb
  	VectorCopy(b, a)
    b.supporta = a.supporta
    b.supportb = a.supportb
    VectorCopy(search_dir, ADB)
  	return false
  end
  --else inside tetrahedron; enclosed!
  return true
  --Note: in the case where two of the faces have similar normals,
  --The origin could conceivably be closest to an edge on the tetrahedron
  --Right now I don't think it'll make a difference to limit our new simplices
  --to just one of the faces, maybe test it later.
end
local function Support(object, dir, General)
  local DotProduct = General.Library.DotProduct
  local maxdot = DotProduct({object.Transformated.data[0], object.Transformated.data[1], object.Transformated.data[2]}, dir)
  local index = 0
  for i=1,3 do
    local dot = DotProduct({object.Transformated.data[i * 4], object.Transformated.data[i * 4 + 1], object.Transformated.data[i * 4 + 2]}, dir)
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
  local faces = {}--[EPA_MAX_NUM_FACES][4] --Array of faces, each with 3 verts and a normal
  --Init with final simplex from GJK
  local Normalise = General.Library.Normalise
  local CrossProduct = General.Library.CrossProduct
  local VectorSubtraction = General.Library.VectorSubtraction
  local DotProduct = General.Library.DotProduct
  local VectorNumberMult = General.Library.VectorNumberMult
  local VectorEqual = General.Library.VectorEqual
  local MinusVector = General.Library.MinusVector
  faces[1] = {a, b, c, Normalise(CrossProduct(VectorSubtraction(b, a), VectorSubtraction(c, a)))}--ABC
  faces[2] = {a, c, d, Normalise(CrossProduct(VectorSubtraction(c, a), VectorSubtraction(d, a)))}--ACD
  faces[3] = {a, d, b, Normalise(CrossProduct(VectorSubtraction(d, a), VectorSubtraction(b, a)))}--ADB
  faces[4] = {b, d, c, Normalise(CrossProduct(VectorSubtraction(d, b), VectorSubtraction(c, b)))}--BDC
  for i=5,EPA_MAX_NUM_FACES do
    faces[i] = {} --[4]
  end
  local num_faces=4
  local closest_face
  for iterations=1, EPA_MAX_NUM_ITERATIONS do
    --Find face that's closest to origin
    local min_dist = DotProduct(faces[1][1], faces[1][4])
    closest_face = 1
    for i=2, num_faces do
      local dist = DotProduct(faces[i][1], faces[i][4])
      if(dist<min_dist)then
        min_dist = dist
        closest_face = i
      end
    end
    --search normal to face that's closest to origin
    local search_dir = faces[closest_face][4]
    local p = VectorSubtraction(Support(coll2, search_dir, General), Support(coll1, MinusVector(search_dir), General))
    p.supporta = Support(coll1, MinusVector(search_dir), General)
    p.supportb = Support(coll2, search_dir, General)
    if DotProduct(p, search_dir)-min_dist < EPA_TOLERANCE then
      --Convergence (new point is not significantly further from origin)
      local contactdata = ExtrapolateContactInformation(faces[closest_face], General)
      return VectorNumberMult(faces[closest_face][3], DotProduct(p, search_dir)), contactdata[1], contactdata[2], contactdata[3] --dot vertex with normal to resolve collision along normal!
    end
    local loose_edges = {}--[EPA_MAX_NUM_LOOSE_EDGES][2] --keep track of edges we need to fix after removing faces
    for i=1,EPA_MAX_NUM_LOOSE_EDGES do
      loose_edges[i] = {}--[2]
    end
    local num_loose_edges = 0
    --Find all triangles that are facing p
    local i = 1
    while i <= num_faces do
      if DotProduct(faces[i][4], VectorSubtraction(p, faces[i][1] )) > 0 then--triangle i faces p, remove it
        --Add removed triangle's edges to loose edge list.
        --If it's already there, remove it (both triangles it belonged to are gone)
        for j=1, 3 do--Three edges per face
          local current_edge = {faces[i][j], faces[i][j%3 + 1]}
          local found_edge = false
          local k = 1
          while k <= num_loose_edges do--Check if current edge is already in list
            if VectorEqual(loose_edges[k][2],current_edge[1]) and VectorEqual(loose_edges[k][1], current_edge[2]) then
              --Edge is already in the list, remove it
              --THIS ASSUMES EDGE CAN ONLY BE SHARED BY 2 TRIANGLES (which should be true)
              --THIS ALSO ASSUMES SHARED EDGE WILL BE REVERSED IN THE TRIANGLES (which
              --should be true provided every triangle is wound CCW)
              loose_edges[k][1] = loose_edges[num_loose_edges][1] --Overwrite current edge
              loose_edges[k][2] = loose_edges[num_loose_edges][2] --with last edge in list
              num_loose_edges = num_loose_edges - 1
              found_edge = true
              k = num_loose_edges + 1 --exit loop because edge can only be shared once
            end
            k = k + 1
          end--endfor loose_edges
          k = nil
          if not found_edge then --add current edge to list
            -- assert(num_loose_edges<EPA_MAX_NUM_LOOSE_EDGES)
            if num_loose_edges>=EPA_MAX_NUM_LOOSE_EDGES then break end
            num_loose_edges = num_loose_edges + 1
            loose_edges[num_loose_edges][1] = current_edge[1]
            loose_edges[num_loose_edges][2] = current_edge[2]
          end
        end
        --Remove triangle i from list
        faces[i][1] = faces[num_faces][1]
        faces[i][2] = faces[num_faces][2]
        faces[i][3] = faces[num_faces][3]
        faces[i][4] = faces[num_faces][4]
        num_faces = num_faces - 1
        i = i - 1
      end--endif p can see triangle i
      i = i + 1
    end--endfor num_faces
    i = nil
    --Reconstruct polytope with p added
    for i=1, num_loose_edges do
      -- assert(num_faces<EPA_MAX_NUM_FACES)
      if num_faces >= EPA_MAX_NUM_FACES then break end
      num_faces = num_faces + 1
      faces[num_faces][1] = loose_edges[i][1]
      faces[num_faces][2] = loose_edges[i][2]
      faces[num_faces][3] = p
      faces[num_faces][4] = Normalise(CrossProduct(VectorSubtraction(loose_edges[i][1], loose_edges[i][2]), VectorSubtraction(loose_edges[i][1], p)))
      --Check for wrong normal to maintain CCW winding
      local bias = 0.000001 --in case dot result is only slightly < 0 (because origin is on face)
      if DotProduct(faces[num_faces][1], faces[num_faces][4])+bias < 0 then
        local temp = faces[num_faces][1]
        faces[num_faces][1] = faces[num_faces][2]
        faces[num_faces][2] = temp
        faces[num_faces][4] = MinusVector(faces[num_faces][4])
      end
    end
  end --End for iterations
    print("EPA did not converge")
    --Return most recent closest point
    local contactdata = ExtrapolateContactInformation(faces[closest_face], General)
    return VectorNumberMult(faces[closest_face][3], DotProduct(faces[closest_face][1], faces[closest_face][3])), contactdata[1], contactdata[2], contactdata[3], true
end
local GJK_MAX_NUM_ITERATIONS = 64
--Returns true if two colliders are intersecting. Has optional Minimum Translation Vector output param;
--If supplied the EPA will be used to find the vector to separate coll1 from coll2
function GiveBack.GJK(coll1, coll2, mtv, Arguments)--(Collider* coll1, Collider* coll2, vec3* mtv=NULL)
  local General = Arguments[1]
  local VectorSubtraction = General.Library.VectorSubtraction
  local DotProduct = General.Library.DotProduct
  local CrossProduct = General.Library.CrossProduct
  local VectorEqual = General.Library.VectorEqual
  local MinusVector = General.Library.MinusVector
  local a, b, c, d = {}, {}, {}, {} --Simplex: just a set of points (a is always most recently added)
  local search_dir = VectorSubtraction(coll1.Translation, coll2.Translation) --initial search direction between colliders
  --Get initial point for simplex
  c = VectorSubtraction(Support(coll2, search_dir, General), Support(coll1, MinusVector(search_dir), General))
  c.supporta = Support(coll1, MinusVector(search_dir), General)
  c.supportb = Support(coll2, search_dir, General)
  search_dir = MinusVector(c) --search in direction of origin
  --Get second point for a line segment simplex
  b = VectorSubtraction(Support(coll2, search_dir, General), Support(coll1, MinusVector(search_dir), General))
  b.supporta = Support(coll1, MinusVector(search_dir), General)
  b.supportb = Support(coll2, search_dir, General)
  if DotProduct(b, search_dir) < 0 then return false end--we didn't reach the origin, won't enclose it
  search_dir = CrossProduct(CrossProduct(VectorSubtraction(c, b),MinusVector(b)),VectorSubtraction(c, b)) --search perpendicular to line segment towards origin
  if VectorEqual(search_dir, {0, 0, 0}) then --origin is on this line segment
    --Apparently any normal search vector will do?
    search_dir = CrossProduct(VectorSubtraction(c, b), {1,0,0}) --normal with x-axis
    if VectorEqual(search_dir, {0, 0, 0}) then
      search_dir = CrossProduct(VectorSubtraction(c, b), {0,0,-1})
    end --normal with z-axis
  end
  local simp_dim = {2} --simplex dimension
  for iterations=1, GJK_MAX_NUM_ITERATIONS do
    a = VectorSubtraction(Support(coll2, search_dir, General), Support(coll1, MinusVector(search_dir), General))
    a.supporta = Support(coll1, MinusVector(search_dir), General)
    a.supportb = Support(coll2, search_dir, General)
    if DotProduct(a, search_dir) < 0 then return false end--we didn't reach the origin, won't enclose it
    simp_dim[1] = simp_dim[1] + 1
    if simp_dim[1] == 3 then
      update_simplex3(a,b,c,d,simp_dim,search_dir, General)
    elseif(update_simplex4(a,b,c,d,simp_dim,search_dir, General)) then
      if mtv then
        local EPAFailed = false
        mtv[1], mtv[2], mtv[3], mtv[4], EPAFailed = GiveBack.EPA(a,b,c,d,coll1,coll2, General)
        if EPAFailed then
          return false
        end
      end
      return true
    end
  end--endfor
  return false
end

--Sorting functions for sweep and prune Broad Phase collision detection
local function SortX(Object1, Object2)
  if Object1.Min[1] < Object2.Min[1] then return true end
end
local function SortY(Object1, Object2)
  if Object1.Min[2] < Object2.Min[2] then return true end
end
local function SortZ(Object1, Object2)
  if Object1.Min[3] < Object2.Min[3] then return true end
end
local Sorts = {SortX, SortY, SortZ}
local function SortList(List1, List2)
  if List1.Counter < List2.Counter then return true end
end

--Faster than lua's quicksort
--TODO:Timsort
local function InsertionSort(Array, Command)
    local Length = #Array
    local ak
    for ak = 2, Length do
        local av = Array[ak]
        local bk = ak - 1
        while bk > 0 and Command(av, Array[bk]) do
            Array[bk + 1] = Array[bk]
            bk = bk - 1
        end
        Array[bk + 1] = av
    end
end

function GiveBack.DetectCollisions(AllDevices, BroadPhaseAxes, Arguments)
  local General = Arguments[1]
  local SameLayer = General.Library.SameLayer
  local remove = table.remove
  local pairs = pairs
  local sort = table.sort
  local PossibleCollisions = {{}, {}, {}}

  for ak=1,3 do
    local av = BroadPhaseAxes[ak]

    --Updates lists of objects
    local bk = 1
    while bk <= #av do
      local bv = av[bk]
      if bv.Parent == nil then remove(av, bk) else bk = bk + 1 end
    end
    bk = nil
    for bk=1,#AllDevices.Space.CreatedObjects do
      local bv = AllDevices.Space.CreatedObjects[bk]
      av[#av + 1] = bv
    end

    --Sorts lists
    InsertionSort(av, Sorts[ak])

    --Finds collision on each axes
    local av2 = PossibleCollisions[ak]
    av2.Counter = 1
    local ActiveList = {av[1]}
    for bk=2,#av do
      local bv = av[bk]
      local ck = 1
      while ck <= #ActiveList do
        local cv = ActiveList[ck]
        if cv.Max[ak] < bv.Min[ak] then
          remove(ActiveList, ck)
        else
          if av2[bv] == nil then av2[bv] = {} end
          av2[bv][cv] = true
          av2.Counter = av2.Counter + 1
          ck = ck + 1
        end
      end
      ActiveList[#ActiveList + 1] = bv
    end
  end

  --Sorts the lists of collisions on each axes by their number for less checks
  sort(PossibleCollisions, SortList)

  --Deletes Counters to not cause error with pairs
  for ak=1,3 do
    PossibleCollisions[ak].Counter = nil
  end

  --Finds collisions present on all axes
  local BroadCollisions = {}
  for ak,av in pairs(PossibleCollisions[1]) do
    for bk,bv in pairs(av) do
      if ((PossibleCollisions[2][ak] and PossibleCollisions[2][ak][bk]) or
      (PossibleCollisions[2][bk] and PossibleCollisions[2][bk][ak]))
      and ((PossibleCollisions[3][ak] and PossibleCollisions[3][ak][bk]) or
      (PossibleCollisions[3][bk] and PossibleCollisions[3][bk][ak])) then
        BroadCollisions[#BroadCollisions + 1] = {ak, bk}
      end
    end
  end

  --Finds collisions that are in the same layers and are approved by GJK
  local RealCollisions = {}
  for ak=1,#BroadCollisions do
    local av = BroadCollisions[ak]
    local mtv = {}
    if SameLayer(av[1].PhysicsLayers, av[2].PhysicsLayers) and
    GiveBack.GJK(av[1], av[2], mtv, Arguments) then
      RealCollisions[#RealCollisions + 1] = av
      RealCollisions[#RealCollisions][3] = mtv
    end
  end
  return RealCollisions
end
GiveBack.Requirements = {"General"}
return GiveBack
