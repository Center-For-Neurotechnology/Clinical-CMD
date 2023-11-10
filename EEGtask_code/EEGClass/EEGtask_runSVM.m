function [parameters,checkrun] = EEGtask_runSVM(eegt,task,analyses_name)

EEG=eegt.tasks.(task).analyses.(analyses_name{7}).EEG;
PSD=eegt.tasks.(task).analyses.(analyses_name{7}).PSD;
parameters=eegt.tasks.(task).analyses.(analyses_name{7}).parameters;

% specOFF=PSD.SScaleOrig(:,PSD.TrigOFFall,:);
% specON=PSD.SScaleOrig(:,PSD.TrigONall,:);

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

% if isempty(specON) || isempty(specOFF); return
% end
% if spm_matlab_version_chk('9.8') < 0
%     [parameters.SVM]=EEGClass_v1(specON,specOFF,EEG.badchannels,...
%         PSD.f,EEG.chanlocs,n_k,iter,n_rep);
% end    
% clear specON specOFF

% Option with NaN in bad TR
SScale=NaN(size(PSD.SScaleOrig,1),EEG.n_trials_orig,size(PSD.SScaleOrig,3));
SScale(:,EEG.good_trials,:)=PSD.SScaleOrig;

trig={EEG.Allevent(contains({EEG.Allevent.trial_type},'trig')).trial_type}'; % Trig Names for all the events
tmp=strfind(trig,'ON_');
tmpON=find(cellfun(@(x,y) strcmp(x(y:y+2),'ON_'),trig,tmp,'UniformOutput',true));
tmp=strfind(trig,'OFF_');
tmpOFF=find(cellfun(@(x,y) strcmp(x(y:y+3),'OFF_'),trig,tmp,'UniformOutput',true));

specOFF=SScale(:,tmpOFF,:);
specON=SScale(:,tmpON,:);

if spm_matlab_version_chk('9.8') < 0
    [parameters.SVM]=EEGClass_v1(specON,specOFF,EEG.badchannels,...
        PSD.f,EEG.chanlocs,n_k,iter,n_rep);
end    
checkrun=true;