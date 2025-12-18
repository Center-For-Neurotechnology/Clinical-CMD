% -----------------------------------------------------------------------
% Input: 
% - eegt structure
% - task: task selected (name of the task)
% - analyses_name: name of the analysis that has to be performed: 'SVM_8'

% Output: 
% - Updated parameters structure
% - checkrun: logical value. True if arrives at the end of the function

% Run Support Vector Machine (only if spm_matlab_version_chk('9.8') = -1)

% The svmtrain and svmclassify functions were deprecated and removed in MATLAB R2018a
% and replaced by modern functions like fitcsvm (classification) and predict
% The function EEGClass_v1 uses the svmtrain and svmclassify functions, 
% as they were published BL Edlow at al., 2017
% The function EEGClass_v2 uses the new functions supported by Matlab,
% fitcsvm and predict
% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------
function [parameters,checkrun] = EEGtask_runSVM(eegt,task,analyses_name)

EEG=eegt.tasks.(task).analyses.(analyses_name{7}).EEG;
PSD=eegt.tasks.(task).analyses.(analyses_name{7}).PSD;
parameters=eegt.tasks.(task).analyses.(analyses_name{7}).parameters;

tmpSVMpar = inputdlg({'Enter Number of repetition:','Enter number of K-fold',...
    'Enter number of iteration'},'SVM parameters',1,{'10','20','500'});
if isempty(tmpSVMpar); checkrun=false; return; end
if isempty(tmpSVMpar{1}); n_rep=10;
else; n_rep=str2double(tmpSVMpar{1});
end
if isempty(tmpSVMpar{2}); n_k=20;
else; n_k=str2double(tmpSVMpar{2});
end
if isempty(tmpSVMpar{3}); iter=500;
else; iter=str2double(tmpSVMpar{3});
end

% Set bad epochs as NaN
SScale=NaN(size(PSD.SScaleOrig,1),EEG.n_trials_orig,size(PSD.SScaleOrig,3));
SScale(:,EEG.good_trials,:)=PSD.SScaleOrig;

trig={EEG.Allevent(contains({EEG.Allevent.trial_type},'trig')).trial_type}'; % Trig Names for all the events
tmp=strfind(trig,'ON_');
tmpON=find(cellfun(@(x,y) strcmp(x(y:y+2),'ON_'),trig,tmp,'UniformOutput',true));
tmp=strfind(trig,'OFF_');
tmpOFF=find(cellfun(@(x,y) strcmp(x(y:y+3),'OFF_'),trig,tmp,'UniformOutput',true));

specOFF=SScale(:,tmpOFF,:);
specON=SScale(:,tmpON,:);

% The svmtrain and svmclassify functions were deprecated and removed in MATLAB R2018a,
% replaced by modern functions like fitcsvm (classification) and predict
if spm_matlab_version_chk('9.3') > 0
    [parameters.SVM]=EEGClass_v2(specON,specOFF,EEG.badchannels,...
        PSD.f,EEG.chanlocs,n_k,iter,n_rep);
else
    choice = questdlg('Which version of the classifier would you run?', ...
        'SVM choice', ...
        'Published in BL Edlow at al., 2017','New supported version','Published in BL Edlow at al., 2017');
    switch choice
        case 'Published in BL Edlow at al., 2017'
            [parameters.SVM]=EEGClass_v1(specON,specOFF,EEG.badchannels,...
                PSD.f,EEG.chanlocs,n_k,iter,n_rep);
        case 'New supported version'
            [parameters.SVM]=EEGClass_v2(specON,specOFF,EEG.badchannels,...
                PSD.f,EEG.chanlocs,n_k,iter,n_rep);
    end
end
checkrun=true;