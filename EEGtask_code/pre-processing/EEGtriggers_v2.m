% -----------------------------------------------------------------------
% Input:
% - EEG structure 
% Output:
% - EEG structure with event and urevent structures updated
% - check: logical value. Default is 'false'; if 'true', the number of
% blocks is incorrect and the block selection should be performed again

% This function look for the following marker in event.type:
% - S 51 marker for beninning Block ON (active)
% - S 59 marker for end Block ON (active)
% - S 61 marker for beninning Block OFF (rest)
% - S 69 marker for end Block OFF (rest)
% Based on the selected epoch duration, the beginning of each epoch is
% stored in the event/urevent structures as:
% trial_type['trig_' EEG.task  ITr] , where EEG.task is the name
% of the task, and ITr is a code that indicate if epoch is part of an
% active (ON) or rest (OFF) block + the number of the block (1,2,3...).
% trial_type examples: trig_handON_1, trig_langOFF_2.
% The use of the word 'trig', as the presence of '_' between the word 'trig' 
% and the name of the block (handON, langOFF, etc.), and the name of the 
% block and the number of the block is required
%
%The First second after the instruction is always excluded
% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------

function [EEG,check]=EEGtriggers_v2(EEG)
check=false;
Lepoch=EEG.epoch_duration; % epoch duration

IS51=find(strcmp({EEG.event.type},'S 51')); % S 51 marker for beninning Block ON
IS59=find(strcmp({EEG.event.type},'S 59')); % S 59 marker for end Block ON
if any(IS59-IS51)>1
    return % return if some events are in the middles of one block 
end
IS61=find(strcmp({EEG.event.type},'S 61')); % S 61 marker for beninning Block ON
IS69=find(strcmp({EEG.event.type},'S 69')); % S 69 marker for end Block ON
if any(IS69-IS61)>1
    return % return if some events are in the middles of one block 
end
if length(IS51)~=length(IS61)
    warndlg({'Number of block ON and OFF are different!'; 'Check the threshold when running From... to EEGtask'})
    check=true;
    return % return if the amount of blockON is different from blockOFF
end
clear IS*
latS51=[EEG.event(strcmp({EEG.event.type},'S 51')).latency];
latS59=[EEG.event(strcmp({EEG.event.type},'S 59')).latency];
latS61=[EEG.event(strcmp({EEG.event.type},'S 61')).latency];
latS69=[EEG.event(strcmp({EEG.event.type},'S 69')).latency];

ITrigON=cell(1,1);
cont=1;
for kk=1:length(latS51)
    % number of epochs in 1 block - first second after the instruction excluded
    Nepoch=fix((latS59(kk)-latS51(kk)-fix(EEG.srate))/(Lepoch*fix(EEG.srate)));
    % unless it is a lang block
    if Nepoch<10 && strcmp(EEG.task,'lang')
        Nepoch=fix((latS59(kk)-latS51(kk))/(Lepoch*fix(EEG.srate)));
    end
    % last epoch is excluded if there is not enough time
    if (Nepoch*Lepoch*fix(EEG.srate))+latS51(kk)>latS59(kk)
        Nepoch=Nepoch-1;
    end
    % beginning of first epoch of the block 
    % (first second after the instruction excluded)
    ITrigON{cont,1}=latS51(kk)+fix(EEG.srate);
    ITrigON{cont,2}=['ON_' num2str(kk)];
    % beginning of each epoch
    cont=cont+1;
    for jj=2:Nepoch
        ITrigON{cont,1}=ITrigON{end,1}+Lepoch*fix(EEG.srate);
        ITrigON{cont,2}=['ON_' num2str(kk)];
        cont=cont+1;
    end
end
    
ITrigOFF=cell(1,1);
cont=1;
for kk=1:length(latS61)
    % number of epochs in 1 block - first second after the instruction excluded
    Nepoch=fix((latS69(kk)-latS61(kk)-fix(EEG.srate))/(Lepoch*fix(EEG.srate)));
    % last epoch is excluded if there is not enough time
    if (Nepoch*Lepoch*fix(EEG.srate))+fix(EEG.srate)+latS61(kk)>latS69(kk)
        Nepoch=Nepoch-1;
    end
    % beginning of first epoch of the block
    % (first second after the instruction excluded)
    ITrigOFF{cont,1}=latS61(kk)+fix(EEG.srate);
    ITrigOFF{cont,2}=['OFF_' num2str(kk)];
    % beginning of each epoch
    cont=cont+1;
    for jj=2:Nepoch
        ITrigOFF{cont,1}=ITrigOFF{end,1}+Lepoch*fix(EEG.srate);
        ITrigOFF{cont,2}=['OFF_' num2str(kk)];
        cont=cont+1;
    end
end  
%--- CHECK: Plot DC channel with superimposed triggers     
figure,plot(EEG.Trig_CH,'k'),hold on,
line([[ITrigON{:,1}]; [ITrigON{:,1}]],repmat([0 1],size(ITrigON,1),1)','Color','r')
line([[ITrigOFF{:,1}]; [ITrigOFF{:,1}]],repmat([0 1],size(ITrigOFF,1),1)','Color','b')
xlim([0 length(EEG.Trig_CH)])
title({'Channel used to select the events'; 'Vertical lines indicates the beginning of each epoch'; '(RED - block ON (active); BLUE: block OFF (rest))'})

% Create/Update the event and urevent structure
ITr=[ITrigON;ITrigOFF];
[~,I]=sort([ITr{:,1}]);
ITr=ITr(I,:);


EEG.event=struct;
EEG.urevent=struct;
% Iev=length(EEG.event);
for jj=1:size(ITr,1)

%for jj=Iev+1:Iev+size(ITr,1)
%     EEG.event(1,jj).latency=ITr{jj-Iev,1};
    EEG.event(1,jj).latency=ITr{jj,1};
    EEG.event(1,jj).duration=1;
    EEG.event(1,jj).channel=0;
    EEG.event(1,jj).bvtime=[];
    EEG.event(1,jj).bvmknum=jj;
%     EEG.event(1,jj).type=ITr{jj-Iev,2};
    EEG.event(1,jj).type=ITr{jj,2};
    EEG.event(1,jj).code='Stimulus';
    EEG.event(1,jj).epoch=[];
    EEG.event(1,jj).urevent=jj;
%     EEG.event(1,jj).trial_type=['trig_' EEG.task  ITr{jj-Iev,2}];
    EEG.event(1,jj).trial_type=['trig_' EEG.task  ITr{jj,2}];
    
%     EEG.urevent(1,jj).latency=ITr{jj-Iev,1};
    EEG.urevent(1,jj).latency=ITr{jj,1};
    EEG.urevent(1,jj).duration=1;
    EEG.urevent(1,jj).channel=0;
    EEG.urevent(1,jj).bvtime=[];
    EEG.urevent(1,jj).bvmknum=jj;
%     EEG.urevent(1,jj).type=ITr{jj-Iev,2};
    EEG.urevent(1,jj).type=ITr{jj,2};
    EEG.urevent(1,jj).code='Stimulus';
    EEG.urevent(1,jj).epoch=[];
%     EEG.urevent(1,jj).trial_type=['trig_' EEG.task  ITr{jj-Iev,2}];
    EEG.urevent(1,jj).trial_type=['trig_' EEG.task  ITr{jj,2}];
end

