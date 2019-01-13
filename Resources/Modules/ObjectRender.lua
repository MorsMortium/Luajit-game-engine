local GiveBack = {}
GiveBack.ObjectRenders = {}
GiveBack.ObjectRenders.ColorPerSide = {}
function GiveBack.ObjectRenders.ColorPerSide.Start(Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
	Space.Elements = ffi.Library.new("GLubyte[3]")
	Space.Color = ffi.Library.new("GLfloat[3]")
end
function GiveBack.ObjectRenders.ColorPerSide.DataCheck(RenderData, GotData, Space, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
	RenderData.Color = ffi.Library.new("float[12]")
	if type(GotData) == "table" and #GotData == 12 and General.Library.GoodTypesOfTable(GotData, "number") then
		for i=1,12 do
			RenderData.Color[i - 1] = GotData[i]/255
		end
	else
		RenderData.Color[0] = 1
		RenderData.Color[1] = 0
		RenderData.Color[2] = 0
		RenderData.Color[3] = 0
		RenderData.Color[4] = 1
		RenderData.Color[5] = 0
		RenderData.Color[6] = 0
		RenderData.Color[7] = 0
		RenderData.Color[8] = 1
		RenderData.Color[9] = 1
		RenderData.Color[10] = 1
		RenderData.Color[11] = 0
	end
end
function GiveBack.ObjectRenders.ColorPerSide.Stop(Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
	Space.Elements = nil
	Space.Color =  nil
end
function GiveBack.ObjectRenders.ColorPerSide.ChangeTo(Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
  OpenGL.Library.glUseProgram(AllPrograms.Space.Programs.DefaultObjectProgram.ProgramID[0])
	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_FILL)
	--OpenGL.Library.glBufferData(OpenGL.Library.GL_ELEMENT_ARRAY_BUFFER, ffi.Library.sizeof(Space.Elements), Space.Elements, OpenGL.Library.GL_STATIC_DRAW)
	OpenGL.Library.glEnableVertexAttribArray(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position)
	OpenGL.Library.glVertexAttribPointer(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position, 4, OpenGL.Library.GL_DOUBLE, OpenGL.Library.GL_FALSE, 0, nil)
	--[[
	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_LINE)
	--]]
end
function GiveBack.ObjectRenders.ColorPerSide.ChangeFrom(Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
  OpenGL.Library.glDisableVertexAttribArray(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position)
end
function GiveBack.ObjectRenders.ColorPerSide.Render(Object, MVP, Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ARRAY_BUFFER, 128, Object.Transformated.data, OpenGL.Library.GL_DYNAMIC_DRAW)
	OpenGL.Library.glUniformMatrix4fv(AllPrograms.Space.Programs.DefaultObjectProgram.Uniforms.MVP,  1, OpenGL.Library.GL_FALSE, MVP)
	local Elements = {0, 1, 2, 3, 0, 1}
	for e=0,3 do
		for i=0,2 do
			Space.Color[i] = Object.RenderData.Color[i + e * 3]
			Space.Elements[i] = Elements[i + e + 1]
		end
		OpenGL.Library.glBufferData(OpenGL.Library.GL_ELEMENT_ARRAY_BUFFER, 3, Space.Elements, OpenGL.Library.GL_DYNAMIC_DRAW)
		OpenGL.Library.glUniform3fv(AllPrograms.Space.Programs.DefaultObjectProgram.Uniforms.COLOR, 1, Space.Color)
		OpenGL.Library.glDrawElements(OpenGL.Library.GL_TRIANGLES, 3, OpenGL.Library.GL_UNSIGNED_BYTE, nil)
	end
end
GiveBack.ObjectRenders.SomeSides = {}
function GiveBack.ObjectRenders.SomeSides.Start(Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
	Space.Elements = ffi.Library.new("GLubyte[3]")
	Space.Color = ffi.Library.new("GLfloat[3]")
end
function GiveBack.ObjectRenders.SomeSides.DataCheck(RenderData, GotData, Space, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
	RenderData.Color = ffi.Library.new("float[12]")
	RenderData.Sides = {}
	if type(GotData) == "table" and #GotData == 2 and type(GotData[1]) == "table" and type(GotData[2]) == "table" and #GotData[1] == 12 and General.Library.GoodTypesOfTable(GotData[1], "number") and #GotData[2] == 4 and General.Library.GoodTypesOfTable(GotData[2], "boolean") then
		for i=1,12 do
			RenderData.Color[i - 1] = GotData[1][i]/255
		end
		for i=1,4 do
			RenderData.Sides[i] = GotData[2][i]
		end
	else
		RenderData.Color[0] = 1
		RenderData.Color[1] = 0
		RenderData.Color[2] = 0
		RenderData.Color[3] = 0
		RenderData.Color[4] = 1
		RenderData.Color[5] = 0
		RenderData.Color[6] = 0
		RenderData.Color[7] = 0
		RenderData.Color[8] = 1
		RenderData.Color[9] = 1
		RenderData.Color[10] = 1
		RenderData.Color[11] = 0
		for i=1,4 do
			RenderData.Sides[i] = true
		end
	end
end
function GiveBack.ObjectRenders.SomeSides.Stop(Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
	Space.Elements = nil
	Space.Color =  nil
end
function GiveBack.ObjectRenders.SomeSides.ChangeTo(Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
  OpenGL.Library.glUseProgram(AllPrograms.Space.Programs.DefaultObjectProgram.ProgramID[0])
	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_FILL)
	--OpenGL.Library.glBufferData(OpenGL.Library.GL_ELEMENT_ARRAY_BUFFER, ffi.Library.sizeof(Space.Elements), Space.Elements, OpenGL.Library.GL_STATIC_DRAW)
	OpenGL.Library.glEnableVertexAttribArray(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position)
	OpenGL.Library.glVertexAttribPointer(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position, 4, OpenGL.Library.GL_DOUBLE, OpenGL.Library.GL_FALSE, 0, nil)
	--[[
	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_LINE)
	--]]
end
function GiveBack.ObjectRenders.SomeSides.ChangeFrom(Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
  OpenGL.Library.glDisableVertexAttribArray(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position)
end
function GiveBack.ObjectRenders.SomeSides.Render(Object, MVP, Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ARRAY_BUFFER, 128, Object.Transformated.data, OpenGL.Library.GL_DYNAMIC_DRAW)
	OpenGL.Library.glUniformMatrix4fv(AllPrograms.Space.Programs.DefaultObjectProgram.Uniforms.MVP,  1, OpenGL.Library.GL_FALSE, MVP)
	local Elements = {0, 1, 2, 3, 0, 1}
	for e=0,3 do
		if Object.RenderData.Sides[e + 1] then
			for i=0,2 do
				Space.Color[i] = Object.RenderData.Color[i + e * 3]
				Space.Elements[i] = Elements[i + e + 1]
			end
			OpenGL.Library.glBufferData(OpenGL.Library.GL_ELEMENT_ARRAY_BUFFER, 3, Space.Elements, OpenGL.Library.GL_DYNAMIC_DRAW)
			OpenGL.Library.glUniform3fv(AllPrograms.Space.Programs.DefaultObjectProgram.Uniforms.COLOR, 1, Space.Color)
			OpenGL.Library.glDrawElements(OpenGL.Library.GL_TRIANGLES, 3, OpenGL.Library.GL_UNSIGNED_BYTE, nil)
		end
	end
end
GiveBack.ObjectRenders.Default = {}
function GiveBack.ObjectRenders.Default.Start(Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
	Space.Elements = ffi.Library.new("GLubyte[6]", 0, 1, 2, 3, 0, 1)
end
function GiveBack.ObjectRenders.Default.DataCheck(RenderData, GotData, Space, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
	RenderData.Color = ffi.Library.new("float[3]")
	if General.Library.IsVector3(GotData) then
		for i=1,3 do
			RenderData.Color[i - 1] = GotData[i]/255
		end
	else
		for i=1,3 do
			RenderData.Color[i - 1] = 0.5
		end
	end
end
function GiveBack.ObjectRenders.Default.Stop(Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
	Space.Elements = nil
end
function GiveBack.ObjectRenders.Default.ChangeTo(Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
  OpenGL.Library.glUseProgram(AllPrograms.Space.Programs.DefaultObjectProgram.ProgramID[0])
	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_FILL)
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ELEMENT_ARRAY_BUFFER, ffi.Library.sizeof(Space.Elements), Space.Elements, OpenGL.Library.GL_STATIC_DRAW)
  OpenGL.Library.glEnableVertexAttribArray(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position)
	OpenGL.Library.glVertexAttribPointer(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position, 4, OpenGL.Library.GL_DOUBLE, OpenGL.Library.GL_FALSE, 0, nil)
	--[[
	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_LINE)
	--]]
end
function GiveBack.ObjectRenders.Default.ChangeFrom(Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
  OpenGL.Library.glDisableVertexAttribArray(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position)
end
function GiveBack.ObjectRenders.Default.Render(Object, MVP, Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ARRAY_BUFFER, 128, Object.Transformated.data, OpenGL.Library.GL_DYNAMIC_DRAW)
	OpenGL.Library.glUniform3fv(AllPrograms.Space.Programs.DefaultObjectProgram.Uniforms.COLOR, 1, Object.RenderData.Color)
	OpenGL.Library.glUniformMatrix4fv(AllPrograms.Space.Programs.DefaultObjectProgram.Uniforms.MVP,  1, OpenGL.Library.GL_FALSE, MVP)
	OpenGL.Library.glDrawElements(OpenGL.Library.GL_TRIANGLE_STRIP, 6, OpenGL.Library.GL_UNSIGNED_BYTE, nil)
end
GiveBack.ObjectRenders.Asteroid = {}
function GiveBack.ObjectRenders.Asteroid.Start(Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
	Space.Elements = ffi.Library.new("GLubyte[6]", 0, 1, 2, 3, 0, 1)
end
function GiveBack.ObjectRenders.Asteroid.DataCheck(RenderData, GotData, Space, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
	RenderData.Color = ffi.Library.new("float[3]")
	if General.Library.IsVector3(GotData) then
		for i=1,3 do
			RenderData.Color[i - 1] = GotData[i]/255
		end
	else
		for i=1,3 do
			RenderData.Color[i - 1] = 1
		end
	end
end
function GiveBack.ObjectRenders.Asteroid.Stop(Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
	Space.Elements = nil
end
function GiveBack.ObjectRenders.Asteroid.ChangeTo(Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
  OpenGL.Library.glUseProgram(AllPrograms.Space.Programs.DefaultObjectProgram.ProgramID[0])
	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_FILL)
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ELEMENT_ARRAY_BUFFER, ffi.Library.sizeof(Space.Elements), Space.Elements, OpenGL.Library.GL_STATIC_DRAW)
  OpenGL.Library.glEnableVertexAttribArray(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position)
	OpenGL.Library.glVertexAttribPointer(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position, 4, OpenGL.Library.GL_DOUBLE, OpenGL.Library.GL_FALSE, 0, nil)
	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_LINE)
end
function GiveBack.ObjectRenders.Asteroid.ChangeFrom(Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
  OpenGL.Library.glDisableVertexAttribArray(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position)
end
function GiveBack.ObjectRenders.Asteroid.Render(Object, MVP, Space, BigSpace, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ARRAY_BUFFER, 128, Object.Transformated.data, OpenGL.Library.GL_DYNAMIC_DRAW)
	OpenGL.Library.glUniform3fv(AllPrograms.Space.Programs.DefaultObjectProgram.Uniforms.COLOR, 1, Object.RenderData.Color)
	OpenGL.Library.glUniformMatrix4fv(AllPrograms.Space.Programs.DefaultObjectProgram.Uniforms.MVP,  1, OpenGL.Library.GL_FALSE, MVP)
	OpenGL.Library.glDrawElements(OpenGL.Library.GL_TRIANGLE_STRIP, 6, OpenGL.Library.GL_UNSIGNED_BYTE, nil)
end
function GiveBack.Start(Space, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
	for k, v in pairs(GiveBack.ObjectRenders) do
		if type(v.Start) == "function" and
		type(v.Stop) == "function" and
		type(v.Render) == "function" and
		type(v.DataCheck) == "function" and
		type(v.ChangeFrom) == "function" and
		type(v.ChangeTo) == "function" then
			v.Space = {}
			v.Start(v.Space, Space, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
		else
			GiveBack.ObjectRenders[k] = nil
		end
	end
	print("ObjectRender Started")
end
function GiveBack.Stop(Space, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
	for k, v in pairs(GiveBack.ObjectRenders) do
		v.Stop(v.Space, Space, OpenGL, OpenGLGive, OpenGLInit, OpenGLInitGive, ffi, ffiGive, AllPrograms, AllProgramsGive, General, GeneralGive)
    v.Space = nil
	end
	print("ObjectRender Stopped")
end
GiveBack.Requirements = {"OpenGL", "OpenGLInit", "ffi", "AllPrograms", "General"}
return GiveBack
