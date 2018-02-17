

clear all
close all

for pp=1:length(instrfind)
    ports = instrfind;
    fclose(ports(pp));
    delete(ports(pp));
end


timeOut = 5;
pausebefore = 0.1;
pauseAfter = 0.1;


evenparity7 = char((0:127)+128*mod(sum(dec2bin(0:127,7)-'0',2),2).');
makevenparity = @(S) evenparity7(S+1);
rmparity = @(S) char(double(S) - (double(S)>128)*128);


CS100 = serial('/dev/tty.usbserial', 'BaudRate',4800, 'Parity','even',...
    'DataBits',7, 'StopBits',2, 'Terminator',10, 'Timeout',5);

pause(1);


%% compute color gamma 
% lumlist = 0:5:255;
% nlum = length(lumlist);
% collist = [...
%     lumlist,zeros(1,nlum),zeros(1,nlum);...
%     zeros(1,nlum),lumlist,zeros(1,nlum);...
%     zeros(1,nlum),zeros(1,nlum),lumlist];
% nmes = length(collist);
% 
% 
% Screen('Preference', 'SkipSyncTests', 1);
% w = Screen('OpenWindow', 1, 0);
% 
% pause(1);
% 

% 
% for pp=1:length(instrfind)
%     ports = instrfind;
%     fclose(ports(pp));
%     delete(ports(pp));
% end
% 

% 
% 
% responseraw = cell(nmes,1);
% response = cell(nmes,1);
% tag = cell(nmes,1);
% lumval = NaN(nmes,3);
% 
% for cc=1:nmes
% 
%     fprintf('\nLuminance %i/%i', cc, nmes);
%     
%     Screen('FillRect', w, collist(:,cc));
%     Screen('Flip', w, 0);
%     
%     fprintf('\nSend measure command');
%     fprintf(CS100,makevenparity(sprintf('MES\r\n')));
%     
%     t0 = GetSecs;
%     while (~CS100.BytesAvailable)&&(GetSecs-t0<timeOut); end
%     if (GetSecs-t0>timeOut)
%         Screen('CloseAll');
%         error('Time out!');
%     else
%         pause(pausebefore);
%         avail = CS100.BytesAvailable;
%         fprintf('\nBytes available: %i', avail);
%         responseraw{cc} = fgets(CS100);
%         response{cc} = rmparity(responseraw{cc});
%         
%         parsind = strfind(response{cc},',');
%         tag{cc} = response{cc}(1:parsind(1)-1);
%         lumval(cc,1) = str2double(response{cc}(parsind(1)+1:parsind(2)-1));
%         lumval(cc,2) = str2double(response{cc}(parsind(2)+1:parsind(3)-1));
%         lumval(cc,3) = str2double(response{cc}(parsind(3)+1:end));
%         
%         fprintf('\nReceived: %s', response{cc});
%     end
%     
%     pause(pauseAfter);
%     
% end
    



%% test inversegamma table
load('/Users/baptiste/Documents/MATLAB/toolboxes/CS100A/CLUT.mat');


Screen('Preference', 'SkipSyncTests', 1);
w = Screen('OpenWindow', 1, 0);
Screen('LoadNormalizedGammaTable', w, CLUT);
Screen('Flip', w);
loadedclut = Screen('ReadNormalizedGammaTable', w);

lumlist = 0:5:255;
nlum = length(lumlist);


fprintf('\nOpen serial port');
fopen(CS100);
pause(1);

responseraw = cell(nlum,1);
response = cell(nlum,1);
tag = cell(nlum,1);
lumval = NaN(nlum,3);

for cc=1:nlum

    fprintf('\nLuminance %i/%i', cc, nlum);
    
    Screen('FillRect', w, lumlist(cc));
    Screen('Flip', w, 0);
    
    fprintf('\nSend measure command');
    fprintf(CS100,makevenparity(sprintf('MES\r\n')));
    
    t0 = GetSecs;
    while (~CS100.BytesAvailable)&&(GetSecs-t0<timeOut); end
    if (GetSecs-t0>timeOut)
        Screen('CloseAll');
        error('Time out!');
    else
        pause(pausebefore);
        avail = CS100.BytesAvailable;
        fprintf('\nBytes available: %i', avail);
        responseraw{cc} = fgets(CS100);
        response{cc} = rmparity(responseraw{cc});
        
        parsind = strfind(response{cc},',');
        tag{cc} = response{cc}(1:parsind(1)-1);
        lumval(cc,1) = str2double(response{cc}(parsind(1)+1:parsind(2)-1));
        lumval(cc,2) = str2double(response{cc}(parsind(2)+1:parsind(3)-1));
        lumval(cc,3) = str2double(response{cc}(parsind(3)+1:end));
        
        fprintf('\nReceived: %s', response{cc});
    end
    
    pause(pauseAfter);
    
end






fprintf('\nClose port');
fclose(CS100);

fprintf('\nDestroy port');
delete(CS100);

Screen('CloseAll');

fprintf('\nDone\n');


