

function pomdp_threebuttons_canon_messages(W,E,bb)


    % set text properties
    Screen('TextSize', W.n, E.textSize);
    Screen('TextStyle', W.n, E.textStyle);
    Screen('TextFont', W.n, E.textFont);
    Screen('TextColor', W.n, E.textColor);

    
    if bb>0
        
        if (bb==1)
            
            % display trial number
            txt1 = 'Click on the buttons';
            txt2 = 'to get rewards';
            bnd1 = Screen('TextBounds', W.n, txt1);
            bnd2 = Screen('TextBounds', W.n, txt2);
            
            while KbCheck; end
            
            vbl = -0.75*W.ifi;
            while 1

                Screen('FillRect', W.n, W.bg*255);
                Screen('DrawText', W.n, txt1, W.center(1)-0.5*bnd1(3), W.center(2)-1.25*bnd1(4), E.textColor);
                Screen('DrawText', W.n, txt2, W.center(1)-0.5*bnd2(3), W.center(2)+0.25*bnd2(4), E.textColor);
                vbl = Screen('Flip', W.n, vbl+0.75*W.ifi);

                if KbCheck
                    break
                end

            end

        end
        
        
        % display trial number
        txt1 = sprintf('Block %i/%i', bb, E.nCond);
        txt2 = sprintf(' ');
        bnd1 = Screen('TextBounds', W.n, txt1);
        bnd2 = Screen('TextBounds', W.n, txt2);
        
        timeStart = GetSecs;
        vbl = timeStart;
        timeEnd = NaN;
        
        while KbCheck; end
        
        while 1
            
            if ((GetSecs-timeStart)>E.durPauseSec) || (bb==1)
                if isnan(timeEnd)
                    timeEnd = GetSecs;
                end
                txt3 = 'Press any key to start';
                bnd3 = Screen('TextBounds', W.n, txt3);
                blinkCol = [E.textColor,E.textColor,E.textColor,255*0.5*(1+sin((GetSecs-timeStart)*2*pi*E.textFreqHz))];
            else
                currDelay = ceil(E.durPauseSec-(GetSecs-timeStart));
                txt3 = sprintf('%i', currDelay);
                bnd3 = Screen('TextBounds', W.n, txt3);
                blinkCol = [E.textColor,E.textColor,E.textColor,255];
            end
            

            Screen('FillRect', W.n, W.bg*255);
            Screen('DrawText', W.n, txt1, W.center(1)-0.5*bnd1(3), W.center(2)-2.0*bnd1(4), E.textColor);
            Screen('DrawText', W.n, txt2, W.center(1)-0.5*bnd2(3), W.center(2)-0.5*bnd2(4), E.textColor);
            Screen('DrawText', W.n, txt3, W.center(1)-0.5*bnd3(3), W.center(2)+1.0*bnd3(4), blinkCol);
            vbl = Screen('Flip', W.n, vbl+0.75*W.ifi);

            if KbCheck
                break
            end

        end

        Screen('FillRect', W.n, W.bg*255);
        Screen('Flip', W.n, vbl+0.75*W.ifi);

        while KbCheck; end
        
    else
        
        % display "thanks"
        txt1 = 'Thanks';
        
        bnd1 = Screen('TextBounds', W.n, txt1);


        Screen('FillRect', W.n, W.bg*255);
        Screen('DrawText', W.n, txt1, W.center(1)-0.5*bnd1(3), W.center(2)-0.5*bnd1(4), E.textColor);
        Screen('Flip', W.n);

        while ~KbCheck; end
        
    end
    
    
end


