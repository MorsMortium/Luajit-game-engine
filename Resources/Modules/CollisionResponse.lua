local GiveBack = {}
local function ApplyLinearCollisionImpulse(Object, Contact, e, General)
  local mass = Object.Mass
  Object.Speed = General.Library.VectorSubtraction(Object.Speed, General.Library.VectorNumberMult(Object.Speed, Object.CollisionDecay))
  local d = General.Library.DotProduct(Object.Speed, Contact[2])
  local j = -(1 + e) * d
  Object.Speed = General.Library.VectorAddition(Object.Speed, General.Library.VectorNumberMult(Contact[2], j))
end
local function InverseInertia(Place, Mass, General)
  local S = General.Library.VectorLength(Place)
  local Inertia = (S ^ 2 * Mass)/20
  return {1 / Inertia, 1 / Inertia, 1 / Inertia}
end
local function ApplyLinearCollisionImpulse2(Object1, Object2, Contact, General, lgsl)
  local r1, r2 = {}, {}
  for i=1,3 do
    r1[i] = Contact[3][i] - Object1.Translation[i]
    r2[i] = Contact[4][i] - Object2.Translation[i]
  end
  local RelativeVelocity2 = General.Library.VectorAddition(Object2.Speed, General.Library.CrossProduct(Object2.RotationSpeed, r2))
  local RelativeVelocity1 = General.Library.VectorAddition(Object1.Speed, General.Library.CrossProduct(Object1.RotationSpeed, r1))
  local RelativeVelocity = General.Library.VectorSubtraction(RelativeVelocity2, RelativeVelocity1)
  local VelocityNormal = General.Library.DotProduct(RelativeVelocity, Contact[2])

  --local InvInertia1 = InverseInertia(General.Library.CrossProduct(r1, Contact[2]), Object1.Mass, General)
  --local InvInertia2 = InverseInertia(General.Library.CrossProduct(r2, Contact[2]), Object2.Mass, General)

  --local KN = 1 / Object1.Mass + 1 / Object2.Mass + General.Library.DotProduct(General.Library.VectorSubtraction(General.Library.CrossProduct(InvInertia1, r1), General.Library.CrossProduct(InvInertia2, r2)), Contact[2])
  --local PN = math.max(-VelocityNormal / KN, 0)---VelocityNormal / KN --max(-vn / kn, 0)
  --local P = General.Library.VectorNumberMult(Contact[2], PN)
  Object1.Speed = General.Library.VectorAddition(Object1.Speed, General.Library.VectorNumberMult(Contact[2], -VelocityNormal))--General.Library.VectorAddition(Object1.Speed, General.Library.VectorNumberMult(P, 1 / Object1.Mass))
  Object2.Speed = General.Library.VectorAddition(Object2.Speed, General.Library.VectorNumberMult(Contact[2], -VelocityNormal))--General.Library.VectorAddition(Object2.Speed, General.Library.VectorNumberMult(P, 1 / Object2.Mass))
  --Object1.RotationSpeed = General.Library.VectorAddition(Object1.RotationSpeed, InverseInertia(General.Library.CrossProduct(r1, P), Object1.Mass, General))
  --Object2.RotationSpeed = General.Library.VectorAddition(Object2.RotationSpeed, InverseInertia(General.Library.CrossProduct(r2, P), Object2.Mass, General))
  Object1.Speed = General.Library.VectorNumberMult(Object1.Speed, 1/20)
  Object2.Speed = General.Library.VectorNumberMult(Object2.Speed, 1/20)
  Object1.RotationSpeed = General.Library.VectorNumberMult(Object1.RotationSpeed, 1/20)
  Object2.RotationSpeed = General.Library.VectorNumberMult(Object2.RotationSpeed, 1/20)
end
function GiveBack.ResponseWithoutTorque(Object1, Object2, Contact, Arguments)
  local General, lgsl = Arguments[1], Arguments[3]
  ApplyLinearCollisionImpulse2(Object1, Object2, Contact, General, lgsl)
  --[[
  if Object2.Fixed and not Object1.Fixed then
    ApplyLinearCollisionImpulse(Object1, Contact, 0, General)
  elseif Object1.Fixed and not Object2.Fixed then
    ApplyLinearCollisionImpulse(Object2, Contact, 0, General)
  elseif (not Object1.Fixed) and (not Object2.Fixed) then

  end
  --]]
end

GiveBack.Requirements = {"General", "lgsl"}
return GiveBack
