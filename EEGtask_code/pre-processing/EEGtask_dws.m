function [EEG]=EEGtask_dws(EEG,NewRate)

timesOUT=linspace(0,EEG.times(end),EEG.times(end)*NewRate);
datatmp=squeeze(num2cell(EEG.data,2));
datatmp=cellfun(@(x) interp1(EEG.times,x,timesOUT,'spline'),datatmp,'UniformOutput', false);
EEG.data=reshape(cell2mat(datatmp),size(datatmp,1),length(datatmp{1}),size(datatmp,2));
clear datatmp

EEG.times=timesOUT;
EEG.srate=NewRate;
EEG.pnts=size(EEG.data,2);
end
