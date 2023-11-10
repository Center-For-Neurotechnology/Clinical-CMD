function [eegt]=eegt_analyses(eegt,task,analysis)
analyses_name={'Hpfilt_1','ChEpSel_2','SplitEpRej_3',...
    'RunICA_4','PostICA_5','Lpfilt_6','ReRef_PSD_7','SVM_8'};
if analysis<length(analyses_name)
    if isfield(eegt.tasks.(task).analyses,analyses_name{analysis+1})
        choice=questdlg('Do you want to continue? If Yes, all the analysys performed after this point will be deleted'...
            ,'Delete Analysis','Yes','No','No');
        switch choice
            case 'Yes'
                eegt = deleteAnalyses(eegt,task,analysis,analyses_name);
            case 'No'
                return
        end
    end
end
switch analysis
    case 1
        parameters=EEGtask_getParams;
        [EEG,parameters,check] = EEGtask_runHpFilt(eegt,task,parameters);
        if check; return; end
        eegt.tasks.(task).chanlocs=EEG.chanlocs;
        eegt.tasks.(task).analyses.(analyses_name{1}).filename=strcat('EEGtask_Hpfilt.dat');
        eegt.tasks.(task).analyses.(analyses_name{1}).parameters=parameters;
        [eegt] = saveDat(eegt,task,analyses_name{1},EEG,false);
        clear parameters
        
    case 2
        if ~isfield(eegt.tasks.(task).analyses,analyses_name{1})
            return
        end
        [eegt] = readDat(eegt,task,analyses_name{1},false,[]);
        
        [EEG,parameters] = EEGtask_runChEpSelection(eegt,task,analyses_name);
        
        eegt.tasks.(task).analyses.(analyses_name{1}).EEG.data=[];
        eegt.tasks.(task).analyses.(analyses_name{2}).parameters=parameters;
        EEG.data=[];
        eegt.tasks.(task).analyses.(analyses_name{2}).EEG=EEG;
        eegt.tasks.(task).analyses.(analyses_name{2}).DateOfCreation=datetime;
        save(fullfile(eegt.PathName,[eegt.FileName '.mat']),'eegt')
    
    case 3
        if ~isfield(eegt.tasks.(task).analyses,analyses_name{1}) &&...
                isfield(eegt.tasks.(task).analyses,analyses_name{2})
            return
        end
        [eegt] = readDat(eegt,task,analyses_name{1},false,[]);
        
        [EEG,parameters] = EEGtask_runRerefEpoching(eegt,task,analyses_name);
        
        eegt.tasks.(task).analyses.(analyses_name{1}).EEG.data=[];
        eegt.tasks.(task).analyses.(analyses_name{3}).filename=strcat('EEGtask_SplitEpRej.dat');
        eegt.tasks.(task).analyses.(analyses_name{3}).parameters=parameters;
        [eegt] = saveDat(eegt,task,analyses_name{3},EEG,false);
        clear parameters
        clear tmp
        
    case 4
        if ~isfield(eegt.tasks.(task).analyses,analyses_name{3})
            return
        end
        [eegt] = readDat(eegt,task,analyses_name{3},false,[]);
        
        [eegt,EEG,parameters]=EEGtask_runICA(eegt,task,analyses_name);
        
        eegt.tasks.(task).analyses.(analyses_name{3}).EEG.data=[];
        eegt.tasks.(task).analyses.(analyses_name{3}).EEG.icaact=[];
        eegt.tasks.(task).analyses.(analyses_name{4}).filename=strcat('EEGtask_ICA.dat');
        eegt.tasks.(task).analyses.(analyses_name{4}).parameters=parameters;
        
        [eegt] = saveDat(eegt,task,analyses_name{4},EEG,true);
        
    case 5
        if ~isfield(eegt.tasks.(task).analyses,analyses_name{4})
            return
        end
        [eegt] = readDat(eegt,task,analyses_name{4},true,analyses_name{3});
        
        [EEG,parameters] = EEGtask_selectICAcomponents(eegt,task,analyses_name);
        
        eegt.tasks.(task).analyses.(analyses_name{4}).EEG.data=[];
        eegt.tasks.(task).analyses.(analyses_name{4}).EEG.comp2remove = EEG.comp2remove;
        eegt.tasks.(task).analyses.(analyses_name{4}).parameters.ICA.comp2remove = EEG.comp2remove;
        eegt.tasks.(task).analyses.(analyses_name{5}).filename=strcat('EEGtask_PostICA.dat');
        eegt.tasks.(task).analyses.(analyses_name{5}).parameters=parameters;
        [eegt] = saveDat(eegt,task,analyses_name{5},EEG,false);
        
    case 6
        if ~isfield(eegt.tasks.(task).analyses,analyses_name{5})
            return
        end
        [eegt] = readDat(eegt,task,analyses_name{5},false,[]);
        [EEG,parameters] = EEGtask_runLpFilt(eegt,task,analyses_name);
        
        eegt.tasks.(task).analyses.(analyses_name{5}).EEG.data=[];
        eegt.tasks.(task).analyses.(analyses_name{6}).filename=strcat('EEGtask_Lpfilt.dat');
        eegt.tasks.(task).analyses.(analyses_name{6}).parameters=parameters;
        [eegt] = saveDat(eegt,task,analyses_name{6},EEG,false);
    case 7
        if ~isfield(eegt.tasks.(task).analyses,analyses_name{6})
            return
        end
        [eegt] = readDat(eegt,task,analyses_name{6},false,[]);

        [EEG, PSD, parameters] = EEGtask_runPSD(eegt,task,analyses_name);
        
        eegt.tasks.(task).analyses.(analyses_name{6}).EEG.data=[];
        eegt.tasks.(task).analyses.(analyses_name{7}).filename=strcat('EEGtask_ReRef.dat');
        eegt.tasks.(task).analyses.(analyses_name{7}).parameters=parameters;

        eegt.tasks.(task).analyses.(analyses_name{7}).PSDorig_filename=strcat('EEGtask_PSDorig.dat');
        eegt.tasks.(task).analyses.(analyses_name{7}).PSDscale_filename=strcat('EEGtask_PSDscale.dat');
        [eegt] = savePSD_Dat(eegt,task,analyses_name{7},PSD);
        
        [eegt] = saveDat(eegt,task,analyses_name{7},EEG,false);
        
    case 8
        if ~isfield(eegt.tasks.(task).analyses,analyses_name{7})
            return
        end
        [eegt] = readPSD_Dat(eegt,task,analyses_name{7});
        
        [parameters,checkrun] = EEGtask_runSVM(eegt,task,analyses_name);

        if checkrun
            eegt.tasks.(task).analyses.(analyses_name{7}).PSD.SScaleOrig=[];
            eegt.tasks.(task).analyses.(analyses_name{7}).PSD.SScale=[];
            eegt.tasks.(task).analyses.(analyses_name{8}).parameters=parameters;
            eegt.tasks.(task).analyses.(analyses_name{8}).DateOfCreation=datetime;
            save(fullfile(eegt.PathName,[eegt.FileName '.mat']),'eegt')
        end
        
end

if isfield(eegt.tasks.(task).analyses,analyses_name{analysis})
    if isfield(eegt.tasks.(task).analyses.(analyses_name{analysis}),'check')
        eegt.tasks.(task).analyses.(analyses_name{analysis}).check=...
            eegt.tasks.(task).analyses.(analyses_name{analysis}).check+1;
    else
        eegt.tasks.(task).analyses.(analyses_name{analysis}).check=1;
    end
end

function [eegt] = saveDat(eegt,task,analysis_name,EEG,icacheck)
h=waitbar(0,'Saving EEG .dat file...');

path_orig=cd;
cd(fullfile(eegt.PathName,'EEGtask',task))
fid=fopen(eegt.tasks.(task).analyses.(analysis_name).filename,'w');
if icacheck
    fwrite(fid,reshape(EEG.icaact,[size(EEG.icaact,1),size(EEG.icaact,2)*size(EEG.icaact,3)]),'double');
    EEG.icaact=[];
else
    fwrite(fid,reshape(EEG.data,[EEG.nbchan,EEG.pnts*EEG.trials]),'double');
end
fclose(fid);
EEG.data=[];
eegt.tasks.(task).analyses.(analysis_name).EEG=EEG;
eegt.tasks.(task).analyses.(analysis_name).DateOfCreation=datetime;
waitbar(1,h)

save(fullfile(eegt.PathName,[eegt.FileName '.mat']),'eegt')
cd(path_orig)
delete(h)
        
function [eegt] = readDat(eegt,task,analysis_name,icacheck,analysis_pre)
path_orig=cd;
cd(fullfile(eegt.PathName,'EEGtask',task))
EEG=eegt.tasks.(task).analyses.(analysis_name).EEG;
if icacheck
    fid=fopen(eegt.tasks.(task).analyses.(analysis_name).filename,'r');
    icadim=eegt.tasks.(task).analyses.(analysis_name).parameters.ICA.dim_icaact;
    tmpICA=fread(fid,[icadim(1),icadim(2)*icadim(3)],'double');
    fclose(fid);
    eegt.tasks.(task).analyses.(analysis_name).EEG.icaact=...
        reshape(tmpICA,[icadim(1),icadim(2),icadim(3)]);
end
if icacheck
    fid=fopen(eegt.tasks.(task).analyses.(analysis_pre).filename,'r');
else
    fid=fopen(eegt.tasks.(task).analyses.(analysis_name).filename,'r');
end
tmpEEG=fread(fid,[EEG.nbchan,EEG.pnts*EEG.trials],'double');
fclose(fid);
eegt.tasks.(task).analyses.(analysis_name).EEG.data=...
        reshape(tmpEEG,[EEG.nbchan,EEG.pnts,EEG.trials]);
cd(path_orig)


function [eegt] = savePSD_Dat(eegt,task,analysis_name,PSD)
h=waitbar(0,'Saving PSD .dat file...');

path_orig=cd;
cd(fullfile(eegt.PathName,'EEGtask',task))
fid=fopen(eegt.tasks.(task).analyses.(analysis_name).PSDorig_filename,'w');
fwrite(fid,reshape(PSD.SScaleOrig,[PSD.dim(1),PSD.dim(2)*PSD.dim(3)]),'double');
fclose(fid);
fid=fopen(eegt.tasks.(task).analyses.(analysis_name).PSDscale_filename,'w');
fwrite(fid,reshape(PSD.SScale,[PSD.dim(1),PSD.dim(2)*PSD.dim(3)]),'double');
fclose(fid);
waitbar(1,h)
PSD.SScaleOrig=[];
PSD.SScale=[];
eegt.tasks.(task).analyses.(analysis_name).PSD=PSD;
cd(path_orig)
delete(h)


function [eegt] = readPSD_Dat(eegt,task,analysis_name)
path_orig=cd;
cd(fullfile(eegt.PathName,'EEGtask',task))
PSD=eegt.tasks.(task).analyses.(analysis_name).PSD;
fid=fopen(eegt.tasks.(task).analyses.(analysis_name).PSDscale_filename,'r');
tmpPSD=fread(fid,[PSD.dim(1),PSD.dim(2)*PSD.dim(3)],'double');
fclose(fid);
eegt.tasks.(task).analyses.(analysis_name).PSD.SScale=...
        reshape(tmpPSD,[PSD.dim(1),PSD.dim(2),PSD.dim(3)]);
    
fid=fopen(eegt.tasks.(task).analyses.(analysis_name).PSDorig_filename,'r');
tmpPSD=fread(fid,[PSD.dim(1),PSD.dim(2)*PSD.dim(3)],'double');
fclose(fid);
eegt.tasks.(task).analyses.(analysis_name).PSD.SScaleOrig=...
    reshape(tmpPSD,[PSD.dim(1),PSD.dim(2),PSD.dim(3)]);
cd(path_orig)


function [eegt] = deleteAnalyses(eegt,task,analysis,analyses_name)

path_orig=cd;
cd(fullfile(eegt.PathName,'EEGtask',task))
for kk=length(analyses_name):-1:analysis+1
    if isfield(eegt.tasks.(task).analyses,analyses_name{kk})
       if isfield(eegt.tasks.(task).analyses.(analyses_name{kk}),'filename')
            delete(eegt.tasks.(task).analyses.(analyses_name{kk}).filename);
       end
       if isfield(eegt.tasks.(task).analyses.(analyses_name{kk}),'PSDorig_filename')
           delete(eegt.tasks.(task).analyses.(analyses_name{kk}).PSDorig_filename);
       end       
       if isfield(eegt.tasks.(task).analyses.(analyses_name{kk}),'PSDscale_filename')
           delete(eegt.tasks.(task).analyses.(analyses_name{kk}).PSDscale_filename);
       end       
       eegt.tasks.(task).analyses=rmfield(eegt.tasks.(task).analyses,analyses_name{kk});
    end
end
cd(path_orig)
