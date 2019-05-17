local GiveBack = {}
function GiveBack.Start(Arguments)
	local Space, Shader, ShaderGive, JSON = Arguments[1], Arguments[2], Arguments[3], Arguments[4]
	local Shaders = JSON.Library:DecodeFromFile("./Resources/Configurations/AllShaders.json")
	Space.Shaders = {}
	if Shaders then
		for ak=1,#Shaders do
			local av = Shaders[ak]
			Space.Shaders[av.Name] = Shader.Library.Create(av, ShaderGive)
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
	Space.Shaders[DefaultShader.Name] = Shader.Library.Create(DefaultShader, ShaderGive)
	DefaultShader.Name = "DefaultObjectFragmentShader"
	DefaultShader.String = "./Resources/Shaders/DefaultObjectFragmentShader.txt"
	DefaultShader.Uniforms[1] = "COLOR"
	Space.Shaders[DefaultShader.Name] = Shader.Library.Create(DefaultShader, ShaderGive)
	DefaultShader.Name = "DefaultObjectVertexShader"
	DefaultShader.String = "./Resources/Shaders/DefaultObjectVertexShader.txt"
	DefaultShader.ShaderType = "GL_VERTEX_SHADER"
	DefaultShader.Inputs = nil
	DefaultShader.Uniforms = nil
	DefaultShader.Uniforms = {}
	DefaultShader.Inputs = {}
	DefaultShader.Inputs[1] = "Position"
	DefaultShader.Uniforms[1] = "MVP"
	Space.Shaders[DefaultShader.Name] = Shader.Library.Create(DefaultShader, ShaderGive)
	DefaultShader.Name = "DefaultOpenGLWindowVertexShader"
	DefaultShader.String = "./Resources/Shaders/DefaultOpenGLWindowVertexShader.txt"
	DefaultShader.Inputs = nil
	DefaultShader.Uniforms = nil
	--TODO
	--DefaultShader.Inputs[1] =
	Space.Shaders[DefaultShader.Name] = Shader.Library.Create(DefaultShader, ShaderGive)
	print("AllShaders Started")
end
function GiveBack.Stop(Arguments)
	local Space, Shader, ShaderGive = Arguments[1], Arguments[2], Arguments[3]
	for ak=1,#Space.Shaders do
		local av = Space.Shaders[ak]
		Shader.Library.Destroy(av.ShaderID, ShaderGive)
	end
	for ak,av in pairs(Space) do
		Space[ak] = nil
	end
	print("AllShaders Stopped")
end
GiveBack.Requirements = {"Shader", "JSON"}
return GiveBack
