return function(args)
	local Space, Program, Globals = args[1], args[2], args[3]
	local Globals = Globals.Library.Globals
	local Create, Destroy, type = Program.Library.Create, Program.Library.Destroy,
	Globals.type
	
	local GiveBack = {}

	--Creates every Program with Program.lua from shaders loaded by AllShaders.lua
	function GiveBack.Start(Configurations)
		Space.Programs = {}
		if type(Configurations) == "table" then
			for ak=1,#Configurations do
				local av = Configurations[ak]
				Space.Programs[av.Name] = Create(av)
			end
		end
		--TODO: Default programs full redo after shaders
		--[[
		local DefaultProgram = {}
		DefaultProgram.Name = "DefaultOpenGLWindowProgram"
		DefaultProgram.Shaders =
		{"DefaultOpenGLWindowVertexShader", "DefaultOpenGLWindowFragmentShader"}
		Space.Programs[DefaultProgram.Name] =
		Create(DefaultProgram)
		DefaultProgram.Name = "DefaultObjectProgram"
		DefaultProgram.Shaders =
		{"DefaultObjectVertexShader", "DefaultObjectFragmentShader"}
		Space.Programs[DefaultProgram.Name] =
		Create(DefaultProgram)
		--]]
	end

	--Deletes every Program
	function GiveBack.Stop()
		for ak=1,#Space.Programs do
			Destroy(Space.Programs[ak].ProgramID)
		end
	end
	return GiveBack
end
