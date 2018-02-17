

Screen('Preference', 'SkipSyncTests', 1);

w1 = Screen('OpenWindow',2);
w2 = Screen('OpenWindow',3);
w3 = Screen('OpenWindow',4);




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
