local GiveBack = {}
local function LoadModules(Modules)
	if type(Modules) == "table" then
		for ak=1,#Modules do
			local av = Modules[ak]
			Data[av.name].Library = nil
			Data[av.name].Library = require(av.Path)
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
function GiveBack.RequireAll(Requirements, Data)
	for ak=1,#Requirements do
		local av = Requirements[ak]
		local Ran, LibraryOrError = pcall(require, av.Path)
		if Ran and LibraryOrError then
			Data[av.Name] = {}
			Data[av.Name].Library = LibraryOrError
			Data[av.Name].StartStopSpace = av.StartStopSpace
		else
			io.write(LibraryOrError, "\n")
		end
	end
	return LoadConfigurations(Requirements, Data.LON)
end
local function RequCalc(MainTable, Table)
	local Give = {}
	if type(Table) == "table" and type(Table.Space) == "table" then
		Give[1] = Table.Space
	end
	if type(Table) == "table" and type(Table.Library) == "table" and
	type(Table.Library.Requirements) == "table" then
		for ak=1,#Table.Library.Requirements do
			local av = Table.Library.Requirements[ak]
			if type(MainTable[av]) == "table" and
			type(MainTable[av].Library) == "table" and
			type(MainTable[av].Library.Requirements) == "table" then
				Give[#Give + 1] = MainTable[av]
				Give[#Give + 1] = RequCalc(MainTable, MainTable[av])
			else
				Give[#Give + 1] = MainTable[av]
				Give[#Give + 1] = true
			end
		end
	end
	return Give
end
local function RequList(MainTable, Table)
	local List = {}
	if type(Table) == "table" and type(Table.Library) == "table" and
	type(Table.Library.Requirements) == "table" then
		for ak=1,#Table.Library.Requirements do
			local av = Table.Library.Requirements[ak]
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
			type(MainTable[av].Library) == "table" and
			type(MainTable[av].Library.Requirements) == "table" then
				local PlusRequ = MainTable[av].Library.Requirements
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
function GiveBack.StartAll(Data, Order, Configurations)
	local Pending
	local Change = true
	local turn = 0
	while Change do
		turn = turn + 1
		Pending = false
		Change = false
		for ak, av in pairs(Data) do
			if not av.Started then
				local Allrequisgood = true
				if type(av) == "table" and type(av.Library) == "table" and
				type(av.Library.Requirements) == "table" then
					for bk=1,#av.Library.Requirements do
						local bv = av.Library.Requirements[bk]
						if Data[bv] == nil or not Data[bv].Started then
							Allrequisgood = false
						end
					end
				end
				if Allrequisgood then
					Order[#Order + 1] = ak
					if av.StartStopSpace then
						Change = true
						av.Space = {}
						av.Library.Start(Configurations[ak], RequCalc(Data, av))
						av.Started = true
					else
						Change = true
						av.Started = true
					end
				else
					Pending = true
				end
			end
		end
	end
	return Pending
end
function GiveBack.PrintBadModules(Data)
	local NotLoaded = {}
	io.write("Error, not loaded Modules:\n")
	for ak, av in pairs(Data) do
		if av.Started == nil then
			NotLoaded[#NotLoaded + 1] = ak
			io.write(ak, "\n")
		end
	end
	io.write("Needed by:\n")
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
				io.write(ak, "\n")
			end
		end
	end
end
function GiveBack.PrintCauses(Data)
	io.write("Caused by:\n")
	for ak,av in pairs(Data) do
		if type(av.Library) == "table" and av.Library.Requirements then
			for bk,bv in pairs(av.Library.Requirements) do
				if Data[bv] == nil then
					io.write("Missing module:", bv, "\n")
				end
			end
		end
	end
	local FullDepPerModule = {}
	for ak,av in pairs(Data) do
		if not av.Started and type(av.Library) == "table" and av.Library.Requirements then
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
				io.write("Cross dependency:", av.Name, " ", bv.Name, "\n")
			end
		end
	end
end
function GiveBack.StopAll(Data, Order)
	for ak=(#Order),1,-1 do
		local av = Order[ak]
		if type(Data[av]) == "table" and type(Data[av].Library) == "table" and
		type(Data[av].Library.Stop) == "function" then
			Data[av].Library.Stop(RequCalc(Data, Data[av]))
			Data[av].Space = nil
		end
		Data[av] = nil
	end
end
function GiveBack.LoadLibrary(Name, Command, Data)
	local LauncherUtilities = Data.LauncherUtilities.Library
	if type(Data[Name]) == "table" and Data[Name].Started then
		return Data[Name].Library[Command], RequCalc(Data, Data[Name])
	end
	return loadstring("if not no" .. Name .. "print then io.write('" .. Name ..
	"' .. ' not found\n') no" .. Name .. "print = true return true end"), {}
end
return GiveBack
