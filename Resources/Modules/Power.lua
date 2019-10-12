return function(args)
  local Space, General, Device, AllDevices, ffi, Globals, Math, CTypes = args[1],
  args[2], args[3], args[4], args[5], args[6], args[7], args[8]
  local Globals, General, Math, CTypes = Globals.Library.Globals,
  General.Library, Math.Library, CTypes.Library.Types
  local SameLayer, VectorLength, VectorSub, Normalise, VectorSign,
  VectorAdd, VectorScale, QuaternionMultiplication, Slerp,
  QuaternionInverse, cos, sin, pcall, type, loadstring, pairs, write, double =
  General.SameLayer, Math.VectorLength, Math.VectorSub, Math.Normalise,
  Math.VectorSign, Math.VectorAdd, Math.VectorScale,
  Math.QuaternionMultiplication, Math.Slerp, Math.QuaternionInverse,
  Globals.cos, Globals.sin, Globals.pcall, Globals.type, Globals.loadstring,
  Globals.pairs, Globals.write, CTypes["double[?]"].Type

  local GiveBack = {}

  --This script is responsible for mechanics that aren't derived from physics
  --DataCheck functions convert data stored in lon into data the power uses
  --Use functions evaluate the power
  --Converts an axis-angle rotatiton into a quaternion rotatiton

  local function AxisAngleToQuaternion(Axis, Angle, Quat)
    Quat[0], Quat[1], Quat[2], Quat[3] =
    cos(Angle / 2),
    Axis[0] * sin(Angle/2),
    Axis[1] * sin(Angle/2),
    Axis[2] * sin(Angle/2)
  end

  GiveBack.Powers = {}

  --Gravity pulls or pushes every object within Distance with a constant force
  --In the direction of the Object using it
  --TODO: dependency on mass, Distance
  GiveBack.Powers.Gravity = {}
  local Gravity = GiveBack.Powers.Gravity
  function Gravity.DataCheck(Devices, Device, Object, Power, Time)
    local Data = {}
    Data.Type = "Gravity"
    Data.Force = 0.005
    if type(Power.Force) == "number" then
      Data.Force = Power.Force
    end
    Data.Distance = 100
    if type(Power.Distance) == "number" then
      Data.Distance = Power.Distance
    end
    Data.Active = false
    if type(Power.Active) == "boolean" then
      Data.Active = Power.Active
    end
    return Data
  end

  local Distance, LinearAcceleration = double(3), double(3)

  function Gravity.Use(Devices, Device, Object, Power, Time)
    for ak=1,#Devices do
      local av = Devices[ak]
      for bk=1,#av.Objects do
        local bv = av.Objects[bk]
        if (Device ~= ak or Object ~= bk) and
        SameLayer(Object.PhysicsLayers, bv.PhysicsLayers) then
          VectorSub(Object.Translation, bv.Translation, Distance)
          if VectorLength(Distance) < Power.Distance then
            Normalise(Distance, Distance)
            local Direction
            if true then
              VectorSign(Distance, Distance)
            end
            VectorScale(Distance, Time * Power.Force, LinearAcceleration)
            if not bv.Fixed then
              VectorAdd(bv.LinearAcceleration, LinearAcceleration, bv.LinearAcceleration)
            end
            VectorScale(LinearAcceleration, -1, LinearAcceleration)
            if not Object.Fixed then
              VectorAdd(Object.LinearAcceleration, LinearAcceleration, Object.LinearAcceleration)
            end
          end
        end
      end
    end
  end

  --Thruster pulls or pushes the object using it with a constant force
  --In the direction of one of its points
  GiveBack.Powers.Thruster = {}
  local Thruster = GiveBack.Powers.Thruster
  function Thruster.DataCheck(Devices, Device, Object, Power, Time)
    local Data = {}
    Data.Type = "Thruster"
    Data.Force = 0.005
    if type(Power.Force) == "number" then
      Data.Force = Power.Force
    end
    Data.Point = 1
    if Power.Point == 1 or Power.Point == 2 or Power.Point == 3 or
    Power.Point == 4 then
      Data.Point = Power.Point
    end
    Data.Active = false
    if type(Power.Active) == "boolean" then
      Data.Active = Power.Active
    end
    return Data
  end

  local Point, Direction = double(3), double(3)

  function Thruster.Use(Devices, Device, Object, Power, Time)
    if not Object.Fixed then
      Point[0], Point[1], Point[2] =
      Object.Transformated[(Power.Point-1) * 4],
      Object.Transformated[(Power.Point-1) * 4 + 1],
      Object.Transformated[(Power.Point-1) * 4 + 2]
      local Center = Object.Translation
      VectorSub(Point, Center, Direction)
      VectorScale(Direction, Time * Power.Force, LinearAcceleration)
      VectorAdd(Object.LinearAcceleration, LinearAcceleration, Object.LinearAcceleration)
    end
  end

  --Pong negates the object's movement on collision
  GiveBack.Powers.Pong = {}
  local Pong = GiveBack.Powers.Pong
  function Pong.DataCheck(Devices, Device, Object, Power, Time)
    local Data = {}
    Data.Type = "Pong"
    Data.Active = false
    if type(Power.Active) == "boolean" then
      Data.Active = Power.Active
    end
    return Data
  end
  function Pong.Use(Devices, Device, Object, Power, Time)
    if not Object.Fixed then
      VectorScale(Object.LinearVelocity, -1, Object.LinearVelocity)
      VectorScale(Object.LinearAcceleration, -1, Object.LinearAcceleration)
    end
    if Power.Object and not Power.Object.Fixed then
      VectorScale(Power.Object.LinearVelocity, -1, Power.Object.LinearVelocity)
      VectorScale(Power.Object.LinearAcceleration, -1, Power.Object.LinearAcceleration)
    end
    Power.Active = false
  end

  --AxisPong negates the object's movement on collision on one axis
  GiveBack.Powers.AxisPong = {}
  local AxisPong = GiveBack.Powers.AxisPong
  function AxisPong.DataCheck(Devices, Device, Object, Power, Time)
    local Data = {}
    Data.Type = "AxisPong"
    Data.Active = false
    if type(Power.Active) == "boolean" then
      Data.Active = Power.Active
    end
    Data.Axis = 0
    if Power.Axis == 2 or Power.Axis == 3 then
      Data.Axis = Power.Axis - 1
    end
    return Data
  end
  function AxisPong.Use(Devices, Device, Object, Power, Time)
    if not Object.Fixed then
      Object.LinearAcceleration[Power.Axis] =
      -Object.LinearAcceleration[Power.Axis]
      Object.LinearVelocity[Power.Axis] =
      -Object.LinearVelocity[Power.Axis]
    end
    if Power.Object and not Power.Object.Fixed then
      Power.Object.LinearAcceleration[Power.Axis] =
      -Power.Object.LinearAcceleration[Power.Axis]
      Power.Object.LinearVelocity[Power.Axis] =
      -Power.Object.LinearVelocity[Power.Axis]
    end
    Power.Active = false
  end

  --SelfRotate rotates the object using it with a constant angle
  --Around one of its points
  GiveBack.Powers.SelfRotate = {}
  local SelfRotate = GiveBack.Powers.SelfRotate
  function SelfRotate.DataCheck(Devices, Device, Object, Power, Time)
    local Data = {}
    Data.Type = "SelfRotate"
    Data.Angle = 0.005
    if type(Power.Angle) == "number" then
      Data.Angle = Power.Angle
    end
    Data.Point = 1
    if Power.Point == 1 or Power.Point == 2 or Power.Point == 3 or
    Power.Point == 4 then
      Data.Point = Power.Point
    end
    Data.Active = false
    if type(Power.Active) == "boolean" then
      Data.Active = Power.Active
    end
    return Data
  end

  local Axis, AngularAcceleration = double(3), double(4)

  function SelfRotate.Use(Devices, Device, Object, Power, Time)
    if not Object.Fixed then
      Point[0], Point[1], Point[2] =
      Object.Transformated[(Power.Point-1) * 4],
      Object.Transformated[(Power.Point-1) * 4 + 1],
      Object.Transformated[(Power.Point-1) * 4 + 2]
      local Center = Object.Translation
      VectorSub(Point, Center, Axis)
      Normalise(Axis, Axis)
      AxisAngleToQuaternion(Axis, Power.Angle * Time, AngularAcceleration)
      QuaternionMultiplication(Object.AngularAcceleration, AngularAcceleration, Object.AngularAcceleration)
    end
  end

  --SelfSlow slows the object using it with a constant rate on every axes
  GiveBack.Powers.SelfSlow = {}
  local SelfSlow = GiveBack.Powers.SelfSlow
  function SelfSlow.DataCheck(Devices, Device, Object, Power, Time)
    local Data = {}
    Data.Type = "SelfSlow"
    Data.Rate = 0.005
    if type(Power.Rate) == "number" then
      Data.Rate = Power.Rate
    end
    Data.Active = false
    if type(Power.Active) == "boolean" then
      Data.Active = Power.Active
    end
    return Data
  end

  local ZeroRotation, InvAngularVelocity = double(4, 1, 0, 0, 0), double(4)

  function SelfSlow.Use(Devices, Device, Object, Power, Time)
    VectorScale(Object.LinearVelocity, Power.Rate ^ Time, LinearAcceleration)
    VectorSub(Object.LinearAcceleration, LinearAcceleration, Object.LinearAcceleration)

    QuaternionInverse(Object.AngularVelocity, InvAngularVelocity)

    Slerp(ZeroRotation, InvAngularVelocity, Power.Rate ^ Time, AngularAcceleration)
    QuaternionMultiplication(Object.AngularAcceleration, AngularAcceleration, Object.AngularAcceleration)
  end

  --Destroypara destroys the object using it if it's command returns true

  local function DefaultDestroypara(...)
    return false
  end

  GiveBack.Powers.Destroypara = {}
  local Destroypara = GiveBack.Powers.Destroypara
  function Destroypara.DataCheck(Devices, Device, Object, Power, Time)
    local Data = {}
    Data.Type = "Destroypara"
    if Power.String == nil then
      Data.Command = DefaultDestroypara
    else
      Data.Command = loadstring(Power.String)
      if not pcall(Data.Command, Devices, Device, Object, Power, Math) then
        Data.Command = DefaultDestroypara
      end
    end
    Data.Active = false
    if type(Power.Active) == "boolean" then
      Data.Active = Power.Active
    end
    return Data
  end
  function Destroypara.Use(Devices, Device, Object, Power, Time)
    if Power.Command(Devices, Device, Object, Power, Math) then
      local DeviceID = 1
      for ak=1,#Devices do
        local av = Devices[ak]
        if av == Device then
          DeviceID = ak
          break
        end
      end
      if #Device.Objects > 1 then
        local ObjectID = 1
        for ak=1,#Device.Objects do
          local av = Device.Objects[ak]
          if av == Object then
            ObjectID = ak
            break
          end
        end
        AllDevices.Library.RemoveObject(DeviceID, ObjectID)
        return true
      end
      AllDevices.Library.RemoveDevice(DeviceID)
      return true
    end
  end

  --Command runs small script which can be custom mechanics for the object/device
  --Or all devices

  local function DefaultCommand(...)
    return false
  end

  GiveBack.Powers.Command = {}
  local Command = GiveBack.Powers.Command
  function Command.DataCheck(Devices, Device, Object, Power, Time)
    local Data = {}
	  Data.Type = "Command"
    if Power.String == nil then
      Data.Command = DefaultCommand
    else
      Data.Command = loadstring(Power.String)
      if not pcall(Data.Command, Devices, Device, Object, Power, Time, Globals) then
        Data.Command = DefaultCommand
      end
    end
    Data.Active = false
    if type(Power.Active) == "boolean" then
      Data.Active = Power.Active
    end
    return Data
  end
  function Command.Use(Devices, Device, Object, Power, Time)
    pcall(Power.Command, Devices, Device, Object, Power, Time, Globals)
  end

  --Summon adds an object or device, then modifies it with it's command

  local function DefaultSummon(...)
    local Created, Creator = ...
    for ak=1,#Created.Objects do
      local av = Created.Objects[ak]
      for bk=0,2 do
        av.Translation[bk] = Creator.Translation[bk]
        av.Rotation[bk] = Creator.Rotation[bk]
      end
      av.Rotation[3] = Creator.Rotation[3]
    end
    write("Bad modifier function\n")
  end

  GiveBack.Powers.Summon = {}
  local Summon = GiveBack.Powers.Summon
  function Summon.DataCheck(Devices, DeviceO, Object, Power, Time)
    local Data = {}
    Data.Type = "Summon"
    Data.Name = "Default"
    Data.Active = false
    if type(Power.Name) == "string" and
    AllDevices.Space.DeviceTypes[Power.Name] then
      Data.Name = Power.Name
    end
    local NewDevice =
    Device.Library.Copy(AllDevices.Space.DeviceTypes[Data.Name])
    if Power.String == nil then
      Data.Command = DefaultSummon
    else
      Data.Command = loadstring(Power.String)
      if not pcall(Data.Command, NewDevice, NewDevice.Objects[1], Math, Globals) then
        Data.Command = DefaultSummon
      end
    end
    Data.IfObject = false
    if type(Power.IfObject) == "boolean" then
      Data.IfObject = Power.IfObject
    end
    if type(Power.Active) == "boolean" then
      Data.Active = Power.Active
    end
    return Data
  end
  function Summon.Use(Devices, DeviceO, Object, Power, Time)
    if Power.IfObject then
      local DeviceID = 1
      for ak=1,#Devices do
        local av = Devices[ak]
        if av == DeviceO then
          DeviceID = ak
          break
        end
      end
      AllDevices.Library.AddObject(DeviceID, Power.Name,
      {Command = Power.Command, Creator = Object})
    else
      AllDevices.Library.AddDevice(Power.Name,
      {Command = Power.Command, Creator = Object})
    end
    Power.Active = false
  end

  --Checks whether every Power has all it's functions, if not, it deletes it
	function GiveBack.Start(Configurations)
		for ak,av in pairs(GiveBack.Powers) do
			if type(av.DataCheck) ~= "function" or type(av.Use) ~= "function" then
				GiveBack.Powers[ak] = nil
			end
		end
	end

  function GiveBack.Stop()
  end
  return GiveBack
end
