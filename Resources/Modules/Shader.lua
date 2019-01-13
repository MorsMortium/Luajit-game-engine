local GiveBack = {}
--If IfPath true, then String is a Path, else it is a lua String filled with the Shadersourcecode
function GiveBack.Load(Shader, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive)
	local Char = ffi.Library.typeof("char[?]")
	-- Create the Shader
	local Object = {}
	Object.ShaderID = ffi.Library.new("GLuint[1]", OpenGL.Library.glCreateShader(OpenGL.Library[Shader.ShaderType]))
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
	local ShaderCodeC = Char(#ShaderCode+1)
	ffi.Library.copy(ShaderCodeC, ShaderCode)

	local Result = ffi.Library.new("GLint[1]", OpenGL.Library.GL_FALSE)
	local InfoLogLength = ffi.Library.new("int[1]")

	-- Compile Shader
	print("Compiling Shader: "..Shader.Name)
	local SourcePointer = ffi.Library.new("char const *[1]", ffi.Library.new("char const *", ShaderCodeC))
	OpenGL.Library.glShaderSource(Object.ShaderID[0], 1, SourcePointer , nil)
	OpenGL.Library.glCompileShader(Object.ShaderID[0])
	-- Check Shader
	OpenGL.Library.glGetShaderiv(Object.ShaderID[0], OpenGL.Library.GL_COMPILE_STATUS, Result)
	if Result[0] ~= OpenGL.Library.GL_TRUE then
		OpenGL.Library.glGetShaderiv(Object.ShaderID[0], OpenGL.Library.GL_INFO_LOG_LENGTH, InfoLogLength)
		local ShaderErrorMessage = Char(InfoLogLength[0]+1)
		OpenGL.Library.glGetShaderInfoLog(Object.ShaderID[0], InfoLogLength[0], nil, ShaderErrorMessage)
		print(ffi.Library.string(ShaderErrorMessage))
	end
	Object.ShaderType = Shader.ShaderType
	if Shader.ShaderType == "GL_VERTEX_SHADER" then
		Object.Inputs = Shader.Inputs
	end
	Object.Uniforms = Shader.Uniforms
	return Object
end
function GiveBack.Delete(ShaderID, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive)
	OpenGL.Library.glDeleteShader(ShaderID[0])
end
GiveBack.Requirements = {"OpenGL", "OpenGLInit", "ffi"}
return GiveBack
