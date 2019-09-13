return function(args)
  local Space, ffi, OpenGL, SDL = args[1], args[2], args[3], args[4]
  local GiveBack = {}

  function GiveBack.Reload(args)
    Space, ffi, OpenGL, SDL = args[1], args[2], args[3], args[4]
  end

  GiveBack.Types = {}

  local function EndsWith(str, ending)
    return ending == "" or str:sub(-#ending) == ending
  end

  function GiveBack.Start(Configurations)
    if type(Configurations) == "table" then
      for ak=1,#Configurations do
        local av = Configurations[ak]
        local Ran, TypeOrError = pcall(ffi.Library.typeof, av)
        if Ran and TypeOrError then
          local SizeString = av
          if EndsWith(SizeString, "[?]") then
            SizeString = av:sub(1, av:len() - 3)
          end
          GiveBack.Types[av] = {Type = TypeOrError, Size = ffi.Library.sizeof(SizeString)}
        else
          io.write(TypeOrError, "\n")
        end
      end
    end
    io.write("CTypes Started\n")
  end
  function GiveBack.Stop()
    for ak,av in pairs(GiveBack.Types) do
      GiveBack.Types[ak] = nil
    end
     io.write("CTypes Stopped\n")
   end
   return GiveBack
end
