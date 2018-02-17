

function ss = fitgammafunction(param,data)
    
    % compute sum of squares 
    % data must be normalized (all between 0 and 1)
    
    input = data(:,1);
    
    estimate = gammafun(param(1),param(2),input);
    
    response = data(:,2);
    
    ss = sum((response-estimate).^2);
    
end


