%% Independent Component Analysis(ICA) and IClabel
% -----------------------------------------------------------------------
% input: 
% - eegt structure
% - task: task selected (name of the task)
% - analyses_name: name of the analysis that has to be performed: 'RunICA_4'

% output: 
% - Updated eegt structure
% - Updated EEG structure
% - Updated parameters structure

% The function requires to enter:
% 1) threshold for muscle component (num from 0 to 1): default 0.9
% 2) threshold for eye components (num from 0 to 1): default 0.9
% 3)  threshold for heart components (num from 0 to 1): default 0.9
% These threshold are used to label muscle, eye, and heart components with
% the eeglab functions pop_iclabel and pop_icflag

% Before applying ICA (run ICA using the runica method from EEGlab), 
% check the maximum number of independent components via singular
% value decomposition (function checkCpca)

% The function automatically opens topoplots of '2D Scalp Maps (Spectra)'
% and plots all the components epoch by epoch (eegplot) to allow for an
% additional epoch rejection based on ICA compontents

% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------

function [eegt,EEG,parameters]=EEGtask_runICA(eegt,task,analyses_name)

EEG=eegt.tasks.(task).analyses.(analyses_name{3}).EEG;

choice = 'Yes';
tmp = inputdlg({'Enter threshold for muscle component (num from 0 to 1):';...
    'Enter threshold for eye components (num from 0 to 1):';...
    'Enter threshold for heart components (num from 0 to 1):'},...
    'Thresholds for ICA components:',1,{'0.9';'0.9';'0.9'}); 
if isempty(tmp{1});MuscleP=0.9;
else;MuscleP=str2double(tmp{1});
end
if isempty(tmp{2}); EyeP=0.9;
else; EyeP=str2double(tmp{2});
end
if isempty(tmp{3}); HeartP=0.9;
else; HeartP=str2double(tmp{3});
end
Cpca=checkCpca(EEG);
check=0;
while strcmp(choice,'Yes')
    % run ICA using the runica method from EEGlab
    EEG=ICA_analysis(EEG,EEG.data,Cpca);
    EEG = pop_iclabel(EEG, 'default');
    
    [EEG] = pop_icflag(EEG, [NaN NaN;MuscleP 1;EyeP 1;HeartP 1;NaN NaN;NaN NaN;NaN NaN]);
    
    check=check+1;
    if check>1
        choice_exit = questdlg('Would you like to visually inspect the epochs one more time?', ...
            'check trial', 'Yes','No','No');
        if strcmp(choice_exit,'No')
            break
        end
    end
    
    pop_topoplot( EEG, 0, 1:1:size(EEG.icawinv,2), '2D Scalp Maps (Spectra)' , [], 'electrodes','on','iclabel','on');
    
    hfig=gcf;
    
    cmd='tmp123=true;clear tmp123';
    eegplot( EEG.icaact, 'srate', EEG.srate,...
        'title','Scroll component activities -- eegplot()',...
        'limits', [EEG.xmin EEG.xmax]*1000,...
        'butlabel','REJECT','command',cmd);
    h=gcf;
    waitfor(h)
    
    close(hfig)
    try
        TMPREJ=evalin('base','TMPREJ');
        evalin( 'base', 'clear(''TMPREJ'')' );
        if ~isempty(TMPREJ)
            [trialrej, ~]=eegplot2trial(TMPREJ,EEG.pnts, size(EEG.data,3));
            tr2reject=find(trialrej==1);
            
            Ibad_tr2rej=EEG.good_trials(tr2reject);
            
            EEG.data(:,:,tr2reject)=[];
            EEG.trials=size(EEG.data,3);
            EEG.event(tr2reject)=[];
            EEG.BadTr=sort([EEG.BadTr, Ibad_tr2rej]);
            EEG.good_trials(tr2reject)=[];
            EEG.dim=size(EEG.data);
            
            eegt.tasks.(task).analyses.(analyses_name{2}).parameters.badepochs=EEG.BadTr;
            eegt.tasks.(task).analyses.(analyses_name{2}).parameters.goodepochs(tr2reject)=[];
            eegt.tasks.(task).analyses.(analyses_name{2}).EEG.BadTr=EEG.BadTr;
            eegt.tasks.(task).analyses.(analyses_name{2}).EEG.good_trials(tr2reject)=[];
            
            eegt.tasks.(task).analyses.(analyses_name{3}).parameters.badepochs=EEG.BadTr;
            eegt.tasks.(task).analyses.(analyses_name{3}).parameters.goodepochs(tr2reject)=[];
            eegt.tasks.(task).analyses.(analyses_name{3}).parameters.eventSel(tr2reject)=[];
            eegt.tasks.(task).analyses.(analyses_name{3}).parameters.dimSelEvents=size(EEG.data);
            eegt.tasks.(task).analyses.(analyses_name{3}).EEG.trials=size(EEG.data,3);
            eegt.tasks.(task).analyses.(analyses_name{3}).EEG.event(tr2reject)=[];
            eegt.tasks.(task).analyses.(analyses_name{3}).EEG.BadTr=EEG.BadTr;
            eegt.tasks.(task).analyses.(analyses_name{3}).EEG.good_trials(tr2reject)=[];
            eegt.tasks.(task).analyses.(analyses_name{3}).EEG.dim=size(EEG.data);
            
            path_orig=cd;
            cd(fullfile(eegt.PathName,'EEGtask',task))
            fid=fopen(eegt.tasks.(task).analyses.(analyses_name{3}).filename,'w');
            fwrite(fid,reshape(EEG.data,[EEG.nbchan,EEG.pnts*EEG.trials]),'double');
            fclose(fid);
            cd(path_orig)
            
            choice='Yes';
        else
            choice='No';
        end
    catch
        choice='No';
    end
end
EEG.comp2remove=[];

parameters=eegt.tasks.(task).analyses.(analyses_name{3}).parameters;
parameters.ICA.muscleP=MuscleP;
parameters.ICA.eyeP=EyeP;
parameters.ICA.heartP=HeartP;
parameters.ICA.Cpca=Cpca;
parameters.ICA.dim_icaact=size(EEG.icaact);
parameters.ICA.comp2remove=[];


