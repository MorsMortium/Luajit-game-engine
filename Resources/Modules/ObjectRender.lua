local GiveBack = {}
GiveBack.ObjectRenders = {}
GiveBack.ObjectRenders.ColorPerSide = {}
function GiveBack.ObjectRenders.ColorPerSide.Start(Space, BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General )
	Space.Elements = ffi.Library.new("GLubyte[3]")
	Space.Color = ffi.Library.new("GLfloat[3]")
end
function GiveBack.ObjectRenders.ColorPerSide.DataCheck(RenderData, GotData, Arguments)
	local Space, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	RenderData.Color = ffi.Library.new("float[12]", 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0)
	if type(GotData) == "table" and #GotData == 12 and General.Library.GoodTypesOfTable(GotData, "number") then
		for ak=1,12 do
			RenderData.Color[ak - 1] = GotData[ak]/255
		end
	end
end
function GiveBack.ObjectRenders.ColorPerSide.Stop(Space, BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General )
	Space.Elements = nil
	Space.Color = nil
end
function GiveBack.ObjectRenders.ColorPerSide.ChangeTo(Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	OpenGL.Library.glUseProgram(AllPrograms.Space.Programs.DefaultObjectProgram.ProgramID[0])
	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_FILL)
	--OpenGL.Library.glBufferData(OpenGL.Library.GL_ELEMENT_ARRAY_BUFFER, ffi.Library.sizeof(Space.Elements), Space.Elements, OpenGL.Library.GL_STATIC_DRAW)
	OpenGL.Library.glEnableVertexAttribArray(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position)
	OpenGL.Library.glVertexAttribPointer(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position, 4, OpenGL.Library.GL_DOUBLE, OpenGL.Library.GL_FALSE, 0, nil)
	--[[
	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_LINE)
	--]]
end
function GiveBack.ObjectRenders.ColorPerSide.ChangeFrom(Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	OpenGL.Library.glDisableVertexAttribArray(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position)
end
function GiveBack.ObjectRenders.ColorPerSide.Render(Object, MVP, Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ARRAY_BUFFER, 128, Object.Transformated.data, OpenGL.Library.GL_DYNAMIC_DRAW)
	OpenGL.Library.glUniformMatrix4fv(AllPrograms.Space.Programs.DefaultObjectProgram.Uniforms.MVP, 1, OpenGL.Library.GL_FALSE, MVP)
	local Elements = {0, 1, 2, 3, 0, 1}
	for ak=0,3 do
		for bk=0,2 do
			Space.Color[bk] = Object.RenderData.Color[bk + ak * 3]
			Space.Elements[bk] = Elements[bk + ak + 1]
		end
		OpenGL.Library.glBufferData(OpenGL.Library.GL_ELEMENT_ARRAY_BUFFER, 3, Space.Elements, OpenGL.Library.GL_DYNAMIC_DRAW)
		OpenGL.Library.glUniform3fv(AllPrograms.Space.Programs.DefaultObjectProgram.Uniforms.COLOR, 1, Space.Color)
		OpenGL.Library.glDrawElements(OpenGL.Library.GL_TRIANGLES, 3, OpenGL.Library.GL_UNSIGNED_BYTE, nil)
	end
end
GiveBack.ObjectRenders.SomeSides = {}
function GiveBack.ObjectRenders.SomeSides.Start(Space, BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General )
	Space.Elements = ffi.Library.new("GLubyte[3]")
	Space.Color = ffi.Library.new("GLfloat[3]")
end
function GiveBack.ObjectRenders.SomeSides.DataCheck(RenderData, GotData, Arguments)
	local Space, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	RenderData.Color = ffi.Library.new("float[12]", 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0)
	RenderData.Sides = {true, true, true, true}
	if type(GotData) == "table" and #GotData == 2 and type(GotData[1]) == "table" and type(GotData[2]) == "table" and #GotData[1] == 12 and General.Library.GoodTypesOfTable(GotData[1], "number") and #GotData[2] == 4 and General.Library.GoodTypesOfTable(GotData[2], "boolean") then
		for ak=1,12 do
			RenderData.Color[ak - 1] = GotData[1][ak]/255
		end
		for ak=1,4 do
			RenderData.Sides[ak] = GotData[2][ak]
		end
	end
end
function GiveBack.ObjectRenders.SomeSides.Stop(Space, BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General )
	Space.Elements = nil
	Space.Color = nil
end
function GiveBack.ObjectRenders.SomeSides.ChangeTo(Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	OpenGL.Library.glUseProgram(AllPrograms.Space.Programs.DefaultObjectProgram.ProgramID[0])
	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_FILL)
	--OpenGL.Library.glBufferData(OpenGL.Library.GL_ELEMENT_ARRAY_BUFFER, ffi.Library.sizeof(Space.Elements), Space.Elements, OpenGL.Library.GL_STATIC_DRAW)
	OpenGL.Library.glEnableVertexAttribArray(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position)
	OpenGL.Library.glVertexAttribPointer(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position, 4, OpenGL.Library.GL_DOUBLE, OpenGL.Library.GL_FALSE, 0, nil)
	--[[
	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_LINE)
	--]]
end
function GiveBack.ObjectRenders.SomeSides.ChangeFrom(Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	OpenGL.Library.glDisableVertexAttribArray(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position)
end
function GiveBack.ObjectRenders.SomeSides.Render(Object, MVP, Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ARRAY_BUFFER, 128, Object.Transformated.data, OpenGL.Library.GL_DYNAMIC_DRAW)
	OpenGL.Library.glUniformMatrix4fv(AllPrograms.Space.Programs.DefaultObjectProgram.Uniforms.MVP, 1, OpenGL.Library.GL_FALSE, MVP)
	local Elements = {0, 1, 2, 3, 0, 1}
	for ak=0,3 do
		if Object.RenderData.Sides[ak + 1] then
			for bk=0,2 do
				Space.Color[bk] = Object.RenderData.Color[bk + ak * 3]
				Space.Elements[bk] = Elements[bk + ak + 1]
			end
			OpenGL.Library.glBufferData(OpenGL.Library.GL_ELEMENT_ARRAY_BUFFER, 3, Space.Elements, OpenGL.Library.GL_DYNAMIC_DRAW)
			OpenGL.Library.glUniform3fv(AllPrograms.Space.Programs.DefaultObjectProgram.Uniforms.COLOR, 1, Space.Color)
			OpenGL.Library.glDrawElements(OpenGL.Library.GL_TRIANGLES, 3, OpenGL.Library.GL_UNSIGNED_BYTE, nil)
		end
	end
end
GiveBack.ObjectRenders.Default = {}
function GiveBack.ObjectRenders.Default.Start(Space, BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General )
	Space.Elements = ffi.Library.new("GLubyte[6]", 0, 1, 2, 3, 0, 1)
end
function GiveBack.ObjectRenders.Default.DataCheck(RenderData, GotData, Arguments)
	local Space, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	RenderData.Color = ffi.Library.new("float[3]", 0.5, 0.5, 0.5)
	if General.Library.IsVector3(GotData) then
		for ak=1,3 do
			RenderData.Color[ak - 1] = GotData[ak]/255
		end
	end
end
function GiveBack.ObjectRenders.Default.Stop(Space, BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General )
	Space.Elements = nil
end
function GiveBack.ObjectRenders.Default.ChangeTo(Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	OpenGL.Library.glUseProgram(AllPrograms.Space.Programs.DefaultObjectProgram.ProgramID[0])
	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_FILL)
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ELEMENT_ARRAY_BUFFER, ffi.Library.sizeof(Space.Elements), Space.Elements, OpenGL.Library.GL_STATIC_DRAW)
	OpenGL.Library.glEnableVertexAttribArray(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position)
	OpenGL.Library.glVertexAttribPointer(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position, 4, OpenGL.Library.GL_DOUBLE, OpenGL.Library.GL_FALSE, 0, nil)
	--[[
	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_LINE)
	--]]
end
function GiveBack.ObjectRenders.Default.ChangeFrom(Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	OpenGL.Library.glDisableVertexAttribArray(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position)
end
function GiveBack.ObjectRenders.Default.Render(Object, MVP, Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ARRAY_BUFFER, 128, Object.Transformated.data, OpenGL.Library.GL_DYNAMIC_DRAW)
	OpenGL.Library.glUniform3fv(AllPrograms.Space.Programs.DefaultObjectProgram.Uniforms.COLOR, 1, Object.RenderData.Color)
	OpenGL.Library.glUniformMatrix4fv(AllPrograms.Space.Programs.DefaultObjectProgram.Uniforms.MVP, 1, OpenGL.Library.GL_FALSE, MVP)
	OpenGL.Library.glDrawElements(OpenGL.Library.GL_TRIANGLE_STRIP, 6, OpenGL.Library.GL_UNSIGNED_BYTE, nil)
end
GiveBack.ObjectRenders.Asteroid = {}
function GiveBack.ObjectRenders.Asteroid.Start(Space, BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General )
	Space.Elements = ffi.Library.new("GLubyte[6]", 0, 1, 2, 3, 0, 1)
end
function GiveBack.ObjectRenders.Asteroid.DataCheck(RenderData, GotData, Arguments)
	local Space, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	RenderData.Color = ffi.Library.new("float[3]", 1, 1, 1)
	if General.Library.IsVector3(GotData) then
		for ak=1,3 do
			RenderData.Color[ak - 1] = GotData[ak]/255
		end
	end
end
function GiveBack.ObjectRenders.Asteroid.Stop(Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	Space.Elements = nil
end
function GiveBack.ObjectRenders.Asteroid.ChangeTo(Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	OpenGL.Library.glUseProgram(AllPrograms.Space.Programs.DefaultObjectProgram.ProgramID[0])
	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_FILL)
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ELEMENT_ARRAY_BUFFER, ffi.Library.sizeof(Space.Elements), Space.Elements, OpenGL.Library.GL_STATIC_DRAW)
	OpenGL.Library.glEnableVertexAttribArray(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position)
	OpenGL.Library.glVertexAttribPointer(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position, 4, OpenGL.Library.GL_DOUBLE, OpenGL.Library.GL_FALSE, 0, nil)
	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_LINE)
end
function GiveBack.ObjectRenders.Asteroid.ChangeFrom(Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	OpenGL.Library.glDisableVertexAttribArray(AllPrograms.Space.Programs.DefaultObjectProgram.Inputs.Position)
end
function GiveBack.ObjectRenders.Asteroid.Render(Object, MVP, Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ARRAY_BUFFER, 128, Object.Transformated.data, OpenGL.Library.GL_DYNAMIC_DRAW)
	OpenGL.Library.glUniform3fv(AllPrograms.Space.Programs.DefaultObjectProgram.Uniforms.COLOR, 1, Object.RenderData.Color)
	OpenGL.Library.glUniformMatrix4fv(AllPrograms.Space.Programs.DefaultObjectProgram.Uniforms.MVP, 1, OpenGL.Library.GL_FALSE, MVP)
	OpenGL.Library.glDrawElements(OpenGL.Library.GL_TRIANGLE_STRIP, 6, OpenGL.Library.GL_UNSIGNED_BYTE, nil)
end
function GiveBack.Start(Arguments)
	local Space, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	for ak, av in pairs(GiveBack.ObjectRenders) do
		if type(av.Start) == "function" and
			type(av.Stop) == "function" and
			type(av.Render) == "function" and
			type(av.DataCheck) == "function" and
			type(av.ChangeFrom) == "function" and
			type(av.ChangeTo) == "function" then
			av.Space = {}
			av.Start(av.Space, Space, OpenGL, OpenGLInit, ffi, AllPrograms, General )
		else
			GiveBack.ObjectRenders[k] = nil
		end
	end
	print("ObjectRender Started")
end
function GiveBack.Stop(Arguments)
	local Space, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	for ak, av in pairs(GiveBack.ObjectRenders) do
		av.Stop(av.Space, Space, OpenGL, OpenGLInit, ffi, AllPrograms, General )
		av.Space = nil
	end
	print("ObjectRender Stopped")
end
GiveBack.Requirements = {"OpenGL", "OpenGLInit", "ffi", "AllPrograms", "General", "SDL"}
return GiveBack
