local GiveBack = {}
function GiveBack.Create(Program, Arguments)
	local AllShaders, OpenGL, ffi = Arguments[1], Arguments[3], Arguments[5]
	local Char = ffi.Library.typeof("char[?]")
	local InfoLogLength = ffi.Library.new("int[1]")
	local Result = ffi.Library.new("GLint[1]", OpenGL.Library.GL_FALSE)
	local Object = {}
	Object.Inputs = {}
	Object.Uniforms = {}
	-- Link the Program
	print("Linking Program: "..Program.Name)
	Object.ProgramID = ffi.Library.new("GLuint[1]", OpenGL.Library.glCreateProgram())
	for ak=1,#Program.Shaders do
		local av = Program.Shaders[ak]
		OpenGL.Library.glAttachShader(Object.ProgramID[0], AllShaders.Space.Shaders[av].ShaderID[0])
	end
	OpenGL.Library.glLinkProgram(Object.ProgramID[0])
	-- Check the Program
	OpenGL.Library.glGetProgramiv(Object.ProgramID[0], OpenGL.Library.GL_LINK_STATUS, Result)
	if Result[0] ~= OpenGL.Library.GL_TRUE then
		OpenGL.Library.glGetProgramiv(Object.ProgramID[0], OpenGL.Library.GL_INFO_LOG_LENGTH, InfoLogLength)
		local ProgramErrorMessage = Char(InfoLogLength[0] + 1)
		OpenGL.Library.glGetProgramInfoLog(Object.ProgramID[0], InfoLogLength[0], nil, ProgramErrorMessage)
		print(ffi.Library.string(ProgramErrorMessage))
	end
	for ak=1,#Program.Shaders do
		local av = Program.Shaders[ak]
		OpenGL.Library.glDetachShader(Object.ProgramID[0], AllShaders.Space.Shaders[av].ShaderID[0])
		if AllShaders.Space.Shaders[av].ShaderType == "GL_VERTEX_SHADER" and type(AllShaders.Space.Shaders[av].Inputs) == "table" then
			for bk=1,#AllShaders.Space.Shaders[av].Inputs do
				local bv = AllShaders.Space.Shaders[av].Inputs[bk]
				Object.Inputs[bv] = OpenGL.Library.glGetAttribLocation(Object.ProgramID[0], bv)
			end
		end
		if type(AllShaders.Space.Shaders[av].Uniforms) == "table" then
			for bk=1,#AllShaders.Space.Shaders[av].Uniforms do
				local bv = AllShaders.Space.Shaders[av].Uniforms[bk]
				Object.Uniforms[bv] = OpenGL.Library.glGetUniformLocation(Object.ProgramID[0], bv)
			end
		end
	end
	return Object
end
function GiveBack.Destroy(ProgramID, Arguments)
	local OpenGL = Arguments[3]
	OpenGL.Library.glDeleteProgram(ProgramID[0])
end
GiveBack.Requirements = {"AllShaders", "OpenGL", "ffi"}
return GiveBack
