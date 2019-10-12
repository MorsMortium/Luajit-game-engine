return function(args)
  local Space, ffi, OpenGL, SDL, Globals = args[1], args[2], args[3], args[4],
  args[5]
  local Globals = Globals.Library.Globals
  local pcall, type, pairs, write = Globals.pcall, Globals.type, Globals.pairs,
  Globals.write
  
  local GiveBack = {}

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
          write(TypeOrError, "\n")
        end
      end
    end
  end
  function GiveBack.Stop()
    for ak,av in pairs(GiveBack.Types) do
      GiveBack.Types[ak] = nil
    end
   end
   return GiveBack
end
