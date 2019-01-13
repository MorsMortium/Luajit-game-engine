local GiveBack = {}
function GiveBack.Start(Space, ObjectRender, ObjectRenderGive, ffi, ffiGive, lgsl, lgslGive, General, GeneralGive)
  Space.ViewProjectionMatrix = ffi.Library.new("float[16]")
  print("AllObjectRenders Started")
end
function GiveBack.Stop(Space, ObjectRender, ObjectRenderGive, ffi, ffiGive, lgsl, lgslGive, General, GeneralGive)
  Space.ViewProjectionMatrix = nil
  print("AllObjectRenders Stopped")
end
function GiveBack.RenderAllObjects(CameraObject, Objects, Space, ObjectRender, ObjectRenderGive, ffi, ffiGive, lgsl, lgslGive, General, GeneralGive)
	for k, v in pairs(Objects) do
    if General.Library.SameLayer(CameraObject.VisualLayers, v.VisualLayers) then
      if v.ObjectRenderer ~= Space.PreviousRenderer then
        if Space.PreviousRenderer ~= nil then
          ObjectRender.Library.ObjectRenders[Space.PreviousRenderer].ChangeFrom(ObjectRender.Library.ObjectRenders[Space.PreviousRenderer].Space, unpack(ObjectRenderGive))
        end
        ObjectRender.Library.ObjectRenders[v.ObjectRenderer].ChangeTo(ObjectRender.Library.ObjectRenders[v.ObjectRenderer].Space, unpack(ObjectRenderGive))
  			Space.PreviousRenderer = v.ObjectRenderer
  		end
      for i=0,15 do
        Space.ViewProjectionMatrix[i] = CameraObject.ViewProjectionMatrix.data[i]
      end
  		ObjectRender.Library.ObjectRenders[v.ObjectRenderer].Render(v, Space.ViewProjectionMatrix, ObjectRender.Library.ObjectRenders[v.ObjectRenderer].Space, unpack(ObjectRenderGive))
  	end
  end
end
GiveBack.Requirements = {"ObjectRender", "ffi", "lgsl", "General"}
return GiveBack
