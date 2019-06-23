local GiveBack = {}
function GiveBack.Create(Program, Arguments)
	local AllShaders, OpenGL, ffi = Arguments[1], Arguments[3], Arguments[5]
	local ffi = ffi.Library
	local OpenGL = OpenGL.Library
	local Char = ffi.typeof("char[?]")
	local InfoLogLength = ffi.new("int[1]")
	local Result = ffi.new("GLint[1]", OpenGL.GL_FALSE)
	local Object = {}
	Object.Inputs = {}
	Object.Uniforms = {}
	-- Link the Program
	print("Linking Program: "..Program.Name)
	Object.ProgramID = OpenGL.glCreateProgram()
	local Shaders = AllShaders.Space.Shaders
	for ak=1,#Program.Shaders do
		local av = Program.Shaders[ak]
		OpenGL.glAttachShader(Object.ProgramID, Shaders[av].ShaderID)
	end
	OpenGL.glLinkProgram(Object.ProgramID)
	-- Check the Program
	OpenGL.glGetProgramiv(Object.ProgramID, OpenGL.GL_LINK_STATUS, Result)
	if Result[0] ~= OpenGL.GL_TRUE then
		OpenGL.glGetProgramiv(Object.ProgramID, OpenGL.GL_INFO_LOG_LENGTH,
		InfoLogLength)
		local ProgramErrorMessage = Char(InfoLogLength[0] + 1)
		OpenGL.glGetProgramInfoLog(Object.ProgramID, InfoLogLength[0], nil,
		ProgramErrorMessage)
		print(ffi.string(ProgramErrorMessage))
	end
	for ak=1,#Program.Shaders do
		local av = Program.Shaders[ak]
		OpenGL.glDetachShader(Object.ProgramID, Shaders[av].ShaderID)
		if AllShaders.Space.Shaders[av].ShaderType == "GL_VERTEX_SHADER" and
		type(AllShaders.Space.Shaders[av].Inputs) == "table" then
			for bk=1,#AllShaders.Space.Shaders[av].Inputs do
				local bv = AllShaders.Space.Shaders[av].Inputs[bk]
				Object.Inputs[bv] = OpenGL.glGetAttribLocation(Object.ProgramID, bv)
			end
		end
		if type(AllShaders.Space.Shaders[av].Uniforms) == "table" then
			for bk=1,#AllShaders.Space.Shaders[av].Uniforms do
				local bv = AllShaders.Space.Shaders[av].Uniforms[bk]
				Object.Uniforms[bv] = OpenGL.glGetUniformLocation(Object.ProgramID, bv)
			end
		end
	end
	return Object
end
function GiveBack.Destroy(ProgramID, Arguments)
	local OpenGL = Arguments[3]
	local OpenGL = OpenGL.Library
	OpenGL.glDeleteProgram(ProgramID)
end
GiveBack.Requirements = {"AllShaders", "OpenGL", "ffi"}
return GiveBack
