

Screen('Preference', 'SkipSyncTests', 1);

w = Screen('OpenWindow',2);


nstep = 52;
colList = [...
    linspace(0,1,nstep)',zeros(nstep,1),zeros(nstep,1);...
    zeros(nstep,1),linspace(0,1,nstep)',zeros(nstep,1);...
    zeros(nstep,1),zeros(nstep,1),linspace(0,1,nstep)';...
    linspace(0,1,nstep)',linspace(0,1,nstep)',zeros(nstep,1);...
    linspace(0,1,nstep)',zeros(nstep,1),linspace(0,1,nstep)';...
    zeros(nstep,1),linspace(0,1,nstep)',linspace(0,1,nstep)';...
    linspace(0,1,nstep)',linspace(0,1,nstep)',linspace(0,1,nstep)'];
ncol = size(colList,1);

Screen('FillRect', w, 255);
vbl = Screen('Flip', w, 0);


while KbCheck; end
while ~KbCheck; end
while KbCheck; end
cc = 1;
fprintf('\nCalib %i',cc)
wasDown = 0;
while 1
    Screen('FillRect', w, 255*colList(cc,:));
    vbl = Screen('Flip', w, vbl+0.75/60 );

    if KbCheck
        if ~wasDown
            cc = cc+1;
            if cc>ncol
                break
            end
            fprintf('\nCalib %i',cc);
        end
        wasDown = 1;
    else
        wasDown = 0;
    end
end


Screen('CloseAll')
