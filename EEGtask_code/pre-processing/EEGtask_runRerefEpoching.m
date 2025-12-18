% -----------------------------------------------------------------------
% Input: 
% - eegt structure
% - task: task selected (name of the task)
% - analyses_name: name of the analysis that has to be performed: 'SplitEpRej_3'

% Output: 
% - Updated EEG structure
% - Updated parameters structure

% 1) Interpolate bad channels (if any) using the eeglab function eeg_interp
% 2) Re-reference the data to the average using the eeglab function pop_reref
% 3) Epoch the data: EEG.data from [channels x time] to [channels x time x epochs]

% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------

function [EEG,parameters] = EEGtask_runRerefEpoching(eegt,task,analyses_name)

EEG=eegt.tasks.(task).analyses.(analyses_name{2}).EEG;
EEG.data=eegt.tasks.(task).analyses.(analyses_name{1}).EEG.data;

parameters=eegt.tasks.(task).analyses.(analyses_name{2}).parameters;
% Bad Channels interpolation
if ~isempty(EEG.badchannels)
    parameters.interp=EEG.badchannels;
    EEG = eeg_interp(EEG, EEG.badchannels, 'spherical');
end

% Re-reference to the average
EEG=pop_reref(EEG,[]);
parameters.ref='average';

% BandStop Filtering (OPTIONAL)
% choice = questdlg('Would you apply a bandstop filter?','Bandstop','Yes','No','No');
% if strcmpi(choice,'Yes')
%     [EEG]=EEGfilters(EEG,[],[],59,61,'N');
%     parameters.filters.bandstop=EEG.filters.bandstop;
% end

% Epoching
EEG=EEGepochs(EEG);

% select good epochs
EEG.data=EEG.data(:,:,EEG.good_trials);
EEG.trials=length(EEG.good_trials);
% parameters.allevent=EEG.event;
tmp=find(contains({EEG.event.trial_type},'trig'));
EEG.event=EEG.event(tmp(EEG.good_trials));
EEG.dim=size(EEG.data);
parameters.eventSel=EEG.event;
parameters.dimSelEvents=EEG.dim;