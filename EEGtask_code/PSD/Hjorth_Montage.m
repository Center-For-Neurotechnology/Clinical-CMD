% -----------------------------------------------------------------------
% Input:
% EEG: EEGlab EEG structure
% Output:
% EEG: EEGlab EEG structure updated
% DistSelected: number from 0 to 100 (Default: 82). 
%                 Select the number of considered channels
% check: number [0 or 1] - 1 imagesc of nearest_neighbors matrix 
%        (useful to understand how many channels have been considered for 
%        calculating the Hjorth montage). If 1, Hjorth montage is not
%        computed. If 0, Hjorth montage is computed and saved
% -----------------------------------------------------------------------

% --------------------------
% Authors: Fecchio Matteo, David Zhou
% --------------------------

function [EEG]=Hjorth_Montage(EEG,DistSelected,check)

subchanlocs = [EEG.chanlocs.X; EEG.chanlocs.Y; EEG.chanlocs.Z].';
chandists = squareform(pdist(subchanlocs));
if isempty(DistSelected)
    DistSelected=82;
end
% DistSelected=82 approximately good at finding 3-5 neighbors per electrode
nearest_neighbors = lt(chandists,DistSelected*unique(round([EEG.chanlocs.sph_radius]))/100) & ~eq(chandists,0);

if check==1
    figure('NumberTitle','off','Name',['Radius: ', num2str(unique(round([EEG.chanlocs.sph_radius]))),' - Selected Distance: ' num2str(DistSelected) '%']),
    subplot(1,2,1)
    imagesc(nearest_neighbors)
    axis('square')
    yticks(1:length(EEG.chanlocs))
    yticklabels({EEG.chanlocs.labels})
    xticks(1:length(EEG.chanlocs))
    xticklabels({EEG.chanlocs.labels})
    subplot(1,2,2)
    topoplot(zeros(1,length(EEG.chanlocs)), EEG.chanlocs,'electrodes','ptslabels','style','blank');
else
    good_ch=setdiff(1:size(EEG.data,1),EEG.badchannels);
    datatmp=squeeze(num2cell(EEG.data(good_ch,:,:),[1 2]))';
    nearest_neighbors=nearest_neighbors(good_ch,good_ch);
    datatmp=cellfun(@(x) nearest_neighbors*x./repmat(sum(nearest_neighbors)',1,size(x,2)),datatmp,'UniformOutput',false);
    RefH=reshape(cell2mat(datatmp),size(datatmp{1},1),size(datatmp{1},2),size(datatmp,2));
    EEG.data=EEG.data(good_ch,:,:)-RefH;
    EEG.nbchan=length(good_ch);
    EEG.ref='hjorth';
    EEG.nearest_neighbors=nearest_neighbors;
    EEG.DistSelected=DistSelected;
end