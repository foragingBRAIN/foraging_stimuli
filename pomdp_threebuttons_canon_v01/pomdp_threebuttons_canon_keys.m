

function K = pomdp_threebuttons_canon_keys(platform)


    switch platform
        case 0
            K.left = KbName('LeftArrow');
            K.right = KbName('RightArrow');
            K.up = KbName('UpArrow');
            K.down = KbName('DownArrow');
            K.w = KbName('w');
            K.s = KbName('s');
            K.a = KbName('a');
            K.d = KbName('d');
            K.quit = KbName('ESCAPE');
        case 1
            K.left = KbName('left');
            K.right = KbName('right');
            K.up = KbName('up');
            K.down = KbName('down');
            K.w = KbName('w');
            K.s = KbName('s');
            K.a = KbName('a');
            K.d = KbName('d');
            K.quit = KbName('esc');
            
%%          for mac
%             K.left = KbName('LeftArrow');
%             K.right = KbName('RightArrow');
%             K.up = KbName('UpArrow');
%             K.down = KbName('DownArrow');
%             K.w = KbName('w');
%             K.s = KbName('s');
%             K.quit = KbName('ESCAPE');
%%          for windows
%             K.left = KbName('left');
%             K.right = KbName('right');
%             K.up = KbName('up');
%             K.down = KbName('down');
%             K.w = KbName('w');
%             K.s = KbName('s');
%             K.quit = KbName('esc');

    end


end