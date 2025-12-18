% -----------------------------------------------------------------------
% Input: 
% - EEG structure
% Output: 
% - Updated EEG structure

% This function: 
% - opens the windows eegplot() and GUI_rej_ch() for epoch and channel rejection
% - Once the window for channel rejection is closed, the variables
%   'bad_elec' and 'trialrej' are loaded from the 'base' workspace
% - EEG structure is updated with bad/good channels and bad/good epochs

% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------

function [EEG]=EEGSelect_ChEpochs(EEG)

% creates a temporary EEG structure if data are not epoched 
if length(size(EEG.data))==2
    tmp=EEGepochs(EEG);
else
    tmp=EEG;
end

badchcolor=repmat({[0 0 0]},EEG.nbchan,1);
if isfield(EEG,'badchannels') && ~isempty(EEG.badchannels)
    badCH=EEG.badchannels;
    ansHide = questdlg('Do you want to hide bad channels?', ...
	'Hide bad channels','Yes','No','No');
    if strcmp(ansHide,'Yes')
        tmp.data(badCH,:,:)=NaN; % set bad channels as NaN
    else
        badchcolor(badCH,:)=repmat({[1 0 0]},numel(badCH),1);
    end
else
    badCH=[];
end



rejepochcol=[0.7 1 0.9]; % Color of rejected epochs - color of the windows for eegplot()
rejepoch=zeros(1,tmp.trials); % rejection vector (0 and 1) with one value per trial
if isfield(EEG,'BadTr') && ~isempty(EEG.BadTr)
    rejepoch(EEG.BadTr)=1;
end
% electrode rejection array (size nb_elec x trials) also made of 0 and 1.
rejepochE=zeros(tmp.nbchan,tmp.trials); 
% array defining windows which is compatible with the function eegplot()
winrej=trial2eegplot(rejepoch,rejepochE,tmp.pnts,rejepochcol); 
clear rejepochcol rejepochE

n_epochs=size(tmp.data,3);
n_points=size(tmp.data,2);
assignin('base','n_epochs',n_epochs)
assignin('base','n_points',n_points)
% convert EEGPLOT rejections (TMPREJ) into trial rejections
cmd = '[trialrej, ~]=eegplot2trial(TMPREJ,n_points,n_epochs);';
eegplot(tmp.data,'winlength',5,'srate',EEG.srate,...
    'limits',[EEG.times(1) EEG.times(end)],'winrej',winrej,...
    'spacing',70,'butlabel','REJECT','command',cmd,'color',badchcolor);
disp('data have been displayed for channels rejection and for first round of trials rejection')

if size(badCH,1)==1
    badCH=badCH';
end

h=GUI_rej_ch(EEG.chanlocs,badCH);
waitfor(h) % to continue, close the GUI_rej_ch window
evalin( 'base', 'clear(''n_epochs'')' )
evalin( 'base', 'clear(''n_points'')' )
try
    bad_elec=evalin('base','bad_elec'); % get variable 'bad_elec' from workspace 'base'
    evalin( 'base', 'clear(''bad_elec'')' ); % clear variable 'bad_elec' from workspace 'base'
catch
    bad_elec=[];
end
EEG.badchannels=bad_elec;
EEG.goodchannels=setdiff(1:EEG.nbchan,EEG.badchannels);
clear bad_elec h badCH
disp('bad channels have been selected')

try
    trialrej=evalin('base','trialrej');
    evalin( 'base', 'clear(''trialrej'')' );
    evalin( 'base', 'clear(''TMPREJ'')' );
    tr2reject=find(trialrej==1);
catch
    tr2reject=rejepoch;
end
[EEG.BadTr, EEG.good_trials]=TrRej_v2(tmp, tr2reject);
  
