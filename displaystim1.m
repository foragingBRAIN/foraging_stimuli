

%% pink noise texture params
% spatial spectrum
stimsize = [600,600];
beta = -2;

u = [(0:floor(stimsize(1)/2)) -(ceil(stimsize(1)/2)-1:-1:1)]'/stimsize(1);
u = repmat(u,1,stimsize(2));
v = [(0:floor(stimsize(2)/2)) -(ceil(stimsize(2)/2)-1:-1:1)]/stimsize(2);
v = repmat(v,stimsize(1),1);

S_f = (u.^2 + v.^2).^(beta/2); 
S_f(S_f==inf) = 0;

% temporal weighting
speedchange = 20;
k = sqrt(u.^2 + v.^2);
invk = exp(-k.*speedchange);
invk(isinf(invk)) = 0;


%% compute clut
L = foraging_clut;

try
	load('foraging_onebutton_calibration.mat')
    Screen('LoadNormalizedGammaTable', num, lutinv);
catch
    error('No calibration file found')
end


%% stim params
colvar = 0.02;
colmax = -3*pi/4;
colmin = 0;


compSpectrum = (randn(stimsize) + 1i*randn(stimsize)) .* sqrt(S_f);
I = NaN([stimsize,3]);

while 1
    
    colmean = colmin+lambda*(colmax-colmin);
    
    tempSpectrum = (randn(stimsize) + 1i*randn(stimsize)) .* sqrt(S_f);
    compSpectrum = invk.*compSpectrum + sqrt(1-invk.^2).*tempSpectrum;

    Xmat = ifft2(compSpectrum);
    Xmat = angle(Xmat + colvar*exp(1i*colmean));
    Xmat = 0.5.*Xmat./pi + (Xmat<=0);

    for cc=1:3
        I(:,:,cc) = reshape(L.Xrgb(cc,ceil(Xmat*L.clutpoints)),stimsize);
    end
    stimTex = Screen('MakeTexture', num, I);
    
end



