% -----------------------------------------------------------------------
% input: 
% - EEG structure
% - tr2reject: vector of bad epochs
% output: 
% - badTr: vector of bad epochs (considering the initial number of epochs 
%   (EEG.n_trials_orig))
% - good_trials: vector of good epochs (considering the initial number 
%   of epochs (EEG.n_trials_orig))
% This function return two vectors of bad and good epochs considering the
% initial number of epochs (EEG.n_trials_orig)

% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------

function [badTr,good_trials]=TrRej_v2(EEG, tr2reject)

% if isfield(EEG,'BadTr') && ~isempty(EEG.BadTr)
%     bad_tr_old=EEG.BadTr;
    tot_trials=1:EEG.n_trials_orig;
%     tot_trials(bad_tr_old)=[];
%     bad_tr_new=tot_trials(tr2reject);
%     badTr=unique([EEG.BadTr,bad_tr_new]); % updates the list of bad epochs
% else
    badTr=tot_trials(tr2reject);
% end
good_trials=1:EEG.trials;
if any(badTr)
    good_trials(badTr)=[];
end

