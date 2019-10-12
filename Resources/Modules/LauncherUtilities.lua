local GiveBack = {}

local pairs, pcall, require, type, write, loadstring = pairs, pcall, require,
type, io.write, loadstring
local Order = {}

local function RequCalc(MainTable, Table)
	local Give = {}
  if Table.StartStopSpace then
		Give[1] = Table.Space
	end
	if Table.Requirements then
		for ak=1,#Table.Requirements do
			local av = Table.Requirements[ak]
      Give[#Give + 1] = MainTable[av]
		end
	end
	return Give
end

function GiveBack.LoadModules(Modules, Data)
	if type(Modules) == "table" then
		for ak=1,#Modules do
			local av = Modules[ak]
			local Ran, LibraryOrError
      package.loaded[av.Path] = nil
      Ran, LibraryOrError = pcall(require, av.Path)
      if Ran and type(LibraryOrError) == "function" then
        Ran, LibraryOrError =
				pcall(LibraryOrError, RequCalc(Data, Data[av.Name]))
      end
      if Ran and LibraryOrError then
        Data[av.Name].Library = LibraryOrError
      end
		end
    --Lazy method, might become slow on higher number of modules
    --TODO: Speed it up by only reloading needed modules
    for ak,av in pairs(Data) do
      if type(av.Function) == "function" then
        av.Library = av.Function(RequCalc(Data, av))
      end
    end
	end
end

local function LoadConfigurations(List, LON)
  local Configurations = {}
  if type(List) == "table" then
    for ak=1,#List do
      local av = List[ak]
      if av.Configuration then
        Configurations[av.Name] = LON.Library.DecodeFromFile(av.Configuration)
      end
    end
  end
	return Configurations
end

local function RequList(MainTable, Table)
	local List = {}
	if type(Table) == "table" and type(Table.Requirements) == "table" then
		for ak=1,#Table.Requirements do
			local av = Table.Requirements[ak]
			local InList = false
			for bk=1,#List do
				local bv = List[bk]
				if bv == av then
					InList = true
					break
				end
			end
			if not InList then
				List[#List + 1] = av
			end
		end
		local ak = 1
		while ak <= #List do
			local av = List[ak]
			if type(MainTable[av]) == "table" and
			type(MainTable[av].Requirements) == "table" then
				local PlusRequ = MainTable[av].Requirements
				for bk=1,#PlusRequ do
					local bv = PlusRequ[bk]
					local InList = false
					for ck=1,#List do
						local cv = List[ck]
						if cv == bv then
							InList = true
							break
						end
					end
					if not InList then
						List[#List + 1] = bv
					end
				end
			end
			ak = ak + 1
		end
	end
	return List
end
local function CompareLists(List1, List2)
	for ak=1,#List1 do
		local av = List1[ak]
		for bk=1,#List2 do
			local bv = List2[bk]
			if av == bv then
				return true
			end
		end
	end
end
local function PrintBadModules(Data)
	local NotLoaded = {}
	write("Error, not loaded Modules:\n")
	for ak, av in pairs(Data) do
		if not av.Started then
			NotLoaded[#NotLoaded + 1] = ak
			write(ak, "\n")
		end
	end
	write("Needed by:\n")
	for ak,av in pairs(Data) do
		if not av.Started then
			local Needs = false
			for bk=1,#NotLoaded do
				local bv = NotLoaded[bk]
				if ak == bv then
					Needs = true
					break
				end
			end
			if Needs then
				write(ak, "\n")
			end
		end
	end
end
local function PrintCauses(Data)
	write("Caused by:\n")
	for ak,av in pairs(Data) do
		if type(av.Library) == "table" and av.Requirements then
			for bk,bv in pairs(av.Requirements) do
				if Data[bv] == nil then
					write("Missing module:", bv, "\n")
				end
			end
		end
	end
	local FullDepPerModule = {}
	for ak,av in pairs(Data) do
		if not av.Started and type(av.Library) == "table" and av.Requirements then
			FullDepPerModule[#FullDepPerModule + 1] = {Name = ak}
			FullDepPerModule[#FullDepPerModule].FullDep =
			RequList(Data, av)
		end
	end
	for ak=1,#FullDepPerModule do
		local av = FullDepPerModule[ak]
		for bk=ak + 1,#FullDepPerModule do
			local bv = FullDepPerModule[bk]
			if CompareLists(av.FullDep, bv.FullDep) then
				write("Cross dependency:", av.Name, " ", bv.Name, "\n")
			end
		end
	end
end
function GiveBack.StartAll(Data, Modules)
	local Configurations = LoadConfigurations(Modules, Data.LON)
	local Pending
	local Change = true
	while Change do
		Pending = false
		Change = false
		for ak=1,#Modules do
			local av = Modules[ak]
			if not Data[av.Name] then
				Data[av.Name] = {}
				Data[av.Name].StartStopSpace = av.StartStopSpace
				Data[av.Name].Requirements = av.Requirements
				if Data[av.Name].StartStopSpace then
					Data[av.Name].Space = {}
				end
			end
			if not Data[av.Name].Started then
				local AllRequIsStarted = true
				if type(Data[av.Name].Requirements) == "table" then
					for bk=1,#Data[av.Name].Requirements do
						local bv = Data[av.Name].Requirements[bk]
						if Data[bv] == nil or
						(type(Data[bv]) == "table" and not Data[bv].Started) then
							AllRequIsStarted = false
						end
					end
				end
				if AllRequIsStarted then
					local Ran, LibraryOrError = pcall(require, av.Path)
					if Ran and type(LibraryOrError) == "function" then
						Data[av.Name].Function = LibraryOrError
						Ran, LibraryOrError =
						pcall(LibraryOrError, RequCalc(Data, Data[av.Name]))
						if Ran and LibraryOrError then
							Data[av.Name].Library = LibraryOrError
						end
					elseif Ran then
						Data[av.Name].Library = LibraryOrError
					end
					if Ran then
						Order[#Order + 1] = av.Name
						Change = true
						Data[av.Name].Started = true
						if av.StartStopSpace then
							Data[av.Name].Library.Start(Configurations[av.Name])
						end
						write(av.Name, " Started\n")
					else
						Pending = true
					end
				else
					Pending = true
				end
			end
		end
	end
	if Pending then
		PrintBadModules(Data)
		PrintCauses(Data)
	end
end
function GiveBack.StopAll(Data)
	for ak=(#Order),1,-1 do
		local av = Order[ak]
		if type(Data[av]) == "table" and type(Data[av].Library) == "table" and
		type(Data[av].Library.Stop) == "function" then
			Data[av].Library.Stop()
			Data[av].Space = nil
		end
		Data[av] = nil
		write(av, " Stopped\n")
	end
end
local function CreateErrorMessage(Name, Command)
	local name, command = Name, Command
	local function ErrorMessage()
		if not _G[name .. command] then
			_G[name .. command] = true
			write(("%s and %s not found\n"):format(name, command))
		end
		return true
	end
	return ErrorMessage
end
function GiveBack.LoadLibrary(Name, Command, Data)
	if Data[Name] and Data[Name].Started and
	Data[Name].Library and Data[Name].Library[Command] then
		return Data[Name].Library[Command]
	end
	return CreateErrorMessage(Name, Command)
end

return GiveBack
