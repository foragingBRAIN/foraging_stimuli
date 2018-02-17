%calibration_phase3.m
%
%Minolta CS100A calibration script
%Characterize display luminance for inverse gamma correction
%determined via phase2 calibration

clear all;
close all;
AssertOpenGL;     %exit if obsolete version of PTB

%--------------------------------------------------------------------------
%Hardware dependent code:
%connect to Minolta CS100A photometer via COM1 port
status=openCS100A;
if(status ~= 0)
    disp('Program terminated: Unable to connect to CS100A meter.');
    return;
end
%--------------------------------------------------------------------------

%define configuration parameters
countdownDelay = 10;                %number of secs wait before measurements start
whichScreen=max(Screen('Screens')); %select secondary display (if available)
calSize=300;                        %size of square luminance target (pixels)

%build array of screen intensity values to be sampled [range:0-255]
indexValues=[0:1:255];
%build array to hold sampled luminance values
luminanceMeasurements=zeros(1,length(indexValues));

%load inverseCLUT created by calibration_phase2.m
load phase2_photometry

%prepare to take photometric measurements
try
   %open PTB full-screen window
   [window,mainRect]=Screen('OpenWindow',whichScreen);
   %upload inverse gamma function to video screen
   originalCLUT=Screen('LoadNormalizedGammaTable',window,inverseCLUT);
   %
   %set window background to GRAY
   Screen('FillRect',window,[128 128 128]);
   Screen('Flip',window);
   %remove mouse cursor from screen
   HideCursor;
   %select large text font
   Screen('TextSize',window,36);
   %determine screen center-of-gravity coordinates
   xcenter = round((mainRect(3)-mainRect(1))/2);
   ycenter = round((mainRect(4)-mainRect(2))/2);
   %determine size of calibration luminance target
   targetRect=zeros(1,4);
   targetRect(1)=round(xcenter-(calSize/2));
   targetRect(2)=round(ycenter-(calSize/2));
   targetRect(3)=round(xcenter+(calSize/2));
   targetRect(4)=round(ycenter+(calSize/2));
   %
   %display text prompt and photometer target on screen
   textMsg = 'Press any key to begin countdown to photometric measurements...';
   Screen('DrawText',window,textMsg,10,30,[1 1 1]);
   Screen('DrawText',window,'+',xcenter,ycenter,[0 0 0]);
   Screen('Flip',window);
   %wait for a key press
   keyDown=0;
   while(keyDown == 0)
       [keyDown,seconds,keyCode]=KbCheck;
   end
   %    
   %begin countdown on PTB3 screen
   Screen('TextSize',window,50);
   for(i=countdownDelay:-1:0)
       textMsg = num2str(i);
       Screen('DrawText',window,textMsg,xcenter,ycenter,[0 0 0]);
       Screen('Flip',window);
       WaitSecs(1);
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % measure luminance for each value in indexValues[] %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   xfeedback=mainRect(3)-100;
   yfeedback=mainRect(4)-80;
   for(i=1:length(indexValues))
       %update screen intensity level (2X to be sure)
       %feedback re: current state displayed at lower-right corner
       Screen('FillRect',window,indexValues(i),targetRect);
       Screen('DrawText',window,num2str(i),xfeedback,yfeedback,[0 0 0]);
       Screen('Flip',window);
       Screen('FillRect',window,indexValues(i),targetRect);
       Screen('DrawText',window,num2str(i),xfeedback,yfeedback,[0 0 0]);
       Screen('Flip',window);
       %
       WaitSecs(1); %delay 1 sec settling time
       %
       %-------------------------------------------------------------------
       %Hardware dependent code:
       %collect luminance measurement from compatible photometer
       [lum,xcie,ycie,status] = readCS100A;
       luminanceMeasurements(i) = lum;
       %-------------------------------------------------------------------
       %luminanceMeasurements(i) = i;  %dummy photometric reading
   end
   
catch
    Screen('CloseAll');
    ShowCursor;
end


%graceful exit from PTB mode
Screen('Close',window);
ShowCursor;

%--------------------------------------------------------------------------
%Hardware dependent code:
%disconnect CS100A photometer
closeCS100A;
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data to phase1_photometry.mat %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
indexValues3=indexValues;
luminanceMeasurements3=luminanceMeasurements;
save phase3_photometry.mat indexValues3 luminanceMeasurements3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot sampled luminance values for linear CLUT ramp %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1); clf;
plot(indexValues,luminanceMeasurements,'b-');
hold on;
xlabel('Pixel Values');
ylabel('Luminance (cd/m2)');
strTitle{1}='Sample Luminance Function';
strTitle{2}='Inverse Gamma Corrected CLUT';
title(strTitle);
axis([0 256 0 max(luminanceMeasurements)]);
axis('square');
hold off;
