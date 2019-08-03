local GiveBack = {}

--This script is responsible for general physics mechanics:
--Updating vertices with translation, rotation and scale, checking new powers
--for initialisation, collision detection and response, and usage of powers
function GiveBack.Start(Configurations, Arguments)
end
function GiveBack.Stop(Arguments)
end
function GiveBack.Physics(Time, Arguments)
  local Space, AllDevices, AllDevicesGive, General, GeneralGive, AllPowers,
  AllPowersGive, CollisionDetection, CollisionDetectionGive, CollisionResponse,
  CollisionResponseGive = Arguments[1], Arguments[2], Arguments[3], Arguments[4],
  Arguments[5], Arguments[6], Arguments[7], Arguments[8], Arguments[9],
  Arguments[10], Arguments[11]
  local RealCollision = CollisionDetection.Library.DetectCollisions(AllDevices,
  CollisionDetectionGive)
  CollisionResponse.Library.ResponseCollisions(RealCollision, CollisionResponseGive)
  AllPowers.Library.UseAllPowers(Time, AllPowersGive)
  CollisionDetection.Library.UpdateAxes(AllDevices)
  AllDevices.Space.InvBroadPhaseAxes = {{}, {}, {}}
  General.Library.UpdateObjects(AllDevices.Space.BroadPhaseAxes[1], Time, GeneralGive)
  AllPowers.Library.DataCheckNewDevicesPowers(Time, AllPowersGive)
  AllDevices.Library.ClearObjectChanges(AllDevicesGive)
end

GiveBack.Requirements =
{"AllDevices", "General", "AllPowers", "CollisionDetection", "CollisionResponse"}
return GiveBack
