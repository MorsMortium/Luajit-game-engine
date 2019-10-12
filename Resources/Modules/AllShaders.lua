return function(args)
	local Space, Shader, Globals = args[1], args[2], args[3]
	local Globals = Globals.Library.Globals
	local Create, Destroy, type = Shader.Library.Create, Shader.Library.Destroy,
	Globals.type
	
	local GiveBack = {}

	--Loads every Shader with Shader.lua
	function GiveBack.Start(Configurations)
		Space.Shaders = {}
		if type(Configurations) == "table" then
			for ak=1,#Configurations do
				local av = Configurations[ak]
				Space.Shaders[av.Name] = Create(av)
			end
		end
		--TODO: Default shaders full redo
		--[[
		local DefaultShader = {}
		DefaultShader.Uniforms = {}
		DefaultShader.Inputs = {}
		DefaultShader.Name = "DefaultOpenGLWindowFragmentShader"
		DefaultShader.IfPath = true
		DefaultShader.String =
		"./Resources/Shaders/DefaultOpenGLWindowFragmentShader.txt"
		DefaultShader.ShaderType = "GL_FRAGMENT_SHADER"
		--DefaultShader.Uniforms[1] =
		Space.Shaders[DefaultShader.Name] = Create(DefaultShader)
		DefaultShader.Name = "DefaultObjectFragmentShader"
		DefaultShader.String =
		"./Resources/Shaders/DefaultObjectFragmentShader.txt"
		DefaultShader.Uniforms[1] = "COLOR"
		Space.Shaders[DefaultShader.Name] = Create(DefaultShader)
		DefaultShader.Name = "DefaultObjectVertexShader"
		DefaultShader.String =
		"./Resources/Shaders/DefaultObjectVertexShader.txt"
		DefaultShader.ShaderType = "GL_VERTEX_SHADER"
		DefaultShader.Inputs = nil
		DefaultShader.Uniforms = nil
		DefaultShader.Uniforms = {}
		DefaultShader.Inputs = {}
		DefaultShader.Inputs[1] = "Position"
		DefaultShader.Uniforms[1] = "MVP"
		Space.Shaders[DefaultShader.Name] = Create(DefaultShader)
		DefaultShader.Name = "DefaultOpenGLWindowVertexShader"
		DefaultShader.String =
		"./Resources/Shaders/DefaultOpenGLWindowVertexShader.txt"
		DefaultShader.Inputs = nil
		DefaultShader.Uniforms = nil
		--DefaultShader.Inputs[1] =
		Space.Shaders[DefaultShader.Name] = Create(DefaultShader)
		--]]
	end

	--Deletes every Shader
	function GiveBack.Stop()
		for ak=1,#Space.Shaders do
			Destroy(Space.Shaders[ak].ShaderID)
		end
	end
	return GiveBack
end
