% -----------------------------------------------------------------------
% Input:
%   EEG: EEGlab EEG structure
%   PathName: EEG structure Path
%   FileName: EEG Filename 
%   Ref: string - 'average' to keep the data in average reference - 
%       'hjorth' to calculate Hjorth montage (default: 'hjorth') also 
%       used for naming purposes
%   DistSelected: number from 0 to 100 (Default: 82). 
%                 Select the number of considered channels
%   frequencyResolution: number of point for each frequency bin (Default: 2)
%   
% -----------------------------------------------------------------------

% --------------------------
% Authors: Fecchio Matteo, CS
% --------------------------

function [EEG, PSD, parameters] = EEGtask_runPSD(eegt,task,analyses_name)

EEG=eegt.tasks.(task).analyses.(analyses_name{6}).EEG;
parameters=eegt.tasks.(task).analyses.(analyses_name{6}).parameters;

% Ref = questdlg('Which reference do you want to use?', ...
% 	'Reference', ...
% 	'average','hjorth','hjorth');

Ref='hjorth';

DistSelected=[];
parameters.PSD.ref=Ref;
if strcmp(Ref,'hjorth')
    [EEG]=Hjorth_Montage(EEG,DistSelected,0);
    clear DistSelected
else
    EEG.nearest_neighbors=[];
    EEG.DistSelected=[];
end
parameters.PSD.distSelected=EEG.DistSelected;
    
PSD=EEGtask_runMultitaperspectra(EEG);
parameters.PSD.fpass=PSD.Params.fpass;


trig=unique({EEG.event(contains({EEG.event.trial_type},'trig')).trial_type});
[~,ia,~]=unique(cellfun(@(x) x(regexp(x,'[a-z]')),lower(trig),'UniformOutput',false));
trig=cellfun(@(x) x(1:find(x=='_',1,'last')-1),trig(ia),'UniformOutput',false);
trigOFF=trig{cellfun(@(x) ~isempty(x),strfind(trig,'OFF'))};
trigON=trig{cellfun(@(x) ~isempty(x),strfind(trig,'ON'))};
AllTrig={trigON;trigOFF}; % Trig Names

EEG.Allevent=eegt.tasks.(task).analyses.(analyses_name{6}).parameters.eventsAll;
[PSD.TrigONall,PSD.TrigOFFall,PSD.Bad_Tr]=EEGgetPSDtrig_v4(EEG,AllTrig);

parameters.PSD.trigON=trigON;
parameters.PSD.trigOFF=trigOFF;
parameters.PSD.dimSpecON=size(PSD.SScale(:,PSD.TrigONall,:));
parameters.PSD.dimSpecOFF=size(PSD.SScale(:,PSD.TrigOFFall,:));
parameters.PSD.dimTrigONall=length(PSD.TrigONall);
parameters.PSD.dimTrigOFFall=length(PSD.TrigOFFall);

