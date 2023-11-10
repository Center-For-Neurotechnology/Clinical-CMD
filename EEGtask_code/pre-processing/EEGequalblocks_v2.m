% -----------------------------------------------------------------------
% input: 
% - EEG structure
% output: 
% - Updated EEG structure
% In case the length of the ON (active) and OFF (rest) blocks is different, 
% a different number of events occur. This function select the same number
% of events for each couple of ON and OFF blocks

% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------

function [EEG]=EEGequalblocks_v2(EEG)
% Fill empty cells with 'Segment'
trial_type={EEG.event.trial_type};
if any(cellfun(@isempty , trial_type,'UniformOutput',true))
    I=find(cellfun(@isempty , trial_type,'UniformOutput',true));
    for kk=1:length(I)
        trial_type{I(kk)}='Segment';
    end
end
trig={EEG.event(contains(trial_type,'trig')).trial_type}';
I=find(contains(trial_type,'trig'));
TRIG=[];
for ll=1:length(unique(trig))/2
    tmp=strfind(trig,['ON_' num2str(ll)]);
    tmpON=find(cellfun(@(x,y) strcmp(x(y:end),['ON_' num2str(ll)]),trig,tmp,'UniformOutput',true));
    clear tmp
    tmp=strfind(trig,['OFF_' num2str(ll)]);
    tmpOFF=find(cellfun(@(x,y) strcmp(x(y:end),['OFF_' num2str(ll)]),trig,tmp,'UniformOutput',true));
    clear tmp
% Selection of the epochs ON and OFF that are close
    if length(tmpON)>length(tmpOFF)
        tmpON=tmpON([length(tmpON)-length(tmpOFF)+1:length(tmpON)]');
    elseif length(tmpOFF)>length(tmpON)
        tmpOFF=tmpOFF([length(tmpOFF)-length(tmpON)+1:length(tmpOFF)]');
    end
    TrigBlock=cat(1,tmpON,tmpOFF);
    TRIG=cat(1,TRIG,TrigBlock);
end
EEG.event_orig=EEG.event;
EEG.event=EEG.event(I(TRIG));
EEG.n_trials_orig=length(TRIG);

%%%% Plot DC channel to check
% figure
% plot(abs(EEG.ALLdata(48,:)-mean(EEG.ALLdata(48,:))),'k')
% hold on
% plot(lat(TRIG),abs(EEG.ALLdata(48,lat(TRIG))-mean(EEG.ALLdata(48,lat(TRIG)))),'*r')
