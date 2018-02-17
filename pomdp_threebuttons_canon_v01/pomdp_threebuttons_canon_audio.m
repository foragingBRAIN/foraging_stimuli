

function A = pomdp_threebuttons_canon_audio(platform)
    
    
    %% set parameters
    switch platform
        case 0
            deviceId = 1;
            sampleFreq = 44100;
            channels = 1;
        case 1
            % find devideId with: d = PsychPortAudio('GetDevices')
            % this will return d as a 1xN structure, find d(X) with a
            % DeviceName that looks womething like 'Built-in Output',
            % the Device ID is the associated DeviceIndex (it should be
            % equal to X-1)
            deviceId = 1;
            sampleFreq = 44100;
            channels = 1;
    end
    
    
    %% feedbacks
    
    freq1 = 440;
    freq2 = 220;
    sndDur = 0.1;
    rampIn = 0.01;
    rampOut = 0.01;
    
    window = [sin(linspace(0,pi/2,sampleFreq*rampIn)).^2,ones(1,round((sndDur-rampIn-rampOut)*sampleFreq)),sin(linspace(pi/2,0,sampleFreq*rampIn)).^2];
    sine1 = sin(linspace(0,2*pi*sndDur*freq1,sndDur*sampleFreq));
    sine2 = sin(linspace(0,2*pi*sndDur*freq2,sndDur*sampleFreq));
    
    A.feedback1 = window.*sine1;
    A.feedback2 = window.*sine2;
    
    
    %% sound localization functions
    
    headRadiusCm = 10;
    maxAttenuation = 1;
    soundSpeed = 30e-6;
    
    A.itd = @(angle) -(headRadiusCm.*2.*pi.*angle./(2.*pi)+headRadiusCm.*sin(angle)).*soundSpeed;
    A.ild = @(angle) exp(-maxAttenuation*erf(angle));
    
    
    %% open PTA
    
    A.p = PsychPortAudio('Open', deviceId, 1, 0, sampleFreq, channels);

    A.sampleFreq = sampleFreq;
    A.channels = channels;
    A.fadeWinDur = 0.01;
    A.fadeWinLength = A.fadeWinDur*A.sampleFreq;

end


