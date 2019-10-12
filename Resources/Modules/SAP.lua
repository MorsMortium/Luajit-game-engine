return function(args)
  local AllDevices, Globals = args[1], args[2]
  local Globals = Globals.Library.Globals
  local floor, insert, sort, CollisionPairs, remove, BroadPhaseAxes, pairs =
  Globals.floor, Globals.insert, Globals.sort, AllDevices.Space.CollisionPairs,
  Globals.remove, AllDevices.Space.BroadPhaseAxes, Globals.pairs

  local GiveBack = {}

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

  --Faster than lua's quicksort for partially sorted lists
  local function InsertionSort(Array, Command)
    local Changed = {}
    for ak = 2, #Array do
      local av = Array[ak]
      local bk = ak - 1
      while bk > 0 and Command(av, Array[bk]) do
        Array[bk + 1] = Array[bk]
        bk = bk - 1
      end
      if ak ~= bk + 1 then
        Changed[#Changed + 1], Changed[#Changed + 2] = bk + 1, av
      end
      Array[bk + 1] = av
    end
    return Changed
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
    local Place = Binary(Table, Value, Command)
    insert(Table, Place, Value)
    return Place, Value
  end

  local function AABB(a, b)
    return
    (a.Min[1] < b.Max[1] and a.Max[1] > b.Min[1]) and
    (a.Min[2] < b.Max[2] and a.Max[2] > b.Min[2]) and
    (a.Min[3] < b.Max[3] and a.Max[3] > b.Min[3])
  end

  local function FindNewPairs(List, Place, Axis)
    local NewPairs, Object = {}, List[Place]
    for ak=Place + 1,#List do
      local av = List[ak]
      if Object.Max[Axis] < av.Min[Axis] then
        break
      elseif AABB(Object, av) then
        NewPairs[#NewPairs + 1] = av
        --NewPairs[av] = 1
      end
    end
    for ak=Place - 1,1, -1 do
      local av = List[ak]
      if Object.Min[Axis] > av.Max[Axis] then
        break
      elseif AABB(Object, av) then
        NewPairs[#NewPairs + 1] = av
        --NewPairs[av] = 1
      end
    end
    return NewPairs
  end

  local function ReplacePairs(Changed, List, Axis)
    for ak=1,#Changed,2 do
      local av = Changed[ak]
      local av2 = Changed[ak + 1]
      local NewPairs = FindNewPairs(List, av, Axis)
      if not CollisionPairs[av2] then
        CollisionPairs[av2] = {}
        CollisionPairs[#CollisionPairs + 1] = av2
        CollisionPairs[av2].Num = #CollisionPairs
      else
        local Num = CollisionPairs[av2].Num
        CollisionPairs[av2] = {}
        CollisionPairs[av2].Num = Num
      end
      for bk=1,#NewPairs do
        local bv = NewPairs[bk]
        CollisionPairs[av2][bv] = 1
        CollisionPairs[av2][#CollisionPairs[av2] + 1] = bv
        if not CollisionPairs[bv] then
          CollisionPairs[bv] = {}
          CollisionPairs[#CollisionPairs + 1] = bv
          CollisionPairs[bv].Num = #CollisionPairs
        end
        CollisionPairs[bv][av2] = 1
        CollisionPairs[bv][#CollisionPairs[bv] + 1] = av2
      end
    end
  end

  --Updates lists of objects
  function GiveBack.Update()
    for ak=1,3 do
      local av = BroadPhaseAxes[ak]
      local bk = 1
      while bk <= #av do
        local bv = av[bk]
        if AllDevices.Space.DestroyedObjects[bv] then
          remove(av, bk)
          if CollisionPairs[bv] then
            remove(CollisionPairs, CollisionPairs[bv].Num)
            CollisionPairs[bv] = nil
          end
        else
          bk = bk + 1
        end
      end
      bk = nil
      --Sorts lists
      local Changed = InsertionSort(av, Sorts[ak])
      ReplacePairs(Changed, av, ak)
      Changed = {}
      sort(AllDevices.Space.CreatedObjects, Sorts[ak])
      for bk=1,#AllDevices.Space.CreatedObjects do
        local bv = AllDevices.Space.CreatedObjects[bk]
        Changed[#Changed + 1], Changed[#Changed + 2] =
        BinaryInsert(av, bv, Binaries[ak])
      end
      ReplacePairs(Changed, av, ak)
    end
  end
  return GiveBack
end
