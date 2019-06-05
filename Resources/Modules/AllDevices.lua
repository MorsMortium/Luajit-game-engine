local GiveBack = {}
function GiveBack.Start(Arguments)
	local Space, JSON, General, Device, DeviceGive, Object, ObjectGive =
	Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[7],
	Arguments[8], Arguments[9]
	Space.Devices = {}
	local Devices = JSON.Library:DecodeFromFile("AllDevices.json")
	if type(Devices) == "table" and General.Library.GoodTypesOfTable(Devices, "string") then
		for ak=1,#Devices do
			local av = Devices[ak]
			local DeviceObject = JSON.Library:DecodeFromFile("AllDevices/" .. av .. ".json")
			if type(DeviceObject) == "table" then
				Space.Devices[ak] = Device.Library.Create(DeviceObject, DeviceGive)
			end
		end
	else
		local DeviceObject = JSON.Library:DecodeFromFile("AllDevices/Default.json")
		Space.Devices[1] = Device.Library.Create(DeviceObject, DeviceGive)
	end
	--Space.Devices[#Space.Devices + 1] = Device.Library.Create(OBJ.Library.makedevice("./Resources/hand.obj"), "Hand", DeviceGive)
	print("AllDevices Started")
end
function GiveBack.Stop(Arguments)
	local Space, Device, DeviceGive = Arguments[1], Arguments[6], Arguments[7]
	for ak=1,#Space.Devices do
		local av = Space.Devices[ak]
		Device.Library.Destroy(av, DeviceGive)
	end
	for ak,av in pairs(Space) do
		Space[ak] = nil
	end
	print("AllDevices Stopped")
end
function GiveBack.Add(IfObject, DeviceID, ObjectOrDevice, Arguments)
	local Space, JSON, General, Device, DeviceGive, Object, ObjectGive =
	Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[7],
	Arguments[8], Arguments[9]
	--If IfObject is true, then its an object, for the Device with the ID in DeviceID, and the objectdata in ObjectOrDevice
	--Otherwise it's a device, and the devicedata is in ObjectOrDevice
	if IfObject then
		--Object for an existing device
		local DeviceIndex = #Space.Devices
		if type(DeviceID) == "number" and 0 < DeviceID and DeviceID <= #Space.Devices then
			DeviceIndex = DeviceID
		end
		Space.Devices[DeviceIndex].Objects[#Space.Devices[DeviceIndex].Objects + 1] = Object.Library.Create(ObjectOrDevice, ObjectGive)
	else
		--Device
		Space.Devices[#Space.Devices + 1] = Device.Library.Create(ObjectOrDevice, DeviceGive)
	end
end
function GiveBack.Remove(IfObject, DeviceID, ObjectID, Arguments)
	local Space, JSON, General, Device, DeviceGive, Object, ObjectGive =
	Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[7],
	Arguments[8], Arguments[9]
	--If IfObject is true, then its an object, for the Device with DeviceID, and ObjectID
	--Otherwise it's a device, with DeviceID
	local DeviceIndex = #Space.Devices
	if type(DeviceID) == "number" and 0 < DeviceID and DeviceID <= #Space.Devices then
		DeviceIndex = DeviceID
	end
	if IfObject then
		--Object for an existing device
		local ObjectIndex = #Space.Devices[DeviceIndex].Objects
		if type(ObjectID) == "number" and 0 < ObjectID and ObjectID <= #Space.Devices[DeviceIndex].Objects then
			ObjectIndex = ObjectID
		end
		Object.Library.Destroy(Space.Devices[DeviceIndex].Objects[ObjectIndex], ObjectGive)
		table.remove(Space.Devices[DeviceIndex].Objects, ObjectIndex)
	else
		--Device
		Device.Library.Destroy(Space.Devices[DeviceIndex], DeviceGive)
		table.remove(Space.Devices, DeviceIndex)
	end
end
GiveBack.Requirements = {"JSON", "General", "Device", "Object"}
return GiveBack
