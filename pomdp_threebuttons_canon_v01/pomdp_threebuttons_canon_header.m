

function R = pomdp_threebuttons_canon_header(subjectName)

    
    
    
    time = clock;   % [year,month,day,hour,minute,seconds]
    
    
    R.subjectName = subjectName;
    R.fileName = sprintf('%s/data/pomdp_threebuttons_canon_%s_%i-%i-%i_%i-%i-%i', cd, subjectName, time(3), time(2), time(1), time(4), time(5), round(time(6)));
    
    R.fid = fopen(sprintf('%s.dat',R.fileName),'w');

    
    R.header = sprintf('%s\t','block');
    
end