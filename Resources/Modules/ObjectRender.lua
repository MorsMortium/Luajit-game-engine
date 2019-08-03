local GiveBack = {}

--Different Object rendering scripts are stored here
GiveBack.ObjectRenders = {}

--The default Object render maps one color per vertex
GiveBack.ObjectRenders.Default = {}
local Default = GiveBack.ObjectRenders.Default
function Default.DataCheck(RenderData, GotData, Arguments)
	local ffi, General = Arguments[6], Arguments[10]
	RenderData.Color = ffi.Library.new("double[16]", 1, 1, 1, 1,
																									1, 1, 1, 1,
																									1, 1, 1, 1,
																									1, 1, 1, 1)
	if General.Library.IsMatrix4(GotData) then
		for ak=0,3 do
			for bk=0,3 do
				RenderData.Color[ak * 4 + bk] = GotData[ak + 1][bk + 1]/255
			end
		end
	end
end
function Default.CopyRenderData(GotData, Arguments)
	local ffi = Arguments[6]
	local RenderData = {}
	RenderData.Color = ffi.Library.new(ffi.Library.typeof(GotData.Color), GotData.Color)
	return RenderData
end
function Default.GetRenderData(RenderData)
	return RenderData.Color, 16, "double"
end
function Default.GetTransformatedMatrix(TransformatedData, ffi)
	return TransformatedData, 16, "double"
end
function Default.MakeElements(NumberOfObjects, GLuint)
	local Sequence = {0, 1, 2, 0, 1, 3, 0, 2, 3, 1, 2, 3}
	local Elements = GLuint(NumberOfObjects * 12)
	local Add = 0
	for ak=0,NumberOfObjects - 1 do
		for bk=0,11 do
			Elements[ak * 12 + bk] = Sequence[bk + 1] + Add
		end
		Add = Add + 4
	end
	return Elements
end
function Default.Render(VBO, RDBO, FullTransformatedMatrix, MVP,
	NumberOfObjects, Elements, RenderData, Space, Arguments)
	local OpenGL, AllPrograms = Arguments[2], Arguments[8]
	local OpenGL = OpenGL.Library
	local TestProgram = AllPrograms.Space.Programs.TestProgram
	OpenGL.glUseProgram(TestProgram.ProgramID)
	OpenGL.glBufferData(OpenGL.GL_ELEMENT_ARRAY_BUFFER, 48 * NumberOfObjects,
	Elements, OpenGL.GL_STATIC_DRAW)
	OpenGL.glBindBuffer(OpenGL.GL_ARRAY_BUFFER, VBO[0])
	OpenGL.glEnableVertexAttribArray(TestProgram.Inputs.vertexPosition_modelspace)
	OpenGL.glVertexAttribPointer(TestProgram.Inputs.vertexPosition_modelspace, 4,
	OpenGL.GL_DOUBLE, OpenGL.GL_FALSE, 0, nil)
	OpenGL.glBufferData(OpenGL.GL_ARRAY_BUFFER, 128 * NumberOfObjects,
	FullTransformatedMatrix, OpenGL.GL_DYNAMIC_DRAW)
	OpenGL.glBindBuffer(OpenGL.GL_ARRAY_BUFFER, RDBO[0])
	OpenGL.glEnableVertexAttribArray(TestProgram.Inputs.vertexColor)
	OpenGL.glVertexAttribPointer(TestProgram.Inputs.vertexColor, 4,
	OpenGL.GL_DOUBLE, OpenGL.GL_FALSE, 0, nil)
	OpenGL.glBufferData(OpenGL.GL_ARRAY_BUFFER, 128 * NumberOfObjects, RenderData,
	OpenGL.GL_DYNAMIC_DRAW)
	OpenGL.glPolygonMode(OpenGL.GL_FRONT_AND_BACK, OpenGL.GL_FILL)
	OpenGL.glUniformMatrix4fv(TestProgram.Uniforms.MVP, 1, OpenGL.GL_FALSE, MVP)
	OpenGL.glDrawElements(OpenGL.GL_TRIANGLES, 12 * NumberOfObjects,
	OpenGL.GL_UNSIGNED_INT, nil)
	OpenGL.glDisableVertexAttribArray(TestProgram.Inputs.vertexPosition_modelspace)
	OpenGL.glDisableVertexAttribArray(TestProgram.Inputs.vertexColor)
end

--The WireFrame Object render works like the Default but with lines
GiveBack.ObjectRenders.WireFrame = {}
local WireFrame = GiveBack.ObjectRenders.WireFrame
function WireFrame.DataCheck(RenderData, GotData, Arguments)
	local ffi, General = Arguments[6], Arguments[10]
	RenderData.Color = ffi.Library.new("double[16]", 1, 1, 1, 1,
																									1, 1, 1, 1,
																									1, 1, 1, 1,
																									1, 1, 1, 1)
	if General.Library.IsMatrix4(GotData) then
		for ak=0,3 do
			for bk=0,3 do
				RenderData.Color[ak * 4 + bk] = GotData[ak + 1][bk + 1]/255
			end
		end
	end
end
function WireFrame.CopyRenderData(GotData, Arguments)
	local ffi = Arguments[6]
	local RenderData = {}
	RenderData.Color = ffi.Library.new(ffi.Library.typeof(GotData.Color), GotData.Color)
	return RenderData
end
function WireFrame.GetRenderData(RenderData)
	return RenderData.Color, 16, "double"
end
function WireFrame.GetTransformatedMatrix(TransformatedData, ffi)
	return TransformatedData, 16, "double"
end
function WireFrame.MakeElements(NumberOfObjects, GLuint)
	local Sequence = {0, 1, 2, 0, 1, 3, 0, 2, 3, 1, 2, 3}
	local Elements = GLuint(NumberOfObjects * 12)
	local Add = 0
	for ak=0,NumberOfObjects - 1 do
		for bk=0,11 do
			Elements[ak * 12 + bk] = Sequence[bk + 1] + Add
		end
		Add = Add + 4
	end
	return Elements
end
function WireFrame.Render(VBO, RDBO, FullTransformatedMatrix, MVP,
	NumberOfObjects, Elements, RenderData, Space, Arguments)
	local OpenGL, AllPrograms = Arguments[2], Arguments[8]
	local OpenGL = OpenGL.Library
	local TestProgram = AllPrograms.Space.Programs.TestProgram
	OpenGL.glUseProgram(TestProgram.ProgramID)
	OpenGL.glBufferData(OpenGL.GL_ELEMENT_ARRAY_BUFFER, 48 * NumberOfObjects,
	Elements, OpenGL.GL_STATIC_DRAW)
	OpenGL.glBindBuffer(OpenGL.GL_ARRAY_BUFFER, VBO[0])
	OpenGL.glEnableVertexAttribArray(TestProgram.Inputs.vertexPosition_modelspace)
	OpenGL.glVertexAttribPointer(TestProgram.Inputs.vertexPosition_modelspace, 4,
	OpenGL.GL_DOUBLE, OpenGL.GL_FALSE, 0, nil)
	OpenGL.glBufferData(OpenGL.GL_ARRAY_BUFFER, 128 * NumberOfObjects,
	FullTransformatedMatrix, OpenGL.GL_DYNAMIC_DRAW)
	OpenGL.glBindBuffer(OpenGL.GL_ARRAY_BUFFER, RDBO[0])
	OpenGL.glEnableVertexAttribArray(TestProgram.Inputs.vertexColor)
	OpenGL.glVertexAttribPointer(TestProgram.Inputs.vertexColor, 4,
	OpenGL.GL_DOUBLE, OpenGL.GL_FALSE, 0, nil)
	OpenGL.glBufferData(OpenGL.GL_ARRAY_BUFFER, 128 * NumberOfObjects, RenderData,
	OpenGL.GL_DYNAMIC_DRAW)
	OpenGL.glPolygonMode(OpenGL.GL_FRONT_AND_BACK, OpenGL.GL_LINE)
	OpenGL.glUniformMatrix4fv(TestProgram.Uniforms.MVP, 1, OpenGL.GL_FALSE, MVP)
	OpenGL.glDrawElements(OpenGL.GL_TRIANGLES, 12 * NumberOfObjects,
	OpenGL.GL_UNSIGNED_INT, nil)
	OpenGL.glDisableVertexAttribArray(TestProgram.Inputs.vertexPosition_modelspace)
	OpenGL.glDisableVertexAttribArray(TestProgram.Inputs.vertexColor)
end

--The ColorPerSide Object render maps one color per face
GiveBack.ObjectRenders.ColorPerSide = {}
local ColorPerSide = GiveBack.ObjectRenders.ColorPerSide
function ColorPerSide.DataCheck(RenderData, GotData, Arguments)
	local ffi, General = Arguments[6], Arguments[10]
	RenderData.Color = ffi.Library.new("double[16]", 1, 1, 1, 1,
																									1, 1, 1, 1,
																									1, 1, 1, 1,
																									1, 1, 1, 1)
	if General.Library.IsMatrix4(GotData) then
		for ak=0,3 do
			for bk=0,3 do
				RenderData.Color[ak * 4 + bk] = GotData[ak + 1][bk + 1]/255
			end
		end
	end
end
function ColorPerSide.CopyRenderData(GotData, Arguments)
	local ffi = Arguments[6]
	local RenderData = {}
	RenderData.Color = ffi.Library.new(ffi.Library.typeof(GotData.Color), GotData.Color)
	return RenderData
end
function ColorPerSide.GetRenderData(RenderData, ffi)
	local Color = RenderData.Color
	local Data = ffi.Library.new("double[48]",
																		Color[0], Color[1], Color[2], Color[3],
	 																	Color[0], Color[1], Color[2], Color[3],
																		Color[0], Color[1], Color[2], Color[3],
																		Color[4], Color[5], Color[6], Color[7],
																		Color[4], Color[5], Color[6], Color[7],
																		Color[4], Color[5], Color[6], Color[7],
																		Color[8], Color[9], Color[10], Color[11],
																		Color[8], Color[9], Color[10], Color[11],
																		Color[8], Color[9], Color[10], Color[11],
																		Color[12], Color[13], Color[14], Color[15],
																		Color[12], Color[13], Color[14], Color[15],
																		Color[12], Color[13], Color[14], Color[15])
	return Data, 48, "double"
end
function ColorPerSide.GetTransformatedMatrix(TransformatedData, ffi)
	local TData = TransformatedData
	local Data = ffi.Library.new("double[48]",
																		TData[0], TData[1], TData[2], TData[3],
																		TData[4], TData[5], TData[6], TData[7],
																		TData[8], TData[9], TData[10], TData[11],
																		TData[0], TData[1], TData[2], TData[3],
																		TData[4], TData[5], TData[6], TData[7],
																		TData[12], TData[13], TData[14], TData[15],
																		TData[0], TData[1], TData[2], TData[3],
																		TData[8], TData[9], TData[10], TData[11],
																		TData[12], TData[13], TData[14], TData[15],
																		TData[4], TData[5], TData[6], TData[7],
																		TData[8], TData[9], TData[10], TData[11],
																		TData[12], TData[13], TData[14], TData[15])
	return Data, 48, "double"
end
function ColorPerSide.MakeElements(NumberOfObjects, GLuint)
	local Elements = GLuint(NumberOfObjects * 12)
	for ak=0,NumberOfObjects * 12 - 1 do
		Elements[ak] = ak
	end
	return Elements
end
function ColorPerSide.Render(VBO, RDBO, FullTransformatedMatrix, MVP,
	NumberOfObjects, Elements, RenderData, Space, Arguments)
	local OpenGL, AllPrograms = Arguments[2], Arguments[8]
	local OpenGL = OpenGL.Library
	local TestProgram = AllPrograms.Space.Programs.TestProgram
	OpenGL.glUseProgram(TestProgram.ProgramID)

	OpenGL.glBufferData(OpenGL.GL_ELEMENT_ARRAY_BUFFER, 48 * NumberOfObjects,
	Elements, OpenGL.GL_STATIC_DRAW)

	OpenGL.glBindBuffer(OpenGL.GL_ARRAY_BUFFER, VBO[0])
	OpenGL.glEnableVertexAttribArray(TestProgram.Inputs.vertexPosition_modelspace)
	OpenGL.glVertexAttribPointer(TestProgram.Inputs.vertexPosition_modelspace, 4,
	OpenGL.GL_DOUBLE, OpenGL.GL_FALSE, 0, nil)
	OpenGL.glBufferData(OpenGL.GL_ARRAY_BUFFER, 384 * NumberOfObjects,
	FullTransformatedMatrix, OpenGL.GL_DYNAMIC_DRAW)

	OpenGL.glBindBuffer(OpenGL.GL_ARRAY_BUFFER, RDBO[0])
	OpenGL.glEnableVertexAttribArray(TestProgram.Inputs.vertexColor)
	OpenGL.glVertexAttribPointer(TestProgram.Inputs.vertexColor, 4,
	OpenGL.GL_DOUBLE, OpenGL.GL_FALSE, 0, nil)
	OpenGL.glBufferData(OpenGL.GL_ARRAY_BUFFER, 384 * NumberOfObjects, RenderData,
	OpenGL.GL_DYNAMIC_DRAW)

	OpenGL.glPolygonMode(OpenGL.GL_FRONT_AND_BACK, OpenGL.GL_FILL)
	OpenGL.glUniformMatrix4fv(TestProgram.Uniforms.MVP, 1, OpenGL.GL_FALSE, MVP)
	OpenGL.glDrawElements(OpenGL.GL_TRIANGLES, 12 * NumberOfObjects,
	OpenGL.GL_UNSIGNED_INT, nil)
	OpenGL.glDisableVertexAttribArray(TestProgram.Inputs.vertexPosition_modelspace)
	OpenGL.glDisableVertexAttribArray(TestProgram.Inputs.vertexColor)
end

--Checks whether every Object render has all needed functions, if not, it's deleted
function GiveBack.Start(Configurations, Arguments)
	for ak, av in pairs(GiveBack.ObjectRenders) do
		if type(av.Render) == "function" and
			type(av.DataCheck) == "function" and
			type(av.GetRenderData) == "function" and
			type(av.CopyRenderData) == "function" and
			type(av.GetTransformatedMatrix) == "function" then
			av.Space = {}
		else
			GiveBack.ObjectRenders[k] = nil
		end
	end
	io.write("ObjectRender Started\n")
end
function GiveBack.Stop(Arguments)
	for ak, av in pairs(GiveBack.ObjectRenders) do
		av.Space = nil
	end
	io.write("ObjectRender Stopped\n")
end
GiveBack.Requirements =
{"OpenGL", "OpenGLInit", "ffi", "AllPrograms", "General", "SDL"}
return GiveBack
