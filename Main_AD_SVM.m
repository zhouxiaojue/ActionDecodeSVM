function Main_AD_SVM(ROI,method,outTXTsuffix)
%method: 'avgRun','all'
%event: 'movie','cue'
%DGSR: 'WGSR' 'WOGSR'
%CueNuis: 'asNuis' or ''

%Future, change ROI as input, more input for more control 
addpath '/data2/2020_ActDecode_Cueing/analysis/Scripts/Test_SVM/'

SublistTxt = '/data2/2020_ActDecode_Cueing/analysis/2018_ActDecode_sublist.txt';
ROIBetaPath = '/data2/2020_ActDecode_Cueing/analysis/test_ActBeta/';

outFileDir = '/data2/2020_ActDecode_Cueing/analysis/SVMResults/';
fileID = fopen (SublistTxt,'r');
file = textscan(fileID,'%q');
subList = file{1};
fclose(fileID);
NumSubs = length(subList);
%load in Beta data matrix 

outFileMatName = strcat(outFileDir,outTXTsuffix,'_',method,'_AllRestuls.mat');
if exist(outFileMatName,'File')
    disp(['already saved' outFileMatName])
    load(outFileMatName);
else
    AllResults.Accuracy = cell(3,length(ROI),NumSubs); %one for each condition, separate in
    %if the run are different across subjects, saving it in a cell array is
    %better to analyze in the future 
    AllResults.Labels = cell(3,length(ROI),NumSubs);
     for sub = 1:NumSubs
        subID = char(subList(sub));
        subID

        %Here, organize data here 
        InBeta = load(strcat(ROIBetaPath,subID,...
            '_voi-rh-cba_event-precue-movie_nuis-none_clean-censoredFD-GSR_model-LSS_hrf-custom_betacoefs.mat'));
        InBeta = InBeta.betaData;
            
        %setup output results structure 
        for r= 1:length(ROI)
            croi = char(ROI(r));

            roiInd = contains(cellstr(InBeta.ROIlist.labels),croi);
            %called betaData
            nRun = size(InBeta.betaCoefs.stim{roiInd}, 3);
            nTrials = size(InBeta.betaCoefs.stim{roiInd}, 1);
            nVox = size(InBeta.betaCoefs.stim{roiInd}, 2);
            ROIBeta = zeros(nTrials*nRun/3,nVox+2,3);
            %ROIBeta: (run * nTrials) X (Voxels, Run, Labels)
            
            for indins = 1:3
                for run = 1:nRun
                    indStart = 1+ (run-1)*nTrials/3;
                    indEnd = nTrials/3 + (run-1)*nTrials/3;
                    meanBeta = mean(InBeta.betaCoefs.stim{roiInd}(:,:,run),1);
                    tmpBeta = InBeta.betaCoefs.stim{roiInd}(:,:,run) - repmat(meanBeta,size(InBeta.betaCoefs.stim{roiInd}(:,:,run),1),1);
                    
                    ROIBeta(indStart:indEnd,1:nVox,indins) = tmpBeta(InBeta.stimLabels.instruction{run}==indins,:);
                    ROIBeta(indStart:indEnd,end-1,indins) = ones(nTrials/3,1)*run;

                    tmpLabels = InBeta.stimLabels.action{run};
                    ROIBeta(indStart:indEnd,end,indins) = tmpLabels(InBeta.stimLabels.instruction{run}==indins);
                    %needs to filter out data only during attending to action
                    %trials


                end

                OutAccuracy = AD_svm(ROIBeta(:,:,indins),method);
                AllResults.Accuracy{indins,r,sub} = OutAccuracy;
            end
            

        end
    end

    %save results as .mat file onto disk
    %average and save th results as .mat 
    AvgAccuracy = zeros(NumSubs,3,length(ROI));
    for r=1:length(ROI)
        for sub = 1:NumSubs
            for indins = 1:3
                AvgAccuracy(sub,indins,r) = mean(AllResults.Accuracy{indins,r,sub},1);
            end
        end
    end

    AllResults.AvgAccuracy = AvgAccuracy;
    AllResults.ROIlist = ROI;
    save(strcat(outFileDir,outTXTsuffix,'_AllRestuls.mat'),'AllResults');

end


%save output to txt file for plotting in r


outFileName = strcat('All_svm_accuracy_',outTXTsuffix,'.txt');
%put all accuracies across all ROIs into one txt file here 
%Accuracy subID taskins ROI 
if ~exist(strcat(outFileDir,outFileName),'file')
    subIDlist = 1:size(AllResults.AvgAccuracy,1);
    OutTXTAccuracy = zeros(length(subIDlist)*length(ROI)*3,4);
    cind = 0;
    for sub = 1:NumSubs
        for r= 1:length(ROI)
            for indins = 1:3
                cind = cind +1;
                OutTXTAccuracy(cind,1) = AllResults.AvgAccuracy(sub,indins,r);
                OutTXTAccuracy(cind,2) = sub;
                OutTXTAccuracy(cind,3) = indins;
                OutTXTAccuracy(cind,4) = r;
            end
        end
    end
    
    header = {'Accuracy';'subID';'TaskInd';'ROI'}';
    fid = fopen(fullfile(outFileDir,outFileName),'wt');
    fprintf(fid,'%s\t',header{1:end-1});
    fprintf(fid,'%s\n',header{end});
    fclose(fid);    
    dlmwrite(fullfile(outFileDir,outFileName),OutTXTAccuracy,'delimiter','\t','-append')
else
    disp(['already saved' strcat(outFileDir,outFileName)])
end 


end