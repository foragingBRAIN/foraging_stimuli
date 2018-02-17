

function L = foraging_clut
    
    
    %% calibration values
    delta = 6/29;
    
    fitparam = [0.6748, 21.8418, 9.1180];
    rx = 0.5273; ry = 0.2997; rz = 0.1729;
    gx = 0.3233; gy = 0.5959; gz = 0.0809;
    bx = 0.1521; by = 0.0694; bz = 0.7786;
    wXYZ = [37.3279, 36.9788, 69.0775];

    %% Lab to XYZ
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
    
    
    %% equisaturation circle
    npoints = 1000;
    colsat = 25;                % saturation (ratio max gamut for this monitor)
    collum = 100;               % fraction luminance at 45deg viewing angle
    anglist = linspace(0,2*pi,npoints);
    Labmat = [collum*ones(npoints,1),colsat.*cos(anglist'),colsat.*sin(anglist')];
    XYZmat = XYZconv(Labmat,repmat(wXYZ*(1-fitparam(1)),size(Labmat,1),1));
    RGBmat =  invM2*XYZmat';
    
    L.clutpoints = npoints;
    L.Xrgb = uint8(255*RGBmat);
    
end

