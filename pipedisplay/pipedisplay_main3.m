

clear all;
close all;
clc;


pipedir = '\\SPIKE2-PC\Data\pipe\';
txtformat = 'SCENE%i_FG_COLOR %f %f %f\n';

betaTex = -2;
stimTexVar = 0.1;
texscale = [768,1024]/4;
disksize = 100;
flickint = 100;

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
% w0 = Screen('OpenWindow',1,0,[0,0,resSup.width,resSup.height/3+10]);
w0 = Screen('OpenWindow',1,0);

fprintf('\nAll Done');
HideCursor;
ListenChar(0);

L = pipedisplay_clut;

currCol = zeros(1,3);
colmat = zeros(4,3);

Screen('FillRect', stimwin(1), 128);
vbl(1) = Screen('Flip', stimwin(1), 0);
Screen('FillRect', stimwin(2), 128);
vbl(2) = Screen('Flip', stimwin(2), 0);
Screen('FillRect', stimwin(3), 128);
vbl(3) = Screen('Flip', stimwin(3), 0);
Screen('FillRect', w0, 128, [0,0,resSup.width/3,resSup.height/3]);
Screen('FillRect', w0, 128, [resSup.width/3,0,2*resSup.width/3,resSup.height/3]);
Screen('FillRect', w0, 128, [2*resSup.width/3,0,resSup.width,resSup.height/3]);
Screen('FrameRect', w0, 128, [0,0,resSup.width/3,resSup.height/3], 2);
Screen('FrameRect', w0, 128, [resSup.width/3,0,2*resSup.width/3,resSup.height/3], 2);
Screen('FrameRect', w0, 128, [2*resSup.width/3,0,resSup.width,resSup.height/3], 2);
vbl0 = Screen('Flip', w0, 0);


% start trial
t1 = NaN([texscale,3]);
t2 = NaN([texscale,3]);
t3 = NaN([texscale,3]);

lastflick = 0;
flick = 0;
pic = randi(4);
I = imread(sprintf('pic%i.jpg',pic));
tex = Screen('MakeTexture',w0,I);
stimcount = 0;
randccord = [rand*(768-300),rand*(1024-300)];
displaystim = 1;

while KbCheck; end
keyWasDown = 0;


while 1
    
    if (GetSecs-lastflick)>0.5
        lastflick = GetSecs;
        flick = 1-flick;
        stimcount = stimcount+1;
        if stimcount>1
            randccord = [rand*(1024-300),rand*(768-300)];
            stimcount = 0;
            Screen('Close', tex);
            pic = randi(4);
            I = imread(sprintf('pic%i.jpg',pic));
            tex = Screen('MakeTexture',w0,I);
        end
    end
    
    for ww=1:3
        % generate pink noise textures
        p = pipedisplay_noise(texscale,betaTex);
        
        p = p.*stimTexVar./std(p(:))+0.25+0.5*currCol(ww);
        p = mod(round(p*3*1000/8),1000); p(p==0) = 1000;

        % map RGB values from CLUT
        for cc=1:3
            temp = L.Xrgb(cc,:);
            t(:,:,cc) = temp(p);
        end

        % make textures
        stimtex{ww} = Screen('Maketexture', stimwin(ww), 255*t);

        % flip stim
     	Screen('DrawTexture', stimwin(ww), stimtex{ww}, [], [0,0,resMon.width,resMon.height]);
        Screen('FillOval', stimwin(ww), max(255*currCol(ww)-flickint*flick,0), [0.5*[1024,768]-disksize,0.5*[1024,768]+disksize]);
        if currCol(ww)>0 && displaystim
            Screen('DrawTexture', stimwin(ww), tex, [], [randccord,randccord+300]);
        end
        vbl(ww) = Screen('Flip', stimwin(ww), vbl(ww)+1/20-0.25/60);
        
        Screen('DrawTexture', w0, stimtex{ww}, [], [(ww-1)*resSup.width/3,0,(ww)*resSup.width/3,resSup.height/3]);
        Screen('FillOval', w0, max(255*currCol(ww)-flickint*flick,0), [(ww-0.5)*resSup.width/3-disksize/3,0.5*resSup.height/3-disksize/3,(ww-0.5)*resSup.width/3+disksize/3,0.5*resSup.height/3+disksize/3]);
        if currCol(ww)>0 && displaystim
            Screen('DrawTexture', w0, tex, [], [randccord/3+[(ww-1)*resSup.width/3,0],randccord/3+[(ww-1)*resSup.width/3+100,100]]);
        end
        Screen('FrameRect', w0, 0, [(ww-1)*resSup.width/3,0,ww*resSup.width/3,resSup.height/3], 2);
    end
    vbl0 = Screen('Flip', w0, vbl0+1/20-0.25/60);

    
    Screen('Close', stimtex{1});
    Screen('Close', stimtex{2});
    Screen('Close', stimtex{3});
    
    if exist(sprintf('%smoogpipe.txt',pipedir),'file')
        fid = fopen(sprintf('%smoogpipe.txt',pipedir));
        tline = fgetl(fid);
        while ischar(tline)
            if contains(tline,'FG_COLOR')
                temp = sscanf(tline,txtformat);
                colmat(:,temp(1)) = temp;
            end
            tline = fgetl(fid);
        end
        fclose(fid);
%         delete(sprintf('%smoogpipe.txt',pipedir));
    end
    
    currCol = (colmat(2,:)>0);
%     fprintf('\nValues: %2.2f, %2.2f, %2.2f', currCol);
    
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


Screen('CloseAll');
ShowCursor;
ListenChar(1);
fprintf('\n\nFinished succesfully\n');


