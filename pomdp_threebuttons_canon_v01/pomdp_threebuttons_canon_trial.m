

function [E,R] = pomdp_threebuttons_canon_trial(W,L,A,K,E,R,bb)
    
    % start telegraph process
    up1 = 0;    pup1 = 1/E.telprocTau;  lambda1 = E.telprocLambdamax;
    up2 = 0;    pup2 = 1/E.telprocTau;  lambda2 = E.telprocLambdamax;
    up3 = 0;    pup3 = 1/E.telprocTau;  lambda3 = E.telprocLambdamax;
    
    currScore = 0;
    scoreBounds = Screen('TextBounds', W.n, sprintf('%i',currScore));
    
    
    % display background
    while MouseCheck; end
    
    SetMouse(W.center(1),W.center(2));
    
    Screen('FillRect', W.n, W.bg*255);
    Screen('DrawText', W.n, sprintf('%i',currScore), W.center(1)-0.5*scoreBounds(3), W.center(2)-0.5*scoreBounds(4), 0);
    Screen('DrawDots', W.n, W.center', E.cursorSizePix, E.cursorColor(:,1), [], 2);
    vbl = Screen('Flip', W.n, 0);
    
    
    % compute window
    [xx,yy] = meshgrid(1:E.stimSizePix,1:E.stimSizePix);
    dd = sqrt((xx-0.5*E.stimSizePix).^2+(yy-0.5*E.stimSizePix).^2);
    winmat = W.bg*ones([size(xx),4]);
    winmat(:,:,4) = normcdf(dd,0.5*E.stimWinSizePix,E.stimWinStdPix);
    wintex = Screen('MakeTexture', W.n, 255*winmat);
    
    % compute patches coord
    randangle = rand*pi;
    patchdist = 300;
    patchrect = NaN(4,3);
    patchcenters = patchdist*[cos(randangle+(0:3)*2*pi/3);sin(randangle+(0:3)*2*pi/3)]';
    patchcenters(4,:) = [];
    for ii=1:3
        patchcenters(ii,:) = patchcenters(ii,:)+W.center;
        patchrect(:,ii) = [patchcenters(ii,:)-0.5*E.stimSizePix,patchcenters(ii,:)+0.5*E.stimSizePix];
    end
    
	
    % start trial
    t1 = NaN([E.stimSizePix,E.stimSizePix,3]);
    t2 = NaN([E.stimSizePix,E.stimSizePix,3]);
    t3 = NaN([E.stimSizePix,E.stimSizePix,3]);
    
    while MouseCheck; end
    mouseDown = 0;
    
    while 1
        
        [cursorX,cursorY] = GetMouse;
        
        % update lamdbas
        lambda1 = lambda1+E.telProcRenewrate*(E.telprocLambdamax-lambda1);
        lambda2 = lambda2+E.telProcRenewrate*(E.telprocLambdamax-lambda2);
        lambda3 = lambda3+E.telProcRenewrate*(E.telprocLambdamax-lambda3);
        
        % check clicks
        feedback = 0;
        correct = 0;
        if MouseCheck
            if ~mouseDown
                if sqrt(sum((patchcenters(1,:)-[cursorX,cursorY]).^2))<0.5*E.stimSizePix
                    feedback = 1;
                    if up1;
                        lambda1 = lambda1 - E.telprocDepleteRate*(lambda1-E.telprocLambdamin);
                        currScore = currScore+1;
                        correct = 1;
                    end
                    up1 = 0;
                elseif sqrt(sum((patchcenters(2,:)-[cursorX,cursorY]).^2))<0.5*E.stimSizePix
                    feedback = 1;
                    if up2;
                        lambda2 = lambda2 - E.telprocDepleteRate*(lambda2-E.telprocLambdamin);
                        currScore = currScore+1;
                        correct = 1;
                    end
                    up2 = 0;
                elseif sqrt(sum((patchcenters(3,:)-[cursorX,cursorY]).^2))<0.5*E.stimSizePix
                    feedback = 1;
                    if up3;
                        lambda3 = lambda3 - E.telprocDepleteRate*(lambda3-E.telprocLambdamin);
                        currScore = currScore+1;
                        correct = 1;
                    end
                    up3 = 0;
                end
            end
            mouseDown = 1;
        else
           mouseDown = 0; 
        end
        
        if strcmp(R.subjectName,'train')
            figure(1)
            hold on
            plot(GetSecs-R.timeStart,lambda1,'bo',GetSecs-R.timeStart,lambda2,'go',GetSecs-R.timeStart,lambda3,'ro')
            axis([0,GetSecs-R.timeStart,0,1])
        end
        
        % update switch probs
        pdown1 = pup1*(1-lambda1)/lambda1;
        pdown2 = pup2*(1-lambda2)/lambda2;
        pdown3 = pup3*(1-lambda3)/lambda3;
        
        % switch states
        if (~up1 && (rand<pup1)) || (up1 && (rand<pdown1))
            up1 = ~up1;
        end
        if (~up2 && (rand<pup2)) || (up2 && (rand<pdown2))
            up2 = ~up2;
        end
        if (~up3 && (rand<pup3)) || (up3 && (rand<pdown3))
            up3 = ~up3;
        end
        
        % generate pink noise textures
        p1 = pomdp_threebuttons_canon_noise([E.stimSizePix,E.stimSizePix],-1);
        p2 = pomdp_threebuttons_canon_noise([E.stimSizePix,E.stimSizePix],-1);
        p3 = pomdp_threebuttons_canon_noise([E.stimSizePix,E.stimSizePix],-1);
        p1 = p1.*E.stimTexVar./std(p1(:))+lambda1;
        p2 = p2.*E.stimTexVar./std(p2(:))+lambda2;
        p3 = p3.*E.stimTexVar./std(p3(:))+lambda3;
        p1 = mod(round(p1*3*E.stimNCol/8),E.stimNCol); p1(p1==0) = E.stimNCol;
        p2 = mod(round(p2*3*E.stimNCol/8),E.stimNCol); p2(p2==0) = E.stimNCol;
        p3 = mod(round(p3*3*E.stimNCol/8),E.stimNCol); p3(p3==0) = E.stimNCol;
        
        % map RGB values from CLUT
        for cc=1:3
            temp = L.Xrgb(cc,:);
            t1(:,:,cc) = temp(p1);
            t2(:,:,cc) = temp(p2);
            t3(:,:,cc) = temp(p3);
        end
        
        % make textures
        tex1 = Screen('Maketexture', W.n, 255*t1);
        tex2 = Screen('Maketexture', W.n, 255*t2);
        tex3 = Screen('Maketexture', W.n, 255*t3);
        
        % diplay stim
        scoreBounds = Screen('TextBounds', W.n, sprintf('%i',currScore));
        
        Screen('FillRect', W.n, W.bg*255);
        Screen('DrawTexture', W.n, tex1, [], patchrect(:,1));
        Screen('DrawTexture', W.n, tex2, [], patchrect(:,2));
        Screen('DrawTexture', W.n, tex3, [], patchrect(:,3));
        for pp=1:3
            Screen('DrawTexture', W.n, wintex, [], patchrect(:,pp));
        end
        if strcmp(R.subjectName,'train')
            Screen('DrawDots', W.n, patchcenters', E.cursorSizePix, 255*repmat([up1,up2,up3],3,1), [], 2);
            paramText = sprintf('1/Tau:%2.3f, Delta:%2.2f, Phi:%2.2f, Sigma:%2.2f',...
                E.telProcRenewrate, E.telprocDepleteRate, E.telprocTau, E.stimTexVar);
            Screen('DrawText', W.n, paramText, 0, 0, 0);
        end
        Screen('DrawText', W.n, sprintf('%i',currScore), W.center(1)-0.5*scoreBounds(3), W.center(2)-0.5*scoreBounds(4), 0);
        Screen('DrawDots', W.n, [cursorX,cursorY], E.cursorSizePix, E.cursorColor(:,1+feedback+correct), [], 2);
        vbl = Screen('Flip', W.n, vbl+E.durStimSec-0.25*W.ifi);
        
        if strcmp(R.subjectName,'screenshot')
           	I = Screen('GetImage', W.n);
            imwrite(I,'stimulus.png');
        end
        
        % play sound if click
        if feedback
            if correct
                PsychPortAudio('FillBuffer', A.p, A.feedback1);
            else
                PsychPortAudio('FillBuffer', A.p, A.feedback2);
            end
            PsychPortAudio('Start', A.p, 1, 0, 0);
        end
        
        % close textures
        Screen('Close',tex1);
        Screen('Close',tex2);
        Screen('Close',tex3);
        
        
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown;
            k = find(keyCode,1);
            switch k
                case K.quit
                    if strcmp(R.subjectName,'train')
                        figure(1)
                        legend({'Box1','Box2','Box3'});
                    end
                    break
                case K.up
                    E.telProcRenewrate = E.telProcRenewrate+0.001;
                case K.down
                    E.telProcRenewrate = max(E.telProcRenewrate-0.001,0);
                case K.right
                    E.telprocDepleteRate = min(E.telprocDepleteRate+0.05,1);
                case K.left
                    E.telprocDepleteRate = max(E.telprocDepleteRate-0.05,0);
                case K.w
                    E.telprocTau = E.telprocTau+1;
                case K.s
                    E.telprocTau = max(E.telprocTau-1,0);
                case K.d
                    E.stimTexVar = E.stimTexVar+0.05;
                case K.a
                    E.stimTexVar = max(E.stimTexVar-0.05,0);
            end
        end
        
    end
    
end

