%% Independent Component Analysis(ICA)
% -----------------------------------------------------------------------
% input: 
% - eegt structure
% - task: task selected (name of the task)
% - analyses_name: name of the analysis that has to be performed: 'PostICA_5'

% output: 
% - Updated EEG structure
% - Updated parameters structure

% The function automatically open topoplots of '2D Scalp Maps (Spectra)'
% labelling muscle, eye, and heart components (estimated with the eeglab
% functions pop_iclabel and pop_icflag

% The function opens a graphical user interface (ICA_selectandremove) that
% allows the user to select which ICA components to discard (if any)

% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------

function [EEG,parameters] = EEGtask_selectICAcomponents(eegt,task,analyses_name)

EEG=eegt.tasks.(task).analyses.(analyses_name{4}).EEG;
parameters=eegt.tasks.(task).analyses.(analyses_name{4}).parameters;

EEG.icaact = (EEG.icaweights*EEG.icasphere)*reshape(EEG.data, EEG.nbchan, EEG.trials*EEG.pnts);
EEG.icaact = reshape( EEG.icaact, size( EEG.icaact,1), EEG.pnts, EEG.trials);

pop_topoplot( EEG, 0, 1:1:size(EEG.icawinv,2), '2D Scalp Maps (Spectra)' , [], 'electrodes','on','iclabel','on');
hfig=gcf;

h=ICA_selectandremove(EEG);

waitfor(h)
if ishandle(hfig)
    close(hfig)
end

data_GUI = evalin('base', 'data_GUI');
evalin( 'base', 'clear(''data_GUI'')' );
disp([num2str(length(data_GUI.comp2remove)) ' components rejected'])
EEG.data=data_GUI.compproj;
EEG.comp2remove=data_GUI.comp2remove;
EEG.icaact=[];
EEG.icawinv=[];
EEG.icasphere=[];
EEG.icaweights=[];
EEG.icachansind=[];

parameters.ICA.compproj_dim=size(data_GUI.compproj);
parameters.ICA.comp2remove=data_GUI.comp2remove;
parameters.ICA.var_compproj=data_GUI.var_compproj;

