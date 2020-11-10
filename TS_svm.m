function [OutAccuracy,OutLabels,OutCost] = TS_svm(ROIBeta,method)
%this function require ROIBeta to be: one ROI all beta from 1:end-2 column
%and end-1 is run labels, end is labels for classification in number 
tic;
naind = isnan(ROIBeta(:,1));
ROIBeta = ROIBeta(~naind,:);
addpath '/data2/2019_ToneScramble/scripts/'
switch method
    case 'avgRun'
        %needs average within run and save the results back to ROIBeta 
       ROIBeta = AverageRun(ROIBeta);
       X = ROIBeta(:,1:(end-2));
       y = cellstr(num2str(ROIBeta(:,end)));
        
    case 'all'
        X = ROIBeta(:,1:(end-2));
        y = cellstr(num2str(ROIBeta(:,end)));
end

%final lasttwo column is [Vox Run TaskInd] 
%use the run to split training and testing and use TaskInd as
%classification labels 

%next task, use cross validation to test out these three models, 1)svm,
%2)with tunning of hyperparameters 3)fitclinear 
%then choose the best performance one

%Specify output matrices 
RunLabels = unique(ROIBeta(:,end-1));
nRun = length(unique(ROIBeta(:,end-1)));
nTrials = size(X,1);
OutAccuracy = zeros(nRun,3);
OutLabels = zeros(nTrials,3); %[numberofTrials/Beta numberOfRun
%3models] can't really do this becasue of number trials might not be the
%same within each run therefore doesn't now how much it has. 
OutCost = zeros(nRun,2,3);

%Partitioning the data into six runs
testind = zeros(nTrials,nRun);%1 or zero index
trainind = zeros(nTrials,nRun);

for run = 1:nRun
    clabel = RunLabels(run);
    cind = ROIBeta(:,end-1) == clabel;
    testind(cind,run) = 1;
    trainind(~cind,run) = 1;
end

testind = logical(testind);
trainind = logical(trainind);


%CV based on leave one run out 
for i=1:nRun
    
    Xtrain = X(trainind(:,i),:);
    ytrain = y(trainind(:,i),:);
    Xtest = X(testind(:,i),:);
    ytest = y(testind(:,i),:);
    
    %first model
    %fit svm with cost =1
    SVM1 = fitcsvm(Xtrain,ytrain);
    %fit it back get accuracy 
    [labels1,~,~] = predict(SVM1,Xtest);
    %this is the classification accuracy 
    OutAccuracy(i,1) =sum(strcmp(labels1, ytest))/size(labels1,1);
    OutLabels(testind(:,i),1) = str2double(labels1);
    OutCost(i,1,1) = SVM1.Cost(1,2);
    OutCost(i,2,1) = SVM1.Cost(2,1);
    
    %second model with hyperparameter tuning 
    params = hyperparameters('fitcsvm',Xtrain,ytrain);
    SVMModel2 = fitcsvm(Xtrain,ytrain,'OptimizeHyperparameters',params,'HyperparameterOptimizationOptions',struct('Verbose',0,'ShowPlots',false));
    [labels2,~,~] = predict(SVMModel2,Xtest);
    OutAccuracy(i,2) =sum(strcmp(labels2, ytest))/size(labels2,1);
    OutLabels(testind(:,i),2) = str2double(labels2);
    OutCost(i,1,2) = SVMModel2.Cost(1,2);
    OutCost(i,2,2) = SVMModel2.Cost(2,1);
    
    %Third model fitclinear 
    %nees to remove NaN from the model, already did in the beginning 
    [SVMlinear3,~] = fitclinear(Xtrain,ytrain);
    labels3 = predict(SVMlinear3,Xtest);
    OutAccuracy(i,3) = sum(strcmp(labels3, ytest))/size(labels3,1);
    OutLabels(testind(:,i),3) = str2double(labels3);
    OutCost(i,1,3) = SVMlinear3.Cost(1,2);
    OutCost(i,2,3) = SVMlinear3.Cost(2,1);
end

time = toc;
fprintf('%d minutes and %f seconds\n', floor(time/60), rem(time,60));
end