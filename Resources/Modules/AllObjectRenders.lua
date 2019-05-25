local GiveBack = {}
function GiveBack.Start(Arguments)
  local Space, ffi = Arguments[1], Arguments[4]
  Space.ViewProjectionMatrix = ffi.Library.new("float[16]")
  print("AllObjectRenders Started")
end
function GiveBack.Stop(Arguments)
  local Space = Arguments[1]
  for ak,av in pairs(Space) do
    Space[ak] = nil
  end
  print("AllObjectRenders Stopped")
end
function GiveBack.RenderAllObjects(CameraObject, Objects, Arguments)
  local Space, ObjectRender, ObjectRenderGive, General = Arguments[1], Arguments[2], Arguments[3], Arguments[6]
  for bk=0,15 do
    Space.ViewProjectionMatrix[bk] = CameraObject.ViewProjectionMatrix.data[bk]
  end
  for ak=1,#Objects do
    local av = Objects[ak]
    if General.Library.SameLayer(CameraObject.VisualLayers, av.VisualLayers) then
      if av.ObjectRenderer ~= Space.PreviousRenderer then
        if Space.PreviousRenderer ~= nil then
          ObjectRender.Library.ObjectRenders[Space.PreviousRenderer].ChangeFrom(ObjectRender.Library.ObjectRenders[Space.PreviousRenderer].Space, ObjectRenderGive)
        end
        ObjectRender.Library.ObjectRenders[av.ObjectRenderer].ChangeTo(ObjectRender.Library.ObjectRenders[av.ObjectRenderer].Space, ObjectRenderGive)
  			Space.PreviousRenderer = av.ObjectRenderer
  		end
  		ObjectRender.Library.ObjectRenders[av.ObjectRenderer].Render(av, Space.ViewProjectionMatrix, ObjectRender.Library.ObjectRenders[av.ObjectRenderer].Space, ObjectRenderGive)
  	end
  end
end
GiveBack.Requirements = {"ObjectRender", "ffi", "General"}
return GiveBack
