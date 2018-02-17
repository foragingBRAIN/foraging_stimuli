
%% pomdp_onebutton_matrix
%
% Three buttons experiment for POMDP framework
%
% Baptiste Caziot, Sept 2017


clear all;
close all;


platform = 0;   % 0=mbp/mbp 1=otherplatform

switch platform
    case 0
        cd('/Users/baptiste/Documents/MATLAB/pomdp/pomdp_threebuttons/pomdp_threebuttons_canon_v01/');
    case 1
        cd('experimentfolderdirectory');
end

% get subject name
while 1
    subjectName = input('\nSubject Name? ', 's');
    if isempty(regexp(subjectName, '[/\*:?"<>|]', 'once'))
        break
    else
        fprintf('\nInvalid subject name!');
    end
end

% set experiment up
W = pomdp_threebuttons_canon_screen(platform);      % open PTB window

K = pomdp_threebuttons_canon_keys(platform);    	% set up keys

E = pomdp_threebuttons_canon_setup(W);          	% set up experimental design

L = pomdp_threebuttons_canon_clut(W,E);           	% generate color lookup table

A = pomdp_threebuttons_canon_audio(platform);    	% open psychportaudio

R = pomdp_threebuttons_canon_header(subjectName); 	% create data text file


ListenChar(2);
clc;


if strcmp(R.subjectName,'robot')
    
end


R.timeStart = GetSecs;


for bb=1:E.nCond
    
    % display messages    
    pomdp_threebuttons_canon_messages(W,E,bb);
    fprintf('\n%s\n', R.header);
    
    % display trial
    if ~strcmp(R.subjectName,'robot')
        [E,R] = pomdp_threebuttons_canon_trial(W,L,A,K,E,R,bb);
    else

    end
    
    textLine = pomdp_threebuttons_canon_write(E,R,bb);
    fprintf(textLine);
    
end


R.timeStop = GetSecs;

save(R.fileName);

fclose(R.fid);

pomdp_threebuttons_canon_messages(W,E,0);

fprintf('\n\nTime total: %i min', round((R.timeStop-R.timeStart)/60));

LoadIdentityClut(W.n);

Screen('CloseAll');

ListenChar(0);


