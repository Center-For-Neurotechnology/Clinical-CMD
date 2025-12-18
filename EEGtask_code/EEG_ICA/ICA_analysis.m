%% Independent Component Analysis(ICA)
% -----------------------------------------------------------------------
% input: 
% - eegt structure
% - dataAVGref: data in average reference [channels x time x number of epochs]
% - Cpca: [N] decompose a principal component subspace of the data. 
%   Value is the number of PCs to retain.

% output: 
% - Updated EEG structure

% Run ICA using the runica method from EEGlab

% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------

function [EEG]=ICA_analysis(EEG,dataAVGref,Cpca)
% concatenate epochs
tmpdata=reshape(dataAVGref,[size(dataAVGref,1) size(dataAVGref,2)*size(dataAVGref,3)]); 
% report the data with zero mean
tmpdata=tmpdata-repmat(mean(tmpdata,2),[1,size(dataAVGref,2)*size(dataAVGref,3)]);

[EEG.icaweights,EEG.icasphere,EEG.compvars] = runica( tmpdata, 'lrate', 0.001, 'pca', Cpca);
EEG.compvars=EEG.compvars/sum(EEG.compvars)*100;
EEG.icaact = (EEG.icaweights*EEG.icasphere)*reshape(tmpdata, size(dataAVGref,1), size(dataAVGref,3)*EEG.pnts); %S=A_trasp*X
EEG.icaact = reshape( EEG.icaact, size( EEG.icaact,1), EEG.pnts, size(dataAVGref,3));            
EEG.icawinv = pinv( EEG.icaweights*EEG.icasphere );
EEG.icachansind=1:EEG.nbchan;
