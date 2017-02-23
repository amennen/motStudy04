function [audiodataSave] = recordaudio(onset,maxsecs,look)

% Perform basic initialization of the sound driver:
%InitializePsychSound;
if look
   % deviceID = findInputDevice([],'audio', 'USB');
    %deviceID = deviceID -1;
     devices = PsychPortAudio('GetDevices');
    devInd = 0;
    for iDev = 1:numel(devices)
        if strncmp(devices(iDev).DeviceName,'USB Audio CODEC: USB Audio',numel('USB Audio CODEC: USB Audio'))
            devInd = iDev;
        end
    end
    deviceID = devInd-1; 
   % pahandle = PsychPortAudio('Open',config.audio.deviceID,2,0,config.audio.samplerate,config.audio.nchans);
else
    deviceID = [];
end
InitializePsychSound;
% Open the default audio device [], with mode 2 (== Only audio capture),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of 44100 Hz and 2 sound channels for stereo capture.
% This returns a handle to the audio device:
freq = 44100;
pahandle = PsychPortAudio('Open', deviceID, 2, 0, freq, 1);
% Preallocate an internal audio recording  buffer with a capacity of 10 seconds:
PsychPortAudio('GetAudioData', pahandle, 25);

% Start audio capture immediately and wait for the capture to start.
% We set the number of 'repetitions' to zero,
% i.e. record until recording is manually stopped.
PsychPortAudio('Start', pahandle, 0, 0, 1);

% Start with empty sound vector:
recordedaudio = [];

% We retrieve status once to get access to SampleRate:
s = PsychPortAudio('GetStatus', pahandle);

% Stay in a little loop until keypress:
%((length(recordedaudio) / s.SampleRate) < maxsecs - .5)
%while GetSecs - onset < maxsecs - .05
while ((length(recordedaudio) / s.SampleRate) < maxsecs - 0.1)
    
    % Query current capture status and print it to the Matlab window:
    s = PsychPortAudio('GetStatus', pahandle);
    
    % Retrieve pending audio data from the drivers internal ringbuffer:
    audiodata = PsychPortAudio('GetAudioData', pahandle);
    nrsamples = size(audiodata, 2);
    
    % And attach it to our full sound vector:
    recordedaudio = [recordedaudio audiodata]; %#ok<AGROW>
end

% Stop capture:
PsychPortAudio('Stop', pahandle);

% Perform a last fetch operation to get all remaining data from the capture engine:
audiodata = PsychPortAudio('GetAudioData', pahandle);

% Attach it to our full sound vector: and increase volume (?)
recordedaudio = 10*[recordedaudio audiodata];

% Close the audio device:
PsychPortAudio('Close', pahandle);
audiodataSave = transpose(recordedaudio);
%audiowrite(wavfilename, transpose(recordedaudio), 44100)
clearvars pahandle
end
