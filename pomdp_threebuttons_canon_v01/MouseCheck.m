

function buttonPressed = MouseCheck

    [~,~,buttons] = GetMouse;
    buttonPressed = sum(buttons)>0;
    
end