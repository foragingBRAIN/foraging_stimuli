


stimsize = [1800,1800,300]/2;
meancol = 128;
stdcol = 30;

beta = -2;

% generate pink noise texture
u = [(0:floor(stimsize(1)/2)) -(ceil(stimsize(1)/2)-1:-1:1)]'/stimsize(1);
u = repmat(u,1,stimsize(2));
v = [(0:floor(stimsize(2)/2)) -(ceil(stimsize(2)/2)-1:-1:1)]/stimsize(2);
v = repmat(v,stimsize(1),1);

S_f = (u.^2 + v.^2).^(beta/2); 
S_f(S_f==inf) = 0;


speedchange = 20;
k = sqrt(u.^2 + v.^2);
invk = exp(-k.*speedchange);
invk(isinf(invk)) = 0;

Sgray = NaN(stimsize);
Xgray = NaN(stimsize);

comptime = NaN(stimsize(3),1);
tic;

oldSpectrum = (randn([stimsize(1),stimsize(2)]) + 1i*randn([stimsize(1),stimsize(2)])) .* sqrt(S_f);

for ff=1:stimsize(3)
    
    fprintf('\nComputing..%i%%',ceil(100*ff/stimsize(3)));
    
    phi = rand([stimsize(1),stimsize(2)]);
    
    
    tempSpectrum = (randn([stimsize(1),stimsize(2)]) + 1i*randn([stimsize(1),stimsize(2)])) .* sqrt(S_f);
    newSpectrum = invk.*oldSpectrum + sqrt(1-invk.^2).*tempSpectrum;

    
    oldSpectrum = newSpectrum;
    
    Xgraytemp = ifft2(newSpectrum);
    Xgray(:,:,ff) = Xgraytemp;
    
    Sgray(:,:,ff) = newSpectrum;
    
    comptime(ff) = toc;
    
%     imagesc(real(Xgraytemp))
    
end


tic;
colmean = -0.25*pi;
colvar = 0.02;

Xgray = angle(Xgray + colvar*exp(1i*colmean));
toc;

nbins = 100;
histvec = NaN(nbins,stimsize(3));


writerObj = VideoWriter('brownian3D_bg','MPEG-4');
writerObj.FrameRate = 60;
open(writerObj);

for ff=1:stimsize(3)
    
    temp = Xgray(:,:,ff);
    [histvec(:,ff),binvec] = hist(temp(:),linspace(-pi,+pi,nbins));
    temp = (temp+pi)./(2*pi);
    
    I = repmat(temp,[1,1,3]);
    
    figure(21)
    image(I)
    axis equal
    
    fprintf('\nWriting avi file %i%%',ceil(100*ff/stimsize(3)));
    
    for fff=1:3
        writeVideo(writerObj,I);
    end
    
end

fprintf('\nDone\n');
close(writerObj);

figure(22)
plot3(repmat(binvec,stimsize(3),1)',repmat((1:stimsize(3))',1,nbins)',histvec')



%% XYZ to RGB

fitparam = [0.6748, 21.8418, 9.1180];
rx = 0.5273; ry = 0.2997; rz = 0.1729;
gx = 0.3233; gy = 0.5959; gz = 0.0809;
bx = 0.1521; by = 0.0694; bz = 0.7786;
wXYZ = [37.3279, 36.9788, 69.0775];

%% Lab to XYZ
delta = 6/29;

fLab2xyz = @(t) (t.^3).*(t>delta.^3) + ((t-4./29).*3.*delta.^2).*(t<=delta.^3);
Yconv = @(L,Yr) Yr.*fLab2xyz((L+16)./116);
Xconv = @(L,a,Xr) Xr.*fLab2xyz(+a./500+(L+16)./116);
Zconv = @(L,b,Zr) Zr.*fLab2xyz(-b./200+(L+16)./116);
XYZconv = @(Lab,refXYZ) [Xconv(Lab(:,1),Lab(:,2),refXYZ(:,1)), Yconv(Lab(:,1),refXYZ(:,2)), Zconv(Lab(:,1),Lab(:,3),refXYZ(:,3))];


%% XYZ to RGB

% RGB XYZ
rxyz = [rx;ry;rz];
gxyz = [gx;gy;gz];
bxyz = [bx;by;bz];

rXYZ = rxyz./ry;
gXYZ = gxyz./gy;
bXYZ = bxyz./by;

% reference point
wXYZ = wXYZ./wXYZ(2);

% conversion matrix
M1 = [rXYZ,gXYZ,bXYZ];
invM1 = inv(M1);

S = invM1*wXYZ';

M2 = M1*diag(S);
invM2 = inv(M2);


colsat = 25;                % saturation (ratio max gamut for this monitor)
collum = 100;               % fraction luminance at 45deg viewing angle

writerObj = VideoWriter('brownian3D_col','MPEG-4');
writerObj.FrameRate = 60;
open(writerObj);

I = NaN([stimsize(1),stimsize(2),3]);

for ff=1:stimsize(3)
    
    vec = Xgray(:,:,ff);
    Labmat = [collum*ones(prod(stimsize(1:2)),1),colsat*cos(vec(:)),colsat*sin(vec(:))];
    XYZmat = XYZconv(Labmat,repmat(wXYZ*(1-fitparam(1)),size(Labmat,1),1));
    RGBmat =  invM2*XYZmat';
    
    for cc=1:3
        I(:,:,cc) = reshape(RGBmat(cc,:),stimsize(1),stimsize(2));
    end
    
%     figure(21)
%     image(I)
%     axis equal
    
    fprintf('\nWriting avi file %i%%',ceil(100*ff/stimsize(3)));
    
    for fff=1:3
        writeVideo(writerObj,uint8(255*I));
    end
    
end


fprintf('\nDone\n');
close(writerObj);
