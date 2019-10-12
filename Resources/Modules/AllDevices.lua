return function(args)
	local Space, LON, General, Device, Object, Globals, Math = args[1], args[2],
	args[3], args[4], args[5], args[6], args[7]
	local Globals, Device, General, Math = Globals.Library.Globals,
	Device.Library, General.Library, Math.Library
	local Copy, Merge, Create, UpdateObject, GoodTypesOfTable, pcall,
	remove, type = Device.Copy, Device.Merge, Device.Create,
	General.UpdateObject, General.GoodTypesOfTable,
	Globals.pcall, Globals.remove, Globals.type

	local GiveBack = {}

	--Adds an Object or multiple Objects to a Device (merges two Devices)
	function GiveBack.AddObject(DeviceID, DeviceName, DeviceMod)
		local DeviceIndex = #Space.Devices
		if type(DeviceID) == "number" and
		0 < DeviceID and DeviceID < #Space.Devices then
			DeviceIndex = DeviceID
		end
		local DeviceSource = Space.DeviceTypes.Default
		if Space.DeviceTypes[DeviceName] then
			DeviceSource = Space.DeviceTypes[DeviceName]
		end
		if Space.MaxObjects < Space.NumberOfObjects + #DeviceSource.Objects then
			return
		end
		Space.NumberOfObjects = Space.NumberOfObjects + #DeviceSource.Objects
		local NewDevice = Copy(DeviceSource)
		if DeviceMod then
			pcall(DeviceMod.Command, NewDevice, DeviceMod.Creator, Math, Globals)
			for ak=1,#NewDevice.Objects do
				local av = NewDevice.Objects[ak]
				av.ScaleCalc, av.RotationCalc, av.TranslationCalc = true, true, true
				UpdateObject(av)
			end
		end
		for ak=1,#NewDevice.Objects do
			local av = NewDevice.Objects[ak]
			Space.CreatedObjects[#Space.CreatedObjects + 1] = av
		end
		Merge(Space.Devices[DeviceID], NewDevice)
	end

	--Adds a new Device to the game
	function GiveBack.AddDevice(DeviceName, DeviceMod)
		local DeviceSource = Space.DeviceTypes.Default
		if Space.DeviceTypes[DeviceName] then
			DeviceSource = Space.DeviceTypes[DeviceName]
		end
		if Space.MaxObjects < #DeviceSource.Objects + Space.NumberOfObjects then
			return
		end
		Space.NumberOfObjects = Space.NumberOfObjects + #DeviceSource.Objects
		local NewDevice = Copy(DeviceSource)
		if DeviceMod then
			pcall(DeviceMod.Command, NewDevice, DeviceMod.Creator, Math, Globals)
			for ak=1,#NewDevice.Objects do
	    	local av = NewDevice.Objects[ak]
				av.ScaleCalc, av.RotationCalc, av.TranslationCalc = true, true, true
	    	UpdateObject(av)
	  	end
		end
		Space.Devices[#Space.Devices + 1] = NewDevice
		for ak=1,#NewDevice.Objects do
			local av = NewDevice.Objects[ak]
			Space.CreatedObjects[#Space.CreatedObjects + 1] = av
		end
	end

	--Creates every Device with Device.lua
	function GiveBack.Start(Configurations)
		Space.Devices = {}
		Space.CollisionPairs = {}
		Space.DeviceTypes = {}
		Space.CreatedObjects = {}
		Space.DestroyedObjects = {}
		Space.BroadPhaseAxes = {{}, {}, {}}
		Space.MaxObjects = 100000
		Space.NumberOfObjects = 0
		if type(Configurations) == "table" then
			if type(Configurations.MaxObjects) == "number" then
				Space.MaxObjects = Configurations.MaxObjects
			end
			for ak=1,#Configurations.DeviceTypes do
				local av = Configurations.DeviceTypes[ak]
				local NewDevice =
				LON.Library.DecodeFromFile(("AllDevices/%s.lon"):format(av))
				if type(NewDevice) == "table" and NewDevice.Name then
					Space.DeviceTypes[NewDevice.Name] =
					Create(NewDevice)
				end
			end
			if Space.DeviceTypes.Default == nil then
				local NewDevice = LON.Library.DecodeFromFile("AllDevices/Default.lon")
				Space.DeviceTypes.Default =
				Create(NewDevice)
			end
			if GoodTypesOfTable(Configurations.Devices, "string") then
				for ak=1,#Configurations.Devices do
					local av = Configurations.Devices[ak]
					GiveBack.AddDevice(av)
				end
			end
		else
			local NewDevice = LON.Library.DecodeFromFile("AllDevices/Default.lon")
			Space.DeviceTypes.Default =
			Create(NewDevice)
			GiveBack.AddDevice("Default")
		end
		--[[
		Space.DeviceTypes.Hand =
		Create(OBJ.Library.makedevice("./Resources/hand.obj", "Hand"))
		GiveBack.AddDevice("Hand")
		--]]
	end

	--Removes one Object from a Device
	function GiveBack.RemoveObject(DeviceID, ObjectID)
		local DeviceIndex = #Space.Devices
		if type(DeviceID) == "number" and
		0 < DeviceID and DeviceID < #Space.Devices then
			DeviceIndex = DeviceID
		end
		local ObjectIndex = #Space.Devices[DeviceIndex].Objects
		if type(ObjectID) == "number" and
		0 < ObjectID and ObjectID < #Space.Devices[DeviceIndex].Objects then
			ObjectIndex = ObjectID
		end
		local Objects = Space.Devices[DeviceIndex].Objects
		Space.DestroyedObjects[#Space.DestroyedObjects + 1] = Objects[ObjectIndex]
		Space.DestroyedObjects[Objects[ObjectIndex]] = true
		remove(Objects, ObjectIndex)
	end

	--Removes a Device from the game
	function GiveBack.RemoveDevice(DeviceID)
		local DeviceIndex = #Space.Devices
		if type(DeviceID) == "number" and
		0 < DeviceID and DeviceID <= #Space.Devices then
			DeviceIndex = DeviceID
		end
		for ak=1,#Space.Devices[DeviceIndex].Objects do
			local av = Space.Devices[DeviceIndex].Objects[ak]
			Space.DestroyedObjects[#Space.DestroyedObjects + 1] = av
			Space.DestroyedObjects[av] = true
		end
		remove(Space.Devices, DeviceIndex)
	end
	function GiveBack.Stop()
	end

	--Clears created and destroyed Objects list (CollisionDetection and AllPowers)
	function GiveBack.ClearObjectChanges()
		Space.CreatedObjects = {}
		Space.DestroyedObjects = {}
	end
	return GiveBack
end
