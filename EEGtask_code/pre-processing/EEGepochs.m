% input: EEG structure with EEG.data [channels x time]
% output: EEG structure updated with EEG.data [channels x time x epochs]

function [EEG]=EEGepochs(EEG)
if length(size(EEG.data))==2
    % Fill empty cells with 'Segment'
    trial_type={EEG.event.trial_type};
    if any(cellfun(@isempty , trial_type,'UniformOutput',true))
%         trial_type{cellfun(@isempty , trial_type,'UniformOutput',true)}='Segment';
        I=find(cellfun(@isempty , trial_type,'UniformOutput',true));
        for kk=1:length(I)
            trial_type{I(kk)}='Segment';
        end
    end
    % looking for events in EEG.event with trial_type 'trig'
    trig={EEG.event(contains(trial_type,'trig')).latency};
    % epoching the data from EEG.event.latency to 
    % EEG.event.latency + EEG.epoch_duration
    tmp=cellfun(@(x) EEG.data(:,x:x+EEG.srate*EEG.epoch_duration-1),trig,'UniformOutput', false);
    EEG.data=reshape(cell2mat(tmp),size(tmp{1},1),size(tmp{1},2),size(tmp,2));
    EEG.trials=size(EEG.data,3);
    EEG.pnts=size(EEG.data,2);
    EEG.times=linspace(0,EEG.epoch_duration,EEG.pnts);
    EEG.dim=size(EEG.data);
end