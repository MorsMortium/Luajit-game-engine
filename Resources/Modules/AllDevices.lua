local GiveBack = {}

--Adds an Object or multiple Objects to a Device (merges two Devices)
function GiveBack.AddObject(DeviceID, DeviceName, ModifierForDevice, Arguments)
	local Space, General, GeneralGive, Device, DeviceGive = Arguments[1],
	Arguments[4], Arguments[5], Arguments[6], Arguments[7]
	local Copy, Merge = Device.Library.Copy, Device.Library.Merge
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
	local NewDevice = Copy(DeviceSource, DeviceGive)
	if ModifierForDevice then
		pcall(ModifierForDevice.Command, NewDevice, ModifierForDevice.Creator, General)
		for ak=1,#NewDevice.Objects do
			local av = NewDevice.Objects[ak]
			av.ScaleCalc, av.RotationCalc, av.TranslationCalc = true, true, true
			General.Library.UpdateObject(av, GeneralGive)
		end
	end
	for ak=1,#NewDevice.Objects do
		local av = NewDevice.Objects[ak]
		Space.CreatedObjects[#Space.CreatedObjects + 1] = av
	end
	Merge(Space.Devices[DeviceID], NewDevice, DeviceGive)
end

--Adds a new Device to the game
function GiveBack.AddDevice(DeviceName, ModifierForDevice, Arguments)
	local Space, General, GeneralGive, Device, DeviceGive = Arguments[1],
	Arguments[4], Arguments[5], Arguments[6], Arguments[7]
	local Copy = Device.Library.Copy
	local DeviceSource = Space.DeviceTypes.Default
	if Space.DeviceTypes[DeviceName] then
		DeviceSource = Space.DeviceTypes[DeviceName]
	end
	if Space.MaxNumberOfObjects < #DeviceSource.Objects + Space.NumberOfObjects then
		return
	end
	Space.NumberOfObjects = Space.NumberOfObjects + #DeviceSource.Objects
	local NewDevice = Copy(DeviceSource, DeviceGive)
	if ModifierForDevice then
		pcall(ModifierForDevice.Command, NewDevice, ModifierForDevice.Creator, General)
		for ak=1,#NewDevice.Objects do
	    local av = NewDevice.Objects[ak]
			av.ScaleCalc, av.RotationCalc, av.TranslationCalc = true, true, true
	    General.Library.UpdateObject(av, GeneralGive)
	  end
	end
	Space.Devices[#Space.Devices + 1] = NewDevice
	for ak=1,#NewDevice.Objects do
		local av = NewDevice.Objects[ak]
		Space.CreatedObjects[#Space.CreatedObjects + 1] = av
	end
end

--Creates every Device with Device.lua
function GiveBack.Start(Configurations, Arguments)
	local Space, LON, General, Device, DeviceGive, OBJ = Arguments[1],
	Arguments[2], Arguments[4], Arguments[6], Arguments[7], Arguments[10]
	Space.Devices = {}
	Space.DeviceTypes = {}
	Space.CreatedObjects = {}
	Space.DestroyedObjects = {}
	Space.BroadPhaseAxes = {{}, {}, {}}
	Space.InvBroadPhaseAxes = {{}, {}, {}}
	Space.MaxNumberOfObjects = 100000
	Space.NumberOfObjects = 0
	local AllDevices = Configurations
	if type(AllDevices) == "table" then
		if type(AllDevices.MaxNumberOfObjects) == "number" then
			Space.MaxNumberOfObjects = AllDevices.MaxNumberOfObjects
		end
		for ak=1,#AllDevices.DeviceTypes do
			local av = AllDevices.DeviceTypes[ak]
			local NewDevice = LON.Library.DecodeFromFile("AllDevices/" .. av .. ".lon")
			if type(NewDevice) == "table" and NewDevice.Name then
				Space.DeviceTypes[NewDevice.Name] =
				Device.Library.Create(NewDevice, DeviceGive)
			end
		end
		if Space.DeviceTypes.Default == nil then
			local NewDevice = LON.Library.DecodeFromFile("AllDevices/Default.lon")
			Space.DeviceTypes.Default =
			Device.Library.Create(NewDevice, DeviceGive)
		end
		if General.Library.GoodTypesOfTable(AllDevices.Devices, "string") then
			for ak=1,#AllDevices.Devices do
				local av = AllDevices.Devices[ak]
				GiveBack.AddDevice(av, nil, Arguments)
			end
		end
	else
		local NewDevice = LON.Library.DecodeFromFile("AllDevices/Default.lon")
		Space.DeviceTypes.Default =
		Device.Library.Create(NewDevice, DeviceGive)
		GiveBack.AddDevice("Default", nil, Arguments)
	end
	--[[
	Space.DeviceTypes.Hand =
	Device.Library.Create(OBJ.Library.makedevice("./Resources/hand.obj", "Hand"), DeviceGive)
	GiveBack.AddDevice("Hand", nil, Arguments)
	--]]
	io.write("AllDevices Started\n")
end

--Removes one Object from a Device
function GiveBack.RemoveObject(DeviceID, ObjectID, Arguments)
	local Space, Object, ObjectGive = Arguments[1], Arguments[8], Arguments[9]
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
	Object.Library.Destroy(RObjects[ObjectIndex], ObjectGive)
	table.remove(RObjects, ObjectIndex)
end

--Removes a Device from the game
function GiveBack.RemoveDevice(DeviceID, Arguments)
	local Space, Device, DeviceGive = Arguments[1], Arguments[6], Arguments[7]
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
	Device.Library.Destroy(Devices[DeviceIndex], DeviceGive)
	table.remove(Devices, DeviceIndex)
end
function GiveBack.Stop(Arguments)
	local Space, Device, DeviceGive = Arguments[1], Arguments[6],
	Arguments[7]
	for ak=1,#Space.Devices do
		local av = Space.Devices[ak]
		Device.Library.Destroy(av, DeviceGive)
	end
	io.write("AllDevices Stopped\n")
end

--Clears created and destroyed Objects list (CollisionDetection and AllPowers)
function GiveBack.ClearObjectChanges(Arguments)
	local Space = Arguments[1]
	Space.CreatedObjects = {}
	Space.DestroyedObjects = {}
end

GiveBack.Requirements = {"LON", "General", "Device", "Object", "OBJ"}
return GiveBack
