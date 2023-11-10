function [] = EEGt_fromEDF2EEGtask_getfile()
[FileName,PathName]=uigetfile('*.edf','Select EDF File');
if FileName==0; return; end

pathOUT=uigetdir(PathName,'Select the folder where save the data (derivatives folder recommended)');
if pathOUT==0; return; end

[data,header] = EEGlab_readedf(fullfile(PathName,FileName));

prompt = {'Enter Subject/Patient ID:';'Enter Session name';};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'';''};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
if isempty(answer{1}); warndlg('Subject/Patient ID is required');return; end
subj=answer{1};
ses=answer{2};
clear answer


EEG=eeg_emptyset;
EEG.filepath=pathOUT;
EEG.subject=subj;
EEG.session=1;
EEG.ses=ses;
% EEG.task=task;
EEG.nbchan=size(data,1);
EEG.trials=1;
% EEG.pnts=size(EEG.data,2);
EEG.srate=header.samplerate(1);
% EEG.xmax=(EEG.pnts-1)/EEG.srate;
% EEG.times=times;
chanlocs = struct('labels', cellstr(header.channelname));
EEG.chanlocs=pop_chanedit(chanlocs, 'lookup','standard-10-5-cap385.elp');


EEG.Itrig = listdlg('PromptString','Select the Trigger Channel:',...
                'SelectionMode','single',...
                'ListString',{EEG.chanlocs.labels});
if isempty(EEG.Itrig); warndlg('Trigger Channel is required');return; end
          
prompt = {'Enter threshold:'};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'0.1'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
if any(cellfun(@(x) isempty(x),answer)); warndlg('Trigger Channel Threshold is required'); return; end
THR=str2double(answer{1});

%%
Trig_CH=data(EEG.Itrig,:);
Trig_CH=abs(Trig_CH-mean(Trig_CH));
Trig_CH=medfilt1(Trig_CH,100);
Trig_CH=(Trig_CH-min(Trig_CH))/(max(Trig_CH)-min(Trig_CH));

sampcontrol=3*EEG.srate;
index_r=find(abs(Trig_CH)>THR);
index_r(find(diff(index_r)<sampcontrol)+1)=[];
index_d=find(abs(Trig_CH)>THR);
index_d(find(diff(index_d)<sampcontrol))=[];
ITr=sort([index_d,index_r]);

tmp=fix(diff(ITr)/EEG.srate);

%HAND
prompt = {'Length Instructions ON:'; 'Length Block ON';...
    'Length Instructions OFF:'; 'Length Block OFF';'Number of Trials'};
dlg_title = 'HAND PARADIGM - Enter:';
num_lines = 1;
defaultans = {'3';'11';'3';'11';'8'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
if any(cellfun(@(x) isempty(x),answer)); warndlg('All fields are required'); return; end
TR_Pattern=[str2double(answer{1}) str2double(answer{2}) str2double(answer{3}) str2double(answer{4})];
hand_pattern=repmat(TR_Pattern,1,str2double(answer{5}));
hand_pattern(end)=[];
tmp(intersect(find(tmp>=str2double(answer{1})-1),find(tmp<=str2double(answer{1})+1)))=str2double(answer{1});
tmp(intersect(find(tmp>=str2double(answer{2})-1),find(tmp<=str2double(answer{2})+1)))=str2double(answer{2});
output_hand = strfind(tmp,hand_pattern);
if isempty(output_hand)
    h=figure('Units','normalized','Position',[0 0 1 1]);
    plot(Trig_CH,'k'), hold on,
    plot(index_d(:),Trig_CH(index_d(:)),'*r')
    plot(index_r(:),Trig_CH(index_r(:)),'*b')
    cont=1;
    while ishandle(h) && strcmp(get(h, 'type'), 'figure')
        [x_ih(cont), ~]=ginput(1);
        [x_fh(cont), ~]=ginput(1);
        if cont==3
            close(h)
        end
        cont=cont+1;
    end
    begin_hand_blocks=index_r(cell2mat(cellfun(@(x) find(index_r>x,1),num2cell(x_ih),'UniformOutput',false)));
    end_hand_blocks=index_d(cell2mat(cellfun(@(x) find(index_d<x,1,'last'),num2cell(x_fh),'UniformOutput',false)))+(str2double(answer{4})+1)*fix(EEG.srate);
else
    begin_hand_blocks=ITr(output_hand);
    end_hand_blocks=ITr(output_hand+length(hand_pattern))+(str2double(answer{4})+1)*fix(EEG.srate);
end
% %LANGUAGE
% prompt = {'Length Block ON';'Length Block OFF';'Number of Trials'};
% dlg_title = 'LANGUAGE PARADIGM - Enter:';
% num_lines = 1;
% defaultans = {'10';'11';'8'};
% answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
% if any(cellfun(@(x) isempty(x),answer)); warndlg('All fields are required'); return; end
% TR_Pattern=[str2double(answer{1}) str2double(answer{2})];
% lang_pattern=repmat(TR_Pattern,1,str2double(answer{3}));
% lang_pattern(end)=[];
% output_lang = strfind(tmp,lang_pattern);
% if isempty(output_lang)
%     h=figure;
%     plot(Trig_CH,'k'), hold on,
%     plot(index_d(:),Trig_CH(index_d(:)),'*r')
%     plot(index_r(:),Trig_CH(index_r(:)),'*b')
%     cont=1;
%     while ishandle(h) && strcmp(get(h, 'type'), 'figure')
%         [x_il(cont), ~]=ginput(1);
%         [x_fl(cont), ~]=ginput(1);
%         if cont==3
%             close(h)
%         end
%         cont=cont+1;
%     end
%     begin_lang_blocks=index_r(cell2mat(cellfun(@(x) find(index_r>x,1),num2cell(x_il),'UniformOutput',false)));
%     end_lang_blocks=index_d(cell2mat(cellfun(@(x) find(index_d<x,1,'last'),num2cell(x_fl),'UniformOutput',false)))+(str2double(answer{2})+1)*fix(EEG.srate);
% else
%     begin_lang_blocks=ITr(output_lang);
%     end_lang_blocks=ITr(output_lang+length(lang_pattern))+(str2double(answer{2})+1)*fix(EEG.srate);
% end

EEGt_fromEDF2EEGtask(EEG,data,subj,ses,'hand',pathOUT,begin_hand_blocks,end_hand_blocks,THR)
% EEGt_fromEDF2EEGtask(EEG,data,subj,ses,'lang',pathOUT,begin_lang_blocks,end_lang_blocks,THR)



