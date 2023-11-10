function [] = EEGt_fromBIDS2EEGtask_getfile()
pathBIDS=uigetdir('','Select BIDS Folder (either the folder of a single subject or a main folder)');
if pathBIDS==0; return; end

list=dir(fullfile(pathBIDS,'**/*eeg.vhdr'));

pathOUT=uigetdir(pathBIDS,'Select the folder where save the data (derivatives folder recommended)');
if pathOUT==0; return; end

sessionlist={list.name}';

SubjSess={};
SubjSess(:,1)={list.name};
SubjSess(:,2)={list.folder};
[token,remain]=strtok(sessionlist,'_');
SubjSess(:,3)=erase(token,'sub-');
SubjSess(strncmp(remain,'_ses',4),4)=erase(strtok(remain(strncmp(remain,'_ses',4)),'_'),'ses-');
[~,remaintmp(strncmp(remain,'_ses',4),1)]=strtok(remain(strncmp(remain,'_ses',4)),'_');
remaintmp(setdiff(1:length(sessionlist),find(strncmp(remain,'_ses',4))))=remain(setdiff(1:length(sessionlist),find(strncmp(remain,'_ses',4))));
[token,~]=strtok(remaintmp,'_');
SubjSess(:,5)=erase(token,'task-');
clear remain remaintmp sessionlist token

% SubjSessORIG=SubjSess;
tmp=unique(SubjSess(:,3));
Sel = listdlg('ListString',tmp,'SelectionMode','single');
if isempty(Sel)
    return
end
subj=tmp{Sel};
SubjSess=SubjSess(strcmp(SubjSess(:,3),subj),:);

if any(~cellfun(@(x) isempty(x),SubjSess(:,4)))
    tmp=unique(SubjSess(:,4));
    if length(tmp)>1
        Sel = listdlg('ListString',tmp,'SelectionMode','single');
    else
        Sel=1;
    end
    ses=tmp{Sel};
    SubjSess=SubjSess(strcmp(SubjSess(:,4),ses),:);
else
    ses=[];
end

tmp=unique(SubjSess(:,5));
Sel = listdlg('ListString',tmp,'SelectionMode','multiple');
if isempty(Sel)
    return
end
for jj=1:length(Sel)
    task=tmp{Sel(jj)};
    SubjSess_t=SubjSess(strcmp(SubjSess(:,5),task),:);
    
    if isempty(subj) || isempty(task);return;end
    EEGt_fromBIDS2EEGtask_mergeBIDSrun(SubjSess_t,subj,ses,task,pathOUT)
end
