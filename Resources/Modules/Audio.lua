local GiveBack = {}
function GiveBack.Start(Configurations, Arguments)
  local Space, PortAudio, ffi = Arguments[1], Arguments[2], Arguments[4]
  --[[
  Space.Stream = ffi.Library.new("PaStream*[1]")
  PortAudio.Library.checkError(PortAudio.Library.dll.Pa_Initialize())
  local InputParameters = ffi.Library.new("PaStreamParameters[1]")
  local OutputParameters = ffi.Library.new("PaStreamParameters[1]")
  InputParameters[0].device = PortAudio.Library.dll.Pa_GetDefaultHostApi()
  InputParameters[0].channelCount = PortAudio.Library.dll.Pa_GetDeviceInfo(InputParameters[0].device).maxInputChannels
  InputParameters[0].sampleFormat = PortAudio.Library.dll.paFloat32
  InputParameters[0].suggestedLatency = PortAudio.Library.dll.Pa_GetDeviceInfo(InputParameters[0].device).defaultHighInputLatency
  OutputParameters[0].device = PortAudio.Library.dll.Pa_GetDefaultHostApi()
  OutputParameters[0].channelCount = PortAudio.Library.dll.Pa_GetDeviceInfo(InputParameters[0].device).maxOutputChannels
  OutputParameters[0].sampleFormat = PortAudio.Library.dll.paFloat32
  OutputParameters[0].suggestedLatency = PortAudio.Library.dll.Pa_GetDeviceInfo(OutputParameters[0].device).defaultHighOutputLatency
  PortAudio.Library.checkError(PortAudio.Library.dll.Pa_OpenStream(Space.Stream, InputParameters, OutputParameters, 44100, 0, PortAudio.Library.dll.paClipOff, nil, nil))
  PortAudio.Library.checkError(PortAudio.Library.dll.Pa_StartStream(Space.Stream[0]))
  --]]
  print("Audio Started")
end
function GiveBack.Stop(Arguments)
  local Space, PortAudio, ffi = Arguments[1], Arguments[2], Arguments[4]
  --[[
	PortAudio.Library.checkError(PortAudio.Library.dll.Pa_StopStream(Space.Stream[0]))
  PortAudio.Library.checkError(PortAudio.Library.dll.Pa_CloseStream(Space.Stream[0]))
  PortAudio.Library.checkError(PortAudio.Library.dll.Pa_Terminate())
  --]]
  print("Audio Stopped")
end
GiveBack.Requirements = {"PortAudio", "ffi"}
return GiveBack
