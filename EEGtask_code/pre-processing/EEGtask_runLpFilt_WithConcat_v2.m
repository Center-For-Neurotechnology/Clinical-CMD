% -----------------------------------------------------------------------
% Input: 
% - eegt structure
% - task: task selected (name of the task)
% - analyses_name: name of the analysis that has to be performed: 'Lpfilt_6'

% Output: 
% - Updated EEG structure
% - Updated parameters structure

% 1) Applies a concatenation of Epochs to prevent edge effects 
% 2) LowPass Filter: 
% - lp: high frequency cut-off [Hz]; default [30]; 
% 3) Downsampling to 256 Hz if needed
%
% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------

function [EEG,parameters] = EEGtask_runLpFilt_WithConcat_v2(eegt,task,analyses_name)

EEG=eegt.tasks.(task).analyses.(analyses_name{5}).EEG;
parameters=eegt.tasks.(task).analyses.(analyses_name{5}).parameters;

%% Concatenation
tmpTR=ones(1,EEG.n_trials_orig);
tmpTR(EEG.BadTr)=0;
EEGdata=NaN(length(EEG.chanlocs),size(EEG.data,2),EEG.n_trials_orig);
EEGdata(EEG.goodchannels,:,EEG.good_trials)=EEG.data(EEG.goodchannels,:,:);

cont=1;
for kk=1:length(tmpTR)
    if kk==1 && tmpTR(kk)~=0
        temp=[tmpTR(kk) tmpTR(kk+1)];
        chTMP=squeeze(EEGdata(:,:,kk));
        chTMPflip=fliplr(chTMP);
        switch num2str(temp)
            case '1  0'
                datatmp(:,:,kk)=[ chTMPflip chTMP chTMPflip];
            case '1  1'
                datatmp(:,:,kk)=[chTMPflip chTMP EEGdata(:,:,kk+1)];
        end
        clear chTMP chTMPflip temp
    elseif kk==length(tmpTR) && tmpTR(kk)~=0
        temp=[tmpTR(kk-1) tmpTR(kk)];
        chTMP=squeeze(EEGdata(:,:,kk));
        chTMPflip=fliplr(chTMP);
        switch num2str(temp)
            case '0  1'
                datatmp(:,:,kk)=[chTMPflip chTMP chTMPflip];
            case '1  1'
                datatmp(:,:,kk)=[EEGdata(:,:,kk-1) chTMP chTMPflip];
        end
        clear chTMP chTMPflip temp
        
    else
        if tmpTR(kk)~=0
            temp=[tmpTR(kk-1) tmpTR(kk) tmpTR(kk+1)];
            chTMP=squeeze(EEGdata(:,:,kk));
            chTMPflip=fliplr(chTMP);
            switch num2str(temp)
                case '0  1  1'
                    datatmp(:,:,kk)=[chTMPflip chTMP EEGdata(:,:,kk+1)];
                case '1  1  0'
                    datatmp(:,:,kk)=[EEGdata(:,:,kk-1) chTMP chTMPflip];
                case '0  1  0'
                    datatmp(:,:,kk)=[ chTMPflip chTMP chTMPflip];
                case '1  1  1'
                    datatmp(:,:,kk)=[EEGdata(:,:,kk-1) chTMP EEGdata(:,:,kk+1)];
            end
            clear chTMP chTMPflip temp
        end
    end
    cont=cont+1;
end
clear cont kk EEGdata tmpTR

EEGtmp=EEG;
EEGtmp.data=datatmp;
EEGtmp.pnts=size(datatmp,2);
EEGtmp.times=linspace(-EEG.times(end),EEG.times(end)*2,EEGtmp.pnts);
clear ch2 kk

%% LowPass Filtering
tmp = inputdlg({'Enter low-pass filter [Hz]:'},...
    'Input filters',1,{'30'}); 

if isempty(tmp{1})
    Lp=30;
else
    Lp=str2double(tmp{1});
end

[EEGtmp]=EEGfilters_v2(EEGtmp,[],Lp,[],[]);
clear Lp tmp

%% removing the concatenation and updating the structure
EEG.data=EEGtmp.data(:,EEG.pnts+1:end-EEG.pnts,EEG.good_trials);
EEG.filters=EEGtmp.filters;

parameters.filters2=EEGtmp.filters;

if EEG.srate>256
    [EEG]=EEGtask_dws(EEG,256);
    parameters.srate=EEG.srate;
end

