local GiveBack = {}
--If IfPath true, then String is a Path
--else it is a lua String filled with the Shadersourcecode
function GiveBack.Create(Shader, Arguments)
	local OpenGL, OpenGLInit, ffi = Arguments[1], Arguments[3], Arguments[5]
	local ffi = ffi.Library
	local OpenGL = OpenGL.Library
	local Char = ffi.typeof("char[?]")
	-- Create the Shader
	local NewShader = {}
	NewShader.ShaderID = OpenGL.glCreateShader(OpenGL[Shader.ShaderType])
	local ShaderCode = ""
	if Shader.IfPath then
		-- Read the Shader code from the File
		local File = io.open(Shader.String, "rb")
		if (File) then
        		ShaderCode = File:read("*all")
        		File:close()
		else
        		print("File not found")
		end
	else
		ShaderCode = Shader.String
	end
	local ShaderCodeC = Char(#ShaderCode + 1)
	ffi.copy(ShaderCodeC, ShaderCode)

	local Result = ffi.new("GLint[1]", OpenGL.GL_FALSE)
	local InfoLogLength = ffi.new("int[1]")

	-- Compile Shader
	print("Compiling Shader: "..Shader.Name)
	local SourcePointer = ffi.new("const char *[1]", ShaderCodeC)
	OpenGL.glShaderSource(NewShader.ShaderID, 1, SourcePointer , nil)
	OpenGL.glCompileShader(NewShader.ShaderID)
	-- Check Shader
	OpenGL.glGetShaderiv(NewShader.ShaderID, OpenGL.GL_COMPILE_STATUS, Result)
	if Result[0] ~= OpenGL.GL_TRUE then
		OpenGL.glGetShaderiv(NewShader.ShaderID, OpenGL.GL_INFO_LOG_LENGTH,
		InfoLogLength)
		local ShaderErrorMessage = Char(InfoLogLength[0] + 1)
		OpenGL.glGetShaderInfoLog(NewShader.ShaderID, InfoLogLength[0], nil,
		ShaderErrorMessage)
		print(ffi.string(ShaderErrorMessage))
	end
	NewShader.ShaderType = Shader.ShaderType
	if Shader.ShaderType == "GL_VERTEX_SHADER" then
		NewShader.Inputs = Shader.Inputs
	end
	NewShader.Uniforms = Shader.Uniforms
	return NewShader
end
function GiveBack.Destroy(ShaderID, Arguments)
	local OpenGL = Arguments[1]
	OpenGL.glDeleteShader(ShaderID[0])
end
GiveBack.Requirements = {"OpenGL", "OpenGLInit", "ffi"}
return GiveBack
