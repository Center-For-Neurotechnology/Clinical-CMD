function [EEG,parameters,check] = EEGtask_runHpFilt(eegt,task,parameters)

EEG=pop_loadset(fullfile(eegt.PathName,eegt.tasks.(task).SETfile));                % Load EEG structure from eeglab files (eeglab)
EEG.srate=fix(EEG.srate);
% Extract the triggers
EEG.epoch_duration = str2double(cell2mat(inputdlg({'Enter epoch duration [s]:'},...
    'Input epoch duration',1,{'1'}))); % seconds

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

if isempty(tmp{1})
    Hp=1;
else
    Hp=str2double(tmp{1});
end
Bp=str2double(tmp{2});
if ~isnan(Bp)
    [EEG]=EEGfilters(EEG,Hp,100,Bp-1,Bp+1,'N');
else
    [EEG]=EEGfilters(EEG,Hp,100,[],[],'N');
end
clear Hp Bp tmp
parameters.filters=EEG.filters;