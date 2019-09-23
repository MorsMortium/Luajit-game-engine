return function(args)
  local AllDevices = args[1]
  local PossibleCollisions = {}
  local GiveBack = {}

  function GiveBack.Reload(args)
    AllDevices = args[1]
  end

  function GiveBack.DetectCollisions()
    local InvBroadPhaseAxes, BroadPhaseAxes =
    AllDevices.Space.InvBroadPhaseAxes, AllDevices.Space.BroadPhaseAxes
    local BroadCollisions = {}
    for ak,av in pairs(PossibleCollisions) do
      for bk,bv in pairs(av) do
        av[bk] = 0
      end
    end
    --No collisions without objects
    if not BroadPhaseAxes[1][1] then return {} end

    InvBroadPhaseAxes[1][BroadPhaseAxes[1][1]] = 1
    local ActiveFirst = 1

    --Loop that goes through every Object in first axis
    for ak=2,#BroadPhaseAxes[1] do
      local av = BroadPhaseAxes[1][ak]
      --Helper for keeping axes up to date with main list of Objects/Devices
      InvBroadPhaseAxes[1][av] = ak

      for bk=ActiveFirst,ak - 1 do
        local bv = BroadPhaseAxes[1][bk]
        --If they are not overlapping on the axis,
        --then ActiveFirst is set to the next object
        if bv.Max[1] < av.Min[1] then
          ActiveFirst = ActiveFirst + 1
        elseif PossibleCollisions[bv] then
          --Adds overlapping pair in PossibleCollisions[ObjectA][ObjectB] = 1 style
          PossibleCollisions[bv][av] = 1
        else
          PossibleCollisions[bv] = {[av] = 1}
        end
      end
    end

    InvBroadPhaseAxes[2][BroadPhaseAxes[2][1]] = 1
    ActiveFirst = 1

    --Loop that goes through every Object in second axis
    for ak=2,#BroadPhaseAxes[2] do
      local av = BroadPhaseAxes[2][ak]
      --Helper for keeping axes up to date with main list of Objects/Devices
      InvBroadPhaseAxes[2][av] = ak

      for bk=ActiveFirst,ak - 1 do
        local bv = BroadPhaseAxes[2][bk]
        --If they are not overlapping on the axis,
        --then ActiveFirst is set to the next object
        if bv.Max[2] < av.Min[2] then
          ActiveFirst = ActiveFirst + 1
        elseif PossibleCollisions[bv] and PossibleCollisions[bv][av] == 1 then
          --if theres already a pair, it sets it to two
          PossibleCollisions[bv][av] = 2
        elseif PossibleCollisions[av] and PossibleCollisions[av][bv] == 1 then
          PossibleCollisions[av][bv] = 2
        end
      end
    end

    InvBroadPhaseAxes[3][BroadPhaseAxes[3][1]] = 1
    ActiveFirst = 1

    --Finds collisions present on all axes
    --Loop that goes through every Object in third axis
    for ak=2,#BroadPhaseAxes[3] do
      local av = BroadPhaseAxes[3][ak]
      --Helper for keeping axes up to date with main list of Objects/Devices
      InvBroadPhaseAxes[3][av] = ak

      for bk=ActiveFirst,ak - 1 do
        local bv = BroadPhaseAxes[3][bk]
        --If they are not overlapping on the axis,
        --then ActiveFirst is set to the next object
        if bv.Max[3] < av.Min[3] then
          ActiveFirst = ActiveFirst + 1
        elseif (PossibleCollisions[bv] and PossibleCollisions[bv][av] == 2) or
        (PossibleCollisions[av] and PossibleCollisions[av][bv] == 2) then
          --if there's a pair with a value of 2 it puts it in BroadCollisions in
          --BroadCollisions[#BroadCollisions + 1] = {ObjectA, ObjectB} style
          --TODO: Smaller if statement
          BroadCollisions[#BroadCollisions + 1] = bv
          BroadCollisions[#BroadCollisions + 1] = av
        end
      end
    end
    return BroadCollisions
  end
  return GiveBack
end
