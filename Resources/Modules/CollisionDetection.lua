return function(args)
  local General, SweepAndPrune, GJKEPA = args[1], args[2], args[3]
  local SameLayer, DetectCollisions, GJK = General.Library.SameLayer,
  SweepAndPrune.Library.DetectCollisions, GJKEPA.Library.GJK

  local GiveBack = {}

  function GiveBack.Reload(args)
    General, SweepAndPrune, GJKEPA = args[1], args[2], args[3]
    SameLayer, DetectCollisions, GJK = General.Library.SameLayer,
    SweepAndPrune.Library.DetectCollisions, GJKEPA.Library.GJK
  end

  function GiveBack.DetectCollisions()
    local BroadCollisions = DetectCollisions()
    --Finds collisions that are in the same layers and are approved by GJK
    local RealCollisions = {}
    for ak=1,#BroadCollisions, 2 do
      local av, bv, mtv = BroadCollisions[ak], BroadCollisions[ak + 1], {}
      if SameLayer(av.PhysicsLayers, av.PLayerKeys, bv.PhysicsLayers, bv.PLayerKeys) and
      GJK(av, bv, mtv) then
        RealCollisions[#RealCollisions + 1] = {av, bv, mtv}
      end
    end
    return RealCollisions
  end
  return GiveBack
end
