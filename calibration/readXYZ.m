
function [XYZ,Yxy] = readXYZ(device)

    switch device
        
        case 1
            
            [~,out] = system('spotread -e -x -O');
            i = strfind(out, 'Result is XYZ:');
            v = sscanf(out(i:end), 'Result is XYZ: %f %f %f, Yxy: %f %f %f');
            XYZ = v(1:3);
            Yxy = v(4:6);
            
    end

end