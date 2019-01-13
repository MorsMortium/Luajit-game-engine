local GiveBack = {}
function GiveBack.Compile(Program, AllShaders, AllShadersGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive)
	local Char = ffi.Library.typeof("char[?]")
	local InfoLogLength = ffi.Library.new("int[1]")
	local Result = ffi.Library.new("GLint[1]", OpenGL.Library.GL_FALSE)
	local Object = {}
	Object.Inputs = {}
	Object.Uniforms = {}
	-- Link the Program
	print("Linking Program: "..Program.Name)
	Object.ProgramID = ffi.Library.new("GLuint[1]", OpenGL.Library.glCreateProgram())
	for k, v in pairs(Program.Shaders) do
		OpenGL.Library.glAttachShader(Object.ProgramID[0], AllShaders.Space.Shaders[v].ShaderID[0])
	end
	OpenGL.Library.glLinkProgram(Object.ProgramID[0])
	-- Check the Program
	OpenGL.Library.glGetProgramiv(Object.ProgramID[0], OpenGL.Library.GL_LINK_STATUS, Result)
	if Result[0] ~= OpenGL.Library.GL_TRUE then
		OpenGL.Library.glGetProgramiv(Object.ProgramID[0], OpenGL.Library.GL_INFO_LOG_LENGTH, InfoLogLength)
		local ProgramErrorMessage = Char(InfoLogLength[0]+1)
		OpenGL.Library.glGetProgramInfoLog(Object.ProgramID[0], InfoLogLength[0], nil, ProgramErrorMessage)
		print(ffi.Library.string(ProgramErrorMessage))
	end
	for k, v in pairs(Program.Shaders) do
		OpenGL.Library.glDetachShader(Object.ProgramID[0], AllShaders.Space.Shaders[v].ShaderID[0])
		if AllShaders.Space.Shaders[v].ShaderType == "GL_VERTEX_SHADER" and type(AllShaders.Space.Shaders[v].Inputs) == "table" then
			for x, y in pairs(AllShaders.Space.Shaders[v].Inputs) do
				Object.Inputs[y] = OpenGL.Library.glGetAttribLocation(Object.ProgramID[0], y)
			end
		end
		if type(AllShaders.Space.Shaders[v].Uniforms) == "table" then
			for x, y in pairs(AllShaders.Space.Shaders[v].Uniforms) do
				Object.Uniforms[y] = OpenGL.Library.glGetUniformLocation(Object.ProgramID[0], y)
			end
		end
	end
	return Object
end
function GiveBack.Delete(ProgramID, AllShaders, AllShadersGive, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive)
	OpenGL.Library.glDeleteProgram(ProgramID[0])
end
GiveBack.Requirements = {"AllShaders", "OpenGL", "OpenGLInit", "ffi"}
return GiveBack
