% -----------------------------------------------------------------------
% input: 
% - eegt structure
% - task: task selected (name of the task)
% - analyses_name: name of the analysis that has to be performed: 'ChEpSel_2'

% output: 
% - Updated EEG structure
% - Updated parameters structure

% 1) Automatically detects flat channels and channels with big deflection
% 2) Opens an EEG Viewer to perform channels and epochs rejection

% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------

function [EEG,parameters] = EEGtask_runChEpSelection(eegt,task,analyses_name)
EEG=eegt.tasks.(task).analyses.(analyses_name{1}).EEG;
if isfield(eegt.tasks.(task).analyses,analyses_name{2})
    EEG.badchannels=eegt.tasks.(task).analyses.(analyses_name{2}).EEG.badchannels;
    EEG.BadTr=eegt.tasks.(task).analyses.(analyses_name{2}).EEG.BadTr;
end
% Automatic bad channels selection
if ~isfield(EEG,'badchannels')
    [EEG]=EEGbadch(EEG);   % this function found the flat channels and channels with big deflections
end
% Automatic bad epochs selection (implemented in a future version)
if ~isfield(EEG,'BadTr')
    EEG.BadTr=[];
end

% EEG Viewer to check whether the channels and epochs rejection worked well
EEG=EEGSelect_ChEpochs(EEG);

parameters=eegt.tasks.(task).analyses.(analyses_name{1}).parameters;
parameters.badchannels=EEG.badchannels;
parameters.goodchannels=EEG.goodchannels;
parameters.badepochs=EEG.BadTr;
parameters.goodepochs=EEG.good_trials;