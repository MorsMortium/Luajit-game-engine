return function(args)
	local AllShaders, OpenGL, ffi, CTypes, Globals = args[1], args[2], args[3],
	args[4], args[5]
	local Globals = Globals.Library.Globals
	local ffi, OpenGL, Shaders, Types, type, write = ffi.Library, OpenGL.Library,
	AllShaders.Space.Shaders, CTypes.Library.Types, Globals.type, Globals.write
	local char, GLint, int = Types["char[?]"].Type, Types["GLint[?]"].Type,
	Types["int[?]"].Type
	
	local GiveBack = {}

	--This script creates a shader program from different shaders
	function GiveBack.Create(GotProgram)
		--Creating the Program array
		local Program = {}

		Program.Inputs = {}
		Program.Uniforms = {}

		--Creating the Program with OpenGL
		Program.ProgramID = OpenGL.glCreateProgram()

		--Ataching the shaders of the Program

		for ak=1,#GotProgram.Shaders do
			local av = GotProgram.Shaders[ak]
			OpenGL.glAttachShader(Program.ProgramID, Shaders[av].ShaderID)
		end

		--Link the Program
		write("Linking Program: ", GotProgram.Name, "\n")
		OpenGL.glLinkProgram(Program.ProgramID)

		--Prepare error handling
		local Result = GLint(1, OpenGL.GL_FALSE)
		local InfoLogLength = int(1)

		--If the Program didn't link, write error to terminal
		--TODO: Proper error handling
		--(Not error message, but not returning faulty Program)
		OpenGL.glGetProgramiv(Program.ProgramID, OpenGL.GL_LINK_STATUS, Result)
		if Result[0] ~= OpenGL.GL_TRUE then
			OpenGL.glGetProgramiv(Program.ProgramID, OpenGL.GL_INFO_LOG_LENGTH,
			InfoLogLength)
			local ProgramErrorMessage = char(InfoLogLength[0] + 1)
			OpenGL.glGetProgramInfoLog(Program.ProgramID, InfoLogLength[0], nil,
			ProgramErrorMessage)
			write(ffi.string(ProgramErrorMessage), "\n")
		end

		--Detaching the shaders of the Program
		--Finding Input and Uniform addresses
		for ak=1,#GotProgram.Shaders do
			local av = GotProgram.Shaders[ak]
			OpenGL.glDetachShader(Program.ProgramID, Shaders[av].ShaderID)
			if Shaders[av].ShaderType == "GL_VERTEX_SHADER" and
			type(Shaders[av].Inputs) == "table" then
				for bk=1,#Shaders[av].Inputs do
					local bv = Shaders[av].Inputs[bk]
					Program.Inputs[bv] = OpenGL.glGetAttribLocation(Program.ProgramID, bv)
				end
			end
			if type(Shaders[av].Uniforms) == "table" then
				for bk=1,#Shaders[av].Uniforms do
					local bv = Shaders[av].Uniforms[bk]
					Program.Uniforms[bv] = OpenGL.glGetUniformLocation(Program.ProgramID, bv)
				end
			end
		end
		return Program
	end

	--Deletes a Program
	function GiveBack.Destroy(ProgramID)
		OpenGL.glDeleteProgram(ProgramID)
	end
	return GiveBack
end
