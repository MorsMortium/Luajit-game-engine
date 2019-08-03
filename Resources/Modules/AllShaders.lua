local GiveBack = {}

--Loads every Shader with Shader.lua
function GiveBack.Start(Configurations, Arguments)
	local Space, Shader, ShaderGive = Arguments[1], Arguments[2], Arguments[3]
	local Shaders = Configurations
	Space.Shaders = {}
	if Shaders then
		for ak=1,#Shaders do
			local av = Shaders[ak]
			Space.Shaders[av.Name] = Shader.Library.Create(av, ShaderGive)
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
	Space.Shaders[DefaultShader.Name] =
	Shader.Library.Create(DefaultShader, ShaderGive)
	DefaultShader.Name = "DefaultObjectFragmentShader"
	DefaultShader.String =
	"./Resources/Shaders/DefaultObjectFragmentShader.txt"
	DefaultShader.Uniforms[1] = "COLOR"
	Space.Shaders[DefaultShader.Name] =
	Shader.Library.Create(DefaultShader, ShaderGive)
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
	Space.Shaders[DefaultShader.Name] =
	Shader.Library.Create(DefaultShader, ShaderGive)
	DefaultShader.Name = "DefaultOpenGLWindowVertexShader"
	DefaultShader.String =
	"./Resources/Shaders/DefaultOpenGLWindowVertexShader.txt"
	DefaultShader.Inputs = nil
	DefaultShader.Uniforms = nil
	--DefaultShader.Inputs[1] =
	Space.Shaders[DefaultShader.Name] =
	Shader.Library.Create(DefaultShader, ShaderGive)
	--]]
	io.write("AllShaders Started\n")
end

--Deletes every Shader
function GiveBack.Stop(Arguments)
	local Space, Shader, ShaderGive = Arguments[1], Arguments[2], Arguments[3]
	for ak=1,#Space.Shaders do
		local av = Space.Shaders[ak]
		Shader.Library.Destroy(av.ShaderID, ShaderGive)
	end
	io.write("AllShaders Stopped\n")
end
GiveBack.Requirements = {"Shader"}
return GiveBack
