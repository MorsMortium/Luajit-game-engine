return function(args)
  local General = args[1]
  local VectorSubtraction, DotProduct, VectorScale,
  VectorAddition, CrossProduct, Normalise, VectorZero, VectorEqual =
  General.Library.VectorSubtraction, General.Library.DotProduct,
  General.Library.VectorScale, General.Library.VectorAddition,
  General.Library.CrossProduct, General.Library.Normalise,
  General.Library.VectorZero, General.Library.VectorEqual

  local GiveBack = {}

  function GiveBack.Reload(args)
    General = args[1]
    VectorSubtraction, DotProduct, VectorScale,
    VectorAddition, CrossProduct, Normalise, VectorZero, VectorEqual =
    General.Library.VectorSubtraction, General.Library.DotProduct,
    General.Library.VectorScale, General.Library.VectorAddition,
    General.Library.CrossProduct, General.Library.Normalise,
    General.Library.VectorZero, General.Library.VectorEqual
  end

  local function VectorCopy(c, o)
    c[1] = o[1]
    c[2] = o[2]
    c[3] = o[3]
  end

  local function GJKCopy(a, b)
    VectorCopy(a, b)
    a.supporta = b.supporta
    a.supportb = b.supportb
  end

  local function Barycentric(p, a, b, c)
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
  local function ExtrapolateContactInformation(aClosestFace)
    local distanceFromOrigin = DotProduct(aClosestFace[4], aClosestFace[1])
    local aContactData = {}
    aContactData[1] = Normalise(aClosestFace[4])
    -- calculate the barycentric coordinates of the closest triangle with respect to
    -- the projection of the origin onto the triangle
    local bary_u, bary_v, bary_w = Barycentric(VectorScale(aClosestFace[4], distanceFromOrigin), aClosestFace[1], aClosestFace[2], aClosestFace[3])
    -- A Contact points
    local supportLocal1 = aClosestFace[1].supporta
    local supportLocal2 = aClosestFace[2].supporta
    local supportLocal3 = aClosestFace[3].supporta
    -- Contact point on object A in local space
    aContactData[2] = VectorAddition(VectorAddition(VectorScale(supportLocal1, bary_u), VectorScale(supportLocal2, bary_v)), VectorScale(supportLocal3, bary_w))
    -- B contact points
    supportLocal1 = aClosestFace[1].supportb
    supportLocal2 = aClosestFace[2].supportb
    supportLocal3 = aClosestFace[3].supportb
    -- Contact point on object B in local space
    aContactData[3] = VectorAddition(VectorAddition(VectorScale(supportLocal1, bary_u), VectorScale(supportLocal2, bary_v)), VectorScale(supportLocal3, bary_w))
    return aContactData
  end
  --Internal functions used in the GJK algorithm
  --Triangle case
  local function update_simplex3(a, b, c, d, simp_dim, search_dir)
    -- Required winding order:
    --  b
    --  | \
    --  |   \
    --  |    a
    --  |   /
    --  | /
    --  c
    --triangle's normal
    local n = CrossProduct(VectorSubtraction(b, a), VectorSubtraction(c, a))
    local AO = VectorScale(a, -1) --direction to origin
    --Determine which feature is closest to origin, make that the new simplex
    simp_dim[1] = 2
    --Closest to edge AB
    if DotProduct(CrossProduct(VectorSubtraction(b, a), n), AO) > 0 then
      GJKCopy(c, a)
      --simp_dim[1] = 2
      VectorCopy(search_dir, CrossProduct(CrossProduct(VectorSubtraction(b, a), AO), VectorSubtraction(b, a)))
      return
    end
    --Closest to edge AC
    if DotProduct(CrossProduct(n, VectorSubtraction(c, a)), AO) > 0 then
      GJKCopy(b, a)
      --simp_dim[1] = 2
      VectorCopy(search_dir, CrossProduct(CrossProduct(VectorSubtraction(c, a), AO), VectorSubtraction(c, a)))
      return
    end
    simp_dim[1] = 3
    if DotProduct(n, AO) > 0 then --Above triangle
      GJKCopy(d, c)
      GJKCopy(c, b)
      GJKCopy(b, a)
      --simp_dim[1] = 3
      VectorCopy(search_dir, n)
      return
    end
    --else --Below triangle
    GJKCopy(d, b)
    GJKCopy(b, a)
    --simp_dim[1] = 3
    VectorCopy(search_dir, VectorScale(n, -1))
    return
  end
  --Tetrahedral case
  local function update_simplex4(a, b, c, d, simp_dim, search_dir)
    -- a is peak/tip of pyramid, BCD is the base (counterclockwise winding order)
    --We know a priori that origin is above BCD and below a
    --Get normals of three new faces
    local ABC = CrossProduct(VectorSubtraction(b, a), VectorSubtraction(c, a))
    local ACD = CrossProduct(VectorSubtraction(c, a), VectorSubtraction(d, a))
    local ADB = CrossProduct(VectorSubtraction(d, a), VectorSubtraction(b, a))
    local AO = VectorScale(a, -1) --dir to origin
    simp_dim[1] = 3 --hoisting this just cause
    --Plane-test origin with 3 faces
    -- Note: Kind of primitive approach used here; If origin is in front of a face, just use it as the new simplex.
    -- We just go through the faces sequentially and exit at the first one which satisfies dot product. Not sure this
    -- is optimal or if edges should be considered as possible simplices? Thinking this through in my head I feel like
    -- this method is good enough. Makes no difference for AABBS, should test with more complex colliders.
    if DotProduct(ABC, AO) > 0 then --In front of ABC
      GJKCopy(d, c)
      GJKCopy(c, b)
      GJKCopy(b, a)
      VectorCopy(search_dir, ABC)
      return false
    end
    if DotProduct(ACD, AO) > 0 then --In front of ACD
      GJKCopy(b, a)
      VectorCopy(search_dir, ACD)
      return false
    end
    if DotProduct(ADB, AO) > 0 then --In front of ADB
      GJKCopy(c, d)
      GJKCopy(d, b)
      GJKCopy(b, a)
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
  local function Support(Object, dir)
    local TData = Object.Transformated.data
    local max = {TData[0], TData[1], TData[2]}
    local maxdot = DotProduct(max, dir)
    for ak=1,3 do
      local newmax = {TData[ak * 4], TData[ak * 4 + 1], TData[ak * 4 + 2]}
      local dot = DotProduct(newmax, dir)
      if maxdot < dot then
        maxdot = dot
        max = newmax
      end
    end
    return max
  end
  --Expanding Polytope Algorithm. Used to find the mtv of two intersecting
  --colliders using the final simplex obtained with the GJK algorithm
  --Expanding Polytope Algorithm
  --Find minimum translation vector to resolve collision
  local EPA_TOLERANCE = 0.0001
  local EPA_MAX_NUM_FACES = 64
  local EPA_MAX_NUM_LOOSE_EDGES = 32
  local EPA_MAX_NUM_ITERATIONS = 64
  function GiveBack.EPA(a, b, c, d, coll1, coll2)
    local faces = {}--[EPA_MAX_NUM_FACES][4] --Array of faces, each with 3 verts and a normal
    --Init with final simplex from GJK
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
      local supporta, supportb =
      Support(coll1, VectorScale(search_dir, -1)),
      Support(coll2, search_dir)
      local p = VectorSubtraction(supportb, supporta)
      p.supporta = supporta
      p.supportb = supportb
      if DotProduct(p, search_dir)-min_dist < EPA_TOLERANCE then
        --Convergence (new point is not significantly further from origin)
        local contactdata = ExtrapolateContactInformation(faces[closest_face])
        return VectorScale(faces[closest_face][3], DotProduct(p, search_dir)), contactdata[1], contactdata[2], contactdata[3] --dot vertex with normal to resolve collision along normal!
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
          faces[num_faces][4] = VectorScale(faces[num_faces][4], -1)
        end
      end
    end --End for iterations
    io.write("EPA did not converge\n")
    --Return most recent closest point
    local contactdata = ExtrapolateContactInformation(faces[closest_face])
    return VectorScale(faces[closest_face][3], DotProduct(faces[closest_face][1], faces[closest_face][3])), contactdata[1], contactdata[2], contactdata[3], true
  end
  local GJK_MAX_NUM_ITERATIONS = 64
  --Returns true if two colliders are intersecting. Has optional Minimum Translation Vector output param;
  --If supplied the EPA will be used to find the vector to separate coll1 from coll2
  function GiveBack.GJK(coll1, coll2, mtv)--(Collider* coll1, Collider* coll2, vec3* mtv=NULL)
    local a, b, c, d = {}, {}, {}, {} --Simplex: just a set of points (a is always most recently added)
    local search_dir = VectorSubtraction(coll1.Translation, coll2.Translation) --initial search direction between colliders
    --Get initial point for simplex
    local supporta, supportb =
    Support(coll1, VectorScale(search_dir, -1)),
    Support(coll2, search_dir)
    c = VectorSubtraction(supportb, supporta)
    c.supporta = supporta
    c.supportb = supportb
    search_dir = VectorScale(c, -1) --search in direction of origin
    --Get second point for a line segment simplex
    local supporta, supportb =
    Support(coll1, VectorScale(search_dir, -1)),
    Support(coll2, search_dir)
    b = VectorSubtraction(supportb, supporta)
    b.supporta = supporta
    b.supportb = supportb
    if DotProduct(b, search_dir) < 0 then return false end--we didn't reach the origin, won't enclose it
    search_dir = CrossProduct(CrossProduct(VectorSubtraction(c, b),VectorScale(b, -1)),VectorSubtraction(c, b)) --search perpendicular to line segment towards origin
    if VectorZero(search_dir) then --origin is on this line segment
      --Apparently any normal search vector will do?
      search_dir = CrossProduct(VectorSubtraction(c, b), {1,0,0}) --normal with x-axis
      if VectorZero(search_dir) then
        search_dir = CrossProduct(VectorSubtraction(c, b), {0,0,-1})
      end --normal with z-axis
    end
    local simp_dim = {2} --simplex dimension
    for iterations=1, GJK_MAX_NUM_ITERATIONS do
      local supporta, supportb =
      Support(coll1, VectorScale(search_dir, -1)),
      Support(coll2, search_dir)
      a = VectorSubtraction(supportb, supporta)
      a.supporta = supporta
      a.supportb = supportb
      if DotProduct(a, search_dir) < 0 then return false end--we didn't reach the origin, won't enclose it
      simp_dim[1] = simp_dim[1] + 1
      if simp_dim[1] == 3 then
        update_simplex3(a,b,c,d,simp_dim,search_dir)
      elseif update_simplex4(a,b,c,d,simp_dim,search_dir) then
        if mtv then
          local EPAFailed = false
          mtv[1], mtv[2], mtv[3], mtv[4], EPAFailed = GiveBack.EPA(a,b,c,d,coll1,coll2)
          if EPAFailed then
            return false
          end
        end
        return true
      end
    end--endfor
    return false
  end
  return GiveBack
end
