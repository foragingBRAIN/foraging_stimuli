

% clear and close all
clear all
close all

% make sure no serial port already open
for pp=1:length(instrfind)
    ports = instrfind;
    fclose(ports(pp));
    delete(ports(pp));
end

% set parameters
timeOut = 5;        % time to wait for response from photometer
pausebefore = 0.1;  % time to wait before sending command
pauseAfter = 0.1;   % time to wait after sending command
nMeasures = 1;      % number of measurements for each point
cenFun = 'mean';   % function to run on measures (median or mean);

nlum = 52;
ntest = 5;



% These functions are here to correct a bug in matlab's serial function.
evenparity7 = char((0:127)+128*mod(sum(dec2bin(0:127,7)-'0',2),2).');
makevenparity = @(S) evenparity7(S+1);
rmparity = @(S) char(double(S) - (double(S)>128)*128);

% open port for CS100A with usb adapter
CS100 = serial('/dev/tty.usbserial', 'BaudRate',4800, 'Parity','even',...
    'DataBits',7, 'StopBits',2, 'Terminator',10, 'Timeout',5);

pause(1);

% default CLUT
defaultCLUT = repmat(linspace(0,1,256)',1,3);


Screen('Preference', 'SkipSyncTests', 1);
w = Screen('OpenWindow', 1, 0);
firstLUT = Screen('ReadNormalizedGammaTable',w);
% Screen('LoadNormalizedGammaTable',w, defaultCLUT);
LoadIdentityClut(w);

lumlist = linspace(0,255,nlum)';

% open port
fprintf('\nOpen serial port\n\n');
fopen(CS100);
pause(1);


responseraw = cell(nlum,nMeasures,3);
response = cell(nlum,nMeasures,3);
tag = cell(nlum,nMeasures,3);
lumval = NaN(nlum,nMeasures,3,3);

for ll=1:nlum
    
    for cc=1:3
    
        % display field
        Screen('FillRect', w, lumlist(ll)*((1:3)==cc));
        Screen('Flip', w, 0);

        % wait before measurement
        pause(pausebefore);

        for mm=1:nMeasures
            fprintf('\nLuminance %i/%i - Channel %i/%i - Measure %i/%i', ll, nlum, cc, 3, mm, nMeasures);

            % send measure command
            fprintf('\nSend measure command...');
            fprintf(CS100,makevenparity(sprintf('MES\r\n')));

            % wait until bytes are available or timeOut
            t0 = GetSecs;
            while (~CS100.BytesAvailable)&&(GetSecs-t0<timeOut); end
            % if timeOut stop the script
            if (GetSecs-t0>timeOut)
                fclose(CS100);
                delete(CS100);
                Screen('CloseAll');
                error('Time out!');
            % else get the data
            else
                avail = CS100.BytesAvailable;
                fprintf('%i bytes available', avail);
                pause(pauseAfter);
                responseraw{ll,mm,cc} = fgets(CS100);
                response{ll,mm,cc} = rmparity(responseraw{ll,mm,cc});
                trimind = strfind(response{ll,mm,cc},char(13))-1;
                parsind = strfind(response{ll,mm,cc},',');
                tag{ll,mm,cc} = response{ll}(1:parsind(1)-1);
                lumval(ll,mm,cc,1) = str2double(response{ll,mm,cc}(parsind(1)+1:parsind(2)-1));
                lumval(ll,mm,cc,2) = str2double(response{ll,mm,cc}(parsind(2)+1:parsind(3)-1));
                lumval(ll,mm,cc,3) = str2double(response{ll,mm,cc}(parsind(3)+1:end));

                fprintf('\nReceived: %s', response{ll,mm,cc}(1:trimind));
            end
            
            
            [~,~,keyCode] = KbCheck;
            if keyCode(KbName('ESCAPE'))
                fclose(CS100);
                delete(CS100);
                Screen('CloseAll');
                error('Interrupted by user');
            end
            
            
        end
    
    end
        
end


% close port
fprintf('\nClose port');
fclose(CS100);


cenLum = squeeze(feval(cenFun, lumval(:,:,:,1), 2));
minIn = repmat(min(cenLum),nlum,1);
maxIn = repmat(max(cenLum),nlum,1);
normLum = (cenLum-minIn)./(maxIn-minIn);
normIn = lumlist/255;

colvec = 'rgb';
for cc=1:3
    x0 = [1,1];
    
    param(cc,:) = fminsearch('fitgammafunction', x0, [], [normIn,normLum(:,cc)]);
    
    gammaInv(:,cc) = (linspace(0,1,256).*param(cc,2)).^(1./param(cc,1))';
    
    figure(1)
    hold on
    plot(normIn,normLum(:,cc),['+',colvec(cc)])
    plot(normIn,(normIn./param(cc,2)).^param(cc,1),colvec(cc));
    plot(linspace(0,1,256),gammaInv(:,cc),['--',colvec(cc)]);
    axis([0,1,0,1])
    legend({'samples','fit','inverse gamma'})
end




%% now, check linearity
CLUT = gammaInv;
CLUT(CLUT>1) = 1;
secondLUT = Screen('ReadNormalizedGammaTable',w);
Screen('LoadNormalizedGammaTable', w, CLUT);
Screen('Flip', w);
pause(0.5);

thirdLUT = Screen('ReadNormalizedGammaTable',w);


% open port
fprintf('\nOpen serial port\n\n');
fopen(CS100);
pause(1);


testlist = linspace(0,255,ntest)';
    
testval = NaN(ntest,3,3);
for tt=1:ntest
    
    for cc=1:3
        
        % display field
        Screen('FillRect', w, testlist(tt)*((1:3)==cc));
        Screen('Flip', w, 0);
        
        % wait before measurement
        pause(pausebefore);
        
        fprintf('\nTest %i/%i - Channel %i/%i', tt, ntest, cc, 3);
        
        % send measure command
        fprintf('\nSend measure command...');
        fprintf(CS100,makevenparity(sprintf('MES\r\n')));
        
        % wait until bytes are available or timeOut
        t0 = GetSecs;
        while (~CS100.BytesAvailable)&&(GetSecs-t0<timeOut); end
        % if timeOut stop the script
        if (GetSecs-t0>timeOut)
            fclose(CS100);
            delete(CS100);
            Screen('CloseAll');
            error('Time out!');
        % else get the data
        else
            avail = CS100.BytesAvailable;
            fprintf('%i bytes available', avail);
            pause(pauseAfter);
            temp = fgets(CS100);
            temp = rmparity(temp);
            trimind = strfind(temp,char(13))-1;
            parsind = strfind(temp,',');
            
            testval(tt,cc,1) = str2double(temp(parsind(1)+1:parsind(2)-1));
            testval(tt,cc,2) = str2double(temp(parsind(2)+1:parsind(3)-1));
            testval(tt,cc,3) = str2double(temp(parsind(3)+1:end));

            fprintf('\nReceived: %s', temp(1:trimind));
        end
        

        [~,~,keyCode] = KbCheck;
        if keyCode(KbName('ESCAPE'))
            fclose(CS100);
            delete(CS100);
            Screen('CloseAll');
            error('Interrupted by user');
        end

    end
        
end


% close port
fprintf('\nClose port');
fclose(CS100);


minTest = repmat(min(testval(:,:,1)),ntest,1);
maxTest = repmat(max(testval(:,:,1)),ntest,1);
normTest = (testval(:,:,1)-minTest)./(maxTest-minTest);

figure(1)
hold on
for cc=1:3
    plot(testlist/255,normTest(:,cc),['o',colvec(cc)])
    plot(testlist/255,polyval(polyfit(testlist/255,normTest(:,cc),1),testlist/255),[':',colvec(cc)])
end



%% now conversion matrices between different color spaces are computed


% open port
fprintf('\nOpen serial port\n\n');
fopen(CS100);
pause(1);


maxval = NaN(3,3);

for cc=1:3
    
    % display field
    Screen('FillRect', w, 255*((1:3)==cc));
    Screen('Flip', w, 0);
    
    % wait before measurement
    pause(pausebefore);
    
    fprintf('\nGet max value channel %i/%i', cc, 3);
    
    % send measure command
    fprintf('\nSend measure command...');
    fprintf(CS100,makevenparity(sprintf('MES\r\n')));
    
    % wait until bytes are available or timeOut
    t0 = GetSecs;
    while (~CS100.BytesAvailable)&&(GetSecs-t0<timeOut); end
    % if timeOut stop the script
    if (GetSecs-t0>timeOut)
        fclose(CS100);
        delete(CS100);
        Screen('CloseAll');
        error('Time out!');
    % else get the data
    else
        avail = CS100.BytesAvailable;
        fprintf('%i bytes available', avail);
        pause(pauseAfter);
        temp = fgets(CS100);
        temp = rmparity(temp);
        trimind = strfind(temp,char(13))-1;
        parsind = strfind(temp,',');
        
        maxval(cc,1) = str2double(temp(parsind(1)+1:parsind(2)-1));
        maxval(cc,2) = str2double(temp(parsind(2)+1:parsind(3)-1));
        maxval(cc,3) = str2double(temp(parsind(3)+1:end));

        fprintf('\nReceived: %s', temp(1:trimind));
    end

end
        
% close port
fprintf('\nClose port');
fclose(CS100);

% First are needed the 3 Yxy values for max values on the 3 color guns.
rx = maxval(1,2);%0.673; % x coordinate of red gun at maximum value in xyY space
ry = maxval(1,3);%0.326; % y coordinate of red gun at maximum value in xyY space
rz = 1-rx-ry;
gx = maxval(2,2);%0.186; % x coordinate of green gun at maximum value in xyY space
gy = maxval(2,3);%0.722; % y coordinate of green gun at maximum value in xyY space
gz = 1-gx-gy;
bx = maxval(3,2);%0.143; % x coordinate of blue gun at maximum value in xyY space
by = maxval(3,3);%0.047; % y coordinate of blue gun at maximum value in xyY space
bz = 1-bx-by;

fprintf('\nMaximum CIE values:')
fprintf('\nRed\tx=%2.2f\ty=%2.2f\trz=%2.2f', rx, ry, rz);
fprintf('\nGreen\tx=%2.2f\ty=%2.2f\trz=%2.2f', gx, gy, gz);
fprintf('\nBlue\tx=%2.2f\ty=%2.2f\trz=%2.2f', bx, by, bz);

% then convert these values in LMS values from Smith-Pokorny estimates
cie2lms = [	+0.15514	+0.54316    -0.03286	;...
            -0.15514    +0.45684    +0.03286    ;...
            0           0           +0.01608    ];

Rlms = cie2lms*[rx;ry;rz];
Rnorm = Rlms./(Rlms(1)+Rlms(2));

Glms = cie2lms*[gx;gy;gz];
Gnorm = Glms./(Glms(1)+Glms(2));

Blms = cie2lms*[bx;by;bz];
Bnorm = Blms./(Blms(1)+Blms(2));

% this is just annoying matlab bullcrap that was probably written when the script was translated from C code to Matlab code a few years ago
% don't touch it
L(1) = Rnorm(1);
L(2) = Gnorm(1);
L(3) = Bnorm(1);
M(1) = Rnorm(2);
M(2) = Gnorm(2);
M(3) = Bnorm(2);
S(1) = Rnorm(3);
S(2) = Gnorm(3);
S(3) = Bnorm(3);

% these are the luminances of the three guns at their maximum values. DONT USE A SPECTROPHOTOMETER TO MEASURE THESE!, it will be inaccurate
% use a photometer to measure these, such as an OptiCAL.
white(1) = maxval(1,1);%33.3; % red gun maximum luminance
white(2) = maxval(2,1);%77.0; % green gun maximum luminance
white(3) = maxval(3,1);%7.73; % blue gun maximum luminance

gray = white/2; % this is the luminance of the mid-gray that the monitor can produce


solvex = @(a,b,c,d,e,f)	(a*f/d-b)/(c*f/d-e);
solvey = @(a,b,c,d,e,f)	(a*e/c-b)/(d*e/c-f);

disp('Red Green Axis');
deltaGrg = solvex(gray(1)*S(1), gray(1)*(L(1)+M(1)), S(2), S(3), L(2)+M(2), L(3)+M(3));
deltaBrg = solvey(gray(1)*S(1), gray(1)*(L(1)+M(1)), S(2), S(3), L(2)+M(2), L(3)+M(3));
dGrg     = -1*deltaGrg/gray(2);
dBrg     = -1*deltaBrg/gray(3);

disp('Blue Yellow Axis');
deltaRyv = solvex(gray(3)*L(3), gray(3)*M(3), L(1), L(2), M(1), M(2));
deltaGyv = solvey(gray(3)*L(3), gray(3)*M(3), L(1), L(2), M(1), M(2));
dRyv     = -1*deltaRyv/gray(1);
dGyv     = -1*deltaGyv/gray(2);

dkl2rgb = [	1	1       dRyv    ;...
            1   dGrg    dGyv    ;...
            1   dBrg    1       ];

ldrgyv2rgb = @(ld,rg,yv,matrix) matrix*[ld;rg;yv]/2.0 + 0.5;



%% Now we can test whether the conversion matrix works properly

ndemo = 11;

ldlist = linspace(-1,+1,ndemo);
rglist = linspace(-1,+1,ndemo);
yvlist = linspace(-1,+1,ndemo);


% open port
fprintf('\nOpen serial port\n\n');
fopen(CS100);
pause(1);

democol = NaN(ndemo,3,3);
demoval = NaN(ndemo,3,3);

for cc=1:ndemo
    
	fprintf('\nL+M+S %i/%i', cc, ndemo);
    
    democol(cc,:,1) = ldrgyv2rgb(ldlist(cc),0,0,dkl2rgb);
    
    Screen('FillRect', w, 255*democol(cc,:,1))
    Screen('Flip', w);
    
    % send measure command
    fprintf('\nSend measure command...');
    fprintf(CS100,makevenparity(sprintf('MES\r\n')));
    
    % wait until bytes are available or timeOut
    t0 = GetSecs;
    while (~CS100.BytesAvailable)&&(GetSecs-t0<timeOut); end
    % if timeOut stop the script
    if (GetSecs-t0>timeOut)
        fclose(CS100);
        delete(CS100);
        Screen('CloseAll');
        error('Time out!');
    % else get the data
    else
        avail = CS100.BytesAvailable;
        fprintf('%i bytes available', avail);
        pause(pauseAfter);
        temp = fgets(CS100);
        temp = rmparity(temp);
        trimind = strfind(temp,char(13))-1;
        parsind = strfind(temp,',');
        
        demoval(cc,1,1) = str2double(temp(parsind(1)+1:parsind(2)-1));
        demoval(cc,2,1) = str2double(temp(parsind(2)+1:parsind(3)-1));
        demoval(cc,3,1) = str2double(temp(parsind(3)+1:end));

        fprintf('\nReceived: %s', temp(1:trimind));
    end
    
end



for cc=1:ndemo
    
    fprintf('\nL-M %i/%i', cc, ndemo);
    
    democol(cc,:,2) = ldrgyv2rgb(0,rglist(cc),0,dkl2rgb);
    
    Screen('FillRect', w, 255*democol(cc,:,2))
    Screen('Flip', w);
    
    % send measure command
    fprintf('\nSend measure command...');
    fprintf(CS100,makevenparity(sprintf('MES\r\n')));
    
    % wait until bytes are available or timeOut
    t0 = GetSecs;
    while (~CS100.BytesAvailable)&&(GetSecs-t0<timeOut); end
    % if timeOut stop the script
    if (GetSecs-t0>timeOut)
        fclose(CS100);
        delete(CS100);
        Screen('CloseAll');
        error('Time out!');
    % else get the data
    else
        avail = CS100.BytesAvailable;
        fprintf('%i bytes available', avail);
        pause(pauseAfter);
        temp = fgets(CS100);
        temp = rmparity(temp);
        trimind = strfind(temp,char(13))-1;
        parsind = strfind(temp,',');
        
        demoval(cc,1,2) = str2double(temp(parsind(1)+1:parsind(2)-1));
        demoval(cc,2,2) = str2double(temp(parsind(2)+1:parsind(3)-1));
        demoval(cc,3,2) = str2double(temp(parsind(3)+1:end));

        fprintf('\nReceived: %s', temp(1:trimind));
    end
    
end


for cc=1:ndemo
    
    fprintf('\nL+M-S %i/%i', cc, ndemo);
    
    democol(cc,:,3) = ldrgyv2rgb(0,0,yvlist(cc),dkl2rgb);
    
    Screen('FillRect', w, 255*democol(cc,:,3))
    Screen('Flip', w);
    
    % send measure command
    fprintf('\nSend measure command...');
    fprintf(CS100,makevenparity(sprintf('MES\r\n')));
    
    % wait until bytes are available or timeOut
    t0 = GetSecs;
    while (~CS100.BytesAvailable)&&(GetSecs-t0<timeOut); end
    % if timeOut stop the script
    if (GetSecs-t0>timeOut)
        fclose(CS100);
        delete(CS100);
        Screen('CloseAll');
        error('Time out!');
    % else get the data
    else
        avail = CS100.BytesAvailable;
        fprintf('%i bytes available', avail);
        pause(pauseAfter);
        temp = fgets(CS100);
        temp = rmparity(temp);
        trimind = strfind(temp,char(13))-1;
        parsind = strfind(temp,',');
        
        demoval(cc,1,3) = str2double(temp(parsind(1)+1:parsind(2)-1));
        demoval(cc,2,3) = str2double(temp(parsind(2)+1:parsind(3)-1));
        demoval(cc,3,3) = str2double(temp(parsind(3)+1:end));

        fprintf('\nReceived: %s', temp(1:trimind));
    end
    
end

% close port
fprintf('\nClose port');
fclose(CS100);




%% reload default CLUT
fourthLUT = Screen('ReadNormalizedGammaTable', w);
LoadIdentityClut(w);
%Screen('LoadNormalizedGammaTable', w, defaultCLUT);
Screen('Flip', w);
pause(0.5);
fifthLUT = Screen('ReadNormalizedGammaTable', w);


% close everything
fprintf('\nClose port');
fclose(CS100);

fprintf('\nDestroy port');
delete(CS100);

Screen('CloseAll');

fprintf('\nDone\n');


