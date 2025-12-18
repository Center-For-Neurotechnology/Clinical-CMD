%% Independent Component Analysis(ICA)
% -----------------------------------------------------------------------
% Input: EEG structure
% Output: Cpca 

% Before applying ICA to reduce artifacts, check which is the maximum 
% number of independent components via singular value decomposition
% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo, Silvia Casarotto, Adenauer Girardi Casali
% --------------------------

function [Cpca]=checkCpca(EEG)

tmpdata=reshape(EEG.data,[size(EEG.data,1) size(EEG.data,2)*size(EEG.data,3)]); 
tmpdata=tmpdata-repmat(mean(tmpdata,2),[1,size(EEG.data,2)*size(EEG.data,3)]);
tempCpca=svd(tmpdata);
hfig=figure;semilogy(tempCpca,'.-')
[~,y]=ginput(1);
a=ylim;
hold on
Cpca=find(tempCpca>y,1,'last');
line([Cpca Cpca],[a(1) a(2)],'Color','k','LineStyle','--');
hold off
clear y a tempCpca tmpdata
disp('check whether the vertical dashed line correctly separates the eigenvalues close to zero from the ones much higher than zero')
waitfor(hfig)