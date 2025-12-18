%% Check path and add to MATLAB search path
% -----------------------------------------------------------------------
% Input: 
% - op_cl: string (i)'open' set the path for EEGtask, or (ii)'close'
% restore the paths saved in the variable 'wel'
% - wel: list of paths that has to be restored when closing EEGtask
% Output:
% - welcome: list of paths previous to EEGtask opening
% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------

function [welcome]=EEGtask_controlpath(op_cl,wel)
%-----------------------------------------------------------------------
switch op_cl
    case 'open'
        welcome=path;
        cdir=fileparts(which('EEGtask.m'));
        a=strfind(welcome,cdir);
        if length(a)>1
            %     figure1_CloseRequestFcn(handles.figure1,[],handles)
            errordlg('EEGtask Path Error: please remove any EEGtask subfolder from the Matlab path');
            error('EEGtask Path Error: please remove any EEGtask subfolder from the Matlab path');
        end
        addpath(fullfile(cdir,'EEGtask_code'));
        addpath(fullfile(cdir,'EEGtask_code','EEG_ICA'));
        addpath(fullfile(cdir,'EEGtask_code','EEGClass'));
        addpath(fullfile(cdir,'EEGtask_code','GUIs'));
        addpath(fullfile(cdir,'EEGtask_code','plotData'));
        addpath(fullfile(cdir,'EEGtask_code','pre-processing'));
        addpath(fullfile(cdir,'EEGtask_code','PSD'));
        
        addpath(fullfile(cdir,'external','Code4Spectra'));
        addpath(fullfile(cdir,'external','eeglab2020_0'));
        addpath(fullfile(cdir,'external','eeglab2020_0','functions'));
        addpath(fullfile(cdir,'external','eeglab2020_0','functions','timefreqfunc'));
        addpath(fullfile(cdir,'external','eeglab2020_0','functions','guifunc'));
        addpath(fullfile(cdir,'external','eeglab2020_0','functions','adminfunc'));
        addpath(fullfile(cdir,'external','eeglab2020_0','functions','miscfunc'));
        addpath(fullfile(cdir,'external','eeglab2020_0','functions','popfunc'));
        addpath(fullfile(cdir,'external','eeglab2020_0','functions','sigprocfunc'));
%         addpath(fullfile(cdir,'external','eeglab2020_0','functions','@mmo'));
%         addpath(fullfile(cdir,'external','eeglab2020_0','functions','@eegobj'));
        
        
        addpath(fullfile(cdir,'external','eeglab2020_0','functions','studyfunc'));
%         addpath(fullfile(cdir,'external','eeglab2020_0','plugins','ICLabel'));
%         addpath(fullfile(cdir,'external','eeglab2020_0','plugins','dipfit'));
        addpath(genpath(fullfile(cdir,'external','eeglab2020_0','plugins')));
    case 'close'
        path(wel)
        welcome=wel;
        
end

  