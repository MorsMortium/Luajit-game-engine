local GiveBack = {}

--Creates every Program with Program.lua from shaders loaded by AllShaders.lua
function GiveBack.Start(Arguments)
	local Space, Program, ProgramGive, JSON = Arguments[1], Arguments[2],
	Arguments[3], Arguments[4]
	local Programs  = JSON.Library:DecodeFromFile("AllPrograms.json")
	Space.Programs = {}
	if Programs then
		for ak=1,#Programs do
			local av = Programs[ak]
			Space.Programs[av.Name] = Program.Library.Create(av, ProgramGive)
		end
	end
	--TODO: Default programs full redo after shaders
	--[[
	local DefaultProgram = {}
	DefaultProgram.Name = "DefaultOpenGLWindowProgram"
	DefaultProgram.Shaders =
	{"DefaultOpenGLWindowVertexShader", "DefaultOpenGLWindowFragmentShader"}
	Space.Programs[DefaultProgram.Name] =
	Program.Library.Create(DefaultProgram, ProgramGive)
	DefaultProgram.Name = "DefaultObjectProgram"
	DefaultProgram.Shaders =
	{"DefaultObjectVertexShader", "DefaultObjectFragmentShader"}
	Space.Programs[DefaultProgram.Name] =
	Program.Library.Create(DefaultProgram, ProgramGive)
	--]]
	print("AllPrograms Started")
end

--Deletes every Program
function GiveBack.Stop(Arguments)
	Space, Program, ProgramGive = Arguments[1], Arguments[2], Arguments[3]
	for ak=1,#Space.Programs do
		local av = Space.Programs[ak]
		Program.Library.Destroy(av.ProgramID, ProgramGive)
	end
	for ak,av in pairs(Space) do
		Space[ak] = nil
	end
	print("AllPrograms Stopped")
end
GiveBack.Requirements = {"Program", "JSON"}
return GiveBack
