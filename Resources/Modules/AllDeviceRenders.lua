local GiveBack = {}
function GiveBack.Start(Arguments)
  local Space, ffi = Arguments[1], Arguments[6]
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
function GiveBack.RenderAllDevices(VBO, RDBO, CameraObject, MVP, Arguments)
	local Space, General, ffi, ObjectRender, ObjectRenderGive, AllDevices =
  Arguments[1], Arguments[4], Arguments[6], Arguments[8], Arguments[9],
  Arguments[10]
	local NumberPerType = {}
	local notfound = true
	for ak=1,#AllDevices.Space.Devices do
		local av = AllDevices.Space.Devices[ak]
		for bk=1,#av.Objects do
			local bv = av.Objects[bk]
			if General.Library.SameLayer(CameraObject.VisualLayers, bv.VisualLayers) then
				for ck,cv in pairs(NumberPerType) do
					if ck == bv.ObjectRenderer then
						cv.TransformatedMatrices[#cv.TransformatedMatrices + 1], cv.VertexLength, cv.VertexType = ObjectRender.Library.ObjectRenders[ck].GetTransformatedMatrix(bv.Transformated.data, ffi)
						cv.RenderData[#cv.RenderData + 1], cv.RenderDataLength, cv.RenderDataType = ObjectRender.Library.ObjectRenders[ck].GetRenderData(bv.RenderData,ffi)
            notfound = false
						break
					end
				end
				if notfound then
					NumberPerType[bv.ObjectRenderer] = {}
					NumberPerType[bv.ObjectRenderer].TransformatedMatrices = {}
					NumberPerType[bv.ObjectRenderer].TransformatedMatrices[#NumberPerType[bv.ObjectRenderer].TransformatedMatrices + 1], NumberPerType[bv.ObjectRenderer].VertexLength, NumberPerType[bv.ObjectRenderer].VertexType = ObjectRender.Library.ObjectRenders[bv.ObjectRenderer].GetTransformatedMatrix(bv.Transformated.data, ffi)
					NumberPerType[bv.ObjectRenderer].RenderData = {}
					NumberPerType[bv.ObjectRenderer].RenderData[#NumberPerType[bv.ObjectRenderer].RenderData + 1], NumberPerType[bv.ObjectRenderer].RenderDataLength, NumberPerType[bv.ObjectRenderer].RenderDataType = ObjectRender.Library.ObjectRenders[bv.ObjectRenderer].GetRenderData(bv.RenderData, ffi)
        end
			end
		end
	end
	local Elements
	for ak,av in pairs(NumberPerType) do
		av.FullTransformatedMatrix = General.Library.ConcatenateCArrays(av.TransformatedMatrices, av.VertexLength, av.VertexType, ffi)
		av.FullRenderData = General.Library.ConcatenateCArrays(av.RenderData, av.RenderDataLength, av.RenderDataType, ffi)
		Elements = ObjectRender.Library.ObjectRenders[ak].MakeElements(#av.TransformatedMatrices, av.PureRenderData, Space.GLuint)
		ObjectRender.Library.ObjectRenders[ak].Render(VBO, RDBO, av.FullTransformatedMatrix, MVP, #av.TransformatedMatrices, Elements, av.FullRenderData, ObjectRender.Library.ObjectRenders[ak].Space, ObjectRenderGive)
	end
end
GiveBack.Requirements = {"JSON", "General", "ffi", "ObjectRender", "AllDevices"}
return GiveBack
