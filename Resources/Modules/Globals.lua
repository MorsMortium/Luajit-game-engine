return function(args)
  local Space = args[1]
  local type, pairs = type, pairs
  local GiveBack = {}

  function GiveBack.Reload(args)
    local Space = args[1]
    type, pairs = type, pairs
  end

  GiveBack.Globals = {["type"] = type, ["pairs"] = pairs}

  function GiveBack.Start(Configurations)
    for ak,av in pairs(_G) do
      if type(av) == "table" then
        for bk,bv in pairs(av) do
          if GiveBack.Globals[bk] then
            GiveBack.Globals[ak .. bk] = bv
          else
            GiveBack.Globals[bk] = bv
          end
        end
      else
        GiveBack.Globals[ak] = av
      end
    end
  end
  function GiveBack.Stop()
    for ak,av in pairs(GiveBack.Globals) do
      GiveBack.Globals[ak] = nil
    end
   end
   return GiveBack
end
