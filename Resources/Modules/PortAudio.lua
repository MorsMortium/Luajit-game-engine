
local M = {}
local ffi = require("ffi")
local pa

do
  local names = { 'libportaudio.so.2' }
  for i = 1,#names do
    local good, value = pcall(function() return ffi.load(names[i]) end)
    if good then
      pa = value
      break
    end
  end
end
assert(pa, "libportaudio could not be found.")

ffi.cdef [[
int Pa_GetVersion( void );
const char* Pa_GetVersionText( void );
typedef int PaError;
typedef enum PaErrorCode
{
    paNoError = 0,

    paNotInitialized = -10000,
    paUnanticipatedHostError,
    paInvalidChannelCount,
    paInvalidSampleRate,
    paInvalidDevice,
    paInvalidFlag,
    paSampleFormatNotSupported,
    paBadIODeviceCombination,
    paInsufficientMemory,
    paBufferTooBig,
    paBufferTooSmall,
    paNullCallback,
    paBadStreamPtr,
    paTimedOut,
    paInternalError,
    paDeviceUnavailable,
    paIncompatibleHostApiSpecificStreamInfo,
    paStreamIsStopped,
    paStreamIsNotStopped,
    paInputOverflowed,
    paOutputUnderflowed,
    paHostApiNotFound,
    paInvalidHostApi,
    paCanNotReadFromACallbackStream,
    paCanNotWriteToACallbackStream,
    paCanNotReadFromAnOutputOnlyStream,
    paCanNotWriteToAnInputOnlyStream,
    paIncompatibleStreamHostApi,
    paBadBufferPtr
} PaErrorCode;
const char *Pa_GetErrorText( PaError errorCode );
PaError Pa_Initialize( void );
PaError Pa_Terminate( void );

typedef int PaDeviceIndex;
enum
{
    paNoDevice=-1,
    paUseHostApiSpecificDeviceSpecification=-2
};
typedef int PaHostApiIndex;
PaHostApiIndex Pa_GetHostApiCount( void );
PaHostApiIndex Pa_GetDefaultHostApi( void );
typedef enum PaHostApiTypeId
{
    paInDevelopment=0, /* use while developing support for a new host API */
    paDirectSound=1,
    paMME=2,
    paASIO=3,
    paSoundManager=4,
    paCoreAudio=5,
    paOSS=7,
    paALSA=8,
    paAL=9,
    paBeOS=10,
    paWDMKS=11,
    paJACK=12,
    paWASAPI=13,
    paAudioScienceHPI=14
} PaHostApiTypeId;
typedef struct PaHostApiInfo
{
    int structVersion;
    PaHostApiTypeId type;
    const char *name;
    int deviceCount;
    PaDeviceIndex defaultInputDevice;
    PaDeviceIndex defaultOutputDevice;
} PaHostApiInfo;
const PaHostApiInfo * Pa_GetHostApiInfo( PaHostApiIndex hostApi );
PaHostApiIndex Pa_HostApiTypeIdToHostApiIndex( PaHostApiTypeId type );
PaDeviceIndex Pa_HostApiDeviceIndexToDeviceIndex( PaHostApiIndex hostApi,
        int hostApiDeviceIndex );
typedef struct PaHostErrorInfo{
    PaHostApiTypeId hostApiType;    /**< the host API which returned the error code */
    long errorCode;                 /**< the error code returned */
    const char *errorText;          /**< a textual description of the error if available, otherwise a zero-length string */
}PaHostErrorInfo;
const PaHostErrorInfo* Pa_GetLastHostErrorInfo( void );
PaDeviceIndex Pa_GetDeviceCount( void );
PaDeviceIndex Pa_GetDefaultInputDevice( void );
PaDeviceIndex Pa_GetDefaultOutputDevice( void );
typedef double PaTime;
typedef unsigned long PaSampleFormat;

enum
{
    paFloat32        = 0x00000001,
    paInt32          = 0x00000002,
    paInt24          = 0x00000004,
    paInt16          = 0x00000008,
    paInt8           = 0x00000010,
    paUInt8          = 0x00000020,
    paCustomFormat   = 0x00010000,

    paNonInterleaved = 0x80000000
};

typedef struct PaDeviceInfo
{
    int structVersion;
    const char *name;
    PaHostApiIndex hostApi;

    int maxInputChannels;
    int maxOutputChannels;

    PaTime defaultLowInputLatency;
    PaTime defaultLowOutputLatency;
    PaTime defaultHighInputLatency;
    PaTime defaultHighOutputLatency;

    double defaultSampleRate;
} PaDeviceInfo;

const PaDeviceInfo* Pa_GetDeviceInfo( PaDeviceIndex device );

typedef struct PaStreamParameters
{
    PaDeviceIndex device;
    int channelCount;
    PaSampleFormat sampleFormat;
    PaTime suggestedLatency;
    void *hostApiSpecificStreamInfo;
} PaStreamParameters;
enum
{
    paFormatIsSupported=0
};
PaError Pa_IsFormatSupported( const PaStreamParameters *inputParameters,
                              const PaStreamParameters *outputParameters,
                              double sampleRate );
typedef void PaStream;
enum
{
    paFramesPerBufferUnspecified=0
};
typedef unsigned long PaStreamFlags;

enum
{
    paNoFlag          = 0,
    paClipOff         = 0x00000001,
    paDitherOff       = 0x00000002,
    paNeverDropInput  = 0x00000004,
    paPrimeOutputBuffersUsingStreamCallback = 0x00000008,
    paPlatformSpecificFlags = 0xFFFF0000
};

typedef struct PaStreamCallbackTimeInfo {
    PaTime inputBufferAdcTime;
    PaTime currentTime;
    PaTime outputBufferDacTime;
} PaStreamCallbackTimeInfo;


typedef unsigned long PaStreamCallbackFlags;
enum
{
    paInputUnderflow  = 0x00000001,
    paInputOverflow   = 0x00000002,
    paOutputUnderflow = 0x00000004,
    paOutputOverflow  = 0x00000008,
    paPrimingOutput   = 0x00000010
};
enum PaStreamCallbackResult
{
    paContinue=0,
    paComplete=1,
    paAbort=2
} PaStreamCallbackResult;
typedef int PaStreamCallback(
    const void *input, void *output,
    unsigned long frameCount,
    const PaStreamCallbackTimeInfo* timeInfo,
    PaStreamCallbackFlags statusFlags,
    void *userData );
PaError Pa_OpenStream( PaStream** stream,
                       const PaStreamParameters *inputParameters,
                       const PaStreamParameters *outputParameters,
                       double sampleRate,
                       unsigned long framesPerBuffer,
                       PaStreamFlags streamFlags,
                       PaStreamCallback *streamCallback,
                       void *userData );
PaError Pa_OpenDefaultStream( PaStream** stream,
                              int numInputChannels,
                              int numOutputChannels,
                              PaSampleFormat sampleFormat,
                              double sampleRate,
                              unsigned long framesPerBuffer,
                              PaStreamCallback *streamCallback,
                              void *userData );
PaError Pa_CloseStream( PaStream *stream );
typedef void PaStreamFinishedCallback( void *userData );
PaError Pa_SetStreamFinishedCallback( PaStream *stream, PaStreamFinishedCallback* streamFinishedCallback );
PaError Pa_StartStream( PaStream *stream );
PaError Pa_StopStream( PaStream *stream );
PaError Pa_AbortStream( PaStream *stream );
PaError Pa_IsStreamStopped( PaStream *stream );
PaError Pa_IsStreamActive( PaStream *stream );
typedef struct PaStreamInfo
{
    int structVersion;
    PaTime inputLatency;
    PaTime outputLatency;
    double sampleRate;
} PaStreamInfo;
const PaStreamInfo* Pa_GetStreamInfo( PaStream *stream );
PaTime Pa_GetStreamTime( PaStream *stream );
double Pa_GetStreamCpuLoad( PaStream* stream );
PaError Pa_ReadStream( PaStream* stream,
                       void *buffer,
                       unsigned long frames );
PaError Pa_WriteStream( PaStream* stream,
                        const void *buffer,
                        unsigned long frames );
signed long Pa_GetStreamReadAvailable( PaStream* stream );
signed long Pa_GetStreamWriteAvailable( PaStream* stream );
PaError Pa_GetSampleSize( PaSampleFormat format );
void Pa_Sleep( long msec );
]]


local function checkError(err, fn)
  if err ~= pa.paNoError then
    if err == pa.paUnanticipatedHostError then
      error(ffi.string(pa.Pa_GetLastHostErrorInfo().errorText))
    else
      error(ffi.string(pa.Pa_GetErrorText(err)))
    end
    if fn then fn() end
  end
end

local function configDevice(device, numChan, format, latency)
  if not device then
    return 0
  end

  return ffi.new("PaStreamParameters", {
    device,
    numChan or 1,
    format or pa.paFloat32,
    latency or pa.Pa_GetDeviceInfo(device)[0].defaultLowOutputLatency,
  })
end

local function newStream()
  return ffi.new("PaStream*[1]")
end

---- Blocking stream
-- Better performance than callback-based, but likely requires multi-threading
-- to obtain user input.

local function blocking(sampleRate, framesPerBuffer, numChannels, audiofun)
  assert(type(sampleRate) == "number", "Bad arg#1: sampleRate (number)")
  assert(type(framesPerBuffer) == "number", "Bad arg#2: framesPerBuffer (number)")
  assert(type(numChannels) == "number", "Bad arg#3: numChannels (number)")
  assert(type(audiofun) == "function", "Bad arg#4: callback (function)")
  assert(framesPerBuffer > 0, "Bad arg#2: framesPerBuffer (> 0)")

  checkError(pa.Pa_Initialize())

  local inpDevice = configDevice(pa.Pa_GetDefaultInputDevice(), numChannels)
  local outDevice = configDevice(pa.Pa_GetDefaultOutputDevice(), numChannels)

  local stream = newStream()

  local function die()
    checkError(pa.Pa_StopStream(stream[0]), pa.Pa_Terminate)
    checkError(pa.Pa_CloseStream(stream[0]), pa.Pa_Terminate)
    pa.Pa_Terminate()
  end

  checkError(pa.Pa_OpenStream(stream, inpDevice, outDevice, sampleRate,
    framesPerBuffer, bit.bor(pa.paClipOff, pa.paDitherOff), nil, nil), die)
  checkError(pa.Pa_StartStream(stream[0]), die)

  local bufferSize = framesPerBuffer * numChannels
  local inpBuffer = ffi.new("float[?]", bufferSize)
  local outBuffer = ffi.new("float[?]", bufferSize)

  repeat
    pa.Pa_ReadStream(stream[0], inpBuffer, framesPerBuffer)
    local stop = audiofun(inpBuffer, outBuffer, framesPerBuffer, numChannels)
    pa.Pa_WriteStream(stream[0], outBuffer, framesPerBuffer)
  until stop

  die()
end

---- Callback-based stream
-- Nicer for Lua since it is single-threaded, but has has lower performance
-- than blocking stream

local function callback(sampleRate, framesPerBuffer, numChannels, audiofun, waitfun)

  assert(type(sampleRate) == "number", "Bad arg#1: sampleRate (number)")
  assert(type(framesPerBuffer) == "number", "Bad arg#2: framesPerBuffer (number)")
  assert(type(numChannels) == "number", "Bad arg#3: numChannels (number)")
  assert(type(audiofun) == "function", "Bad arg#4: audiofun (function)")
  assert(type(waitfun) == "function", "Bad arg#5: waitfun (function)")
  assert(framesPerBuffer > 0, "Bad arg#2: framesPerBuffer (> 0)")

  local function callback(inputBuff, outputBuff, size, timeInfo, flags, udata)
    local inp = ffi.cast("float*", inputBuff)
    local out = ffi.cast("float*", outputBuff)
    audiofun(inp, out, tonumber(size), numChannels)
    return 0
  end

  checkError(pa.Pa_Initialize())

  local inpParams = configDevice(pa.Pa_GetDefaultInputDevice(), numChannels)
  local outParams = configDevice(pa.Pa_GetDefaultOutputDevice(), numChannels)
  local flags = bit.bor(
    pa.paClipOff, pa.paDitherOff, pa.paPrimeOutputBuffersUsingStreamCallback)

  local stream = newStream()
  local function die()
    checkError(pa.Pa_StopStream(stream[0]), pa.Pa_Terminate)
    checkError(pa.Pa_CloseStream(stream[0]), pa.Pa_Terminate)
    pa.Pa_Terminate()
  end

  checkError(pa.Pa_OpenStream(stream, inpParams, outParams, sampleRate,
    framesPerBuffer, flags, callback, nil), die)
  checkError(pa.Pa_StartStream(stream[0]), die)

  waitfun()

  die()
end

----

M.dll = pa
M.configDevice = configDevice
M.newStream = newStream
M.checkError = checkError
M.blocking = blocking
M.callback = callback

return M
