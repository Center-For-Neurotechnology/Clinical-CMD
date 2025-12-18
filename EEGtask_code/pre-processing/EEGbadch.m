% -----------------------------------------------------------------------
% Input: 
% - EEG structure
% Output: 
% - EEG structure updated with bad channels
%
% This function consider one EEG channel bad if:
% - is flat;
% - contains large discontinuities;
% - the average amplitude is different from the distrubution of the 
%   amplitudes for more than 3.5 std.
% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------
function [EEG]=EEGbadch(EEG)
tempdata=EEG.data;
tempch=[];
distr=[];
h = waitbar(0,'Performing Channel Rejection...');
% looking for flat channels or channels with large discontinuities
for kk=1:size(EEG.data,1)
    waitbar(kk/size(EEG.data,1))
    if  (max(tempdata(kk,:))-min(tempdata(kk,:)))>10000 || max(tempdata(kk,:))-min(tempdata(kk,:))<0.1% max(tempdata(kk,:))>=150 || min(tempdata(kk,:))<=-150
        tempch=[tempch,kk];
    end
    temp=max(tempdata(kk,:))-min(tempdata(kk,:));
    distr=[distr,temp];
end
close (h)
%%%%%%% additional badchannels%%%%%
% a channel is considered as bad if the amplitude is different from the 
% distrubution of the amplitudes
distr(tempch)=nan;
otherbad=find(distr>=nanmean(distr)+3.5*nanstd(distr));
% if not present,creates 'badchannels' field in the EEG structure
if ~isfield(EEG,'badchannels')
    EEG.badchannels=[];
end
tempch=union(tempch,otherbad);
% if more that 5 channels are considered as bad, a check is needed
if length(tempch)>5
    eegplot(EEG.data,'winlength',30) % Color the bad ch in red
    bad_elec = input('Channels to reject: ');
    EEG.badchannels=bad_elec;
    clear bad_elec
else
    EEG.badchannels=tempch;
end
clear tempch kk j tempdata h