% -----------------------------------------------------------------------
% Input: 
% - eegt structure
% - task: task selected (name of the task)
% - analyses_name: name of the analysis that has to be performed: 'ReRef_PSD_7'
% - fig_type: select one plot ['DisplayAllPSD'; 'PSD_Topography'; 'PSD_F_C_P_O'; 'PSD_L_M_R';
%   'PSD_Bar_L_M_R';]
% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------
function EEGt_runPlotPSD(eegt,task,analysis_name,fig_type)
h = waitbar(0,'Wait...');

path_orig=cd;
cd(fullfile(eegt.PathName,'EEGtask',task))
PSD=eegt.tasks.(task).analyses.(analysis_name).PSD;

fid=fopen(eegt.tasks.(task).analyses.(analysis_name).PSDorig_filename,'r');
tmpPSD=fread(fid,[PSD.dim(1),PSD.dim(2)*PSD.dim(3)],'double');
fclose(fid);
PSD.SScaleOrig=reshape(tmpPSD,[PSD.dim(1),PSD.dim(2),PSD.dim(3)]);

cd(path_orig)
clear tmpPSD

badCH=eegt.tasks.(task).analyses.(analysis_name).parameters.badchannels;
chanlocs=eegt.tasks.(task).chanlocs;
goodCH=setdiff(1:length(chanlocs),badCH);

if isempty(PSD.SScaleOrig); return; end

waitbar(1)
close(h)

% set Bad TR as NaN
EEG=eegt.tasks.(task).analyses.(analysis_name).EEG;

SScale_ALL=NaN(size(PSD.SScaleOrig,1),EEG.n_trials_orig,size(PSD.SScaleOrig,3));
SScale_ALL(:,EEG.good_trials,:)=PSD.SScaleOrig;

trig={EEG.Allevent(contains({EEG.Allevent.trial_type},'trig')).trial_type}'; % Trig Names for all the events
tmp=strfind(trig,'ON_');
tmpON=find(cellfun(@(x,y) strcmp(x(y:y+2),'ON_'),trig,tmp,'UniformOutput',true));
tmp=strfind(trig,'OFF_');
tmpOFF=find(cellfun(@(x,y) strcmp(x(y:y+3),'OFF_'),trig,tmp,'UniformOutput',true));

specOFF=SScale_ALL(:,tmpOFF,:);
specON=SScale_ALL(:,tmpON,:);
EEGplotPSD(specON,specOFF,PSD.f,chanlocs,goodCH,fig_type)


