%% Split a single BrainVision file to separate files each containing a single task
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------

function [] = EEGt_fromBrainAMP2EEGtask_MAonly()
%% Select patient/session/task
[FileName,PathName]=uigetfile('\*.vhdr','MOTOR ACTION - Select the .vhdr file');% select .nxe file
if PathName==0; return; end
EEG_orig=pop_loadbv(PathName, FileName);
pathBIDS=PathName(1:strfind(PathName,'sub-')-1);
[subj,remain]=strtok(FileName,'_');
if ~isempty(strfind(remain,'ses'))
    ses=erase(strtok(remain,'_'),'ses-');
    if strfind(ses,'ses')
        ses=erase(ses,'ses');
    end
else
    ses='01';
end
clear remain
%% Create and plot the structure of the recording based on the triggers

mrklat_tmp=[];  % latencies of the triggers
mrk_tmp=[];     % number corresponding to the trigger (see 'triggers_val')   
mrktype_tmp={}; % Type of trigger (see 'triggers')
blocks_tmp={};  % see 'blocks'
tasks_tmp={};   % see 'tasks'

triggers={'S 21', 'S 22', 'S 23', 'S 29', 'S 31', 'S 32', 'S 33', 'S 39','S255'};
blocks={'MAr_1', 'MAr_2', 'MAr_3', [], 'MAl_1', 'MAl_2', 'MAl_3', [],[]};
tasks={'MAr', 'MAr', 'MAr', [], 'MAl', 'MAl', 'MAl', [],[]};
triggers_val=[1,1,1,-1,1,1,1,-1,-2];
mrksig=zeros(1,EEG_orig.pnts);
for kk=1:length(triggers)
    mrklat_tmp=cat(2,mrklat_tmp,[EEG_orig.event(find(strcmp({EEG_orig.event.type},triggers{kk}))).latency]);
    mrktype_tmp=cat(2,mrktype_tmp,{EEG_orig.event(find(strcmp({EEG_orig.event.type},triggers{kk}))).type});
    mrk_tmp=cat(2,mrk_tmp,ones(1,length({EEG_orig.event(find(strcmp({EEG_orig.event.type},triggers{kk}))).type}))*triggers_val(kk));
    blocks_tmp=cat(2,blocks_tmp,repmat(blocks(kk),1,length({EEG_orig.event(strcmp({EEG_orig.event.type},triggers{kk})).type})));
    tasks_tmp=cat(2,tasks_tmp,repmat(tasks(kk),1,length({EEG_orig.event(strcmp({EEG_orig.event.type},triggers{kk})).type})));

    if kk==1 || kk==2 || kk==3 || kk==5 || kk==6 || kk==7
        mrksig([EEG_orig.event(strcmp({EEG_orig.event.type},triggers{kk})).latency])=1;
    elseif kk==4 || kk==8
        mrksig([EEG_orig.event(strcmp({EEG_orig.event.type},triggers{kk})).latency])=-1;
    elseif kk==9
        mrksig([EEG_orig.event(strcmp({EEG_orig.event.type},triggers{kk})).latency])=-2;
    end
end
clear kk triggers_val triggers
% figure,plot(mrksig,'k')
% line([find(mrksig==1); find(mrksig==1)],repmat([0 1],length(find(mrksig==1)),1)','Color','b')
% line([find(mrksig==-2); find(mrksig==-2)],repmat([-2 0],length(find(mrksig==-2)),1)','Color','r')
% ylim([-3 2])

%% Remove the triggers S255 and the Trigger that indicate the beginning 
%% of the block (if needed)

% Sort the triggers based on the latencies
[~,I]=sort(mrklat_tmp);
mrklat_tmp=mrklat_tmp(I);
mrktype_tmp=mrktype_tmp(I);
blocks_tmp=blocks_tmp(I);
mrk_tmp=mrk_tmp(I);
tasks_tmp=tasks_tmp(I);
clear I

% if diff=-3 means that a block was interrupted before it was finished [1 -2].
% In this case, the following code delete both the S255 and the trigger 
% that indicate the beginning of the block 
S255=find(diff(mrk_tmp)==-3); 
if ~isempty(S255)
    for kk=length(S255):-1:1
        mrklat_tmp(S255(kk)+1)=[];
        mrklat_tmp(S255(kk))=[];
        mrktype_tmp(S255(kk)+1)=[];
        mrktype_tmp(S255(kk))=[];
        blocks_tmp(S255(kk)+1)=[];
        blocks_tmp(S255(kk))=[];
        tasks_tmp(S255(kk)+1)=[];
        tasks_tmp(S255(kk))=[];
    end
end
clear kk S255
% if there are other S255 it means that it was not used to stop a block 
% and thus it can be deleted 
mrksig(mrklat_tmp(strcmp(mrktype_tmp,'S255')))=0;
blocks_tmp(strcmp(mrktype_tmp,'S255'))=[];
tasks_tmp(strcmp(mrktype_tmp,'S255'))=[];
mrk_tmp(strcmp(mrktype_tmp,'S255'))=[];
mrklat_tmp(strcmp(mrktype_tmp,'S255'))=[];
mrktype_tmp(strcmp(mrktype_tmp,'S255'))=[];

if rem(length(blocks_tmp), 2)==1
    blocks_tmp(end)=[];
    mrk_tmp(end)=[];
    mrklat_tmp(end)=[];
    mrktype_tmp(end)=[];
    tasks_tmp(end)=[];
end

% Select blocks that should not be considered
I_begin=1:2:length(blocks_tmp);
h = msgbox({'Select the BAD blocks' '' 'Press CANCEL if they are all good'});
waitfor(h)
Sel = listdlg('ListString',blocks_tmp(I_begin),'SelectionMode','multiple','PromptString','Select only BAD blocks');
I_bad=sort([I_begin(Sel) I_begin(Sel)+1]);

mrksig(mrklat_tmp(I_bad))=0;
blocks_tmp(I_bad)=[];
mrk_tmp(I_bad)=[];
mrklat_tmp(I_bad)=[];
mrktype_tmp(I_bad)=[];
tasks_tmp(I_bad)=[];

% SELECT 19 CH
MyMontage={'Fp1';'Fp2';'F7';'F3';'Fz';'F4';'F8';'T7';'C3';'Cz';'C4';'T8';'P7';'P3';'Pz';'P4';'P8';'O1';'O2'};

% Load the current montage, updates channels names, and select the 19
% channels
load('chlocs_brainamp62milano.mat')
ch_orig={EEG_orig.chanlocs.labels};
Ich=cell2mat(cellfun(@(x) find(strcmp(ch_orig,x)),{chlocs.labels},'UniformOutput',false));
EEG_orig.data=EEG_orig.data(Ich,:);
for kk=1:length(chlocs)
    chlocs(kk).labels=chlocs(kk).newlabels;
end
EEG_orig.chanlocs=chlocs;

%% Extract each block, concatenate them, and save 
taskU=unique(tasks_tmp(1:2:end));
for pp=1:length(taskU)
    task=taskU{pp};
    
    EEG=eeg_emptyset;
    if ~isempty(ses)
        EEG.filename=['sub-' subj '_ses-' ses '_task-' lower(task) '_eeg.set'];
    else
        EEG.filename=['sub-' subj '_task-' lower(task) '_eeg.set'];
    end
    EEG.filepath=PathName;
    EEG.subject=subj;
    EEG.session=1;
    EEG.ses=ses;
    EEG.task=lower(task);
    EEG.trials=1;
    EEG.srate=EEG_orig.srate;
    
    
    Itasks=find(strcmp(tasks_tmp,task));
    data_tmp=[];
    event_tmp=[];
    for kk=1:length(Itasks)
        I(1)=find([EEG_orig.event.latency]==mrklat_tmp(Itasks(kk)));
        I(2)=find([EEG_orig.event.latency]==mrklat_tmp(Itasks(kk)+1));
        event=EEG_orig.event(I(1)+1:I(2)-1);
        event(strcmp({event.code},'Comment'))=[];
        % Check lunghezza di TrLength
%         lat=diff([event.latency]);
%         lat=lat(1:2:end);
        
        data_tmp=cat(2,data_tmp,EEG_orig.data(:,event(1).latency:event(end).latency+EEG.srate));
        for zz=length(event):-1:1
           event(zz).latency=event(zz).latency-event(1).latency+1;
           event(zz).trial_type=[];
           if ~isempty(event_tmp)
               event(zz).latency=event(zz).latency+event_tmp(end).latency+EEG.srate;
           end
        end
        event_tmp=cat(2,event_tmp,event);
        EOFpnts(kk)=event_tmp(end).latency+EEG.srate;
    end
    
    EEG.event=event_tmp;
    EEG.urevent=EEG_orig.urevent;
    EEG.data=data_tmp;
    EEG.nbchan=size(EEG.data,1);
    EEG.pnts=size(EEG.data,2);
    EEG.xmax=(EEG.pnts-1)/EEG.srate;
    EEG.times=0:1000/EEG.srate:[(size(data_tmp,2)/EEG.srate)*1000]-1;
    EEG.chanlocs=EEG_orig.chanlocs;
    
    if ~isempty(ses)
        EEG.datfile=['sub-' subj '_ses-' ses '_task-' lower(task) '.fdt'];
    else
        EEG.datfile=['sub-' subj '_task-' lower(task) '.fdt'];
    end
    
    EEG.EOFpnts=EOFpnts;
    EEG.Itrig=[];
    
    Trig_CH=zeros(1,EEG.pnts);
    for kk=1:2:length(event_tmp)
       if strcmp(event_tmp(kk).type,'S 51')
           Trig_CH(event_tmp(kk).latency:event_tmp(kk+1).latency)=1;
       elseif strcmp(event_tmp(kk).type,'S 61')
           Trig_CH(event_tmp(kk).latency:event_tmp(kk+1).latency)=0.5;
       end
    end
   
    EEG.Trig_CH=Trig_CH;
    
    
    EEG=pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp');
    
    % SALVA
%     PN=fullfile(pathBIDS, 'derivatives');
% 
%     FN=EEG.filepath(strfind(EEG.filepath,'sub-'):end);
%     [token,remain]=strtok(FN,filesep);
%     while ~isempty(token)
%         if ~isdir(fullfile(PN,token))
%             mkdir(PN,token)
%         end
%         PN=fullfile(PN,token);
%         [token,remain]=strtok(remain,filesep);
%     end
    PN=EEG.filepath;
    disp(['Saving: ' fullfile(PN,EEG.filename)])
    [~] =  pop_saveset(EEG, 'filename', EEG.filename, 'filepath', PN);
    
    
    Ich19=cell2mat(cellfun(@(x) find(strcmp({EEG.chanlocs.labels},x)),MyMontage,'UniformOutput',false));
    EEG.data=EEG.data(Ich19,:);
    EEG.nbchan=size(EEG.data,1);
    EEG.chanlocs=EEG.chanlocs(Ich19);
    
    if ~isempty(ses)
        EEG.filename=['sub-' subj '_ses-' ses '_task-' lower(task) '19_eeg.set'];
    else
        EEG.filename=['sub-' subj '_task-' lower(task) '19_eeg.set'];
    end
    
    if ~isempty(ses)
        EEG.datfile=['sub-' subj '_ses-' ses '_task-' lower(task) '19_eeg.fdt'];
    else
        EEG.datfile=['sub-' subj '_task-' lower(task) '19_eeg.fdt'];
    end
    
    disp(['Saving: ' fullfile(PN,EEG.filename)])
    [~] =  pop_saveset(EEG, 'filename', EEG.filename, 'filepath', PN);    
    
    clear PN token remain FN filename EEG
end


%% Concatenate all blocks and save 
task='MotorAction';
EEG=eeg_emptyset;
if ~isempty(ses)
    EEG.filename=['sub-' subj '_ses-' ses '_task-' lower(task) '_eeg.set'];
else
    EEG.filename=['sub-' subj '_task-' lower(task) '_eeg.set'];
end
EEG.filepath=PathName;
EEG.subject=subj;
EEG.session=1;
EEG.ses=ses;
EEG.task=lower(task);
EEG.trials=1;
EEG.srate=EEG_orig.srate;
    
    Itasks=find(~cellfun(@isempty,tasks_tmp));
    data_tmp=[];
    event_tmp=[];
    for kk=1:length(Itasks)
        I(1)=find([EEG_orig.event.latency]==mrklat_tmp(Itasks(kk)));
        I(2)=find([EEG_orig.event.latency]==mrklat_tmp(Itasks(kk)+1));
        event=EEG_orig.event(I(1)+1:I(2)-1);
        event(strcmp({event.code},'Comment'))=[];
        % Check lunghezza di TrLength
%         lat=diff([event.latency]);
%         lat=lat(1:2:end);
        
        data_tmp=cat(2,data_tmp,EEG_orig.data(:,event(1).latency:event(end).latency+EEG.srate));
        for zz=length(event):-1:1
           event(zz).latency=event(zz).latency-event(1).latency+1;
           event(zz).trial_type=[];
           if ~isempty(event_tmp)
               event(zz).latency=event(zz).latency+event_tmp(end).latency+EEG.srate;
           end
        end
        event_tmp=cat(2,event_tmp,event);
        EOFpnts(kk)=event_tmp(end).latency+EEG.srate;
    end
    
    EEG.event=event_tmp;
    EEG.urevent=EEG_orig.urevent;
    EEG.data=data_tmp;
    EEG.nbchan=size(EEG.data,1);
    EEG.pnts=size(EEG.data,2);
    EEG.xmax=(EEG.pnts-1)/EEG.srate;
    EEG.times=0:1000/EEG.srate:[(size(data_tmp,2)/EEG.srate)*1000]-1;
    EEG.chanlocs=EEG_orig.chanlocs;
    
    if ~isempty(ses)
        EEG.datfile=['sub-' subj '_ses-' ses '_task-' lower(task) '.fdt'];
    else
        EEG.datfile=['sub-' subj '_task-' lower(task) '.fdt'];
    end
    
    EEG.EOFpnts=EOFpnts;
    EEG.Itrig=[];
    
    Trig_CH=zeros(1,EEG.pnts);
    for kk=1:2:length(event_tmp)
       if strcmp(event_tmp(kk).type,'S 51')
           Trig_CH(event_tmp(kk).latency:event_tmp(kk+1).latency)=1;
       elseif strcmp(event_tmp(kk).type,'S 61')
           Trig_CH(event_tmp(kk).latency:event_tmp(kk+1).latency)=0.5;
       end
    end
   
    EEG.Trig_CH=Trig_CH;
    
    
    EEG=pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp');
    
    PN=EEG.filepath;
    disp(['Saving: ' fullfile(PN,EEG.filename)])
    [~] =  pop_saveset(EEG, 'filename', EEG.filename, 'filepath', PN);
    
    
    Ich19=cell2mat(cellfun(@(x) find(strcmp({EEG.chanlocs.labels},x)),MyMontage,'UniformOutput',false));
    EEG.data=EEG.data(Ich19,:);
    EEG.nbchan=size(EEG.data,1);
    EEG.chanlocs=EEG.chanlocs(Ich19);
    
    if ~isempty(ses)
        EEG.filename=['sub-' subj '_ses-' ses '_task-' lower(task) '19_eeg.set'];
    else
        EEG.filename=['sub-' subj '_task-' lower(task) '19_eeg.set'];
    end
    
    if ~isempty(ses)
        EEG.datfile=['sub-' subj '_ses-' ses '_task-' lower(task) '19_eeg.fdt'];
    else
        EEG.datfile=['sub-' subj '_task-' lower(task) '19_eeg.fdt'];
    end
    
    disp(['Saving: ' fullfile(PN,EEG.filename)])
    [~] =  pop_saveset(EEG, 'filename', EEG.filename, 'filepath', PN);    
    
    clear PN token remain FN filename EEG
end
