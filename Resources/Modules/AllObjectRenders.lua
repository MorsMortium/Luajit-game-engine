local GiveBack = {}
function GiveBack.Start(Arguments)
  local Space, ffi = Arguments[1], Arguments[4]
  print("AllObjectRenders Started")
end
function GiveBack.Stop(Arguments)
  local Space = Arguments[1]
  for ak,av in pairs(Space) do
    Space[ak] = nil
  end
  print("AllObjectRenders Stopped")
end
function GiveBack.RenderAllObjects(CameraObject, Objects, MVP, Arguments)
  local Space, ObjectRender, ObjectRenderGive, General = Arguments[1], Arguments[2], Arguments[3], Arguments[6]
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
  		ObjectRender.Library.ObjectRenders[av.ObjectRenderer].Render(av, MVP, ObjectRender.Library.ObjectRenders[av.ObjectRenderer].Space, ObjectRenderGive)
  	end
  end
end
GiveBack.Requirements = {"ObjectRender", "ffi", "General"}
return GiveBack
