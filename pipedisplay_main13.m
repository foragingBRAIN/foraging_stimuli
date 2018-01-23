

clearvars;
close all;
clc;


pipedir = '\\SPIKE2-PC\Data\pipe\';
pipedisplay = 'pipedisplay';
pipetouch = 'pipetouch';
txtformat = 'Box %i: lambda=%f, avail=%i\n';


%% stim parameters
% tex parameter
betaTex = -2;
stimTexVar = 0.1;
stimsize = [768,1024];
disksize = 100;
flickint = 100;

u = [(0:floor(stimsize(1)/2)) -(ceil(stimsize(1)/2)-1:-1:1)]'/stimsize(1);
u = repmat(u,1,stimsize(2));
v = [(0:floor(stimsize(2)/2)) -(ceil(stimsize(2)/2)-1:-1:1)]/stimsize(2);
v = repmat(v,stimsize(1),1);

S_f = (u.^2 + v.^2).^(betaTex/2); 
S_f(S_f==inf) = 0;

% temporal weighting
speedchange = 20;
k = sqrt(u.^2 + v.^2);
invk = exp(-k.*speedchange);
invk(isinf(invk)) = 0;

L = pipedisplay_clut;
load('pipedisplay_calibration.mat')
lutinv;


Screen('Preference', 'SkipSyncTests', 1);

resMon = Screen('Resolution',2);
fprintf('\nOpening window 1');
stimwin(1) = Screen('OpenWindow',2);
fprintf('\nOpening window 2');
stimwin(2) = Screen('OpenWindow',3);
fprintf('\nOpening window 3');
stimwin(3) = Screen('OpenWindow',4);

fprintf('\nOpening monitoring window');
resSup = Screen('Resolution',1);
supwin = Screen('OpenWindow',1,0);

for ww=1:3
    Screen('LoadNormalizedGammaTable', stimwin(ww), lutinv);
end
Screen('LoadNormalizedGammaTable', supwin, lutinv);

fprintf('\nAll Done');
HideCursor;
ListenChar(0);




% start trial
while KbCheck; end

t1 = NaN([texscale,3]);
t2 = NaN([texscale,3]);
t3 = NaN([texscale,3]);

keyWasDown = 0;
isClicked = 0;
displaystim = 0;

currLambda = zeros(3,1);
currAvail = zeros(3,1);
vbl = zeros(3,1);

compSpectrum = NaN([stimsize,3]);
I = NaN([stimsize,3]);
    
for ww=1:3
    compSpectrum(:,:,ww) = (randn(stimsize) + 1i*randn(stimsize)) .* sqrt(S_f);
end

while 1
    
    for ww=1:3
        
        % generate new spectrum
        tempSpectrum = (randn(stimsize) + 1i*randn(stimsize)) .* sqrt(S_f);
        compSpectrum(:,:,ww) = invk.*compSpectrum(:,:,1,ww) + sqrt(1-invk.^2).*tempSpectrum;
        
        % convert to polar val
        Xmat = ifft2(compSpectrum(:,:,ww));
        Xmat = angle(Xmat + colvar*exp(1i*colmean));
        Xmat = 0.5.*Xmat./pi + (Xmat<=0);
        
        % map RGB values from CLUT
        for cc=1:3
            I(:,:,cc) = reshape(L.Xrgb(cc,ceil(Xmat*L.clutpoints)),stimsize);
        end
        % make textures
        stimtex = Screen('Maketexture', stimwin(ww), I);

        % flip stim
     	Screen('DrawTexture', stimwin(ww), stimtex{ww}, [], [0,0,resMon.width,resMon.height]);
        if currAvail(ww)
            Screen('FillOval', stimwin(ww), 0, [0.5*[1024,768]-disksize,0.5*[1024,768]+disksize]);
        end
        vbl(ww) = Screen('Flip', stimwin(ww), vbl(ww)+0.75/60);
        
        Screen('DrawTexture', supwin, stimtex{ww}, [], [(ww-1)*resSup.width/3,0,(ww)*resSup.width/3,resSup.height/3]);
        if currAvail(ww)
            Screen('FillOval', supwin, 0, [(ww-0.5)*resSup.width/3-disksize/3,0.5*resSup.height/3-disksize/3,(ww-0.5)*resSup.width/3+disksize/3,0.5*resSup.height/3+disksize/3]);
        end
        Screen('FrameRect', supwin, 0, [(ww-1)*resSup.width/3,0,ww*resSup.width/3,resSup.height/3], 2);
        
        
        % check display pipe
        if exist(sprintf('%s%s.txt',pipedir,pipedisplay),'file')
            try
                fiddisplay = fopen(sprintf('%s%s.txt',pipedir,pipedisplay));
                tline = fgetl(fiddisplay);
                while ischar(tline)
                    if contains(tline,'Box')
                        temp = sscanf(tline,txtformat);
                        currLambda(temp(1)) = temp(2);
                        currAvail(temp(1)) = temp(3);
                    end
                    tline = fgetl(fiddisplay);
                end
                fclose(fiddisplay);
            catch
                fprintf('Cannot open pipedisplay\n');
            end
        else
            fprintf('Cannot find pipedisplay\n');
        end
        
        % check touchscreens
        [mousex,mousey,mousebuttons] = GetMouse;
        if sum(mousebuttons)
            if ~isClicked
                if (mousey>0) && (mousey<768) && (mousex>1920) && (mousex<4992)
                    fidtouch = fopen(sprintf('%s%s.txt',pipedir,pipetouch),'w');
                    if fidtouch>0
                        fprintf(fidtouch,'%i\n',fix((mousex-1920)./1024));
                        fprintf('Clicked %i\n',ceil((mousex-1920)./1024));
                    else
                        fprintf('Cannot open pipetouch\n');
                    end
                    fclose(fidtouch);
                end
            end
            isClicked = 1;
        else
            isClicked = 0;
        end
        
        % check keyboard input
        [keyPress,~,keyCode] = KbCheck;
        if keyPress
            if ~keyWasDown
                if keyCode(KbName('esc'))
                    break
                elseif keyCode(KbName('space'))
                    displaystim = 1-displaystim;
                end 
            end
            keyWasDown = 1;
        else
            keyWasDown = 0;
        end
        
    end
    
    vbl0 = Screen('Flip', supwin, vbl0+2.75/60);
    for ww=1:3
        Screen('Close', stimtex{ww});
    end

end


Screen('CloseAll');
ShowCursor;
ListenChar(1);
fprintf('\n\nFinished succesfully\n');


