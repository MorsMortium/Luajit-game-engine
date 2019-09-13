return function(args)
  local General = args[1]
  local GiveBack = {}

  function GiveBack.Reload(args)
    General = args[1]
  end

  --This script is responds to collisions detected by CollisionDetection.lua
  function GiveBack.ResponseCollisions(RealCollision)
    for ak=1,#RealCollision do

      --Activates both object's OnCollisionPowers and fills in the needed data
      local av = RealCollision[ak]
      local OnCollisionPowers = av[1].OnCollisionPowers
      local Powers = av[1].Powers
      local Parent = av[2].Parent
      for bk=1,#OnCollisionPowers do
        local bv = OnCollisionPowers[bk]
        if bv then
          Powers[bk].Active = true
          Powers[bk].Device = Parent
          Powers[bk].Contact = mtv
        end
      end

      OnCollisionPowers = av[2].OnCollisionPowers
      Powers = av[2].Powers
      Parent = av[1].Parent
      for bk=1,#OnCollisionPowers do
        local bv = OnCollisionPowers[bk]
        if bv then
          Powers[bk].Active = true
          Powers[bk].Device = Parent
          Powers[bk].Contact = mtv
        end
      end

      --TODO: constraints
    end
  end
  return GiveBack
end
