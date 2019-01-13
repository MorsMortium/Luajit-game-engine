local GiveBack = {}
function GiveBack.Start(Space, Program, ProgramGive, JSON, JSONGive)
	local Programs  = JSON.Library:DecodeFromFile("./Resources/Configurations/AllPrograms.json")
	Space.Programs = {}
	if Programs then
		for k, v in pairs(Programs) do
			Space.Programs[v.Name] = Program.Library.Compile(v, unpack(ProgramGive))
		end
	end
	local DefaultProgram = {}
	DefaultProgram.Name = "DefaultOpenGLWindowProgram"
	DefaultProgram.Shaders = {"DefaultOpenGLWindowVertexShader", "DefaultOpenGLWindowFragmentShader"}
	Space.Programs[DefaultProgram.Name] = Program.Library.Compile(DefaultProgram, unpack(ProgramGive))
	DefaultProgram.Name = "DefaultObjectProgram"
	DefaultProgram.Shaders = {"DefaultObjectVertexShader", "DefaultObjectFragmentShader"}
	Space.Programs[DefaultProgram.Name] = Program.Library.Compile(DefaultProgram, unpack(ProgramGive))
	print("AllPrograms Started")
end
function GiveBack.Stop(Space, Program, ProgramGive, JSON, JSONGive)
	for k,v in pairs(Space.Programs) do
		Program.Library.Delete(v.ProgramID, unpack(ProgramGive))
	end
	print("AllPrograms Stopped")
end
GiveBack.Requirements = {"Program", "JSON"}
return GiveBack
