return function(args)
  local AllDevices = args[1]
  local GiveBack = {}

  function GiveBack.Reload(args)
    AllDevices = args[1]
  end

  function GiveBack.DetectCollisions()
    local InvBroadPhaseAxes, BroadPhaseAxes =
    AllDevices.Space.InvBroadPhaseAxes, AllDevices.Space.BroadPhaseAxes
    local PossibleCollisions, BroadCollisions = {}, {}
    --ActiveList is a linked list (list[a] = b) with objects to check with the
    --Recent Object
    --Head is the first element in ActiveList
    local ActiveList, Head = {}, BroadPhaseAxes[1][1]

    --Loop that goes through every Object in first axis
    for ak=1,#BroadPhaseAxes[1] do

      --Helper for keeping axes up to date with main list of Objects/Devices
      InvBroadPhaseAxes[1][BroadPhaseAxes[1][ak]] = ak

      --Current is the Object to test with the Recent Object given by the loop
      --It goes from Head to the last Object in ActiveList
      local Current = Head

      --Loop that goes through every Object in ActiveList
      while ActiveList[Current] do

        --If they are not overlapping on the axis, then Head is set to the next
        --Object (Removing from ActiveList)
        if Current.Max[1] < BroadPhaseAxes[1][ak].Min[1] then
          Head = ActiveList[Head]
        elseif PossibleCollisions[Current] then
        --Adds overlapping pair in PossibleCollisions[ObjectA][ObjectB] = 1 style
        PossibleCollisions[Current][BroadPhaseAxes[1][ak]] = 1
        else
          PossibleCollisions[Current] = {[BroadPhaseAxes[1][ak]] = 1}
        end
        Current = ActiveList[Current]
      end
      ActiveList[Current] = BroadPhaseAxes[1][ak + 1]
    end

    ActiveList, Head = {}, BroadPhaseAxes[2][1]

    --Loop that goes through every Object in second axis
    for ak=1,#BroadPhaseAxes[2] do

      --Helper for keeping axes up to date with main list of Objects/Devices
      InvBroadPhaseAxes[2][BroadPhaseAxes[2][ak]] = ak

      --Current is the Object to test with the Recent Object given by the loop
      --It goes from Head to the last Object in ActiveList
      local Current = Head

      --Loop that goes through every Object in ActiveList
      while ActiveList[Current] do

        --If they are not overlapping on the axis, then Head is set to the next
        --Object (Removing from ActiveList)
        if Current.Max[2] < BroadPhaseAxes[2][ak].Min[2] then
          Head = ActiveList[Head]
        elseif PossibleCollisions[Current] and PossibleCollisions[Current][BroadPhaseAxes[2][ak]] then
          --if theres already a pair, it sets it to two
          PossibleCollisions[Current][BroadPhaseAxes[2][ak]] = 2
        elseif PossibleCollisions[BroadPhaseAxes[2][ak]] and PossibleCollisions[BroadPhaseAxes[2][ak]][Current] then
          PossibleCollisions[BroadPhaseAxes[2][ak]][Current] = 2
        end
        Current = ActiveList[Current]
      end
      ActiveList[Current] = BroadPhaseAxes[2][ak + 1]
    end

    ActiveList, Head = {}, BroadPhaseAxes[3][1]

    --Finds collisions present on all axes
    --Loop that goes through every Object in third axis
    for ak=1,#BroadPhaseAxes[3] do

      --Helper for keeping axes up to date with main list of Objects
      InvBroadPhaseAxes[3][BroadPhaseAxes[3][ak]] = ak

      --Current is the Object to test with the Recent Object given by the loop
      --It goes from Head to the last Object in ActiveList
      local Current = Head

      --Loop that goes through every Object in ActiveList
      while ActiveList[Current] do

        --If they are not overlapping on the axis, then Head is set to the next
        --value
        if Current.Max[3] < BroadPhaseAxes[3][ak].Min[3] then
          Head = ActiveList[Head]
        elseif PossibleCollisions[Current] and PossibleCollisions[Current][BroadPhaseAxes[3][ak]] == 2 or
        PossibleCollisions[BroadPhaseAxes[3][ak]] and PossibleCollisions[BroadPhaseAxes[3][ak]][Current] == 2 then
          --if there's a pair with a value of 2 it puts it in BroadCollisions in
          --BroadCollisions[#BroadCollisions + 1] = {ObjectA, ObjectB} style
          --TODO: Smaller if statement
          BroadCollisions[#BroadCollisions + 1] = {Current, BroadPhaseAxes[3][ak]}
        end
        Current = ActiveList[Current]
      end
      ActiveList[Current] = BroadPhaseAxes[3][ak + 1]
    end
    return BroadCollisions
  end
  return GiveBack
end
