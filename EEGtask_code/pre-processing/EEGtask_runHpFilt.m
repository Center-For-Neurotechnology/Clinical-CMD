% -----------------------------------------------------------------------
% Input: 
% - eegt structure
% - task: task selected (name)
% - parameters: empty parameters structure

%  1) Load the .SET file for the selected task using the pop_loadset eeglab function
%  2) Create events based on the duration of epoch [s]; default [1]
%  3) In case the length of the ON (active) and OFF (rest) blocks is different,
%  select the same number of events for each couple of ON and OFF blocks
%  4) HighPass, BandStop, and LowPass Filters: 
% - hp: low frequency cut-off [Hz]; default [1]; 
% - lp: high frequency cut-off [Hz]; default [100]; 
% - Bs: band stop [Hz]; default [60]; 

% Output: 
% - EEG structure updated with EEG.data imported and filtered
% - Updated parameters structure
% - check: logical value. Default is 'false'; if 'true', the number of
% blocks is incorrect and the block selection should be performed again

% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------

function [EEG,parameters,check] = EEGtask_runHpFilt(eegt,task,parameters)

EEG=pop_loadset(fullfile(eegt.PathName,eegt.tasks.(task).SETfile));                % Load EEG structure from eeglab files (eeglab)
EEG.srate=fix(EEG.srate);
% Extract the triggers
EEG.epoch_duration = str2double(cell2mat(inputdlg({'Enter epoch duration [s]:'},...
    'Input epoch duration',1,{'1'}))); % seconds
if isnan(EEG.epoch_duration); check=true; return; end
parameters.srate=EEG.srate;
parameters.eventsOrig=EEG.event;
parameters.ref=EEG.ref;
% eegt.tasks.(task).urevent_orig=EEG.urevent;
[EEG, check]=EEGtriggers_v2(EEG);
if check; return; end
parameters.epochDuration=EEG.epoch_duration;
parameters.eventsAllOrig=EEG.event;
parameters.dimAllEventsOrig=length(EEG.event);

EEG=EEGequalblocks_v2(EEG);
parameters.eventsAll=EEG.event;
parameters.dimAllEvents=length(EEG.event);

% HighPass Filter
tmp = inputdlg({'Enter high-pass filter [Hz]:';...
    'Enter band-stop filter [Hz]:'},...
    'Input filters',1,{'1';'60'}); % seconds

if isempty(tmp) || isempty(tmp{1})
    Hp=1;
else
    Hp=str2double(tmp{1});
end
if isempty(tmp) || isempty(tmp{2})
    Bs=NaN;
else
    Bs=str2double(tmp{2});
end
if ~isnan(Bs)
    [EEG]=EEGfilters_v2(EEG,Hp,100,Bs-1,Bs+1);
else
    [EEG]=EEGfilters_v2(EEG,Hp,100,[],[]);
end
clear Hp Bs tmp
parameters.filters=EEG.filters;