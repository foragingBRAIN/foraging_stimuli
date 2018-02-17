

clear all;
close all;
clc;



cd('/Users/baptiste/Documents/MATLAB/pomdp/pomdp_onebutton/pomdp_onebutton_matrix_v01/');



fileList = {
    'pomdp_onebutton_matrix_test_16-7-2017_18-38-21'
};

nSub = length(fileList);

rtmax = 20;

for su=1:nSub
    
    load(sprintf('%s/data/%s',cd,fileList{su}));
    
    currCond = 0;
    for rr=1:length(E.stimRate)
        for cc=1:length(E.stimCost)
            currCond = currCond+1;
            bb = find((E.rateList==rr)&(E.costList==cc));
            
            rtMean(rr,cc) = median(R.clickDelay{bb});
            
            figure(1)
            subplot(length(E.stimRate),length(E.stimCost),currCond)
            hist(R.clickDelay{bb},linspace(0,rtmax,11))
            axis([0,rtmax,0,20])
        end
    end
    
    figure(2)
    subplot(1,3,1)
    plot(E.stimRate,mean(rtMean,2))
    subplot(1,3,2)
    plot(E.stimCost,mean(rtMean,1))
    subplot(1,3,3)
    plot(E.stimRate,rtMean')
    legend({'0','-1','-2','-4'})
    
end

