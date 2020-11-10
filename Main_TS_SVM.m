function Main_TS_SVM(ROI,method,event,DGSR,CueNuis,outTXTsuffix)
%method: 'avgRun','all'
%event: 'movie','cue'
%DGSR: 'WGSR' 'WOGSR'
%CueNuis: 'asNuis' or ''

%Future, change ROI as input, more input for more control 
addpath '/data2/2020_ActDecode_Cueing/analysis/Scripts/'

SublistTxt = '/data2/2020_ActDecode_Cueing/analysis/2020ad_cue_sublist.txt';
ROIBetaPath = '/data2/2020_ActDecode_Cueing/analysis/Beta/';
switch DGSR
    case 'WGSR'
       ROIBetaPath = strcat(ROIBetaPath,'WGSR/');
    case 'WOGSR'
       ROIBetaPath = strcat(ROIBetaPath,'WOGSR/');
end
outFileDir = '/data2/2020_ActDecode_Cueing/analysis/SVMResults/';
fileID = fopen (SublistTxt,'r');
file = textscan(fileID,'%q');
subList = file{1};
fclose(fileID);
NumSubs = length(subList);
%load in Beta data matrix 

outFileMatName = strcat(outFileDir,outTXTsuffix,'_',method,'_',event,'_',CueNuis,'_',DGSR,'_AllRestuls.mat');
if exist(outFileMatName,'File')
    disp(['already saved' outFileMatName])
    load(outFileMatName);
else
    AllResults.Accuracy = cell(2,NumSubs); %one for LH one for RH, separate in
    %if the run are different across subjects, saving it in a cell array is
    %better to analyze in the future 
    AllResults.Labels = cell(2,NumSubs);
    AllResults.Cost = cell(2,NumSubs);

    %setup output results structure 
    for r= 1:length(ROI)
        croi = char(ROI(r));

        for sub = 1:NumSubs
            subID = char(subList(sub));
            subID

            ROIBeta = dlmread(strcat(ROIBetaPath,subID,'_',croi,'_',event,'_',CueNuis,'_',DGSR,'_allBeta.txt'), '\t', 1, 0);

            [OutAccuracy,OutLabels,OutCost] = TS_svm(ROIBeta,method);
            AllResults.Accuracy{r,sub} = OutAccuracy;
            AllResults.Labels{r,sub} = OutLabels;
            AllResults.Cost{r,sub} = OutCost;
        end
    end

    %save results as .mat file onto disk
    %average and save th results as .mat 
    AvgAccuracy = zeros(NumSubs,3,length(ROI));
    for r=1:length(ROI)
        for sub = 1:NumSubs
            AvgAccuracy(sub,:,r) = mean(AllResults.Accuracy{r,sub},1);
        end
    end


    AllResults.AvgAccuracy = AvgAccuracy;
    AllResults.ROIlist = ROI;
    save(strcat(outFileDir,outTXTsuffix,'_',event,'_',CueNuis,'_',DGSR,'_AllRestuls.mat'),'AllResults');

end


%save output to txt file for plotting in r


outFileName = strcat('All_svm_accuracy',outTXTsuffix,'_',method,'_',event,'_',CueNuis,'_',DGSR,'.txt');
%put all accuracies across all ROIs into one txt file here 

if ~exist(strcat(outFileDir,outFileName),'file')
    subIDlist = 1:size(AllResults.AvgAccuracy,1);
    OutTXTAccuracy = zeros(length(subIDlist)*length(ROI),5);
    for r= 1:length(ROI)
        croi = char(ROI(r));
        cindstart = 1+(r-1)*length(subIDlist);
        cindend = length(subIDlist) + (r-1)*length(subIDlist);
        OutTXTAccuracy(cindstart:cindend,1:3) = AllResults.AvgAccuracy(:,:,r);
        OutTXTAccuracy(cindstart:cindend,4) = subIDlist;
        OutTXTAccuracy(cindstart:cindend,5) = repmat(r,length(subIDlist),1);
    end
    
    header = {'SVM1';'SVMCost';'SVMlinear';'subID';'ROI'}';
    fid = fopen(fullfile(outFileDir,outFileName),'wt');
    fprintf(fid,'%s\t',header{1:end-1});
    fprintf(fid,'%s\n',header{end});
    fclose(fid);    
    dlmwrite(fullfile(outFileDir,outFileName),OutTXTAccuracy,'delimiter','\t','-append')
else
    disp(['already saved' strcat(outFileDir,outFileName)])
end 


end