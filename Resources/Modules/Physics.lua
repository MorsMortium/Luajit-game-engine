local GiveBack = {}

--This script is responsible for general physics mechanics:
--Updating vertices with translation, rotation and scale, checking new powers
--for initialisation, collision detection and response, and usage of powers
function GiveBack.Start(Arguments)
  local Space = Arguments[1]
  Space.BroadPhaseAxes = {{}, {}, {}}
end
function GiveBack.Stop(Arguments)
  local Space = Arguments[1]
  for ak,av in pairs(Space) do
    Space[ak] = nil
  end
end
function GiveBack.Physics(Time, Arguments)
  local Space, AllDevices, AllDevicesGive, General, GeneralGive, AllPowers,
  AllPowersGive, CollisionDetection, CollisionDetectionGive, CollisionResponse,
  CollisionResponseGive = Arguments[1], Arguments[2], Arguments[3], Arguments[6],
  Arguments[7], Arguments[8], Arguments[9], Arguments[10], Arguments[11],
  Arguments[12], Arguments[13]
  General.Library.UpdateDevices(AllDevices.Space.Devices, Time, GeneralGive)
  AllPowers.Library.DataCheckNewDevicesPowers(Time, AllPowersGive)
  local RealCollision = CollisionDetection.Library.DetectCollisions(AllDevices,
  Space.BroadPhaseAxes, CollisionDetectionGive)
  CollisionResponse.Library.ResponseCollisions(RealCollision, CollisionResponseGive)
  AllDevices.Library.ClearDeviceChanges(AllDevicesGive)
  AllPowers.Library.UseAllPowers(Time, AllPowersGive)
end

GiveBack.Requirements =
{"AllDevices", "SDLInit", "General", "AllPowers", "CollisionDetection",
"CollisionResponse"}
return GiveBack
