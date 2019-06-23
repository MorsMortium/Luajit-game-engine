local GiveBack = {}
function GiveBack.AddObject(DeviceID, DeviceName, ModifierForDevice, Arguments)
	local Space, General, GeneralGive, Device, DeviceGive = Arguments[1],
	Arguments[4], Arguments[5], Arguments[6], Arguments[7]
	local Copy = Device.Library.Copy
	local Merge = Device.Library.Merge
	local DeviceIndex = #Space.Devices
	if type(DeviceID) == "number" and
	0 < DeviceID and DeviceID < #Space.Devices then
		DeviceIndex = DeviceID
	end
	if Space.DeviceTypes[DeviceName] then
		NewDevice =
		Copy(Space.DeviceTypes[DeviceName], DeviceGive, Space.HelperMatrices)
	else
		NewDevice =
		Copy(Space.DeviceTypes.Default, DeviceGive, Space.HelperMatrices)
	end
	if ModifierForDevice then
		pcall(ModifierForDevice.Command, NewDevice, ModifierForDevice.Creator, General)
		for ak=1,#NewDevice.Objects do
			local av = NewDevice.Objects[ak]
			General.Library.UpdateObject(av, true, Space.HelperMatrices, GeneralGive)
		end
	end
	for ak=1,#NewDevice.Objects do
		local av = NewDevice.Objects[ak]
		Space.CreatedObjects[#Space.CreatedObjects + 1] = av
	end
	Merge(Space.Devices[DeviceID], NewDevice, DeviceGive, Space.HelperMatrices)
end
function GiveBack.AddDevice(DeviceName, ModifierForDevice, Arguments)
	local Space, General, GeneralGive, Device, DeviceGive = Arguments[1],
	Arguments[4], Arguments[5], Arguments[6], Arguments[7]
	local Copy = Device.Library.Copy
	local NewDevice
	if Space.DeviceTypes[DeviceName] then
		NewDevice =
		Copy(Space.DeviceTypes[DeviceName], DeviceGive, Space.HelperMatrices)
	else
		NewDevice =
		Copy(Space.DeviceTypes.Default, DeviceGive, Space.HelperMatrices)
	end
	if ModifierForDevice then
		pcall(ModifierForDevice.Command, NewDevice, ModifierForDevice.Creator, General)
		for ak=1,#NewDevice.Objects do
	    local av = NewDevice.Objects[ak]
	    General.Library.UpdateObject(av, true, Space.HelperMatrices, GeneralGive)
	  end
	end
	Space.Devices[#Space.Devices + 1] = NewDevice
	for ak=1,#NewDevice.Objects do
		local av = NewDevice.Objects[ak]
		Space.CreatedObjects[#Space.CreatedObjects + 1] = av
	end
end
function GiveBack.Start(Arguments)
	local Space, JSON, General, Device, DeviceGive, lgsl = Arguments[1],
	Arguments[2], Arguments[4], Arguments[6], Arguments[7], Arguments[10]
	local gsl = lgsl.Library.gsl
	Space.HelperMatrices = {}
	for ak=1,3 do
		Space.HelperMatrices[ak] = gsl.gsl_matrix_alloc(4, 4)
	end
	Space.Devices = {}
	Space.DeviceTypes = {}
	Space.CreatedObjects = {}
	local AllDevices = JSON.Library:DecodeFromFile("AllDevices.json")
	if type(AllDevices) == "table" and
	General.Library.GoodTypesOfTable(AllDevices.DeviceTypes, "string") then
		for ak=1,#AllDevices.DeviceTypes do
			local av = AllDevices.DeviceTypes[ak]
			local NewDevice = JSON.Library:DecodeFromFile("AllDevices/" .. av .. ".json")
			Space.DeviceTypes[NewDevice.Name] =
			Device.Library.Create(NewDevice, DeviceGive, Space.HelperMatrices)
		end
		if Space.DeviceTypes.Default == nil then
			local NewDevice = JSON.Library:DecodeFromFile("AllDevices/Default.json")
			Space.DeviceTypes.Default =
			Device.Library.Create(NewDevice, DeviceGive, Space.HelperMatrices)
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
		Device.Library.Create(NewDevice, DeviceGive, Space.HelperMatrices)
		GiveBack.AddDevice("Default", nil, Arguments)
	end
	--Space.Devices[#Space.Devices + 1] = Device.Library.Create(OBJ.Library.makedevice("./Resources/hand.obj"), "Hand", DeviceGive)
	print("AllDevices Started")
end
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
	local Space, Device, DeviceGive, lgsl = Arguments[1], Arguments[6],
	Arguments[7], Arguments[10]
	local gsl = lgsl.Library.gsl
	for ak=1,3 do
		gsl.gsl_matrix_free(Space.HelperMatrices[ak])
	end
	for ak=1,#Space.Devices do
		local av = Space.Devices[ak]
		Device.Library.Destroy(av, DeviceGive)
	end
	for ak,av in pairs(Space) do
		Space[ak] = nil
	end
	print("AllDevices Stopped")
end
function GiveBack.ClearDeviceChanges(Arguments)
	local Space = Arguments[1]
	Space.CreatedObjects = {}
end
GiveBack.Requirements = {"JSON", "General", "Device", "Object", "lgsl"}
return GiveBack
