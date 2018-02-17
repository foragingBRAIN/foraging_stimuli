

function L = pomdp_threebuttons_canon_clut(W,E)

    colsat = 0.5; 	% saturation (ratio max gamut for this monitor)
    collum = 0.0;   % luminance in [-1,+1]
    
    % hue angle in equiluminance plane
    anglist = linspace(0,2*pi,E.stimNCol+1);
    anglist(end) = [];
    anglist = 3*pi/4-anglist;
    
    Xdkl = NaN(3,E.stimNCol);
    Xrgb = NaN(3,E.stimNCol);
    
    for aa=1:E.stimNCol
        
        % coordinates in DKL space
        Xdkl(:,aa) = [collum,colsat*cos(anglist(aa)),colsat*sin(anglist(aa))]';
        % convert to RGB from calibration matrix
        Xrgb(:,aa) = 0.5+0.5*W.dkl2rgb*Xdkl(:,aa);
        
    end

    L.Xdkl = Xdkl;
    L.Xrgb = Xrgb;
    
end