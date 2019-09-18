return function(args)
  local Space, General, CTypes, ObjectRender, AllDevices = args[1], args[2], args[3], args[4], args[5]
  local SameLayer, ConcatenateCArrays =
  General.Library.SameLayer, General.Library.ConcatenateCArrays
  local GiveBack = {}

  function GiveBack.Reload(args)
    Space, General, CTypes, ObjectRender, AllDevices = args[1], args[2], args[3], args[4], args[5]
    SameLayer, ConcatenateCArrays = General.Library.SameLayer,
    General.Library.ConcatenateCArrays
  end

  --Thist script is responsible for drawing every Device to a Camera
  --GLuint Is for the Elements of the Devices
  function GiveBack.Start(Configurations)
    Space.GLuint = CTypes.Library.Types["GLuint[?]"].Type
    Space.NumberPerType = {}
    Space.ORenderKeys = {}
    for ak,av in pairs(ObjectRender.Library.ObjectRenders) do
      Space.ORenderKeys[#Space.ORenderKeys + 1] = ak
      Space.NumberPerType[ak] = {}
      Space.NumberPerType[ak].TransformatedMatrices = {}
      Space.NumberPerType[ak].RenderData = {}
      Space.NumberPerType[ak].Elements = av.MakeElements(AllDevices.Space.MaxNumberOfObjects, Space.GLuint)
    end
  end
  function GiveBack.Stop()
  end

  --Checks whether an Object is in the same visual layers as the Camera, if true
  --Then puts its vertex data and rendering data in arrays
  --After that it merges the arrays into two C arrays, creates the elements for
  --Each renderer from ObjectRenders.lua and renders them
  function GiveBack.RenderAllDevices(VBO, RDBO, CameraObject, MVP)
    for ak=1,#AllDevices.Space.BroadPhaseAxes[1] do
      if SameLayer(CameraObject.VisualLayers, CameraObject.VLayerKeys, AllDevices.Space.BroadPhaseAxes[1][ak].VisualLayers, AllDevices.Space.BroadPhaseAxes[1][ak].VLayerKeys) then
        local ObjectRenderer = ObjectRender.Library.ObjectRenders[AllDevices.Space.BroadPhaseAxes[1][ak].ObjectRenderer]
        local GetTransformatedMatrix = ObjectRenderer.GetTransformatedMatrix
        local GetRenderData = ObjectRenderer.GetRenderData
        local ORA = Space.NumberPerType[AllDevices.Space.BroadPhaseAxes[1][ak].ObjectRenderer]
        ORA.TransformatedMatrices[#ORA.TransformatedMatrices + 1],
        ORA.VertexLength, ORA.VertexType =
        GetTransformatedMatrix(AllDevices.Space.BroadPhaseAxes[1][ak].Transformated.data)
        ORA.RenderData[#ORA.RenderData + 1],
        ORA.RenderDataLength, ORA.RenderDataType =
        GetRenderData(AllDevices.Space.BroadPhaseAxes[1][ak].RenderData)
      end
    end
    for ak1=1,#Space.ORenderKeys do
      local ak2 = Space.ORenderKeys[ak1]
      local av = Space.NumberPerType[ak2]
      if #av.TransformatedMatrices ~= 0 then
        local Render = ObjectRender.Library.ObjectRenders[ak2].Render
        av.FullTransformatedMatrix =
        ConcatenateCArrays(av.TransformatedMatrices, av.VertexLength, av.VertexType)
        av.FullRenderData =
        ConcatenateCArrays(av.RenderData, av.RenderDataLength, av.RenderDataType)
        Render(VBO, RDBO, av.FullTransformatedMatrix, MVP, #av.TransformatedMatrices,
        av.Elements, av.FullRenderData, ObjectRender.Library.ObjectRenders[ak2].Space)
        av.TransformatedMatrices = {}
        av.RenderData = {}
      end
    end
  end
  return GiveBack
end
