
function x = pipedisplay_noise(DIM,BETA)
    
    u = [(0:floor(DIM(1)/2)) -(ceil(DIM(1)/2)-1:-1:1)]'/DIM(1);
    u = repmat(u,1,DIM(2));
    
    v = [(0:floor(DIM(2)/2)) -(ceil(DIM(2)/2)-1:-1:1)]/DIM(2);
    v = repmat(v,DIM(1),1);
    
    % power spectrum
    S_f = (u.^2 + v.^2).^(BETA/2);
    S_f(S_f==inf) = 0;
    
    % phase spectrum
    phi = rand(DIM);
    
    % inverse FT
    x = ifft2(S_f.^0.5 .* (cos(2*pi*phi)+1i*sin(2*pi*phi)));
    x = real(x);
    
end
