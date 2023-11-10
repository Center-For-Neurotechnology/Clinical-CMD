function EEGPlotSpectraByWT_1(specON,specOFF,class,chanlocs,f)

freq_range=[f(1) f(end)];

% Find maximal weight.
% max_ind = find(abs(class.pooled_wt_avg)==max(abs(class.pooled_wt_avg)));
pooled_wt_avg=mean(abs(class.pooled_wt_avg_freq),1);
[~, I] = sort(pooled_wt_avg, 'descend');
% [~, I] = sort(abs(class.pooled_wt_avg), 'descend');
figure;
plot(sort(pooled_wt_avg,'descend'),'o'); hold on, 
% plot(sort(abs(class.pooled_wt_avg),'descend'),'*'); hold on, 
axp=gca;
title('Weights sorted')

CH = inputdlg('Enter number of channels to plot:','',1,{'4'});
if isempty(CH{1}); return; else; CH=str2double(CH{1}); end
plot(axp,pooled_wt_avg(I(1:CH)),'or','MarkerFaceColor','r')
% plot(axp,abs(class.pooled_wt_avg(I(1:CH))),'o')


% Get temporal variance info as well for boxplots.
ON_tmp = squeeze(nanmean(specON(:,:,I(1:CH)),2));
OFF_tmp = squeeze(nanmean(specOFF(:,:,I(1:CH)),2));

freq_bands = {[1,3],[4,7],[8,13],[14,30]};
Ifreqs=cellfun(@(x) find(abs(f-x(1))==min(abs(f-x(1)))): ...
    find(abs(f-x(2))==min(abs(f-x(2)))),freq_bands,'UniformOutput',false);
ON_bands=[];
OFF_bands=[];
for j = 1:length(freq_bands)
    ON_bands(j,:) = nanmean(ON_tmp(Ifreqs{j},:),1);
    OFF_bands(j,:) = nanmean(OFF_tmp(Ifreqs{j},:),1);
end

dd_bands = 10*log10(ON_bands) - 10*log10(OFF_bands);

hfig=figure;
tmp=1:4:CH;
Y=[];
axH=[];
for jj = 1:CH
    subplot(round(CH/2),4,jj)
    plot(f,10*log10(ON_tmp(:,jj)),'r', 'LineWidth', 1.5), hold on
    plot(f,10*log10(OFF_tmp(:,jj)),'b', 'LineWidth', 1.5), hold off
    axis(gca,'square')
    set(gca,'xlim', freq_range, 'xtick', 0:10:freq_range(2),...
        'xticklabel', 0:10:freq_range(2), 'fontsize', 8, 'fontweight', 'bold')
    title(chanlocs(I(jj)).labels, 'fontweight', 'bold', 'fontsize', 12)
    if any(ismember(tmp,jj))
        ylabel('pwr (dB)', 'FontWeight', 'Bold', 'Fontsize', 7)
    end
    Y(jj,:)=ylim;
    axH = [axH; gca];
    
    subplot(round(CH/2),4,jj+CH)
    bb = bar(dd_bands(:,jj));
    set(bb, 'FaceColor', 'black');
    set(gca,'xlim', [0.5 4.5], 'xticklabel', {'d', 't', 'a', 'b',}, 'fontsize', 8, 'fontweight', 'bold', ...
         'ylim', [(floor(min(min(dd_bands))*10)/10)-0.1 (ceil(max(max(dd_bands))*10)/10)+0.1])
    if any(ismember(tmp,jj))
        ylabel('pwr (dB)', 'FontWeight', 'Bold', 'Fontsize', 7)
    end
    title(chanlocs(I(jj)).labels, 'fontweight', 'bold', 'fontsize', 12)
    axis square;
end
set(axH, 'ylim', [min(Y(:,1)) max(Y(:,2))])
for kk=1:length(axH)
    line(axH(kk),[freq_bands{2}(1) freq_bands{2}(1)],[min(Y(:,1)) max(Y(:,2))],'Color','k','LineStyle','--','LineWidth', 1.5)
    line(axH(kk),[freq_bands{3}(1) freq_bands{3}(1)],[min(Y(:,1)) max(Y(:,2))],'Color','k','LineStyle','--','LineWidth', 1.5)
    line(axH(kk),[freq_bands{4}(1) freq_bands{4}(1)],[min(Y(:,1)) max(Y(:,2))],'Color','k','LineStyle','--','LineWidth', 1.5)
end


hfig=figure;
topoplot(pooled_wt_avg,chanlocs,'maplimits',[-0.2 0.2],'electrodes','ptslabels','emarker2',{I(1:CH),'o','b',7,1},'conv','off');
% topoplot(abs(class.pooled_wt_avg),chanlocs,'maplimits',[-0.2 0.2],'electrodes','ptslabels','emarker2',{I(1:CH),'o','b',7,1},'conv','off');


%%
[~, I] = sort(abs(class.pooled_wt_avg_freq),2, 'descend');
freq_names={'Delta','Theta','Alpha','Beta'};
for jj=1:4
    figure,    
    subplot(1,2,1)
    plot(sort(abs(class.pooled_wt_avg_freq(jj,:)),'descend'),'o'), hold on,
    plot(abs(class.pooled_wt_avg_freq(jj,I(jj,1:CH))),'or','MarkerFaceColor','r')
    axH = findall(gcf,'type','axes');
    axis(axH, 'square')
    title(['Weights sorted in the ' freq_names{jj} ' band'])
    
    subplot(1,2,2)
    topoplot(abs(class.pooled_wt_avg_freq(jj,:)),chanlocs,...
        'maplimits',[-0.3 0.3],'electrodes','ptslabels','emarker2',{I(jj,1:CH),'o','b',7,1},'conv','off');
end