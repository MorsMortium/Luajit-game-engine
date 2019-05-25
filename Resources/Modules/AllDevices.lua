local GiveBack = {}
function GiveBack.Start(Arguments)
	local Space, JSON, General, Device, DeviceGive, OBJ = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[7], Arguments[10]
	Space.Devices = {}
	local Devices = JSON.Library:DecodeFromFile("./Resources/Configurations/AllDevices.json")
	if type(Devices) == "table" and General.Library.GoodTypesOfTable(Devices, "string") then
		for ak=1,#Devices do
			local av = Devices[ak]
			local DeviceObject = JSON.Library:DecodeFromFile("./Resources/Configurations/AllDevices/" .. av .. ".json")
			if type(DeviceObject) == "table" then
				Space.Devices[ak] = Device.Library.Create(DeviceObject, av, DeviceGive)
			end
		end
	end
	--Space.Devices[#Space.Devices + 1] = Device.Library.Create(OBJ.Library.makedevice("./Resources/hand.obj"), "Hand", DeviceGive)
	print("AllDevices Started")
end
function GiveBack.RenderAllDevices(CameraObject, Arguments)
	local Space, AllObjectRenders, AllObjectRendersGive = Arguments[1], Arguments[8], Arguments[9]
	for ak=1,#Space.Devices do
		local av = Space.Devices[ak]
		AllObjectRenders.Library.RenderAllObjects(CameraObject, av.Objects, AllObjectRendersGive)--, AllCameras.Framebuffer[0])
	end
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
GiveBack.Requirements = {"JSON", "General", "Device", "AllObjectRenders", "OBJ"}
return GiveBack
