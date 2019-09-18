local GiveBack = {}

--Path variable
local Path = "./"

--Loads a file, returns its content or nil, in case of error
local function ReadFile(Name)
  local Content = ""
  local File = io.open(Path .. tostring(Name), "r" )
  if (File) then
    Content = File:read("*a")
    File:close()
    return Content
  end
end

--Remove space from end of string
local function rtrim(s)
  local n = #s
  while n > 0 and s:find("^%s", n) do n = n - 1 end
  return s:sub(1, n)
end

local function RemoveAllSpaces(Table)
  for ak,av in pairs(Table) do
    if type(av) == "table" then
      RemoveAllSpaces(av)
    elseif type(av) == "string" then
      Table[ak] = rtrim(av)
    end
  end
end

--Loads file, checks, if it begins with return, runs it, and gives back the table
--Doesn't raise an error, instead prints it and returns nil
function GiveBack.DecodeFromFile(Name)
  local String = ReadFile(Name)
  if String then
    if "return" == String:match("(%w+)(.+)") then
      local DataFunction = loadstring(String)
      local Ran, DataOrError = pcall(DataFunction)
      if Ran and DataOrError then
        if type(DataOrError) == "table" then
          RemoveAllSpaces(DataOrError)
          return DataOrError
        elseif type(DataOrError) == "string" then
          return rtrim(DataOrError)
        else
          return DataOrError
        end
      else
        io.write("LON error in file: ", Path .. tostring(Name), "\n")
        io.write(DataOrError, "\n")
      end
    else
      io.write("LON error in file: ", Path .. tostring(Name), "\n")
      io.write("Return statement not first\n")
    end
  else
    io.write("LON error in file: ", Path .. tostring(Name), "\n")
    io.write("File not found\n")
  end
end

--Helper function for table.sort
local function KeySort(Key1, Key2)
  if type(Key1) == "number" and type(Key2) == "number" then
    return Key1 < Key2
  elseif tonumber(Key1) ~= nil and tonumber(Key2) ~= nil then
    return tonumber(Key1) < tonumber(Key2)
  else
    return tostring(Key1) < tostring(Key2)
  end
end

--Converts a table into a string
--Keys are ordered in abc, numbers first, handles multi digit numbers
--Uses tabs on every subtable, handles arrays differently from hashtables
--Excludes functions as they are read only, handles multiline strings
local function ToString(Table, Tab)
  local Tabs, Result, NumKeysOnly, Keys = 1, "{", true, {}
  if type(Tab) == "number" then
    Tabs = Tab
  end
  --populate the table that holds the keys
  for ak in pairs(Table) do Keys[#Keys + 1] = ak end
  --sort the keys
  table.sort(Keys, KeySort)
  for ak, av in pairs(Table) do
    if type(ak) == "string" then
      NumKeysOnly = false
      Result = "{\n"
    end
  end
  --use the keys to retrieve the values in the sorted order
  for _,ak in ipairs(Keys) do
    local av = Table[ak]
    if type(av) ~= "function" then
      if not NumKeysOnly then Result = Result .. string.rep("\t", Tabs) end
      --Check the key type (ignore any numerical keys - assume its an array)
      if type(ak) == "string" then
        Result = Result .. "[\"" .. ak .. "\"] = "
      end
      --Check the value type
      if type(av) == "table" then
        Result = Result .. ToString(av, Tabs + 1)
      elseif type(av) == "boolean" then
        Result = Result .. tostring(av)
      elseif type(av) == "string" then
        if string.match(av, "\n") then
          if string.sub(av, -1) == "]" then
            Result = Result .. "[[" .. av .. " ]]"
          else
            Result = Result .. "[[" .. av .. "]]"
          end
        else
          Result = Result .. "\"" .. av .. "\""
        end
      else
        Result = Result .. av
      end
      if NumKeysOnly then Result = Result .. ", " else Result = Result .. ",\n" end
    end
  end
  --Remove leading commas from the Result
  if Result ~= "" then
    Result = Result:sub(1, Result:len()-2)
    if not NumKeysOnly then
      Result = Result .. "\n" .. string.rep("\t", Tabs - 1)
    end
  end
  return Result .. "}"
end

--Handles, if it's not a table but another type, that has been passed
local function FullString(Data)
  if type(Data) == "table" then
    return "return" .. ToString(Data) .. "\n"
  elseif type(Data) == "function" then
    return "return\n"
  elseif type(Data) == "string" then
    if string.match(Data, "\n") then
      return "return [[ " .. Data .. " ]]\n"
    else
      return "return \""..Data.."\"\n"
    end
  else
    return "return " .. tostring(Data) .. "\n"
  end
end

--Saves string into file
local function SaveFile(Name, String)
  local File = io.open(Path .. tostring(Name), "w" )
  if File then
    File:write(String)
    File:close()
    return true
  end
end

--Converts table into string, and saves it into the file
--Doesn't raise an error, instead prints it and returns nil
function GiveBack.EncodeToFile(Name, Data)
  local String = FullString(Data)
  if not SaveFile(Name, String) then
    io.write("LON error in file: ", tostring(GiveBack.Path) .. tostring(Name), "\n")
    io.write("Access denied\n")
  end
end

function GiveBack.SetPath(NewPath)
  if type(NewPath) == "string" then
    Path = NewPath
  end
end

function GiveBack.GetPath()
  return Path
end

return GiveBack
