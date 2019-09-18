local GiveBack = {}

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
        Ran, LibraryOrError = pcall(LibraryOrError, RequCalc(Data, Data[av.Name]))
      end
      if Ran and LibraryOrError then
        Data[av.Name].Library = LibraryOrError
      end
		end
    --Lazy method, might become slow on higher number of modules
    --TODO: Speed it up by only reloading needed modules
    for ak,av in pairs(Data) do
      if type(av.Library) == "table" and type(av.Library.Reload) == "function" then
        av.Library.Reload(RequCalc(Data, av))
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
function GiveBack.StartAll(Data, Order, Modules)
	local Configurations = LoadConfigurations(Modules, Data.LON)
	local Pending
	local Change = true
	while Change do
		Pending = false
		Change = false
		for ak=1,#Modules do
			local av = Modules[ak]
			if not Data[av.Name] then
				local Allrequisgood = true
				if type(av.Requirements) == "table" then
					for bk=1,#av.Requirements do
						local bv = av.Requirements[bk]
						if Data[bv] == nil then
							Allrequisgood = false
						end
					end
				end
				if Allrequisgood then
					local Ran, LibraryOrError
          Data[av.Name] = {}
          Data[av.Name].StartStopSpace = av.StartStopSpace
          if av.StartStopSpace then
            Data[av.Name].Space = {}
          end
          if av.Requirements then
            Data[av.Name].Requirements = av.Requirements
          end
          Ran, LibraryOrError = pcall(require, av.Path)
          if Ran and type(LibraryOrError) == "function" then
            Ran, LibraryOrError = pcall(LibraryOrError, RequCalc(Data, Data[av.Name]))
          end
					if Ran and LibraryOrError then
						Data[av.Name].Library = LibraryOrError
						local AllRequIsStarted = true
						if type(av.Requirements) == "table" then
							for bk=1,#av.Requirements do
								local bv = av.Requirements[bk]
								if type(Data[bv]) == "table" and not Data[bv].Started then
									AllRequIsStarted = false
								end
							end
						end
						if AllRequIsStarted then
							Order[#Order + 1] = av.Name
							Change = true
							Data[av.Name].Started = true
							if av.StartStopSpace then
								Data[av.Name].Library.Start(Configurations[av.Name])
							end
							io.write(av.Name, " Started\n")
						else
							Pending = true
						end
					else
						io.write(LibraryOrError, "\n")
						Pending = true
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
		if type(av.Library) == "table" and av.Requirements then
			for bk,bv in pairs(av.Requirements) do
				if Data[bv] == nil then
					io.write("Missing module:", bv, "\n")
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
			Data[av].Library.Stop()
			Data[av].Space = nil
		end
		Data[av] = nil
		io.write(av, " Stopped\n")
	end
end
function GiveBack.LoadLibrary(Name, Command, Data)
	local LauncherUtilities = Data.LauncherUtilities.Library
	if type(Data[Name]) == "table" and Data[Name].Started then
		return Data[Name].Library[Command]
	end
	return loadstring("if not no" .. Name .. "print then io.write('" .. Name ..
	"' .. ' not found\n') no" .. Name .. "print = true return true end"), {}
end

return GiveBack
