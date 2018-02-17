

pipedir = '\\Spike2\Data\pipe\';
txtformat = 'SCENE%i_FG_COLOR %i %i %i\n';


Screen('Preference', 'SkipSyncTests', 1);
w0 = Screen('OpenWindow',1,0,[0,1024,0,256]);
w1 = Screen('OpenWindow',2);
w2 = Screen('OpenWindow',3);
w3 = Screen('OpenWindow',4);


currCol = zeros(3,1);



while 1
    
    
    
    
    
    
    
    Screen('FillRect', w1, [255,0,0]);
    Screen('Flip', w1 );
    Screen('FillRect', w1, [255,0,255]);
    Screen('Flip', w2 );
    Screen('FillRect', w1, [0,0,255]);
    Screen('Flip', w3 );

    if KbCheck
        break
    end
end


Screen('CloseAll')



while 1
   
    if exist(sprintf('%smoogpipe.txt',pipedir),'file')
        fid = fopen(sprintf('%smoogpipe.txt',pipedir));
        vec = reshape(fscanf(fid,txtformat),4,3);
        fclose(fid);
    end
    
    if KbCheck
        break;
    end
    
end