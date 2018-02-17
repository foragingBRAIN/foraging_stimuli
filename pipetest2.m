


pipedir = '\\Spike2\Data\pipe\';

txtformat = 'SCENE%i_FG_COLOR %i %i %i\n';


while 1
   
    if exist(sprintf('%smoogpipe.txt',pipedir),'file')
        fid = fopen(sprintf('%smoogpipe.txt',pipedir));
        vec = reshape(fscanf(fid,txtformat),4,3);
        fclose(fid);
    end
    
    if KbCheck
        break;
    end
    
end