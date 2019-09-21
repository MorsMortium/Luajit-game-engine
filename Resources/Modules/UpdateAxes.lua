return function(args)
  local AllDevices, Globals = args[1], args[2]
  local Globals = Globals.Library.Globals
  local floor, insert = Globals.floor, Globals.insert
  local GiveBack = {}

  function GiveBack.Reload(args)
    AllDevices, Globals = args[1], args[2]
    Globals = Globals.Library.Globals
    floor, insert = Globals.floor, Globals.insert
  end

  --Sorting functions for sweep and prune broad phase collision detection
  local function SortX(Object1, Object2)
    return Object1.Min[1] < Object2.Min[1]
  end

  local function SortY(Object1, Object2)
    return Object1.Min[2] < Object2.Min[2]
  end

  local function SortZ(Object1, Object2)
    return Object1.Min[3] < Object2.Min[3]
  end

  local Sorts = {SortX, SortY, SortZ}
  SortX, SortY, SortZ = nil, nil, nil

  local function RemoveSort(Number1, Number2)
    return Number2 < Number1
  end

  --Faster than lua's quicksort
  --TODO:Timsort
  local function InsertionSort(Array, Command)
    for ak = 2, #Array do
      local av = Array[ak]
      local bk = ak - 1
      while bk > 0 and Command(av, Array[bk]) do
        Array[bk + 1] = Array[bk]
        bk = bk - 1
      end
      Array[bk + 1] = av
    end
  end

  local function remove(Table, Index)
    for ak=Index,#Table - 1 do
      Table[ak] = Table[ak + 1]
    end
    Table[#Table] = nil
  end

  local function BinaryC(Number1, Number2)
    if Number2 > Number1 then
  		return -1
  	elseif Number2 < Number1 then
  		return 1
  	end
  	return 0
  end

  local function BinaryX(Object1, Object2)
    return BinaryC(Object1.Min[1], Object2.Min[1])
  end

  local function BinaryY(Object1, Object2)
    return BinaryC(Object1.Min[2], Object2.Min[2])
  end

  local function BinaryZ(Object1, Object2)
    return BinaryC(Object1.Min[3], Object2.Min[3])
  end

  local Binaries = {BinaryX, BinaryY, BinaryZ}
  BinaryX, BinaryY, BinaryZ = nil, nil, nil

  local function Binary(Table, Value, Command)
    if #Table == 0 then
      return 1
    end
    local MinKey, MaxKey, CheckKey = 1, #Table
    while true do
      CheckKey = floor((MaxKey+MinKey)/2)
      local CompareValue = Command(Table[CheckKey], Value)
      if CompareValue == 0 then
        return CheckKey
      elseif CompareValue > 0 then
        MinKey = CheckKey + 1
        if MinKey > MaxKey then
          return MinKey
        end
      else
        MaxKey = CheckKey - 1
        if MinKey > MaxKey then
          return CheckKey
        end
      end
    end
  end

  local function BinaryInsert(Table, Value, Command)
    insert(Table, Binary(Table, Value, Command), Value)
  end

  --Updates lists of objects
  function GiveBack.Update()
    local InvBroadPhaseAxes, BroadPhaseAxes =
    AllDevices.Space.InvBroadPhaseAxes, AllDevices.Space.BroadPhaseAxes
    local DestroyIndices = {{}, {}, {}}
    for ak=1,3 do
      for bk=1,#AllDevices.Space.DestroyedObjects do
        DestroyIndices[ak][#DestroyIndices[ak] + 1] = InvBroadPhaseAxes[ak][AllDevices.Space.DestroyedObjects[bk]]
      end
      InsertionSort(DestroyIndices[ak], RemoveSort)
      for bk=1,#DestroyIndices[ak] do remove(BroadPhaseAxes[ak], DestroyIndices[ak][bk]) end

      --Sorts lists
      InsertionSort(BroadPhaseAxes[ak], Sorts[ak])

      for bk=1,#AllDevices.Space.CreatedObjects do
        local bv = AllDevices.Space.CreatedObjects[bk]
        BinaryInsert(BroadPhaseAxes[ak], bv, Binaries[ak])
      end
    end
    AllDevices.Space.InvBroadPhaseAxes = {{}, {}, {}}
  end
  return GiveBack
end
