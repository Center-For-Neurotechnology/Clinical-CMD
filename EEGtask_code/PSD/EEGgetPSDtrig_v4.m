% -----------------------------------------------------------------------
% Input:
% - EEG structure 
% - AllTrig: cell array containing the trigger's name (text) of each block
% Output:
% - TrigONall: vector of good indexes for the ON block
% - TrigOFFall: vector of good indexes for the OFF block
% - Bad_Epochs: vector of indexes of bad epochs

% This function checks for epochs selected as bad during epoch rejection 
% and sets as bad the corresponding epoch in the nearest opposite block 
% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------
function [TrigONall,TrigOFFall, Bad_Epochs]=EEGgetPSDtrig_v4(EEG,AllTrig)

TrigONall=[];
TrigOFFall=[];

scoreepoch=true(1,EEG.n_trials_orig); % vector of epoch scoring (true-good,false-bad)
scoreepoch(EEG.BadTr)=false;
GoodEp=find(scoreepoch); % Indexes of good epochs

trig={EEG.Allevent(contains({EEG.Allevent.trial_type},'trig')).trial_type}'; % Trig Names for all the events

for ll=1:length(unique(trig))/2
    tmp=strfind(trig,['ON_' num2str(ll)]);
    % select epochs where ['ON_' num2str(ll)] is present
    tmpON=find(cellfun(@(x,y) strcmp(x(y:end),['ON_' num2str(ll)]),trig,tmp,'UniformOutput',true));
    clear tmp
    tmp=strfind(trig,['OFF_' num2str(ll)]);
    % select epochs where ['OFF_' num2str(ll)] is present
    tmpOFF=find(cellfun(@(x,y) strcmp(x(y:end),['OFF_' num2str(ll)]),trig,tmp,'UniformOutput',true));
    clear tmp
    % save the original; put all the indexes together and consider only the good ones
    TrigBlock_orig=cat(1,tmpON,tmpOFF);
    TrigBlock_orig=TrigBlock_orig(scoreepoch(TrigBlock_orig));
    Itrig={tmpON,tmpOFF}';
    scoretrig=cellfun(@(x) find(scoreepoch(x)),Itrig,'UniformOutput', false);
    IBADin1not2=Itrig{1}(scoretrig{1}(~ismember(scoretrig{1},scoretrig{2}))); % epochs present in Block ON but not in Block OFF
    IBADin2not1=Itrig{2}(scoretrig{2}(~ismember(scoretrig{2},scoretrig{1}))); % epochs present in Block OFF but not in Block ON
    ITrGood=cell2mat(cellfun(@(x) find(x==GoodEp),num2cell(setdiff(TrigBlock_orig,[IBADin1not2;IBADin2not1])),'UniformOutput', false));
    TrigON=ITrGood(contains(trig(GoodEp(ITrGood)),AllTrig{1}));
    TrigOFF=ITrGood(contains(trig(GoodEp(ITrGood)),AllTrig{2}));
    TrigONall=cat(1,TrigONall,TrigON);
    TrigOFFall=cat(1,TrigOFFall,TrigOFF);
end

Bad_Epochs=setdiff(1:EEG.n_trials_orig,GoodEp([TrigONall TrigOFFall]));