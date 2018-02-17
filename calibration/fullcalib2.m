

% clear and close all
clear all
close all


cenFun = 'mean';   % function to run on measures (median or mean);

nlum = 256;
nMeasures = 50;
ntest = 256;
ndemo = 51;
afterflippause = 0.1;
warmup = 1*60/afterflippause;
colvec = 'rgb';

pause(1);

% default CLUT
defaultCLUT = repmat(linspace(0,1,256)',1,3);


Screen('Preference', 'SkipSyncTests', 1);
w = Screen('OpenWindow', 4, 0);
% w = Screen('OpenWindow', 1, 0, [1420,580,1920,1080]);
firstLUT = Screen('ReadNormalizedGammaTable',w);
LoadIdentityClut(w);


lumlist = linspace(0,255,nlum)';

lumvalXYZ = NaN(nlum,3,nMeasures,3);



for ll=1:nlum
    
    for cc=1:3
        
        % display field
        Screen('FillRect', w, lumlist(ll)*((1:3)==cc));
        Screen('Flip', w, 0);

        pause(afterflippause);
        
        for mm=1:nMeasures
            fprintf('\nLuminance %i/%i - Channel %i/%i - Measure %i/%i', ll, nlum, cc, 3, mm, nMeasures);
            
            % send measure command
%             fprintf('\nSend measure command...');

            [XYZ,Yxy] = readXYZ(1);
            lumvalXYZ(ll,cc,mm,:) = XYZ;
            lumvalYxy(ll,cc,mm,:) = Yxy;
                
            fprintf(' - Received: %2.2f, %2.2f, %2.2f', lumvalYxy(ll,cc,mm,:));
            
            [~,~,keyCode] = KbCheck;
            if keyCode(KbName('esc'))
                Screen('CloseAll');
                error('Interrupted by user');
            end
            
            figure(1)
            hold on
            plot(ll,mean(lumvalYxy(ll,cc,:,1)),sprintf('%so',colvec(cc)))
            
        end
        
        
        
    end
        
end

fprintf('\nEnd measures');

save('fullcalibtemp');

cenLum = squeeze(feval(cenFun, lumvalYxy(:,:,:,1), 3));
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


fprintf('\nCheck linearity\n\n');
pause(1);


testlist = linspace(0,255,ntest)';
    
testvalXYZ = NaN(ntest,3,3);
testvalYxy = NaN(ntest,3,3);
for tt=1:ntest
    
    for cc=1:3
        
        % display field
        Screen('FillRect', w, testlist(tt)*((1:3)==cc));
        Screen('Flip', w, 0);
        
        fprintf('\nTest %i/%i - Channel %i/%i', tt, ntest, cc, 3);
        
        [XYZ,Yxy] = readXYZ(1);
        testvalXYZ(tt,cc,:) = XYZ;
        testvalYxy(tt,cc,:) = Yxy;

        fprintf(' - Received: %2.2f, %2.2f, %2.2f', testvalYxy(tt,cc,:));
    	
        [~,~,keyCode] = KbCheck;
        if keyCode(KbName('esc'))
            Screen('CloseAll');
            error('Interrupted by user');
        end

    end
        
end



minTest = repmat(min(testvalYxy(:,:,1)),ntest,1);
maxTest = repmat(max(testvalYxy(:,:,1)),ntest,1);
normTest = (testvalYxy(:,:,1)-minTest)./(maxTest-minTest);

figure(1)
hold on
for cc=1:3
    plot(testlist/255,normTest(:,cc),['o',colvec(cc)])
    plot(testlist/255,polyval(polyfit(testlist/255,normTest(:,cc),1),testlist/255),[':',colvec(cc)])
end



%% now conversion matrices between different color spaces are computed


% open port
fprintf('\nCompute conversion matrices\n\n');
pause(1);

maxvalXYZ = NaN(3,3);
maxvalYxy = NaN(3,3);
for cc=1:3
    
    % display field
    Screen('FillRect', w, 255*((1:3)==cc));
    Screen('Flip', w, 0);
    
    fprintf('\nGet max value channel %i/%i', cc, 3);
   
    [XYZ,Yxy] = readXYZ(1);
    maxvalXYZ(cc,:) = XYZ;
    maxvalYxy(cc,:) = Yxy;

    fprintf(' - Received: %2.2f, %2.2f, %2.2f', maxvalYxy(cc,:));
    
end

maxvalYxy2(:,1) = maxvalXYZ(:,2);
maxvalYxy2(:,2) = maxvalXYZ(:,1)./sum(maxvalXYZ(:,1),2);
maxvalYxy2(:,3) = maxvalXYZ(:,2)./sum(maxvalXYZ(:,1),2);
fprintf('\nOriginal Yxy:\n%2.2f',maxvalYxy);
fprintf('\nRecovered Yxy:\n%2.2f',maxvalYxy2);

% First are needed the 3 Yxy values for max values on the 3 color guns.
rx = maxvalYxy(1,2);%0.673; % x coordinate of red gun at maximum value in Yxy space
ry = maxvalYxy(1,3);%0.326; % y coordinate of red gun at maximum value in Yxy space
rz = 1-rx-ry;
gx = maxvalYxy(2,2);%0.186; % x coordinate of green gun at maximum value in Yxy space
gy = maxvalYxy(2,3);%0.722; % y coordinate of green gun at maximum value in Yxy space
gz = 1-gx-gy;
bx = maxvalYxy(3,2);%0.143; % x coordinate of blue gun at maximum value in Yxy space
by = maxvalYxy(3,3);%0.047; % y coordinate of blue gun at maximum value in Yxy space
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
white(1) = maxvalYxy(1,1);%33.3; % red gun maximum luminance
white(2) = maxvalYxy(2,1);%77.0; % green gun maximum luminance
white(3) = maxvalYxy(3,1);%7.73; % blue gun maximum luminance

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

ldlist = linspace(-1,+1,ndemo);
rglist = linspace(-1,+1,ndemo);
yvlist = linspace(-1,+1,ndemo);


% open port
fprintf('\nCheck color space\n\n');
pause(1);

democol = NaN(ndemo,3,3);
demovalXYZ = NaN(ndemo,3,3);
demovalYxy = NaN(ndemo,3,3);

for cc=1:ndemo
    
	fprintf('\nL+M+S %i/%i', cc, ndemo);
    
    democol(cc,:,1) = ldrgyv2rgb(ldlist(cc),0,0,dkl2rgb);
    
    Screen('FillRect', w, 255*democol(cc,:,1))
    Screen('Flip', w);
    
    [XYZ,Yxy] = readXYZ(1);
    demovalXYZ(cc,1,:) = XYZ;
    demovalYxy(cc,1,:) = Yxy;

    fprintf(' - Received: %2.2f, %2.2f, %2.2f', demovalYxy(cc,1,:));
    
end

for cc=1:ndemo
    
    fprintf('\nL-M %i/%i', cc, ndemo);
    
    democol(cc,:,2) = ldrgyv2rgb(0,rglist(cc),0,dkl2rgb);
    
    Screen('FillRect', w, 255*democol(cc,:,2))
    Screen('Flip', w);
    
    [XYZ,Yxy] = readXYZ(1);
    demovalXYZ(cc,2,:) = XYZ;
    demovalYxy(cc,2,:) = Yxy;

    fprintf(' - Received: %2.2f, %2.2f, %2.2f', demovalYxy(cc,2,:));
    
end


for cc=1:ndemo
    
    fprintf('\nL+M-S %i/%i', cc, ndemo);
    
    democol(cc,:,3) = ldrgyv2rgb(0,0,yvlist(cc),dkl2rgb);
    
    Screen('FillRect', w, 255*democol(cc,:,3))
    Screen('Flip', w);
    
    [XYZ,Yxy] = readXYZ(1);
    demovalXYZ(cc,3,:) = XYZ;
    demovalYxy(cc,3,:) = Yxy;

    fprintf(' - Received: %2.2f, %2.2f, %2.2f', demovalYxy(cc,3,:));
    
end

figure(2)
subplot(1,2,1)
plot(demovalYxy(:,:,1))
subplot(1,2,2)
plot(demovalYxy(:,:,2),demovalYxy(:,:,3))


%% reload default CLUT
fourthLUT = Screen('ReadNormalizedGammaTable', w);
LoadIdentityClut(w);
%Screen('LoadNormalizedGammaTable', w, defaultCLUT);
Screen('Flip', w);
pause(0.5);
fifthLUT = Screen('ReadNormalizedGammaTable', w);


save(sprintf('fullcalib_%s.mat',date),'CLUT','dkl2rgb','ldrgyv2rgb');

Screen('CloseAll');

fprintf('\nDone\n');


