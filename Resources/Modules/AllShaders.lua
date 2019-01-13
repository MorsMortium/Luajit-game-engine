local GiveBack = {}
function GiveBack.Start(Space, Shader, ShaderGive, JSON, JSONGive)
	local Shaders = JSON.Library:DecodeFromFile("./Resources/Configurations/AllShaders.json")
	Space.Shaders = {}
	if Shaders then
		for k, v in pairs(Shaders) do
			Space.Shaders[v.Name] = Shader.Library.Load(v, unpack(ShaderGive))
		end
	end
	local DefaultShader = {}
	DefaultShader.Uniforms = {}
	DefaultShader.Inputs = {}
	DefaultShader.Name = "DefaultOpenGLWindowFragmentShader"
	DefaultShader.IfPath = true
	DefaultShader.String = "./Resources/Shaders/DefaultOpenGLWindowFragmentShader.txt"
	DefaultShader.ShaderType = "GL_FRAGMENT_SHADER"
	--TODO
	--DefaultShader.Uniforms[1] =
	Space.Shaders[DefaultShader.Name] = Shader.Library.Load(DefaultShader, unpack(ShaderGive))
	DefaultShader.Name = "DefaultObjectFragmentShader"
	DefaultShader.String = "./Resources/Shaders/DefaultObjectFragmentShader.txt"
	DefaultShader.Uniforms[1] = "COLOR"
	Space.Shaders[DefaultShader.Name] = Shader.Library.Load(DefaultShader, unpack(ShaderGive))
	DefaultShader.Name = "DefaultObjectVertexShader"
	DefaultShader.String = "./Resources/Shaders/DefaultObjectVertexShader.txt"
	DefaultShader.ShaderType = "GL_VERTEX_SHADER"
	DefaultShader.Inputs = nil
	DefaultShader.Uniforms = nil
	DefaultShader.Uniforms = {}
	DefaultShader.Inputs = {}
	DefaultShader.Inputs[1] = "Position"
	DefaultShader.Uniforms[1] = "MVP"
	Space.Shaders[DefaultShader.Name] = Shader.Library.Load(DefaultShader, unpack(ShaderGive))
	DefaultShader.Name = "DefaultOpenGLWindowVertexShader"
	DefaultShader.String = "./Resources/Shaders/DefaultOpenGLWindowVertexShader.txt"
	DefaultShader.Inputs = nil
	DefaultShader.Uniforms = nil
	--TODO
	--DefaultShader.Inputs[1] =
	Space.Shaders[DefaultShader.Name] = Shader.Library.Load(DefaultShader, unpack(ShaderGive))
	print("AllShaders Started")
end
function GiveBack.Stop(Space, Shader, ShaderGive, JSON, JSONGive)
	for k,v in pairs(Space.Shaders) do
		Shader.Library.Delete(v.ShaderID, unpack(ShaderGive))
	end
	print("AllShaders Stopped")
end
GiveBack.Requirements = {"Shader", "JSON"}
return GiveBack
