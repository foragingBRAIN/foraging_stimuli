

clear all;
close all;
clc;


pipedir = '\\SPIKE2-PC\Data\pipe\';
txtformat = 'SCENE%i_FG_COLOR %f %f %f\n';


stimTexVar = 0.1;
texscale = [768,1024]/4;


Screen('Preference', 'SkipSyncTests', 1);

resMon = Screen('Resolution',2);
fprintf('\nOpening window 1');
w1 = Screen('OpenWindow',2);
fprintf('\nOpening window 2');
w2 = Screen('OpenWindow',3);
fprintf('\nOpening window 3');
w3 = Screen('OpenWindow',4);

fprintf('\nOpening monitoring window');
resSup = Screen('Resolution',1);
% w0 = Screen('OpenWindow',1,0,[0,0,resSup.width,resSup.height/3+10]);
w0 = Screen('OpenWindow',1,0);

fprintf('\nAll Done');
HideCursor;

L = pipedisplay_clut;

currCol = zeros(1,3);
colmat = zeros(4,3);

Screen('FillRect', w1, 128);
vbl1 = Screen('Flip', w1, 0);
Screen('FillRect', w2, 128);
vbl2 = Screen('Flip', w2, 0);
Screen('FillRect', w3, 128);
vbl3 = Screen('Flip', w3, 0);
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


while 1
    
    % generate pink noise textures
    p1 = pipedisplay_noise(texscale,-1);
    p2 = pipedisplay_noise(texscale,-1);
    p3 = pipedisplay_noise(texscale,-1);
    p1 = p1.*stimTexVar./std(p1(:))+currCol(1);
    p2 = p2.*stimTexVar./std(p2(:))+currCol(2);
    p3 = p3.*stimTexVar./std(p3(:))+currCol(3);
    p1 = mod(round(p1*3*1000/8),1000); p1(p1==0) = 1000;
    p2 = mod(round(p2*3*1000/8),1000); p2(p2==0) = 1000;
    p3 = mod(round(p3*3*1000/8),1000); p3(p3==0) = 1000;

    % map RGB values from CLUT
    for cc=1:3
        temp = L.Xrgb(cc,:);
        t1(:,:,cc) = temp(p1);
        t2(:,:,cc) = temp(p2);
        t3(:,:,cc) = temp(p3);
    end
    
    % make textures
    tex1 = Screen('Maketexture', w1, 255*t1);
    tex2 = Screen('Maketexture', w2, 255*t2);
    tex3 = Screen('Maketexture', w3, 255*t3);
    
    % flip stim
    Screen('DrawTexture', w1, tex1, [], [0,0,resMon.width,resMon.height]);
    vbl1 = Screen('Flip', w1, vbl1+1/20-0.25/60);
    Screen('DrawTexture', w2, tex2, [], [0,0,resMon.width,resMon.height]);
    vbl2 = Screen('Flip', w2, vbl2+1/20-0.25/60);
    Screen('DrawTexture', w3, tex3, [], [0,0,resMon.width,resMon.height]);
    vbl3 = Screen('Flip', w3, vbl3+1/20-0.25/60);
    
    Screen('DrawTexture', w0, tex1, [], [0,0,resSup.width/3,resSup.height/3]);
    Screen('DrawTexture', w0, tex2, [], [resSup.width/3,0,2*resSup.width/3,resSup.height/3]);
    Screen('DrawTexture', w0, tex3, [], [2*resSup.width/3,0,resSup.width,resSup.height/3]);
    Screen('FrameRect', w0, 0, [0,0,resSup.width/3,resSup.height/3], 2);
    Screen('FrameRect', w0, 0, [resSup.width/3,0,2*resSup.width/3,resSup.height/3], 2);
    Screen('FrameRect', w0, 0, [2*resSup.width/3,0,resSup.width,resSup.height/3], 2);
    vbl0 = Screen('Flip', w0, vbl0+1/20-0.25/60);

    Screen('Close', tex1);
    Screen('Close', tex2);
    Screen('Close', tex3);

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
    if keyPress && keyCode(KbName('esc'))
        break
    end

end


Screen('CloseAll');
ShowCursor;
fprintf('\n\nFinished succesfully\n');


