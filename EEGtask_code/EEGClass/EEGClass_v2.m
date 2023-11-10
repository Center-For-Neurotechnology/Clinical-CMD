function [class]=EEGClass_v2(specON,specOFF,badCH,f,chanlocs,n_k,iter,n_rep)
% n_k=20; %!!!
% iter=500;
% n_rep=10;
freq_bands = {[1,3],[4,7],[8,13],[14,30]};
Ifreqs=cellfun(@(x) find(abs(f-x(1))==min(abs(f-x(1)))): ...
    find(abs(f-x(2))==min(abs(f-x(2)))),freq_bands,'UniformOutput',false);
goodCH=setdiff(1:length(chanlocs),badCH);

% Generate features by averaging power over bands instead of using
% power at each electrode.
ON=cell2mat(cellfun(@(x) squeeze(mean(specON(x,:,:))),Ifreqs,'UniformOutput',false));
OFF=cell2mat(cellfun(@(x) squeeze(mean(specOFF(x,:,:))),Ifreqs,'UniformOutput',false));

group_labels = [ones(size(ON,1),1); zeros(size(OFF,1),1)];
data = [ON; OFF];

class_recall = NaN(1,n_rep);
class_precision = NaN(1,n_rep);
class_accuracy = NaN(1,n_rep);
pooled_wt_all = NaN(n_rep, length(goodCH),n_k);
pooled_wt_avg = NaN(n_rep, length(goodCH),1);
pooled_wt_avg_freq = NaN(n_rep, length(goodCH),length(freq_bands));
h = waitbar(0,'Wait...');
for jj = 1:n_rep
    cp = classperf(group_labels); % Create and initialize an empty classifier performance object.
    ind = crossvalind('Kfold',group_labels,n_k); % Generate indices for splitting data
    w_all = NaN(size(data,2),n_k);
    test=cellfun(@(x) (ind == x),num2cell(1:n_k),'UniformOutput',false);
    train=cellfun(@(x) ~x,test,'UniformOutput',false);
    warning('off','all')
    
    
    SVMModel=cellfun(@(x) fitcsvm(data(x,:),group_labels(x,:),...
        'KernelFunction','linear', 'BoxConstraint', 1),train,'UniformOutput',false);
    est_labels =cellfun(@(x,y) predict(x,data(y,:)),SVMModel,test,'UniformOutput',false);

    
   
    for k = 1:n_k % For n_k folds
        classperf(cp,est_labels{k},test{k});
        w_all(:,k) = SVMModel{k}.Alpha'*SVMModel{k}.SupportVectors; % Save weights for each fold
    end
    w_avg = mean(w_all,2); % Save average of all folds
    
    % Pool weights from all frequency bands per electrode to
    % get one weight per electrode.
    pooled_wt_all(jj,:,:)=mean(reshape(w_all,[length(goodCH) length(freq_bands) n_k]),2);
    pooled_wt_avg(jj,:)=mean(reshape(w_avg,[length(goodCH) length(freq_bands)]),2);
    pooled_wt_avg_freq(jj,:,:)=reshape(w_avg,[length(goodCH) length(freq_bands)]);
    class_accuracy(jj) = cp.CorrectRate;
    class_precision(jj)=cp.PositivePredictiveValue;
    class_recall(jj)=cp.Sensitivity;
    waitbar(jj/n_rep)
end
close(h)
class_precision = mean(class_precision);
class_recall = mean(class_recall);
class_accuracy = mean(class_accuracy);
pooled_wt_all = squeeze(mean(pooled_wt_all));
pooled_wt_avg = mean(pooled_wt_avg,1);
pooled_wt_avg_freq = squeeze(mean(pooled_wt_avg_freq,1));

clear k jj cp SVMModel test train

figure,topoplot(pooled_wt_avg,chanlocs(goodCH))
caxis([0 30])
hfig=gca;
% figure,
% freqsname={'Delta','Theta','Alpha','Beta'};
% for kk=1:4
%     subplot(1,4,kk)
%     topoplot(pooled_wt_avg_freq(:,kk),chanlocs(goodCH))
%     title(freqsname{kk})
%     caxis([-0.2 0.2])
% end
%% Permutation test - do the exact same thing, but mix up the
% labels for each iteration of the classifier.
h = waitbar(0,'Permutation test...');
for x = 1:iter
    mixed_group_labels = group_labels(randperm(size(data,1)));
    
    cp = classperf(group_labels);   % Ground truth is preserved by initializing w/true group labels.
    ind = crossvalind('Kfold',group_labels,n_k);
    
    test=cellfun(@(x) (ind == x),num2cell(1:n_k),'UniformOutput',false);
    train=cellfun(@(x) ~x,test,'UniformOutput',false);
    warning('off','all')
    
    
    SVMModel=cellfun(@(x) fitcsvm(data(x,:),mixed_group_labels(x,:),...
        'KernelFunction','linear', 'BoxConstraint', 1),train,'UniformOutput',false);
    est_labels =cellfun(@(x,y) predict(x,data(y,:)),SVMModel,test,'UniformOutput',false);

    
    for k = 1:n_k
        classperf(cp,est_labels{k},test{k});
    end
    
    dummy_accuracy(x) = cp.CorrectRate;
    dummy_class_precision(x)=cp.PositivePredictiveValue;
    dummy_class_recall(x)=cp.Sensitivity;
    clear cp ind mixed_group_labels
    waitbar(x/iter)
end
close (h)
% Get p-value according to method described in Noirhomme 2014.
class.p_values = (sum(dummy_accuracy>=class_accuracy)+1)/(iter+1);
class.accuracies = class_accuracy;
class.precision=class_precision;
class.recall=class_recall;
class.dur = sum(~isnan(ON(:,1)))+sum(~isnan(OFF(:,1)));
class.folds = n_k;
class.all_iter = iter;
class.pooled_wt_all=pooled_wt_all;
class.pooled_wt_avg=pooled_wt_avg;
class.pooled_wt_avg_freq=pooled_wt_avg_freq;

title(hfig,['pvalue:' num2str(round(class.p_values*1000)/1000) ' - class accuracy:' num2str(round(class.accuracies*100)/100)])
