local GiveBack = {}
GiveBack.ObjectRenders = {}
GiveBack.ObjectRenders.Default = {}
function GiveBack.ObjectRenders.Default.Start(Space, BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General )
end
function GiveBack.ObjectRenders.Default.DataCheck(RenderData, GotData, Arguments)
	local Space, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
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
function GiveBack.ObjectRenders.Default.GetRenderData(RenderData)
	return RenderData.Color, 16, "double"
end
function GiveBack.ObjectRenders.Default.GetTransformatedMatrix(TransformatedData, ffi)
	return TransformatedData, 16, "double"
end
function GiveBack.ObjectRenders.Default.MakeElements(NumberOfObjects, PureRenderData, GLuint)
	local Sequence = {0, 1, 2, 0, 1, 3, 0, 2, 3, 1, 2, 3}
	local Elements = GLuint(NumberOfObjects * 12)
	local Counter = 1
	local Add = 0
	for bk=0,NumberOfObjects * 12 - 1 do
		Elements[bk] = Sequence[Counter] + Add
		Counter = Counter + 1
		if Counter > 12 then
			Counter = 1
			Add = Add + 4
		end
	end
	return Elements
end
function GiveBack.ObjectRenders.Default.Stop(Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
end
function GiveBack.ObjectRenders.Default.Render(VBO, RDBO, FullTransformatedMatrix, MVP, NumberOfObjects, Elements, RenderData, Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	OpenGL.Library.glUseProgram(AllPrograms.Space.Programs.TestProgram.ProgramID[0])
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ELEMENT_ARRAY_BUFFER, 48 * NumberOfObjects, Elements, OpenGL.Library.GL_STATIC_DRAW)
	OpenGL.Library.glBindBuffer(OpenGL.Library.GL_ARRAY_BUFFER, VBO[0])
	OpenGL.Library.glEnableVertexAttribArray(AllPrograms.Space.Programs.TestProgram.Inputs.vertexPosition_modelspace)
	OpenGL.Library.glVertexAttribPointer(AllPrograms.Space.Programs.TestProgram.Inputs.vertexPosition_modelspace, 4, OpenGL.Library.GL_DOUBLE, OpenGL.Library.GL_FALSE, 0, nil)
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ARRAY_BUFFER, 128 * NumberOfObjects, FullTransformatedMatrix, OpenGL.Library.GL_DYNAMIC_DRAW)
	OpenGL.Library.glBindBuffer(OpenGL.Library.GL_ARRAY_BUFFER, RDBO[0])
	OpenGL.Library.glEnableVertexAttribArray(AllPrograms.Space.Programs.TestProgram.Inputs.vertexColor)
	OpenGL.Library.glVertexAttribPointer(AllPrograms.Space.Programs.TestProgram.Inputs.vertexColor, 4, OpenGL.Library.GL_DOUBLE, OpenGL.Library.GL_FALSE, 0, nil)
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ARRAY_BUFFER, 128 * NumberOfObjects, RenderData, OpenGL.Library.GL_DYNAMIC_DRAW)
	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_FILL)
	OpenGL.Library.glUniformMatrix4fv(AllPrograms.Space.Programs.TestProgram.Uniforms.MVP, 1, OpenGL.Library.GL_FALSE, MVP)
	OpenGL.Library.glDrawElements(OpenGL.Library.GL_TRIANGLES, 12 * NumberOfObjects, OpenGL.Library.GL_UNSIGNED_INT, nil)
	OpenGL.Library.glDisableVertexAttribArray(AllPrograms.Space.Programs.TestProgram.Inputs.vertexPosition_modelspace)
	OpenGL.Library.glDisableVertexAttribArray(AllPrograms.Space.Programs.TestProgram.Inputs.vertexColor)
end
GiveBack.ObjectRenders.WireFrame = {}
function GiveBack.ObjectRenders.WireFrame.Start(Space, BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General )
end
function GiveBack.ObjectRenders.WireFrame.DataCheck(RenderData, GotData, Arguments)
	local Space, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
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
function GiveBack.ObjectRenders.WireFrame.GetRenderData(RenderData)
	return RenderData.Color, 16, "double"
end
function GiveBack.ObjectRenders.WireFrame.GetTransformatedMatrix(TransformatedData, ffi)
	return TransformatedData, 16, "double"
end
function GiveBack.ObjectRenders.WireFrame.MakeElements(NumberOfObjects, PureRenderData, GLuint)
	local Sequence = {0, 1, 2, 0, 1, 3, 0, 2, 3, 1, 2, 3}
	local Elements = GLuint(NumberOfObjects * 12)
	local Counter = 1
	local Add = 0
	for bk=0,NumberOfObjects * 12 - 1 do
		Elements[bk] = Sequence[Counter] + Add
		Counter = Counter + 1
		if Counter > 12 then
			Counter = 1
			Add = Add + 4
		end
	end
	return Elements
end
function GiveBack.ObjectRenders.WireFrame.Stop(Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
end
function GiveBack.ObjectRenders.WireFrame.Render(VBO, RDBO, FullTransformatedMatrix, MVP, NumberOfObjects, Elements, RenderData, Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	OpenGL.Library.glUseProgram(AllPrograms.Space.Programs.TestProgram.ProgramID[0])
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ELEMENT_ARRAY_BUFFER, 48 * NumberOfObjects, Elements, OpenGL.Library.GL_STATIC_DRAW)
	OpenGL.Library.glBindBuffer(OpenGL.Library.GL_ARRAY_BUFFER, VBO[0])
	OpenGL.Library.glEnableVertexAttribArray(AllPrograms.Space.Programs.TestProgram.Inputs.vertexPosition_modelspace)
	OpenGL.Library.glVertexAttribPointer(AllPrograms.Space.Programs.TestProgram.Inputs.vertexPosition_modelspace, 4, OpenGL.Library.GL_DOUBLE, OpenGL.Library.GL_FALSE, 0, nil)
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ARRAY_BUFFER, 128 * NumberOfObjects, FullTransformatedMatrix, OpenGL.Library.GL_DYNAMIC_DRAW)
	OpenGL.Library.glBindBuffer(OpenGL.Library.GL_ARRAY_BUFFER, RDBO[0])
	OpenGL.Library.glEnableVertexAttribArray(AllPrograms.Space.Programs.TestProgram.Inputs.vertexColor)
	OpenGL.Library.glVertexAttribPointer(AllPrograms.Space.Programs.TestProgram.Inputs.vertexColor, 4, OpenGL.Library.GL_DOUBLE, OpenGL.Library.GL_FALSE, 0, nil)
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ARRAY_BUFFER, 128 * NumberOfObjects, RenderData, OpenGL.Library.GL_DYNAMIC_DRAW)
	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_LINE)
	OpenGL.Library.glUniformMatrix4fv(AllPrograms.Space.Programs.TestProgram.Uniforms.MVP, 1, OpenGL.Library.GL_FALSE, MVP)
	OpenGL.Library.glDrawElements(OpenGL.Library.GL_TRIANGLES, 12 * NumberOfObjects, OpenGL.Library.GL_UNSIGNED_INT, nil)
	OpenGL.Library.glDisableVertexAttribArray(AllPrograms.Space.Programs.TestProgram.Inputs.vertexPosition_modelspace)
	OpenGL.Library.glDisableVertexAttribArray(AllPrograms.Space.Programs.TestProgram.Inputs.vertexColor)
end
GiveBack.ObjectRenders.ColorPerSide = {}
function GiveBack.ObjectRenders.ColorPerSide.Start(Space, BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General )
end
function GiveBack.ObjectRenders.ColorPerSide.DataCheck(RenderData, GotData, Arguments)
	local Space, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
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
function GiveBack.ObjectRenders.ColorPerSide.GetRenderData(RenderData, ffi)
	local Data = ffi.Library.new("double[48]", RenderData.Color[0], RenderData.Color[1], RenderData.Color[2], RenderData.Color[3],
	 																	RenderData.Color[0], RenderData.Color[1], RenderData.Color[2], RenderData.Color[3],
																		RenderData.Color[0], RenderData.Color[1], RenderData.Color[2], RenderData.Color[3],
																		RenderData.Color[4], RenderData.Color[5], RenderData.Color[6], RenderData.Color[7],
																		RenderData.Color[4], RenderData.Color[5], RenderData.Color[6], RenderData.Color[7],
																		RenderData.Color[4], RenderData.Color[5], RenderData.Color[6], RenderData.Color[7],
																		RenderData.Color[8], RenderData.Color[9], RenderData.Color[10], RenderData.Color[11],
																		RenderData.Color[8], RenderData.Color[9], RenderData.Color[10], RenderData.Color[11],
																		RenderData.Color[8], RenderData.Color[9], RenderData.Color[10], RenderData.Color[11],
																		RenderData.Color[12], RenderData.Color[13], RenderData.Color[14], RenderData.Color[15],
																		RenderData.Color[12], RenderData.Color[13], RenderData.Color[14], RenderData.Color[15],
																		RenderData.Color[12], RenderData.Color[13], RenderData.Color[14], RenderData.Color[15])
	return Data, 48, "double"
end
function GiveBack.ObjectRenders.ColorPerSide.GetTransformatedMatrix(TransformatedData, ffi)
	local Data = ffi.Library.new("double[48]", TransformatedData[0], TransformatedData[1], TransformatedData[2], TransformatedData[3],
																		TransformatedData[4], TransformatedData[5], TransformatedData[6], TransformatedData[7],
																		TransformatedData[8], TransformatedData[9], TransformatedData[10], TransformatedData[11],
																		TransformatedData[0], TransformatedData[1], TransformatedData[2], TransformatedData[3],
																		TransformatedData[4], TransformatedData[5], TransformatedData[6], TransformatedData[7],
																		TransformatedData[12], TransformatedData[13], TransformatedData[14], TransformatedData[15],
																		TransformatedData[0], TransformatedData[1], TransformatedData[2], TransformatedData[3],
																		TransformatedData[8], TransformatedData[9], TransformatedData[10], TransformatedData[11],
																		TransformatedData[12], TransformatedData[13], TransformatedData[14], TransformatedData[15],
																		TransformatedData[4], TransformatedData[5], TransformatedData[6], TransformatedData[7],
																		TransformatedData[8], TransformatedData[9], TransformatedData[10], TransformatedData[11],
																		TransformatedData[12], TransformatedData[13], TransformatedData[14], TransformatedData[15])
	return Data, 48, "double"
end
function GiveBack.ObjectRenders.ColorPerSide.MakeElements(NumberOfObjects, PureRenderData, GLuint)
	local Sequence = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
	local Elements = GLuint(NumberOfObjects * 12)
	local Counter = 1
	local Add = 0
	for bk=0,NumberOfObjects * 12 - 1 do
		Elements[bk] = Sequence[Counter] + Add
		Counter = Counter + 1
		if Counter > 12 then
			Counter = 1
			Add = Add + 12
		end
	end
	return Elements
end
function GiveBack.ObjectRenders.ColorPerSide.Stop(Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
end
function GiveBack.ObjectRenders.ColorPerSide.Render(VBO, RDBO, FullTransformatedMatrix, MVP, NumberOfObjects, Elements, RenderData, Space, Arguments)
	local BigSpace, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	OpenGL.Library.glUseProgram(AllPrograms.Space.Programs.TestProgram.ProgramID[0])

	OpenGL.Library.glBufferData(OpenGL.Library.GL_ELEMENT_ARRAY_BUFFER, 48 * NumberOfObjects, Elements, OpenGL.Library.GL_STATIC_DRAW)

	OpenGL.Library.glBindBuffer(OpenGL.Library.GL_ARRAY_BUFFER, VBO[0])
	OpenGL.Library.glEnableVertexAttribArray(AllPrograms.Space.Programs.TestProgram.Inputs.vertexPosition_modelspace)
	OpenGL.Library.glVertexAttribPointer(AllPrograms.Space.Programs.TestProgram.Inputs.vertexPosition_modelspace, 4, OpenGL.Library.GL_DOUBLE, OpenGL.Library.GL_FALSE, 0, nil)
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ARRAY_BUFFER, 384 * NumberOfObjects, FullTransformatedMatrix, OpenGL.Library.GL_DYNAMIC_DRAW)

	OpenGL.Library.glBindBuffer(OpenGL.Library.GL_ARRAY_BUFFER, RDBO[0])
	OpenGL.Library.glEnableVertexAttribArray(AllPrograms.Space.Programs.TestProgram.Inputs.vertexColor)
	OpenGL.Library.glVertexAttribPointer(AllPrograms.Space.Programs.TestProgram.Inputs.vertexColor, 4, OpenGL.Library.GL_DOUBLE, OpenGL.Library.GL_FALSE, 0, nil)
	OpenGL.Library.glBufferData(OpenGL.Library.GL_ARRAY_BUFFER, 384 * NumberOfObjects, RenderData, OpenGL.Library.GL_DYNAMIC_DRAW)

	OpenGL.Library.glPolygonMode(OpenGL.Library.GL_FRONT_AND_BACK, OpenGL.Library.GL_FILL)
	OpenGL.Library.glUniformMatrix4fv(AllPrograms.Space.Programs.TestProgram.Uniforms.MVP, 1, OpenGL.Library.GL_FALSE, MVP)
	OpenGL.Library.glDrawElements(OpenGL.Library.GL_TRIANGLES, 12 * NumberOfObjects, OpenGL.Library.GL_UNSIGNED_INT, nil)
	OpenGL.Library.glDisableVertexAttribArray(AllPrograms.Space.Programs.TestProgram.Inputs.vertexPosition_modelspace)
	OpenGL.Library.glDisableVertexAttribArray(AllPrograms.Space.Programs.TestProgram.Inputs.vertexColor)
end
function GiveBack.Start(Arguments)
	local Space, OpenGL, OpenGLInit, ffi, AllPrograms, General = Arguments[1], Arguments[2], Arguments[4], Arguments[6], Arguments[8], Arguments[10]
	for ak, av in pairs(GiveBack.ObjectRenders) do
		if type(av.Start) == "function" and
			type(av.Stop) == "function" and
			type(av.Render) == "function" and
			type(av.DataCheck) == "function" and
			type(av.GetRenderData) == "function" and
			type(av.GetTransformatedMatrix) == "function" then
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
