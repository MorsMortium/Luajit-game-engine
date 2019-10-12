return function(args)
  local General, GJKEPA, AllDevices, Globals = args[1], args[2], args[3],
  args[4]
  local SameLayer, GJK, CollisionPairs, pairs = General.Library.SameLayer,
  GJKEPA.Library.GJK, AllDevices.Space.CollisionPairs,
  Globals.Library.Globals.pairs

  local GiveBack = {}

  function GiveBack.DetectCollisions()
    --Finds collisions that are in the same layers and are approved by GJK
    local RealCollisions = {}
    for ak=1,#CollisionPairs do
      local av = CollisionPairs[ak]
      local av2 = CollisionPairs[av]
      if av2 then
        for bk=1,#av2 do
          local bv = av2[bk]
          if CollisionPairs[bv] then
            if CollisionPairs[bv][av] == 1 then
              CollisionPairs[bv][av], CollisionPairs[av][bv] = 2, 2
              if SameLayer(av.PhysicsLayers, bv.PhysicsLayers) then
                local mtv = {}
                if GJK(av, bv, mtv) then
                  RealCollisions[#RealCollisions + 1] = {av, bv, mtv}
                end
              end
            elseif CollisionPairs[bv][av] == 2 then
              CollisionPairs[bv][av], CollisionPairs[av][bv] = 1, 1
            end
          end
        end
      end
    end
    return RealCollisions
  end
  return GiveBack
end
