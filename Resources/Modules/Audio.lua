return function(args)
  local Space, PortAudio, ffi = args[1], args[2], args[3]
  local PortAudio = PortAudio.Library
  local GiveBack = {}

  function GiveBack.Reload(args)
    Space, PortAudio, ffi = args[1], args[2], args[3]
    PortAudio = PortAudio.Library
  end

  function GiveBack.Start(Configurations)
    --[[
    Space.Stream = ffi.Library.new("PaStream*[1]")
    PortAudio.checkError(PortAudio.dll.Pa_Initialize())
    local InputParameters = ffi.Library.new("PaStreamParameters[1]")
    local OutputParameters = ffi.Library.new("PaStreamParameters[1]")
    InputParameters[0].device = PortAudio.dll.Pa_GetDefaultHostApi()
    InputParameters[0].channelCount = PortAudio.dll.Pa_GetDeviceInfo(InputParameters[0].device).maxInputChannels
    InputParameters[0].sampleFormat = PortAudio.dll.paFloat32
    InputParameters[0].suggestedLatency = PortAudio.dll.Pa_GetDeviceInfo(InputParameters[0].device).defaultHighInputLatency
    OutputParameters[0].device = PortAudio.dll.Pa_GetDefaultHostApi()
    OutputParameters[0].channelCount = PortAudio.dll.Pa_GetDeviceInfo(InputParameters[0].device).maxOutputChannels
    OutputParameters[0].sampleFormat = PortAudio.dll.paFloat32
    OutputParameters[0].suggestedLatency = PortAudio.dll.Pa_GetDeviceInfo(OutputParameters[0].device).defaultHighOutputLatency
    PortAudio.checkError(PortAudio.dll.Pa_OpenStream(Space.Stream, InputParameters, OutputParameters, 44100, 0, PortAudio.dll.paClipOff, nil, nil))
    PortAudio.checkError(PortAudio.dll.Pa_StartStream(Space.Stream[0]))
    --]]
    io.write("Audio Started\n")
  end
  function GiveBack.Stop()
    --[[
	   PortAudio.checkError(PortAudio.dll.Pa_StopStream(Space.Stream[0]))
     PortAudio.checkError(PortAudio.dll.Pa_CloseStream(Space.Stream[0]))
     PortAudio.checkError(PortAudio.dll.Pa_Terminate())
     --]]
     io.write("Audio Stopped\n")
   end
   return GiveBack
end
