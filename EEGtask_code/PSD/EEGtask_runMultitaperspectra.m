% -----------------------------------------------------------------------
% Input:
%   EEG: EEGlab EEG structure
%   FR: frequency resolution - number of point for each frequency bin (Default: 2)
%   Ref: string - 'average' to consider the data in average reference - 
%       'hjorth' to consider the data in Hjorth reference (default: 'hjorth')
% Output:
% EEG: EEGlab EEG structure updated

% This function:
%   1) uses the chronux mtspectrumc code to compute the multitaper power
%      spectrum for multiple trials
%      D is [points x trials]
%      multitaper parameters set as below
%   2) scales results per trial [-1 1]
%   3) computes average and standard deviation per electrode across trials
%      after scaling (not yet implemented)
%   
% -----------------------------------------------------------------------

% --------------------------
% Authors: Fecchio Matteo, CS
% --------------------------

%[f,s, Serr, Sscale, Savg_elecs, Sstd_elecs, Savg, Sstd]

function [PSD]=EEGtask_runMultitaperspectra(EEG)

% FR = inputdlg({'Enter Frequency resolution [Hz - Default: 1]:'},...
%     'Input Frequency resolution',1,{'1'}); % Hz
% if isempty(FR{1}); frequencyResolution=1;
% else; frequencyResolution=str2double(FR{1});
% end

%define multitaper power spectrum parameters
% snippetLengthInSec=EEG.pnts/EEG.srate;

% % PARAMETERS - BE VERY CAREFUL CHANGING THESE
% freq_range = [1 30];
% interval=1*Fs; %time
% N=1; %time bandwidth product (1Hz resolution) TW= interval * freq resolution
% K=1; %no. tapers = 2*TW-1
% 
% if K>(2*N-1)
%     warning('Number of tapers must be less than or equal to 2*(TW)-1. ')
% end

%params.tapers = [N K];         %[time-bandwidth product no.tapers]
params.tapers = [1 1]; 
% params.tapers(1) = snippetLengthInSec*frequencyResolution;
% params.tapers(2) = floor(params.tapers(1)*2-1);
params.Fs = EEG.srate;          % sampling rate
params.err = [2 0.05];          % uses Jackknife error calc [1,...] for theoretical err. [...,pvalue]
params.trialave = 0;            % don't average over trials/channel
params.fpass = [1 EEG.filters.lowpass];          % calculates for freq bands [min max] 1<=f<=100
params.pad = -1;                % changes the zero padding

% datatmp = cell of data (1,n. of electrodes)
datatmp=squeeze(num2cell(EEG.data-repmat(nanmean(EEG.data,3),1,1,size(EEG.data,3)),[2 3]))';
% compute multi-taper power spectra with error for each trial, each electrode
[s,f,Serr]=cellfun(@(D) mtspectrumc(double(squeeze(D)), params),datatmp,'UniformOutput', false); 
f=f{1};

% Default: scale by area under curve.(total power)
Sscale0=cellfun(@(x) x./sum(x,1),s,'UniformOutput', false);

% save results for each electrode
Sscale=reshape(cell2mat(Sscale0),size(Sscale0{1},1),size(Sscale0{1},2),size(Sscale0,2));

PSD.SScaleOrig=reshape(cell2mat(s),size(s{1},1),size(s{1},2),size(s,2));
PSD.Serr=Serr;
PSD.SScale=Sscale;
PSD.Params=params;
PSD.f=f;
PSD.dim=size(PSD.SScaleOrig);
PSD.Params.scale_flag=1;
PSD.Params.ref=EEG.ref;
PSD.Params.DistSelected=EEG.DistSelected;
PSD.AnalysisDate=datetime;
clear snippetLengthInSec datatmp Sscale0