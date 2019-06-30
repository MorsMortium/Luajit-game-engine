local GiveBack = {}

--This script is responds to collisions detected by CollisionDetection.lua
function GiveBack.ResponseCollisions(RealCollision, Arguments)
  local General, lgsl = Arguments[1], Arguments[3]
  for ak=1,#RealCollision do

    --Activates both object's OnCollisionPowers and fills in the needed data
    local av = RealCollision[ak]
    for bk=1,#av[1].OnCollisionPowers do
      local bv = av[1].OnCollisionPowers[bk]
      if bv then
        av[1].Powers[bk].Active = true
        av[1].Powers[bk].Device = av[2].Parent
        av[1].Powers[bk].Contact = mtv
      end
    end

    for bk=1,#av[2].OnCollisionPowers do
      local bv = av[2].OnCollisionPowers[bk]
      if bv then
        av[2].Powers[bk].Active = true
        av[2].Powers[bk].Device = av[1].Parent
        av[2].Powers[bk].Contact = mtv
      end
    end
    
    --TODO: constraints
  end
end
GiveBack.Requirements = {"General", "lgsl"}
return GiveBack
