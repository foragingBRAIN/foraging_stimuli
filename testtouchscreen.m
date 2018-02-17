

while KbCheck; end

isclicked = 0;
cc = 0;
while ~KbCheck
	[x,y,buttons,focus,valuators,valinfo] = GetMouse;
    fprintf('\n%i/%i, %i/%i/%i',x,y,buttons);
    if sum(buttons)
        if ~isclicked
            cc = cc+1;
            clicktimes(cc) = GetSecs;
            clickrect(cc,:) = [x,y];
        end
        isclicked = 1;
    else
        isclicked = 0;
    end
end