%test svm use now on fischer flower data 
addpath '/data2/2020_ActDecode_Cueing/analysis/Scripts/Test_SVM'
%use AD SVM 
load fisheriris
inds = ~strcmp(species,'setosa');
X = meas(inds,3:4);
y = species(inds);

%convert y to number 
y2 = zeros(length(y),1);
y2(contains(y,'virginica'))=2;
y2(contains(y,'versicolor'))=1;


%generate random index from 1 to 10 
tmpind = repmat(1:10,1,10);
%randomly shuffle this tmp ind 
run = tmpind(randperm(length(tmpind)));

ROIBeta = horzcat(X,run',y2);

%test simple one 
[OutAccuracy,OutLabels,OutCost] = AD_svm(ROIBeta,'all');
%then test high-dimensional data with action decode data 
%verified, the algorithm works. looks for maybe high-dimensional data? 

Main_AD_SVM({'hMT_RH','pSTS_RH'},'all','Task_oldAD')

%can't use the AD_svm cause it's classification depending on the run 

%use model by itself 
Main_AD_SVM({'hMT_RH','pSTS_RH'},'avgRun','Task_oldAD_AvgRun')
