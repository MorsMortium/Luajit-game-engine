local GiveBack = {}

--This script creates a shader program from different shaders
function GiveBack.Create(GotProgram, Arguments)
	local AllShaders, OpenGL, ffi = Arguments[1], Arguments[3], Arguments[5]
	local ffi = ffi.Library
	local OpenGL = OpenGL.Library

	--Construtor for error message
	local Char = ffi.typeof("char[?]")

	--Creating the Program array
	local Program = {}

	Program.Inputs = {}
	Program.Uniforms = {}

	--Creating the Program with OpenGL
	Program.ProgramID = OpenGL.glCreateProgram()

	--Ataching the shaders of the Program
	local Shaders = AllShaders.Space.Shaders
	for ak=1,#GotProgram.Shaders do
		local av = GotProgram.Shaders[ak]
		OpenGL.glAttachShader(Program.ProgramID, Shaders[av].ShaderID)
	end

	-- Link the Program
	print("Linking Program: "..GotProgram.Name)
	OpenGL.glLinkProgram(Program.ProgramID)

	--Prepare error handling
	local InfoLogLength = ffi.new("int[1]")
	local Result = ffi.new("GLint[1]", OpenGL.GL_FALSE)

	--If the Program didn't link, write error to terminal
	--TODO: Proper error handling
	--(Not error message, but not returning faulty Program)
	OpenGL.glGetProgramiv(Program.ProgramID, OpenGL.GL_LINK_STATUS, Result)
	if Result[0] ~= OpenGL.GL_TRUE then
		OpenGL.glGetProgramiv(Program.ProgramID, OpenGL.GL_INFO_LOG_LENGTH,
		InfoLogLength)
		local ProgramErrorMessage = Char(InfoLogLength[0] + 1)
		OpenGL.glGetProgramInfoLog(Program.ProgramID, InfoLogLength[0], nil,
		ProgramErrorMessage)
		print(ffi.string(ProgramErrorMessage))
	end

	--Detaching the shaders of the Program
	--Finding Input and Uniform addresses
	for ak=1,#GotProgram.Shaders do
		local av = GotProgram.Shaders[ak]
		OpenGL.glDetachShader(Program.ProgramID, Shaders[av].ShaderID)
		if AllShaders.Space.Shaders[av].ShaderType == "GL_VERTEX_SHADER" and
		type(AllShaders.Space.Shaders[av].Inputs) == "table" then
			for bk=1,#AllShaders.Space.Shaders[av].Inputs do
				local bv = AllShaders.Space.Shaders[av].Inputs[bk]
				Program.Inputs[bv] = OpenGL.glGetAttribLocation(Program.ProgramID, bv)
			end
		end
		if type(AllShaders.Space.Shaders[av].Uniforms) == "table" then
			for bk=1,#AllShaders.Space.Shaders[av].Uniforms do
				local bv = AllShaders.Space.Shaders[av].Uniforms[bk]
				Program.Uniforms[bv] = OpenGL.glGetUniformLocation(Program.ProgramID, bv)
			end
		end
	end

	return Program
end

--Deletes a Program
function GiveBack.Destroy(ProgramID, Arguments)
	local OpenGL = Arguments[3]
	local OpenGL = OpenGL.Library
	OpenGL.glDeleteProgram(ProgramID)
end
GiveBack.Requirements = {"AllShaders", "OpenGL", "ffi"}
return GiveBack
