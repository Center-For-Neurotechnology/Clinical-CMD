function EEGt_fromEDF2EEGtask(EEG,data,subj,ses,task,PN,begin_blocks,end_blocks,THR)

data_tmp=[];
EOFpnts=0;
for kk=1:length(begin_blocks)
    data_tmp=cat(2,data_tmp,data(:,begin_blocks(kk):end_blocks(kk)));
    EOFpnts(kk)=size(data_tmp,2);
end
times=0:1000/EEG.srate:[(size(data_tmp,2)/EEG.srate)*1000]-1;

if ~isempty(ses)
    EEG.filename=['sub-' subj '_ses-' ses '_task-' task '_eeg.set'];
else
    EEG.filename=['sub-' subj '_task-' task '_eeg.set'];
end

EEG.data=data_tmp;
EEG.task=task;
EEG.pnts=size(EEG.data,2);
EEG.xmax=(EEG.pnts-1)/EEG.srate;
EEG.times=times;

if ~isempty(ses)
    EEG.datfile=['sub-' subj '_ses-' ses '_task-' task '.fdt'];
else
    EEG.datfile=['sub-' subj '_task-' task '.fdt'];
end
EEG.EOFpnts=EOFpnts;

Trig_CH=EEG.data(EEG.Itrig,:);
Trig_CH=abs(Trig_CH-mean(Trig_CH));
Trig_CH=medfilt1(Trig_CH,100);
Trig_CH=(Trig_CH-min(Trig_CH))/(max(Trig_CH)-min(Trig_CH));

sampcontrol=3*EEG.srate;
index_r=find(abs(Trig_CH)>THR);
index_r(find(diff(index_r)<sampcontrol)+1)=[];
index_d=find(abs(Trig_CH)>THR);
index_d(find(diff(index_d)<sampcontrol))=[];
ITr=sort([index_d,index_r]);

cont=1;
for kk=2:2:(length(ITr))
    if kk<length(ITr)
        TrLength(cont)=ITr(kk+1)-ITr(kk);
    else
        TrLength(cont)=length(Trig_CH)-ITr(kk);
    end
    cont=cont+1;
end
TrLength=min(TrLength);
clear kk cont

switch EEG.task
    case 'lang'
        figure,
        plot(Trig_CH,'k'), hold on,
        plot(index_r(:),Trig_CH(index_r(:)),'*r')
        plot(index_d(:),Trig_CH(index_d(:)),'*r')
        plot(index_d(:)+1,Trig_CH(index_d(:)+1),'*b')
        plot(index_d(:)+TrLength,Trig_CH(index_d(:)+TrLength),'*b')
        title([num2str(fix(length(ITr)/2)) ' blocks found - Press h for Help'])
        ITr=sort([index_r index_d index_d+1 index_d+TrLength]);
    case 'hand'
        figure,
        plot(Trig_CH,'k'), hold on,
        plot(index_d(:),Trig_CH(index_d(:)),'*r')
        plot(index_d(:)+TrLength,Trig_CH(index_d(:)+TrLength),'*b')
        title([num2str(fix(length(ITr)/2)) ' blocks found - Press h for Help'])
        ITr=sort([index_d index_d+TrLength]);
end
EEG.Trig_CH=Trig_CH;
line([EEG.EOFpnts; EEG.EOFpnts],repmat([0, 1]',1,length(EEG.EOFpnts)),'Color','m')
clear sampcontrol THR Itrig index_d index_r TrLength CH_Trig_name Trig_CH
% Add trigger at the beginning and at the end of each block
Trig_Stim={'S 51','S 59','S 61','S 69'};
for kk=1:4
    for jj=kk:4:length(ITr)
        EEG.event(1,jj).latency=ITr(jj);
        EEG.event(1,jj).duration=1;
        EEG.event(1,jj).channel=0;
        EEG.event(1,jj).bvtime=[];
        EEG.event(1,jj).bvmknum=jj;
        EEG.event(1,jj).type=Trig_Stim{kk};
        EEG.event(1,jj).code='Stimulus';
        EEG.event(1,jj).epoch=[];
        EEG.event(1,jj).urevent=jj;
        EEG.event(1,jj).trial_type=[];
        
        EEG.urevent(1,jj).latency=ITr(jj);
        EEG.urevent(1,jj).duration=1;
        EEG.urevent(1,jj).channel=0;
        EEG.urevent(1,jj).bvtime=[];
        EEG.urevent(1,jj).bvmknum=jj;
        EEG.urevent(1,jj).type=Trig_Stim{kk};
        EEG.urevent(1,jj).code='Stimulus';
        EEG.urevent(1,jj).epoch=[];
        EEG.event(1,jj).trial_type=[];
    end
end
clear ITr kk jj Trig_Stim


MyMontage={'Fp1';'Fp2';'F7';'F3';'Fz';'F4';'F8';'T3';'C3';'Cz';'C4';'T4';'T5';'P3';'Pz';'P4';'T6';'O1';'O2'};
Ich=cell2mat(cellfun(@(x) find(strcmpi({EEG.chanlocs.labels},x)),MyMontage,'UniformOutput', false));
EEG.data=EEG.data(Ich,:);
EEG.chanlocs=EEG.chanlocs(Ich);
EEG.nbchan=size(EEG.data,1);
clear Ich MyMontage
%
% PN=fullfile(pathBIDS, 'derivatives');
if ~strcmp(EEG.filepath,PN)
    FN=EEG.filepath(strfind(EEG.filepath,'sub-'):end);
    [token,remain]=strtok(FN,filesep);
    while ~isempty(token)
        if ~isdir(fullfile(PN,token))
            mkdir(PN,token)
        end
        PN=fullfile(PN,token);
        [token,remain]=strtok(remain,filesep);
        if strcmpi(token,'eeg')
            break
        end
    end
end
disp(['Saving: ' fullfile(PN,EEG.filename)])
[~] =  pop_saveset(EEG, 'filename', EEG.filename, 'filepath', PN);

clear PN token remain FN filename