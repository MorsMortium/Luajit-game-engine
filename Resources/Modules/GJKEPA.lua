return function(args)
  local Math, Globals, CTypes = args[1], args[2], args[3]
  local Globals, Math, CTypes = Globals.Library.Globals, Math.Library,
  CTypes.Library.Types
  local VectorSub, VectorDot, VectorScale,
  VectorAdd, VectorCross, Normalise, VectorZero, VectorEqual, write,
  double, VectorCopy = Math.VectorSub, Math.VectorDot, Math.VectorScale,
  Math.VectorAdd, Math.VectorCross, Math.Normalise, Math.VectorZero,
  Math.VectorEqual, Globals.write, CTypes["double[?]"].Type,Math.VectorCopy

  local GiveBack = {}

  local function GJKPointFromSupport(a)
    a[0], a[1], a[2] = a[6] - a[3], a[7] - a[4], a[8] - a[5]
  end

  local function GJKCopy(a, b)
    b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8] =
    a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8]
  end

  local v0, v1, v2 = double(3), double(3), double(3)

  local function Barycentric(p, a, b, c)
    VectorSub(b, a, v0)
    VectorSub(c, a, v1)
    VectorSub(p, a, v2)
    local d00 = VectorDot(v0, v0)
    local d01 = VectorDot(v0, v1)
    local d11 = VectorDot(v1, v1)
    local d20 = VectorDot(v2, v0)
    local d21 = VectorDot(v2, v1)
    local denom = d00 * d11 - d01 * d01
    local v = (d11 * d20 - d01 * d21) / denom
    local w = (d00 * d21 - d01 * d20) / denom
    local u = 1 - v - w
    return u, v, w
  end

  local ContactHelp1, supportLocal1, supportLocal2, supportLocal3 = double(3),
  double(3), double(3), double(3)

  local function ExtrapolateContactInformation(aClosestFace)
    local distanceFromOrigin = VectorDot(aClosestFace[4], aClosestFace[1])
    local aContactData = {double(3), double(3), double(3)}
    Normalise(aClosestFace[4], aContactData[1])
    --calculate the barycentric coordinates of the closest triangle
    --with respect to the projection of the origin onto the triangle
    VectorScale(aClosestFace[4], distanceFromOrigin, ContactHelp1)
    local bary_u, bary_v, bary_w =
    Barycentric(ContactHelp1, aClosestFace[1], aClosestFace[2], aClosestFace[3])
    --A Contact points
    supportLocal1[0], supportLocal1[1], supportLocal1[2] =
    aClosestFace[1][3], aClosestFace[1][4], aClosestFace[1][5]
    supportLocal2[0], supportLocal2[1], supportLocal2[2] =
    aClosestFace[2][3], aClosestFace[2][4], aClosestFace[2][5]
    supportLocal3[0], supportLocal3[1], supportLocal3[2] =
    aClosestFace[3][3], aClosestFace[3][4], aClosestFace[3][5]
    --Contact point on object A in local space
    VectorScale(supportLocal1, bary_u, supportLocal1)
    VectorScale(supportLocal2, bary_v, supportLocal2)
    VectorScale(supportLocal3, bary_w, supportLocal3)
    VectorAdd(supportLocal1, supportLocal2, supportLocal2)
    VectorAdd(supportLocal2, supportLocal3, aContactData[2])
    --B contact points
    supportLocal1[0], supportLocal1[1], supportLocal1[2] =
    aClosestFace[1][6], aClosestFace[1][7], aClosestFace[1][8]
    supportLocal2[0], supportLocal2[1], supportLocal2[2] =
    aClosestFace[2][6], aClosestFace[2][7], aClosestFace[2][8]
    supportLocal3[0], supportLocal3[1], supportLocal3[2] =
    aClosestFace[3][6], aClosestFace[3][7], aClosestFace[3][8]
    --Contact point on object B in local space
    VectorScale(supportLocal1, bary_u, supportLocal1)
    VectorScale(supportLocal2, bary_v, supportLocal2)
    VectorScale(supportLocal3, bary_w, supportLocal3)
    VectorAdd(supportLocal1, supportLocal2, supportLocal2)
    VectorAdd(supportLocal2, supportLocal3, aContactData[3])
    return aContactData
  end

  local NewMax = double(3)

  local function Support(Object, Dir, Max)
    local TData = Object.Transformated
    Math.VectorCopy(TData, Max)
    local MaxDot = VectorDot(Max, Dir)
    for ak=1,3 do
      NewMax[0], NewMax[1], NewMax[2] =
      TData[ak * 4], TData[ak * 4 + 1], TData[ak * 4 + 2]
      local NewDot = VectorDot(NewMax, Dir)
      if MaxDot < NewDot then
        MaxDot = NewDot
        Math.VectorCopy(NewMax, Max)
      end
    end
  end

  --Expanding Polytope Algorithm. Used to find the mtv of two intersecting
  --colliders using the final simplex obtained with the GJK algorithm
  --Expanding Polytope Algorithm
  --Find minimum translation Vector to resolve collision
  local EPA_TOLERANCE = 0.0001
  local EPA_MAX_NUM_FACES = 64
  local EPA_MAX_NUM_LOOSE_EDGES = 32
  local EPA_MAX_NUM_ITERATIONS = 64

  local FacesHelp1, FacesHelp2, SupportRes, FullGJKPointHelp1,
  EPAHelp1 = double(3), double(3), double(3), double(3), double(3)

  local function FullGJKPoint(coll1, coll2, search_dir, p)
    Support(coll2, search_dir, SupportRes)
    p[6], p[7], p[8] = SupportRes[0], SupportRes[1], SupportRes[2]
    VectorScale(search_dir, -1, FullGJKPointHelp1)
    Support(coll1, FullGJKPointHelp1, SupportRes)
    p[3], p[4], p[5] = SupportRes[0], SupportRes[1], SupportRes[2]
    GJKPointFromSupport(p)
  end


  function GiveBack.EPA(a, b, c, d, coll1, coll2)
    local faces = {} --Array of faces, each with 3 verts and a normal
    --Init with final simplex from GJK
    VectorSub(b, a, FacesHelp1)
    VectorSub(c, a, FacesHelp2)
    local Norm = double(3)
    VectorCross(FacesHelp1, FacesHelp2, Norm)
    Normalise(Norm, Norm)
    faces[1] = {a, b, c, Norm}--ABC
    VectorSub(d, a, FacesHelp1)
    Norm = double(3)
    VectorCross(FacesHelp2, FacesHelp1, Norm)
    Normalise(Norm, Norm)
    faces[2] = {a, c, d, Norm}--ACD
    VectorSub(b, a, FacesHelp2)
    Norm = double(3)
    VectorCross(FacesHelp1, FacesHelp2, Norm)
    Normalise(Norm, Norm)
    faces[3] = {a, d, b, Norm}--ADB
    VectorSub(d, b, FacesHelp1)
    VectorSub(c, b, FacesHelp2)
    Norm = double(3)
    VectorCross(FacesHelp1, FacesHelp2, Norm)
    Normalise(Norm, Norm)
    faces[4] = {b, d, c, Norm}--BDC
    local closest_face
    for iterations=1, EPA_MAX_NUM_ITERATIONS do
      --Find face that's closest to origin
      local min_dist = VectorDot(faces[1][1], faces[1][4])
      closest_face = 1
      for i=2, #faces do
        local dist = VectorDot(faces[i][1], faces[i][4])
        if(dist<min_dist)then
          min_dist = dist
          closest_face = i
        end
      end
      --search normal to face that's closest to origin
      local search_dir = faces[closest_face][4]
      local p = double(9)
      FullGJKPoint(coll1, coll2, search_dir, p)
      if VectorDot(p, search_dir) - min_dist < EPA_TOLERANCE then
        --Convergence (new point is not significantly further from origin)
        local contactdata = ExtrapolateContactInformation(faces[closest_face])
        local EPAData = double(3)
        --dot vertex with normal to resolve collision along normal!
        VectorScale(faces[closest_face][3], VectorDot(p, search_dir), EPAData)
        return EPAData, contactdata[1], contactdata[2], contactdata[3]
      end
      --keep track of edges we need to fix after removing faces
      local loose_edges = {}
      --Find all triangles that are facing p
      local i = 1
      while i <= #faces do
        VectorSub(p, faces[i][1], EPAHelp1)
        --triangle i faces p, remove it
        if VectorDot(faces[i][4], EPAHelp1) > 0 then
          --Add removed triangle's edges to loose edge list.
          --If it's already there, remove it
          --(both triangles it belonged to are gone)
          for j=1,3 do--Three edges per face
            local current_edge = {faces[i][j], faces[i][j%3 + 1]}
            local found_edge = false
            --Check if current edge is already in list
            for k=1,#loose_edges do
              if VectorEqual(loose_edges[k][2], current_edge[1]) and
              VectorEqual(loose_edges[k][1], current_edge[2]) then
                --Edge is already in the list, remove it
                --THIS ASSUMES EDGE CAN ONLY BE SHARED BY 2 TRIANGLES
                --(which should be true)
                --THIS ASSUMES SHARED EDGE WILL BE REVERSED IN THE TRIANGLES
                --(which should be true provided every triangle is wound CCW)
                --Overwrite current edge
                loose_edges[k] = loose_edges[#loose_edges]
                --with last edge in list
                loose_edges[#loose_edges] = nil
                found_edge = true
                break --exit loop because edge can only be shared once
              end
            end
            if not found_edge then --add current edge to list
              if #loose_edges>=EPA_MAX_NUM_LOOSE_EDGES then break end
              loose_edges[#loose_edges + 1] = current_edge
            end
          end
          --Remove triangle i from list
          faces[i] = faces[#faces]
          faces[#faces] = nil
          i = i - 1
        end--endif p can see triangle i
        i = i + 1
      end--endfor num_faces
      i = nil
      --Reconstruct polytope with p added
      for i=1, #loose_edges do
        if #faces >= EPA_MAX_NUM_FACES then break end
        VectorSub(loose_edges[i][1], loose_edges[i][2], FacesHelp1)
        VectorSub(loose_edges[i][1], p, FacesHelp2)
        Norm = double(3)
        VectorCross(FacesHelp1, FacesHelp2, Norm)
        Normalise(Norm, Norm)
        faces[#faces + 1] = {loose_edges[i][1], loose_edges[i][2], p, Norm}
        --Check for wrong normal to maintain CCW winding
        --in case dot result is only slightly < 0 (because origin is on face)
        local bias = 0.000001
        if VectorDot(faces[#faces][1], faces[#faces][4]) + bias < 0 then
          local temp = faces[#faces][1]
          faces[#faces][1] = faces[#faces][2]
          faces[#faces][2] = temp
          VectorScale(faces[#faces][4], -1, faces[#faces][4])
        end
      end
    end --End for iterations
    write("EPA did not converge\n")
    --Return most recent closest point
    local contactdata = ExtrapolateContactInformation(faces[closest_face])
    local EPAData = double(3)
    --dot vertex with normal to resolve collision along normal!
    local DotResult = VectorDot(faces[closest_face][1], faces[closest_face][3])
    VectorScale(faces[closest_face][3], DotResult, EPAData)
    return EPAData, contactdata[1], contactdata[2], contactdata[3], true
  end

  local Normal, NormalHelp1, NormalHelp2, AO, Simplex3Helper = double(3),
  double(3), double(3), double(3), double(3)

  --Internal functions used in the GJK algorithm
  --Triangle case
  local function update_simplex3(a, b, c, d, simp_dim, search_dir)
    --Required winding order:
    --b
    --| \
    --|   \
    --|    a
    --|   /
    --| /
    --c
    --triangle's normal
    VectorSub(b, a, NormalHelp1)
    VectorSub(c, a, NormalHelp2)
    VectorCross(NormalHelp1, NormalHelp2, Normal)
    VectorScale(a, -1, AO) --direction to origin
    --Determine which feature is closest to origin, make that the new simplex
    simp_dim[1] = 2
    --Closest to edge AB
    VectorCross(NormalHelp1, Normal, Simplex3Helper)
    if VectorDot(Simplex3Helper, AO) > 0 then
      GJKCopy(a, c)
      --simp_dim[1] = 2
      VectorCross(NormalHelp1, AO, Simplex3Helper)
      VectorCross(Simplex3Helper, NormalHelp1, search_dir)
      return
    end
    --Closest to edge AC
    VectorCross(Normal, NormalHelp2, Simplex3Helper)
    if VectorDot(Simplex3Helper, AO) > 0 then
      GJKCopy(a, b)
      --simp_dim[1] = 2
      VectorCross(NormalHelp2, AO, Simplex3Helper)
      VectorCross(Simplex3Helper, NormalHelp2, search_dir)
      return
    end
    simp_dim[1] = 3
    if VectorDot(Normal, AO) > 0 then --Above triangle
      GJKCopy(c, d)
      GJKCopy(b, c)
      GJKCopy(a, b)
      --simp_dim[1] = 3
      Math.VectorCopy(Normal, search_dir)
      return
    end
    --else --Below triangle
    GJKCopy(b, d)
    GJKCopy(a, b)
    --simp_dim[1] = 3
    VectorScale(Normal, -1, search_dir)
    return
  end

  local ABC, ACD, ADB, Simplex4Help1, Simplex4Help2 = double(3), double(3),
  double(3), double(3), double(3)

  --Tetrahedral case
  local function update_simplex4(a, b, c, d, simp_dim, search_dir)
    --a is peak/tip of pyramid, BCD is the base
    --(counterclockwise winding order)
    --We know a priori that origin is above BCD and below a
    --Get normals of three new faces
    VectorSub(b, a, Simplex4Help1)
    VectorSub(c, a, Simplex4Help2)
    VectorCross(Simplex4Help1, Simplex4Help2, ABC)
    VectorSub(d, a, Simplex4Help1)
    VectorCross(Simplex4Help2, Simplex4Help1, ACD)
    VectorSub(b, a, Simplex4Help2)
    VectorCross(Simplex4Help1, Simplex4Help2, ADB)
    VectorScale(a, -1, AO) --dir to origin
    simp_dim[1] = 3 --hoisting this just cause
    --Plane-test origin with 3 faces
    --Note: Kind of primitive approach used here;
    --If origin is in front of a face, just use it as the new simplex.
    --We just go through the faces sequentially and exit at the first one
    --which satisfies dot product.
    --Not sure this is optimal or if edges should be considered as
    --possible simplices?
    --Thinking this through in my head I feel like this method is good enough.
    --Makes no difference for AABBS, should test with more complex colliders.
    if VectorDot(ABC, AO) > 0 then --In front of ABC
      GJKCopy(c, d)
      GJKCopy(b, c)
      GJKCopy(a, b)
      Math.VectorCopy(ABC, search_dir)
      return false
    end
    if VectorDot(ACD, AO) > 0 then --In front of ACD
      GJKCopy(a, b)
      Math.VectorCopy(ACD, search_dir)
      return false
    end
    if VectorDot(ADB, AO) > 0 then --In front of ADB
      GJKCopy(d, c)
      GJKCopy(b, d)
      GJKCopy(a, b)
      Math.VectorCopy(ADB, search_dir)
      return false
    end
    --else inside tetrahedron; enclosed!
    return true
    --Note: in the case where two of the faces have similar normals,
    --The origin could conceivably be closest to an edge on the tetrahedron
    --Right now I don't think it makes a difference to limit our new simplices
    --to just one of the faces, maybe test it later.
  end

  local GJK_MAX_NUM_ITERATIONS = 64

  --Simplex: just a set of points (a is always most recently added)
  local a, b, c, d, search_dir, search_dirHelp1, search_dirHelp2,
  search_dirHelp3 = double(9), double(9), double(9), double(9), double(3),
  double(3), double(3), double(3)



  --Returns true if two colliders are intersecting.
  --Has optional Minimum Translation Vector output param
  --EPA will be used to find the Vector to separate coll1 from coll2
  function GiveBack.GJK(coll1, coll2, mtv)
    --initial search direction between colliders
    VectorSub(coll1.Translation, coll2.Translation, search_dir)

    --Get initial point for simplex
    FullGJKPoint(coll1, coll2, search_dir, c)

    --search in direction of origin
    VectorScale(c, -1, search_dir)

    --Get second point for a line segment simplex
    FullGJKPoint(coll1, coll2, search_dir, b)

    --we didn't reach the origin, won't enclose it
    if VectorDot(b, search_dir) < 0 then return false end

    --search perpendicular to line segment towards origin
    VectorSub(c, b, search_dirHelp1)
    VectorScale(b, -1, search_dirHelp2)
    VectorCross(search_dirHelp1, search_dirHelp2, search_dirHelp3)
    VectorCross(search_dirHelp3, search_dirHelp1, search_dir)

    --origin is on this line segment
    if VectorZero(search_dir) then

      --Apparently any normal search Vector will do?
      search_dirHelp2[0], search_dirHelp2[1], search_dirHelp2[2] = 1, 0, 0

      --normal with x-axis
      VectorCross(search_dirHelp1, search_dirHelp2, search_dir)
      if VectorZero(search_dir) then
        search_dirHelp2[0], search_dirHelp2[1], search_dirHelp2[2] = 0, 0, -1

        --normal with z-axis
        VectorCross(search_dirHelp1, search_dirHelp2, search_dir)
      end
    end

    --simplex dimension
    local simp_dim = {2}
    for iterations=1, GJK_MAX_NUM_ITERATIONS do
      FullGJKPoint(coll1, coll2, search_dir, a)
      --we didn't reach the origin, won't enclose it
      if VectorDot(a, search_dir) < 0 then return false end
      simp_dim[1] = simp_dim[1] + 1
      if simp_dim[1] == 3 then
        update_simplex3(a,b,c,d,simp_dim,search_dir)
      elseif update_simplex4(a,b,c,d,simp_dim,search_dir) then
        if mtv then
          local EPAFailed = false
          mtv[1], mtv[2], mtv[3], mtv[4], EPAFailed =
          GiveBack.EPA(a,b,c,d,coll1,coll2)
          if EPAFailed then
            return false
          end
        end
        return true
      end
    end
    return false
  end
  return GiveBack
end
