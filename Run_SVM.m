%method: 'avgRun','all'
%event: 'movie','cue'
%DGSR: 'WGSR' 'WOGSR'
%CueNuis: 'asNuis' or ''
ROI = {'hMT_LH','hMT_RH'};

DGSR = 'WGSR';
method = 'all';
CueNuis = '';
outTXTsuffix = '1103';
event = 'movie';
Main_TS_SVM(ROI,method,event,DGSR,CueNuis,outTXTsuffix)

DGSR = 'WOGSR';
method = 'all';
CueNuis = '';
outTXTsuffix = '1103';
event = 'movie';
Main_TS_SVM(ROI,method,event,DGSR,CueNuis,outTXTsuffix)

DGSR = 'WOGSR';
method = 'all';
CueNuis = 'asNuis';
outTXTsuffix = '1103';
event = 'movie';
Main_TS_SVM(ROI,method,event,DGSR,CueNuis,outTXTsuffix)

DGSR = 'WGSR';
method = 'all';
CueNuis = 'asNuis';
outTXTsuffix = '1103';
event = 'movie';
Main_TS_SVM(ROI,method,event,DGSR,CueNuis,outTXTsuffix)


DGSR = 'WGSR';
method = 'avgRun';
CueNuis = '';
outTXTsuffix = '1103';
event = 'movie';
Main_TS_SVM(ROI,method,event,DGSR,CueNuis,outTXTsuffix)

DGSR = 'WOGSR';
method = 'avgRun';
CueNuis = '';
outTXTsuffix = '1103';
event = 'movie';
Main_TS_SVM(ROI,method,event,DGSR,CueNuis,outTXTsuffix)

DGSR = 'WOGSR';
method = 'avgRun';
CueNuis = 'asNuis';
outTXTsuffix = '1103';
event = 'movie';
Main_TS_SVM(ROI,method,event,DGSR,CueNuis,outTXTsuffix)

DGSR = 'WGSR';
method = 'avgRun';
CueNuis = 'asNuis';
outTXTsuffix = '1103';
event = 'movie';
Main_TS_SVM(ROI,method,event,DGSR,CueNuis,outTXTsuffix)


