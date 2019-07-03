local GiveBack = {}

--Thist script is responsible for drawing every Device to a Camera
--GLuint Is for the Elements of the Devices
function GiveBack.Start(Configurations, Arguments)
  local Space, ffi = Arguments[1], Arguments[4]
  Space.GLuint = ffi.Library.typeof("GLuint[?]")
  print("AllDeviceRenders Started")
end
function GiveBack.Stop(Arguments)
  local Space = Arguments[1]
  for ak,av in pairs(Space) do
    Space[ak] = nil
  end
  print("AllDeviceRenders Stopped")
end

--Checks whether an Object is in the same visual layers as the Camera, if true
--Then puts its vertex data and rendering data in layers
--After that it merges the arrays into two C arrays, creates the Elements for
--Each renderer from ObjectRenders.lua and renders them
function GiveBack.RenderAllDevices(VBO, RDBO, CameraObject, MVP, Arguments)
	local Space, General, ffi, ObjectRender, ObjectRenderGive, AllDevices =
  Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[7],
  Arguments[8]
  local SameLayer, ConcatenateCArrays = General.Library.SameLayer,
  General.Library.ConcatenateCArrays
  local ObjectRenders = ObjectRender.Library.ObjectRenders
	local NumberPerType = {}
	local notfound = true
	for ak=1,#AllDevices.Space.Devices do
		local av = AllDevices.Space.Devices[ak]
		for bk=1,#av.Objects do
			local bv = av.Objects[bk]
			if SameLayer(CameraObject.VisualLayers, bv.VisualLayers) then
        local GetTransformatedMatrix =
        ObjectRenders[bv.ObjectRenderer].GetTransformatedMatrix
        local GetRenderData =
        ObjectRenders[bv.ObjectRenderer].GetRenderData
				for ck,cv in pairs(NumberPerType) do
					if ck == bv.ObjectRenderer then
						cv.TransformatedMatrices[#cv.TransformatedMatrices + 1],
            cv.VertexLength, cv.VertexType =
            GetTransformatedMatrix(bv.Transformated.data, ffi)
						cv.RenderData[#cv.RenderData + 1],
            cv.RenderDataLength, cv.RenderDataType =
            GetRenderData(bv.RenderData,ffi)
            notfound = false
						break
					end
				end
				if notfound then
					NumberPerType[bv.ObjectRenderer] = {}
          local ORA = NumberPerType[bv.ObjectRenderer]
					ORA.TransformatedMatrices = {}
					ORA.TransformatedMatrices[#ORA.TransformatedMatrices + 1],
          ORA.VertexLength, ORA.VertexType =
          GetTransformatedMatrix(bv.Transformated.data, ffi)
					ORA.RenderData = {}
					ORA.RenderData[#ORA.RenderData + 1],
          ORA.RenderDataLength, ORA.RenderDataType =
          GetRenderData(bv.RenderData, ffi)
        end
			end
		end
	end
	local Elements
	for ak,av in pairs(NumberPerType) do
    local MakeElements = ObjectRenders[ak].MakeElements
    local Render = ObjectRenders[ak].Render
		av.FullTransformatedMatrix =
    ConcatenateCArrays(av.TransformatedMatrices, av.VertexLength, av.VertexType, ffi)
		av.FullRenderData =
    ConcatenateCArrays(av.RenderData, av.RenderDataLength, av.RenderDataType, ffi)
    Elements =
    MakeElements(#av.TransformatedMatrices, av.PureRenderData, Space.GLuint)
		Render(VBO, RDBO, av.FullTransformatedMatrix, MVP, #av.TransformatedMatrices,
    Elements, av.FullRenderData, ObjectRender.Library.ObjectRenders[ak].Space,
    ObjectRenderGive)
	end
end
GiveBack.Requirements = {"General", "ffi", "ObjectRender", "AllDevices"}
return GiveBack
