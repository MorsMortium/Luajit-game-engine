return function(args)
  local AllDevices, General, AllPowers, CollisionDetection, CollisionResponse,
  UpdateAxes = args[1], args[2], args[3], args[4], args[5], args[6], args[7]
  local GiveBack = {}

  function GiveBack.Reload(args)
    AllDevices, General, AllPowers, CollisionDetection, CollisionResponse,
    UpdateAxes = args[1], args[2], args[3], args[4], args[5], args[6], args[7]
  end

  --This script is responsible for general physics mechanics:
  --Updating vertices with translation, rotation and scale, checking new powers
  --for initialisation, collision detection and response, and usage of powers
  function GiveBack.Physics(Time)
    local RealCollision = CollisionDetection.Library.DetectCollisions()
    CollisionResponse.Library.ResponseCollisions(RealCollision)
    AllPowers.Library.UseAllPowers(Time)
    UpdateAxes.Library.Update()
    General.Library.UpdateObjects(AllDevices.Space.BroadPhaseAxes[1], Time)
    AllPowers.Library.DataCheckNewDevicesPowers(Time)
    AllDevices.Library.ClearObjectChanges()
  end
  return GiveBack
end
