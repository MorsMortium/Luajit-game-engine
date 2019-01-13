local GiveBack = {}
function GiveBack.Start(Space, JSON, JSONGive, General, GeneralGive, Device, DeviceGive, AllObjectRenders, AllObjectRendersGive)
	Space.Devices = {}
	local Devices = JSON.Library:DecodeFromFile("./Resources/Configurations/AllDevices.json")
	if type(Devices) == "table" and General.Library.GoodTypesOfTable(Devices, "string") then
    for k, v in pairs(Devices) do
      local DeviceObject = JSON.Library:DecodeFromFile("./Resources/Configurations/AllDevices/" .. v .. ".json")
			if type(DeviceObject) == "table" then
				Space.Devices[k] = Device.Library.Create(DeviceObject, v, unpack(DeviceGive))
			end
    end
	end
	print("AllDevices Started")
end
function GiveBack.RenderAllDevices(CameraObject, Space, JSON, JSONGive, General, GeneralGive, Device, DeviceGive, AllObjectRenders, AllObjectRendersGive)
	for k, v in pairs(Space.Devices) do
		AllObjectRenders.Library.RenderAllObjects(CameraObject, v.Objects, unpack(AllObjectRendersGive))--, AllCameras.Framebuffer[0])
	end
end
function GiveBack.Stop(Space, JSON, JSONGive, General, GeneralGive, Device, DeviceGive, AllObjectRenders, AllObjectRendersGive)
	for k,v in pairs(Space.Devices) do
		Device.Library.Destroy(v, unpack(DeviceGive))
		Space.Devices[k] = nil
	end
	print("AllDevices Stopped")
end
GiveBack.Requirements = {"JSON", "General", "Device", "AllObjectRenders"}
return GiveBack
