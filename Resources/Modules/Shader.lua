return function(args)
	local OpenGL, OpenGLInit, ffi, CTypes = args[1], args[2], args[3], args[4]
	local ffi, OpenGL, Types = ffi.Library, OpenGL.Library, CTypes.Library.Types
	local char, GLint, int, constcharp = Types["char[?]"].Type,
	Types["GLint[?]"].Type, Types["int[?]"].Type, Types["const char *[?]"].Type
	local GiveBack = {}

	function GiveBack.Reload(args)
		OpenGL, OpenGLInit, ffi, CTypes = args[1], args[2], args[3], args[4]
		ffi, OpenGL, Types = ffi.Library, OpenGL.Library, CTypes.Library.Types
		char, GLint, int, constcharp = Types["char[?]"].Type,
		Types["GLint[?]"].Type, Types["int[?]"].Type, Types["const char *[?]"].Type
  end

	--If IfPath true, then String is a Path
	--othervise it is a lua String filled with the Shadersourcecode
	function GiveBack.Create(GotShader)
		--Creating the Shader array
		local Shader = {}

		--Creating the Shader with OpenGL
		Shader.ShaderID = OpenGL.glCreateShader(OpenGL[GotShader.ShaderType])

		--Reading in the source code
		local ShaderCode = ""
		if GotShader.IfPath then
			--Read the Shader code from the file
			local File = io.open(GotShader.String, "rb")
			if (File) then
				ShaderCode = File:read("*all")
				File:close()
			else
				io.write("File not found\n")
			end
		else
			--Read the Shader code from the string
			ShaderCode = GotShader.String
		end

		--Copy the source code from Lua string into C string
		local ShaderCodeC = char(#ShaderCode + 1)
		ffi.copy(ShaderCodeC, ShaderCode)

		--Prepare error handling
		local Result = GLint(1, OpenGL.GL_FALSE)
		local InfoLogLength = int(1)

		io.write("Compiling Shader: "..GotShader.Name, "\n")

		--Load source into OpenGL
		local SourcePointer = constcharp(1, ShaderCodeC)
		OpenGL.glShaderSource(Shader.ShaderID, 1, SourcePointer , nil)

		--Compile Shader
		OpenGL.glCompileShader(Shader.ShaderID)

		--Check Shader for error
		OpenGL.glGetShaderiv(Shader.ShaderID, OpenGL.GL_COMPILE_STATUS, Result)

		--If the Shader didn't compile, write error to terminal
		--TODO: Proper error handling
		--(Not error message, but not returning faulty Shader)
		if Result[0] ~= OpenGL.GL_TRUE then
			OpenGL.glGetShaderiv(Shader.ShaderID, OpenGL.GL_INFO_LOG_LENGTH,
			InfoLogLength)
			local ShaderErrorMessage = char(InfoLogLength[0] + 1)
			OpenGL.glGetShaderInfoLog(Shader.ShaderID, InfoLogLength[0], nil,
			ShaderErrorMessage)
			io.write(ffi.string(ShaderErrorMessage), "\n")
		end

		--Set type of Shader
		Shader.ShaderType = GotShader.ShaderType

		--Set inputs for vertex shader
		if GotShader.ShaderType == "GL_VERTEX_SHADER" then
			Shader.Inputs = GotShader.Inputs
		end

		--Set Uniforms for all shaders
		Shader.Uniforms = GotShader.Uniforms

		return Shader
	end

	--Deletes a Shader
	function GiveBack.Destroy(ShaderID)
		OpenGL.glDeleteShader(ShaderID[0])
	end
	return GiveBack
end
