function EEGPlotSpectraByWT(specON,specOFF,class,chanlocs,f)
CH=8;

ON_abs_pwr = squeeze(mean(specON,2)); 
OFF_abs_pwr = squeeze(mean(specOFF,2)); 

% Find maximal weight.
[~, I] = sort(abs(class.pooled_wt_avg), 'descend');
% I=1:CH;
% Grab power at top eight electrodes.
ON = ON_abs_pwr(:,I(1:CH)); %ON = ON./sum(ON);
OFF = OFF_abs_pwr(:,I(1:CH)); %OFF = OFF./sum(OFF);

freq_bands = {[1,3],[4,7],[8,13],[14,30]};
Ifreqs=cellfun(@(x) find(abs(f-x(1))==min(abs(f-x(1)))): ...
    find(abs(f-x(2))==min(abs(f-x(2)))),freq_bands,'UniformOutput',false);
% raw_ON = NaN(length(ON),length(freq_bands),8);
% raw_OFF = NaN(length(OFF),length(freq_bands),8);
raw_ON=[];
raw_OFF=[];
for j = 1:length(Ifreqs)
    raw_ON(j,:) = mean(ON(Ifreqs{j},:))';
    raw_OFF(j,:) = mean(OFF(Ifreqs{j},:))';
end
dd_bands=raw_ON-raw_OFF;

limY=round(max(max(abs(dd_bands)))*1000)/1000+0.001;

figure,
tmp=1:4:CH;
for jj = 1:CH
    subplot(round(CH/4),4,jj)
    bb = bar(dd_bands(:,jj));
    set(bb, 'FaceColor', 'black');
    set(gca, 'xticklabel', {'d', 't', 'a', 'b',}, 'fontsize', 10, 'fontweight', 'bold', ...
        'xlim', [0.5 4.5], 'ylim', [-limY limY],... 
        'fontweight', 'bold', 'fontsize', 10)
    if any(ismember(tmp,jj))
        ylabel('pwr', 'FontWeight', 'Bold', 'Fontsize', 10)
    end
    title(chanlocs(I(jj)).labels, 'fontweight', 'bold', 'fontsize', 12)
    axis square;
end


%%
CH=4;
if isfield(class,'TrigONall')
    % % Find maximal weight.
    [~, I] = sort(abs(class.pooled_wt_avg), 'descend');
    
    % Grab power at top four electrodes.
    ON_tmp = squeeze(specON(:,:,I(1:4)));
    OFF_tmp = squeeze(specOFF(:,:,I(1:4)));
    
    freq_bands = {[1,3],[4,7],[8,13],[14,30]};
    Ifreqs=cellfun(@(x) find(abs(f-x(1))==min(abs(f-x(1)))): ...
        find(abs(f-x(2))==min(abs(f-x(2)))),freq_bands,'UniformOutput',false);
    raw_ON=[];
    raw_OFF=[];
    for j = 1:length(Ifreqs)
        raw_ON(j,:,:) = squeeze(mean(ON_tmp(Ifreqs{j},:,:),1));
        raw_OFF(j,:,:) = squeeze(mean(OFF_tmp(Ifreqs{j},:,:),1));
    end
    freq_names={'Delta','Theta','Alpha','Beta'};
    for jj=1:size(raw_ON,3)
        figure,
        for kk=1:size(raw_ON,1)
            subplot(size(raw_ON,1),1,kk)
            plot(class.TrigONall,raw_ON(kk,:,jj),'ok','MarkerFaceColor','k')
            hold on
            plot(class.TrigOFFall,raw_OFF(kk,:,jj),'ob','MarkerFaceColor','b')
            ylabel(freq_names{kk}, 'FontWeight', 'Bold', 'Fontsize', 10)
            if kk==1
                title(chanlocs(I(jj)).labels, 'fontweight', 'bold', 'fontsize', 12)
            end
        end

    end
end
%%
CH=12;
[~, I] = sort(abs(class.pooled_wt_avg), 'descend');

% Grab power at top eight electrodes.
ON_tmp = specON(:,:,I(1:CH)); %ON = ON./sum(ON);
OFF_tmp = specOFF(:,:,I(1:CH)); %OFF = OFF./sum(OFF);

freq_bands = {[1,3],[4,7],[8,13],[14,30]};
Ifreqs=cellfun(@(x) find(abs(f-x(1))==min(abs(f-x(1)))): ...
    find(abs(f-x(2))==min(abs(f-x(2)))),freq_bands,'UniformOutput',false);% raw_ON = NaN(length(ON),length(freq_bands),8);
% raw_OFF = NaN(length(OFF),length(freq_bands),8);
freq_names={'d', 't', 'a', 'b',};
g=[];
raw=[];
for j = 1:length(Ifreqs)
    raw = [raw; squeeze(mean(ON_tmp(Ifreqs{j},:,:),1))];
    g=cat(2,g,repmat({[freq_names{j} '_ON']},1,size(ON_tmp,2)));
    raw  = [raw; squeeze(mean(OFF_tmp(Ifreqs{j},:,:),1))];
    g=cat(2,g,repmat({[freq_names{j} '_OFF']},1,size(OFF_tmp,2)));
end


figure,
tmp=1:4:CH;
for jj = 1:CH
    subplot(round(CH/4),4,jj)
    boxplot(raw(:,jj),g,'PlotStyle','compact');
    set(gca, 'fontsize', 10, 'fontweight', 'bold', 'xlim', [0 9], 'ylim', [-0 round(max(max(raw))*10)/10+0.1])
    if any(ismember(tmp,jj))
        ylabel('pwr', 'FontWeight', 'Bold', 'Fontsize', 10)
    end
    title(chanlocs(I(jj)).labels, 'fontweight', 'bold', 'fontsize', 12)
    axis square;
end
%%
[~, I] = sort(abs(class.pooled_wt_avg), 'descend');
CH=5;
figure,topoplot(zeros(1,length(chanlocs)),chanlocs,'electrodes','ptslabels','emarker2',{I(1:CH)})
% Grab power at top four electrodes.
ON_tmp = squeeze(specON(:,:,I(1:CH)));
OFF_tmp = squeeze(specOFF(:,:,I(1:CH)));

freq_bands = {[1,3],[4,7],[8,13],[14,30]};
Ifreqs=cellfun(@(x) find(abs(f-x(1))==min(abs(f-x(1)))): ...
    find(abs(f-x(2))==min(abs(f-x(2)))),freq_bands,'UniformOutput',false);% raw_ON = NaN(length(ON),length(freq_bands),8);
raw_ON=[];
raw_OFF=[];
for j = 1:length(Ifreqs)
    tmp_ON=squeeze(mean(ON_tmp(Ifreqs{j},:,:),1));
    tmp_OFF=squeeze(mean(OFF_tmp(Ifreqs{j},:,:),1));
    if size(tmp_ON,1)==size(ON_tmp,2)
        raw_ON(j,:,:) = tmp_ON;
        raw_OFF(j,:,:) = tmp_OFF;
    else
        raw_ON(j,:,:) = tmp_ON';
        raw_OFF(j,:,:) = tmp_OFF';
    end
end

It=find(diff(class.TrigOFFall)>3);
raw_OFF_t=[];
T_off=[];
for kk=1:length(It)
    if kk==1
        raw_OFF_t(:,kk,:)=mean(raw_OFF(:,1:It(kk),:),2);
        T_off(kk)=round(mean(class.TrigOFFall(1):class.TrigOFFall(It(kk))));
    else
        raw_OFF_t(:,kk,:)=mean(raw_OFF(:,It(kk-1)+1:It(kk),:),2);
        T_off(kk)=round(mean(class.TrigOFFall(It(kk-1)):class.TrigOFFall(It(kk))));
    end
end
raw_OFF_t(:,kk+1,:)=mean(raw_OFF(:,It(end)+1:size(raw_OFF,2),:),2);
T_off(kk+1)=round(mean(class.TrigOFFall(It(end)+1):class.TrigOFFall(end)));

It=find(diff(class.TrigONall)>3);
raw_ON_t=[];
T_on=[];
for kk=1:length(It)
    if kk==1
        raw_ON_t(:,kk,:)=mean(raw_ON(:,1:It(kk),:),2);
        T_on(kk)=round(mean(class.TrigONall(1):class.TrigONall(It(kk))));
    else
        raw_ON_t(:,kk,:)=mean(raw_ON(:,It(kk-1)+1:It(kk),:),2);
        T_on(kk)=round(mean(class.TrigONall(It(kk-1)):class.TrigONall(It(kk))));
    end
end
raw_ON_t(:,kk+1,:)=mean(raw_ON(:,It(end)+1:size(raw_ON,2),:),2);
T_on(kk+1)=round(mean(class.TrigONall(It(end)+1):class.TrigONall(end)));

freq_names={'Delta','Theta','Alpha','Beta'};
for jj=1:CH
    figure,
    for kk=1:4
        subplot(4,1,kk)
        plot(T_on,raw_ON_t(kk,:,jj),'.k')
        hold on
        plot(T_off,raw_OFF_t(kk,:,jj),'.b')
        ylabel(freq_names{kk}, 'FontWeight', 'Bold', 'Fontsize', 10)
        if kk==1
            title(chanlocs(I(jj)).labels, 'fontweight', 'bold', 'fontsize', 12)
        end
    end
end
%
% % % freq_names={'Delta','Theta','Alpha','Beta'};
% % % for jj=1:CH
% % %     figure('NumberTitle','off','Name',chanlocs(I(jj)).labels),
% % %     for kk=1:4
% % %         subplot(1,4,kk)
% % %         plot(ones(1,size(raw_ON_t,2)),raw_ON_t(kk,:,jj),'.r')
% % %         hold on
% % %         plot(ones(1,size(raw_ON_t,2))*2,raw_OFF_t(kk,:,jj),'.b')
% % %         xlim([0 3])
% % %         for zz=1:size(raw_ON_t,2)
% % %             line([1 2],[raw_ON_t(kk,zz,jj) raw_OFF_t(kk,zz,jj)],'Color','k')
% % %         end
% % % %         ylabel(freq_names{kk}, 'FontWeight', 'Bold', 'Fontsize', 10)
% % %             title(freq_names{kk}, 'fontweight', 'bold', 'fontsize', 12)
% % %     end
% % % end
%

[T,IT]=sort([T_on T_off]);
raw=cat(2,raw_ON_t,raw_OFF_t);
raw=mean(raw(:,IT,:),3);
raw=raw-repmat(mean(raw,2),1,size(raw,2));


figure,
subplot(2,1,1)
plot(T,raw(1:2,:));hold on
Y=ylim;

tmpShape=ones(1,max([class.TrigONall; class.TrigOFFall]))*max(Y);
tmpShape(class.TrigOFFall)=min(Y);
plot(1:length(tmpShape),tmpShape,'--k')
ylim([Y(1)-0.05 Y(2)+0.05])
xlim([0 length(tmpShape)])
line([0 length(tmpShape)],[0 0],'Color','k')
legend({'Delta','Theta'})

subplot(2,1,2)
plot(T,raw(3:4,:));hold on
Y=ylim;

tmpShape=ones(1,max([class.TrigONall; class.TrigOFFall]))*max(Y);
tmpShape(class.TrigOFFall)=min(Y);
plot(1:length(tmpShape),tmpShape,'--k')
ylim([Y(1)-0.005 Y(2)+0.005])
xlim([0 length(tmpShape)])
line([0 length(tmpShape)],[0 0],'Color','k')
legend({'Alpha','Beta'})

% legend({'Delta','Theta','Alpha','Beta'})
% for pp=2:2:length(T)-1
%     plot([mean([T(pp),T(pp+1)]) mean([T(pp),T(pp+1)])],Y,'--k')
% end