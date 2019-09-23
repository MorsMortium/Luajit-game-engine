return function(args)
	local Space, LON, General, Device, Object, Globals, Math = args[1], args[2],
	args[3], args[4], args[5], args[6], args[7]
	local Globals = Globals.Library.Globals
	local Copy, Merge, Create, Destroy, UpdateObject, GoodTypesOfTable, pcall,
	remove, type = Device.Library.Copy, Device.Library.Merge, Device.Library.Create,
	Device.Library.Destroy, General.Library.UpdateObject,
	General.Library.GoodTypesOfTable, Globals.pcall, Globals.remove, Globals.type
	local GiveBack = {}

	function GiveBack.Reload(args)
		Space, LON, General, Device, Object, Globals, Math = args[1], args[2],
		args[3], args[4], args[5], args[6], args[7]
		Globals = Globals.Library.Globals
		Copy, Merge, Create, Destroy, UpdateObject, GoodTypesOfTable, pcall,
		remove, type = Device.Library.Copy, Device.Library.Merge, Device.Library.Create,
		Device.Library.Destroy, General.Library.UpdateObject,
		General.Library.GoodTypesOfTable, Globals.pcall, Globals.remove, Globals.type
	end

	--Adds an Object or multiple Objects to a Device (merges two Devices)
	function GiveBack.AddObject(DeviceID, DeviceName, ModifierForDevice)
		local DeviceIndex = #Space.Devices
		if type(DeviceID) == "number" and
		0 < DeviceID and DeviceID < #Space.Devices then
			DeviceIndex = DeviceID
		end
		local DeviceSource = Space.DeviceTypes.Default
		if Space.DeviceTypes[DeviceName] then
			DeviceSource = Space.DeviceTypes[DeviceName]
		end
		if Space.MaxNumberOfObjects < #DeviceSource.Objects + Space.NumberOfObjects then
			return
		end
		Space.NumberOfObjects = Space.NumberOfObjects + #DeviceSource.Objects
		local NewDevice = Copy(DeviceSource)
		if ModifierForDevice then
			pcall(ModifierForDevice.Command, NewDevice, ModifierForDevice.Creator, Math, Globals)
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
	function GiveBack.AddDevice(DeviceName, ModifierForDevice)
		local DeviceSource = Space.DeviceTypes.Default
		if Space.DeviceTypes[DeviceName] then
			DeviceSource = Space.DeviceTypes[DeviceName]
		end
		if Space.MaxNumberOfObjects < #DeviceSource.Objects + Space.NumberOfObjects then
			return
		end
		Space.NumberOfObjects = Space.NumberOfObjects + #DeviceSource.Objects
		local NewDevice = Copy(DeviceSource)
		if ModifierForDevice then
			pcall(ModifierForDevice.Command, NewDevice, ModifierForDevice.Creator, Math, Globals)
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
		Space.DeviceTypes = {}
		Space.CreatedObjects = {}
		Space.DestroyedObjects = {}
		Space.BroadPhaseAxes = {{}, {}, {}}
		Space.InvBroadPhaseAxes = {{}, {}, {}}
		Space.MaxNumberOfObjects = 100000
		Space.NumberOfObjects = 0
		if type(Configurations) == "table" then
			if type(Configurations.MaxNumberOfObjects) == "number" then
				Space.MaxNumberOfObjects = Configurations.MaxNumberOfObjects
			end
			for ak=1,#Configurations.DeviceTypes do
				local av = Configurations.DeviceTypes[ak]
				local NewDevice = LON.Library.DecodeFromFile("AllDevices/" .. av .. ".lon")
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
		local RObjects = Space.Devices[DeviceIndex].Objects
		Space.DestroyedObjects[#Space.DestroyedObjects + 1] = RObjects[ObjectIndex]
		Object.Library.Destroy(RObjects[ObjectIndex])
		remove(RObjects, ObjectIndex)
	end

	--Removes a Device from the game
	function GiveBack.RemoveDevice(DeviceID)
		local Devices = Space.Devices
		local DeviceIndex = #Space.Devices
		if type(DeviceID) == "number" and
		0 < DeviceID and DeviceID <= #Space.Devices then
			DeviceIndex = DeviceID
		end
		for ak=1,#Devices[DeviceIndex].Objects do
			local av = Devices[DeviceIndex].Objects[ak]
			Space.DestroyedObjects[#Space.DestroyedObjects + 1] = av
		end
		Destroy(Devices[DeviceIndex])
		remove(Devices, DeviceIndex)
	end
	function GiveBack.Stop()
		for ak=1,#Space.Devices do
			local av = Space.Devices[ak]
			Destroy(av)
		end
	end

	--Clears created and destroyed Objects list (CollisionDetection and AllPowers)
	function GiveBack.ClearObjectChanges()
		Space.CreatedObjects = {}
		Space.DestroyedObjects = {}
	end
	return GiveBack
end
