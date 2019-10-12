return function(args)
  local Space, General, CTypes, ObjectRender, AllDevices, Globals = args[1],
  args[2], args[3], args[4], args[5], args[6]
  local Globals = Globals.Library.Globals
  local ConcatCArrays, pairs = General.Library.ConcatCArrays,
  Globals.pairs

  local GiveBack = {}

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
      Space.NumberPerType[ak].Elements =
      av.MakeElements(AllDevices.Space.MaxObjects, Space.GLuint)
    end
  end
  function GiveBack.Stop()
  end

  --Checks whether an Object is in the same visual layers as the Camera, if true
  --Then puts its vertex data and rendering data in arrays
  --After that it merges the arrays into two C arrays, creates the elements for
  --Each renderer from ObjectRenders.lua and renders them
  function GiveBack.RenderAllDevices(VBO, RDBO, Camera, MVP)
    for ak=1,#Camera.Objects do
      local av = Camera.Objects[ak]
      local ObjectRenderer =
      ObjectRender.Library.ObjectRenders[av.ObjectRenderer]
      local GetTransformatedMatrix = ObjectRenderer.GetTransformatedMatrix
      local GetRenderData = ObjectRenderer.GetRenderData
      local ORA = Space.NumberPerType[av.ObjectRenderer]
      ORA.TransformatedMatrices[#ORA.TransformatedMatrices + 1],
      ORA.VertexLength, ORA.VertexType =
      GetTransformatedMatrix(av.Transformated)
      ORA.RenderData[#ORA.RenderData + 1],
      ORA.RenderDataLength, ORA.RenderDataType =
      GetRenderData(av.RenderData)
    end
    for ak1=1,#Space.ORenderKeys do
      local ak2 = Space.ORenderKeys[ak1]
      local av = Space.NumberPerType[ak2]
      local av2 = ObjectRender.Library.ObjectRenders[ak2]
      if #av.TransformatedMatrices ~= 0 then
        local Render = av2.Render
        av.FullTransformatedMatrix =
        ConcatCArrays(av.TransformatedMatrices, av.VertexLength, av.VertexType)
        av.FullRenderData =
        ConcatCArrays(av.RenderData, av.RenderDataLength, av.RenderDataType)
        Render(VBO, RDBO, av.FullTransformatedMatrix, MVP,
        #av.TransformatedMatrices, av.Elements, av.FullRenderData, av2.Space)
        av.TransformatedMatrices = {}
        av.RenderData = {}
      end
    end
  end
  return GiveBack
end
