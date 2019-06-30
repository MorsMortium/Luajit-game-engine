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
	if Space.DeviceTypes[DeviceName] then
		NewDevice =
		Copy(Space.DeviceTypes[DeviceName], DeviceGive)
	else
		NewDevice =
		Copy(Space.DeviceTypes.Default, DeviceGive)
	end
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
	local NewDevice
	if Space.DeviceTypes[DeviceName] then
		NewDevice =
		Copy(Space.DeviceTypes[DeviceName], DeviceGive)
	else
		NewDevice =
		Copy(Space.DeviceTypes.Default, DeviceGive)
	end
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
function GiveBack.Start(Arguments)
	local Space, JSON, General, Device, DeviceGive, OBJ = Arguments[1],
	Arguments[2], Arguments[4], Arguments[6], Arguments[7], Arguments[10]
	Space.Devices = {}
	Space.DeviceTypes = {}
	Space.CreatedObjects = {}
	local AllDevices = JSON.Library:DecodeFromFile("AllDevices.json")
	if type(AllDevices) == "table" and
	General.Library.GoodTypesOfTable(AllDevices.DeviceTypes, "string") then
		for ak=1,#AllDevices.DeviceTypes do
			local av = AllDevices.DeviceTypes[ak]
			local NewDevice = JSON.Library:DecodeFromFile("AllDevices/" .. av .. ".json")
			if type(NewDevice) == "table" and NewDevice.Name then
				Space.DeviceTypes[NewDevice.Name] =
				Device.Library.Create(NewDevice, DeviceGive)
			end
		end
		if Space.DeviceTypes.Default == nil then
			local NewDevice = JSON.Library:DecodeFromFile("AllDevices/Default.json")
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
		local NewDevice = JSON.Library:DecodeFromFile("AllDevices/Default.json")
		Space.DeviceTypes.Default =
		Device.Library.Create(NewDevice, DeviceGive)
		GiveBack.AddDevice("Default", nil, Arguments)
	end
	--[[
	Space.DeviceTypes.Hand =
	Device.Library.Create(OBJ.Library.makedevice("./Resources/hand.obj", "Hand"), DeviceGive)
	GiveBack.AddDevice("Hand", nil, Arguments)
	--]]
	print("AllDevices Started")
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
	Object.Library.Destroy(RObjects[ObjectIndex], ObjectGive)
	table.remove(RObjects, ObjectIndex)
end

--Removes a Device from the game
function GiveBack.RemoveDevice(DeviceID, Arguments)
	local Space, Device, DeviceGive = Arguments[1], Arguments[6], Arguments[7]
	local DeviceIndex = #Space.Devices
	if type(DeviceID) == "number" and
	0 < DeviceID and DeviceID <= #Space.Devices then
		DeviceIndex = DeviceID
	end
	Device.Library.Destroy(Space.Devices[DeviceIndex], DeviceGive)
	table.remove(Space.Devices, DeviceIndex)
end
function GiveBack.Stop(Arguments)
	local Space, Device, DeviceGive = Arguments[1], Arguments[6],
	Arguments[7]
	for ak=1,#Space.Devices do
		local av = Space.Devices[ak]
		Device.Library.Destroy(av, DeviceGive)
	end
	for ak,av in pairs(Space) do
		Space[ak] = nil
	end
	print("AllDevices Stopped")
end

--Clears created Objects list (CollisionDetection and AllPowers)
function GiveBack.ClearDeviceChanges(Arguments)
	local Space = Arguments[1]
	Space.CreatedObjects = {}
end
GiveBack.Requirements = {"JSON", "General", "Device", "Object", "OBJ"}
return GiveBack
