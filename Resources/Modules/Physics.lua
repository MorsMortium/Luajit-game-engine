return function(args)
  local AllDevices, General, AllPowers, CollisionDetection, CollisionResponse,
  SAP = args[1], args[2], args[3], args[4], args[5], args[6], args[7]
  local DetectCollisions, ResponseCollisions, UseAllPowers, Update,
  UpdateObjects, AllPowersUpdate, BroadPhaseAxes =
  CollisionDetection.Library.DetectCollisions,
  CollisionResponse.Library.ResponseCollisions, AllPowers.Library.UseAllPowers,
  SAP.Library.Update, General.Library.UpdateObjects,
  AllPowers.Library.AllPowersUpdate, AllDevices.Space.BroadPhaseAxes
  local GiveBack = {}

  --This script is responsible for general physics mechanics:
  --Updating vertices with translation, rotation and scale, checking new powers
  --for initialisation, collision detection and response, and usage of powers
  function GiveBack.Physics(Time)
    local RealCollision = DetectCollisions()
    ResponseCollisions(RealCollision)
    UseAllPowers(Time)
    Update()
    UpdateObjects(BroadPhaseAxes[1], Time)
    AllPowersUpdate(Time)
  end
  return GiveBack
end
