function []=EEGplotPSD(spectraON,spectraOFF,f,chanlocs,goodCH,fig_type)

spectrum_avg={squeeze(nanmean(spectraON,2)),squeeze(nanmean(spectraOFF,2))};
freq_bands = {[1,3],[4,7],[8,13],[14,30]};
freq_bands=cellfun(@(x) find(abs(f-x(1))==min(abs(f-x(1)))): ...
    find(abs(f-x(2))==min(abs(f-x(2)))),freq_bands,'UniformOutput',false);
freq_names={'Delta','Theta','Alpha','Beta'};


[frontal_elecs, central_elecs, parietal_elecs, occipital_elecs, left_elecs, middle_elecs, right_elecs] = ...
    EEGget_elecs({chanlocs(goodCH).labels});
freq_range=[f(1) f(end)];
FCPO={frontal_elecs, central_elecs, parietal_elecs, occipital_elecs};
FCPOelecNames={'Frontal elecs','Central elecs','Parietal elecs','Occipital elecs'};
LMR={left_elecs, middle_elecs, right_elecs};
LMRelecNames={'Left elecs','Midline elecs','Right elecs'};

switch fig_type
    case 'DisplayAllPSD'
        
        EEGDisplayAllPSD(spectrum_avg{1}',spectrum_avg{2}',f,chanlocs(goodCH))

        figure;
        plot(f, 10*log10(mean(mean(spectrum_avg{1},2),3)), 'r', 'LineWidth', 1.5)
        hold on, plot(f, 10*log10(mean(mean(spectrum_avg{2},2),3)), 'b', 'LineWidth', 1.5)
        title('Avg all elecs', 'FontWeight', 'Bold', 'Fontsize', 12)
        set(gca, 'xlim', freq_range, 'xtick', 0:10:freq_range(2), 'xticklabel', 0:10:freq_range(2), 'fontsize', 12)
        xlabel(gca, 'Hz', 'FontWeight', 'Bold', 'Fontsize', 10)
        ylabel(gca, 'power (dB)', 'FontWeight', 'Bold', 'Fontsize', 10)
        axis(gca, 'square')
        
    case 'PSD_Topography'
        
        figure('NumberTitle','off','Name','Task ON'),
        subplot(2,4,[1 4])
        tmp_spect=spectrum_avg{1}./repmat(mean(spectrum_avg{1},1),size(spectrum_avg{1},1),1);
        plot(f,10*log10(tmp_spect),'k')
        for kk=1:length(freq_bands)
            subplot(2,4,4+kk)
            topoplot(10*log10(mean(tmp_spect(freq_bands{kk},:),1)),chanlocs(goodCH),'maplimits',[-10 10]);
            title(freq_names{kk})
        end
        
        figure('NumberTitle','off','Name','Task OFF')
        subplot(2,4,[1 4])
        tmp_spect=spectrum_avg{2}./repmat(mean(spectrum_avg{2},1),size(spectrum_avg{2},1),1);
        plot(f,10*log10(tmp_spect),'k')
        for kk=1:length(freq_bands)
            subplot(2,4,4+kk)
            topoplot(10*log10(mean(tmp_spect(freq_bands{kk},:),1)),chanlocs(goodCH),'maplimits',[-10 10]);
            title(freq_names{kk})
        end

    case 'PSD_F_C_P_O'
        hfig=figure;
        Y=[];
        for kk=1:length(FCPO)
            subplot(2,2,kk), plot(f, 10*log10(mean(spectrum_avg{1}(:,FCPO{kk}),2)), 'r', 'LineWidth', 1.5)
            hold on
            subplot(2,2,kk), plot(f, 10*log10(mean(spectrum_avg{2}(:,FCPO{kk}),2)), 'b', 'LineWidth', 1.5)
            title(FCPOelecNames{kk}, 'FontWeight', 'Bold', 'Fontsize', 12)
            Y(kk,:)=ylim;
            legend({'Task ON','Task OFF'})
        end
        
        axH = findall(gcf,'type','axes');
        set(axH, 'xlim', freq_range, 'ylim', [min(Y(:,1)) max(Y(:,2))], 'xtick', [0:10:freq_range(2)], 'xticklabel', [0:10:freq_range(2)], 'fontsize', 8)
        for j = 1:length(axH)
            xlabel(axH(j), 'Hz', 'FontWeight', 'Bold', 'Fontsize', 7)
            ylabel(axH(j), 'power (dB)', 'FontWeight', 'Bold', 'Fontsize', 7)
            line(axH(j),[freq_bands{2}(1) freq_bands{2}(1)],[min(Y(:,1)) max(Y(:,2))],'Color','k','LineStyle','--','LineWidth', 1.5)
            line(axH(j),[freq_bands{3}(1) freq_bands{3}(1)],[min(Y(:,1)) max(Y(:,2))],'Color','k','LineStyle','--','LineWidth', 1.5)
            line(axH(j),[freq_bands{4}(1) freq_bands{4}(1)],[min(Y(:,1)) max(Y(:,2))],'Color','k','LineStyle','--','LineWidth', 1.5)
        end
        axis(axH, 'square')
        
    case 'PSD_L_M_R'
        hfig=figure;
        Y=[];
        for kk=1:length(LMR)
            subplot(2,3,kk), plot(f, 10*log10(mean(spectrum_avg{1}(:,LMR{kk}),2)), 'r', 'LineWidth', 1)
            hold on
            subplot(2,3,kk), plot(f, 10*log10(mean(spectrum_avg{2}(:,LMR{kk}),2)), 'b', 'LineWidth', 1)
            Y(kk,:)=ylim;
            title(LMRelecNames{kk}, 'FontWeight', 'Bold', 'Fontsize', 12)
        end
        axH = findall(gcf,'type','axes');
        set(axH, 'xlim', freq_range, 'ylim', [min(Y(:,1)) max(Y(:,2))], 'xtick', [0:10:freq_range(2)], 'xticklabel', [0:10:freq_range(2)], 'fontsize', 8)
        for j = 1:length(axH)
            xlabel(axH(j), 'Hz', 'FontWeight', 'Bold', 'Fontsize', 7)
            ylabel(axH(j), 'power (dB)', 'FontWeight', 'Bold', 'Fontsize', 7)
            line(axH(j),[freq_bands{2}(1) freq_bands{2}(1)],[min(Y(:,1)) max(Y(:,2))],'Color','k','LineStyle','--','LineWidth', 1.5)
            line(axH(j),[freq_bands{3}(1) freq_bands{3}(1)],[min(Y(:,1)) max(Y(:,2))],'Color','k','LineStyle','--','LineWidth', 1.5)
            line(axH(j),[freq_bands{4}(1) freq_bands{4}(1)],[min(Y(:,1)) max(Y(:,2))],'Color','k','LineStyle','--','LineWidth', 1.5)
        end
        
        ON_bands=[];
        OFF_bands=[];
        for fb = 1:length(freq_bands)
            ON_bands(fb,:) = nanmean(spectrum_avg{1}(freq_bands{fb},:),1);
            OFF_bands(fb,:) = nanmean(spectrum_avg{2}(freq_bands{fb},:),1);
        end
        dd_bands = 10*log10(ON_bands) - 10*log10(OFF_bands);
        LMR_M=cellfun(@(x) mean(dd_bands(:,x),2),LMR,'UniformOutput',false);
        LMR_std=cellfun(@(x) std(dd_bands(:,x),[],2),LMR,'UniformOutput',false);
     
        axH = [];
        for kk=1:length(LMR)
            subplot(2,3,kk+3),
            LMR_bar = bar(LMR_M{kk}); title(LMRelecNames{kk}, 'FontWeight', 'Bold', 'Fontsize', 11);
            hold on
            for b = 1:length(freq_bands)
                errorbar(b,LMR_M{kk}(b), LMR_std{kk}(b), 'k.');
            end
            axH = [axH; gca];
            set(LMR_bar, 'FaceColor', [128 128 128]/255);
            ylabel(gca, 'power (dB)', 'FontWeight', 'Bold', 'Fontsize', 7)
        end
        set(axH,'xlim', [0.5 4.5], 'xticklabel', {'d', 't', 'a', 'b',}, 'fontsize', 7, 'fontweight', 'bold', ...
            'ylim', [(floor(min(min(dd_bands))*10)/10)-0.1 (ceil(max(max(dd_bands))*10)/10)+0.1])
        axH = findall(gcf,'type','axes');
        axis(axH, 'square')
        
        
        % Plot each spectra in a separate figure
        for kk=1:length(LMR)
            figure;
            plot(f, 10*log10(mean(spectrum_avg{1}(:,LMR{kk}),2)), 'r', 'LineWidth', 1.5)
            hold on, plot(f, 10*log10(mean(spectrum_avg{2}(:,LMR{kk}),2)), 'b', 'LineWidth', 1.5)
            title(LMRelecNames{kk}, 'FontWeight', 'Bold', 'Fontsize', 12)
            set(gca, 'xlim', freq_range, 'ylim', [min(Y(:,1)) max(Y(:,2))], 'xtick', 0:10:freq_range(2), 'xticklabel', 0:10:freq_range(2), 'fontsize', 12)
            xlabel(gca, 'Hz', 'FontWeight', 'Bold', 'Fontsize', 10)
            ylabel(gca, 'power (dB)', 'FontWeight', 'Bold', 'Fontsize', 10)
            %         ylim([min(min(Y)) 10])
            line(gca,[freq_bands{2}(1) freq_bands{2}(1)],[min(Y(:,1)) max(Y(:,2))],'Color','k','LineStyle','--','LineWidth', 1.5)
            line(gca,[freq_bands{3}(1) freq_bands{3}(1)],[min(Y(:,1)) max(Y(:,2))],'Color','k','LineStyle','--','LineWidth', 1.5)
            line(gca,[freq_bands{4}(1) freq_bands{4}(1)],[min(Y(:,1)) max(Y(:,2))],'Color','k','LineStyle','--','LineWidth', 1.5)
            axis(gca, 'square')
        end
        
    case 'PSD_Bar_L_M_R'
        %% Option 1
        % Within a frequency band averaged over left/middle/right
        % electrodes, find value of maximum peak from the average of those
        % electrodes, and plot it in a bar graph. The standard deviation comes
        % from absolute power at all electrodes in a region (L, M, R) at peak
        % freq band.

        % Computing error
        for fb = 1:length(freq_bands)
            for kk=1:length(LMR)
                [LMR_M{kk}(fb,1), ind]= max(10*log10(nanmean(spectrum_avg{1}(freq_bands{fb},LMR{kk}),2)));
                LMR_std{kk}(fb,1) = nanstd(10*log10(spectrum_avg{1}(ind,LMR{kk})));
                [LMR_M{kk}(fb,2), ind ]= max(10*log10(nanmean(spectrum_avg{2}(freq_bands{fb},LMR{kk}),2)));
                LMR_std{kk}(fb,2) = nanstd(10*log10(spectrum_avg{2}(ind,LMR{kk})));
            end
        end

        ngroups=length(freq_bands);
        nbars=2;
        % Calculate the width for each bar group
        groupwidth = min(0.8, nbars/(nbars + 1.5));

        hfig=figure;
        for kk=1:length(LMR)
            subplot(1,3,kk),
            LMR_bar{kk} = bar(LMR_M{kk}); title(LMRelecNames{kk}, 'FontWeight', 'Bold', 'Fontsize', 11);
            hold on
            for b = 1:nbars
                % Calculate center of each bar
                x = (1:ngroups) - groupwidth/2 + (2*b-1) * groupwidth / (2*nbars);
                errorbar(x,LMR_M{kk}(:,b), LMR_std{kk}(:,b), 'k.');
            end
        end
        
        set([LMR_bar{1}(1), LMR_bar{2}(1), LMR_bar{3}(1)], 'FaceColor', 'red');
        set([LMR_bar{1}(2), LMR_bar{2}(2), LMR_bar{3}(2)], 'FaceColor', 'blue');
        axH = findall(gcf,'type','axes');
        
        yl = [floor(min(min([LMR_M{1}(:)-LMR_std{1}(:),LMR_M{2}(:)-LMR_std{2}(:),LMR_M{3}(:)-LMR_std{3}(:)]))*10)/10 ceil(max(max([LMR_M{1}(:)+LMR_std{1}(:),LMR_M{2}(:)+LMR_std{2}(:),LMR_M{3}(:)+LMR_std{3}(:)])))];
        set(axH, 'xlim', [0.5 4.5], 'ylim', yl, 'xticklabel', freq_names, 'fontsize', 7, 'fontweight', 'bold')
        
        for j = 1:length(axH)
            ylabel(axH(j), 'power (dB)', 'FontWeight', 'Bold', 'Fontsize', 7)
        end
        
        axis(axH, 'square')
        suptitle({'Within a frequency band averaged over left/middle/right electrodes,'...
         'find value of maximum peak from the average of those electrodes', ...
        'Std comes from absolute power of those electrodes at peak frequency band'})

        %% Option 2
        LMR_M=[];
        LMR_std=[];
        for fb = 1:length(freq_bands)
           for kk=1:length(LMR)
                LMR_M{kk}(fb,1)= 10*log10(mean(mean(spectrum_avg{1}(freq_bands{fb},LMR{kk}),1),2));
                LMR_std{kk}(fb,1) = nanstd(10*log10(nanmean(nanmean(spectraON(freq_bands{fb},:,LMR{kk}),1),3)));
                LMR_M{kk}(fb,2)= 10*log10(mean(mean(spectrum_avg{2}(freq_bands{fb},LMR{kk}),1),2));
                LMR_std{kk}(fb,2) = nanstd(10*log10(nanmean(nanmean(spectraOFF(freq_bands{fb},:,LMR{kk}),1),3)));
           end
        end

        ngroups=length(freq_bands);
        nbars=2;
        % Calculate the width for each bar group
        groupwidth = min(0.8, nbars/(nbars + 1.5));
        
        
        hfig=figure;
        for kk=1:length(LMR)
            subplot(1,3,kk),
            LMR_bar{kk} = bar(LMR_M{kk}); title(LMRelecNames{kk}, 'FontWeight', 'Bold', 'Fontsize', 11);
            hold on
            for b = 1:nbars
                % Calculate center of each bar
                x = (1:ngroups) - groupwidth/2 + (2*b-1) * groupwidth / (2*nbars);
                errorbar(x,LMR_M{kk}(:,b), LMR_std{kk}(:,b), 'k.');
            end
        end
        
        set([LMR_bar{1}(1), LMR_bar{2}(1), LMR_bar{3}(1)], 'FaceColor', 'red');
        set([LMR_bar{1}(2), LMR_bar{2}(2), LMR_bar{3}(2)], 'FaceColor', 'blue');
        axH = findall(gcf,'type','axes');
        
        yl = [floor(min(min([LMR_M{1}(:)-LMR_std{1}(:),LMR_M{2}(:)-LMR_std{2}(:),LMR_M{3}(:)-LMR_std{3}(:)]))*10)/10 ceil(max(max([LMR_M{1}(:)+LMR_std{1}(:),LMR_M{2}(:)+LMR_std{2}(:),LMR_M{3}(:)+LMR_std{3}(:)])))];
        set(axH, 'xlim', [0.5 4.5], 'ylim', yl, 'xticklabel', freq_names, 'fontsize', 7, 'fontweight', 'bold')
        
        for j = 1:length(axH)
            ylabel(axH(j), 'power (dB)', 'FontWeight', 'Bold', 'Fontsize', 7)
        end
        
        axis(axH, 'square')
        
        suptitle({'Power in each frequency band averaged over left/middle/right electrodes,'...
        'Std comes from absolute power across at all epoch averaged across frequency band and electrodes'})
        
        %% Option 2 with boxplot

        figure,
        for kk=1:length(LMR)
            specALL=[];
            g=[];
            subplot(1,3,kk)
            for fb=1:length(freq_bands)
                specALL=cat(2,specALL,10*log10(nanmean(nanmean(spectraON(freq_bands{fb},:,LMR{kk}),1),3)));
                g=cat(2,g,repmat({[freq_names{fb} '_ON']},1,size(spectraON,2)));
                specALL=cat(2,specALL,10*log10(nanmean(nanmean(spectraOFF(freq_bands{fb},:,LMR{kk}),1),3)));
                g=cat(2,g,repmat({[freq_names{fb} '_OFF']},1,size(spectraON,2)));
            end
            boxplot(specALL,g,'Widths',0.3,'Colors','rb');
            title(LMRelecNames{kk}, 'FontWeight', 'Bold', 'Fontsize', 11)
            y(kk,:)=ylim;
            h = findobj(gcf,'tag','Outliers');
            for i = 1:2:numel(h)
                h(i).MarkerEdgeColor = 'b';
            end
            for i = 2:2:numel(h)
                h(i).MarkerEdgeColor = 'r';
            end
        end
        axH = findall(gcf,'type','axes');
                
%         set(axH, 'ylim', [-0.2 max(y(:,2))], 'fontsize', 7, 'fontweight', 'bold')
        set(axH, 'fontsize', 7, 'fontweight', 'bold')

        for j = 1:length(axH)
            ylabel(axH(j), 'power (dB)', 'FontWeight', 'Bold', 'Fontsize', 7)
        end
        suptitle({'Power in each frequency band averaged over left/middle/right electrodes,'...
        'Std comes from absolute power across at all epoch averaged across frequency band and electrodes'})
        
        %% Option 3
        LMR_M=[];
        LMR_std=[];
        for fb = 1:length(freq_bands)
            for kk=1:length(LMR)
                LMR_M{kk}(fb,1) = 10*log10(mean(mean(spectrum_avg{1}(freq_bands{fb},LMR{kk}),2)));
                LMR_std{kk}(fb,1) = std(10*log10(mean(spectrum_avg{1}(freq_bands{fb},LMR{kk}),1)));
                LMR_M{kk}(fb,2) = 10*log10(mean(mean(spectrum_avg{2}(freq_bands{fb},LMR{kk}),2)));
                LMR_std{kk}(fb,2) = std(10*log10(mean(spectrum_avg{2}(freq_bands{fb},LMR{kk}),1)));
            end
        end

        ngroups=length(freq_bands);
        nbars=2;
        % Calculate the width for each bar group
        groupwidth = min(0.8, nbars/(nbars + 1.5));
        
        
        hfig=figure;
        for kk=1:length(LMR)
            subplot(1,3,kk),
            LMR_bar{kk} = bar(LMR_M{kk}); title(LMRelecNames{kk}, 'FontWeight', 'Bold', 'Fontsize', 11);
            hold on
            for b = 1:nbars
                % Calculate center of each bar
                x = (1:ngroups) - groupwidth/2 + (2*b-1) * groupwidth / (2*nbars);
                errorbar(x,LMR_M{kk}(:,b), LMR_std{kk}(:,b), 'k.');
            end
        end
        
        set([LMR_bar{1}(1), LMR_bar{2}(1), LMR_bar{3}(1)], 'FaceColor', 'red');
        set([LMR_bar{1}(2), LMR_bar{2}(2), LMR_bar{3}(2)], 'FaceColor', 'blue');
        axH = findall(gcf,'type','axes');
        
        yl = [floor(min(min([LMR_M{1}(:)-LMR_std{1}(:),LMR_M{2}(:)-LMR_std{2}(:),LMR_M{3}(:)-LMR_std{3}(:)]))*10)/10 ceil(max(max([LMR_M{1}(:)+LMR_std{1}(:),LMR_M{2}(:)+LMR_std{2}(:),LMR_M{3}(:)+LMR_std{3}(:)])))];
        set(axH, 'xlim', [0.5 4.5], 'ylim', yl, 'xticklabel', freq_names, 'fontsize', 7, 'fontweight', 'bold')
        
        for j = 1:length(axH)
            ylabel(axH(j), 'power (dB)', 'FontWeight', 'Bold', 'Fontsize', 7)
        end
        
        axis(axH, 'square')
        
        suptitle({'Within a frequency band averaged over left/middle/right electrodes:'...
            'Mean comes from the average of those electrodes', ...
            'Std comes from the absolute power of those electrodes'})

        %% Option 3 with boxplot
        figure,
        for kk=1:length(LMR)
            specALL=[];
            g=[];
            subplot(1,3,kk)
            for fb=1:length(freq_bands)
                specALL=cat(2,specALL,10*log10(nanmean(spectrum_avg{1}(freq_bands{fb},LMR{kk}),1)));
                g=cat(2,g,repmat({[freq_names{fb} '_ON']},1,length(LMR{kk})));
                specALL=cat(2,specALL,10*log10(nanmean(spectrum_avg{2}(freq_bands{fb},LMR{kk}),1)));
                g=cat(2,g,repmat({[freq_names{fb} '_OFF']},1,length(LMR{kk})));
            end
            boxplot(specALL,g,'Widths',0.3,'Colors','rb');
            title(LMRelecNames{kk}, 'FontWeight', 'Bold', 'Fontsize', 11)
            y(kk,:)=ylim;
            h = findobj(gcf,'tag','Outliers');
            for i = 1:2:numel(h)
                h(i).MarkerEdgeColor = 'b';
            end
            for i = 2:2:numel(h)
                h(i).MarkerEdgeColor = 'r';
            end
        end
        axH = findall(gcf,'type','axes');
                
%         set(axH, 'ylim', [-0.2 max(y(:,2))], 'fontsize', 7, 'fontweight', 'bold')
        set(axH, 'fontsize', 7, 'fontweight', 'bold')
        
        for j = 1:length(axH)
            ylabel(axH(j), 'power (dB)', 'FontWeight', 'Bold', 'Fontsize', 7)
        end
        suptitle({'Within a frequency band averaged over left/middle/right electrodes:'...
            'Mean comes from the average of those electrodes', ...
            'Std comes from the absolute power of those electrodes'})

end