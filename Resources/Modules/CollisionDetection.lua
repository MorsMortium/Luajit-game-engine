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
    for ak=1,#BroadCollisions do
      local av, mtv = BroadCollisions[ak], {}
      if SameLayer(av[1].PhysicsLayers, av[1].PLayerKeys, av[2].PhysicsLayers, av[2].PLayerKeys) and
      GJK(av[1], av[2], mtv) then
        RealCollisions[#RealCollisions + 1] = {av[1], av[2], mtv}
      end
    end
    return RealCollisions
  end
  return GiveBack
end
