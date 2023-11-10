function [EEG,parameters] = EEGtask_runLpFilt(eegt,task,analyses_name)

EEG=eegt.tasks.(task).analyses.(analyses_name{5}).EEG;
parameters=eegt.tasks.(task).analyses.(analyses_name{5}).parameters;

tmp = inputdlg({'Enter low-pass filter [Hz]:'},...
    'Input filters',1,{'30'}); % seconds

if isempty(tmp{1})
    Lp=30;
else
    Lp=str2double(tmp{1});
end
% LowPass Filtering and Epoching
[EEG]=EEGfilters(EEG,[],Lp,[],[],'Y');
parameters.filters2=EEG.filters;
parameters.srate=EEG.srate;
clear Lp tmp