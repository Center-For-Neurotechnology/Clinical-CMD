function [S,mean_Savg,mean_Savg_elecs,spectral_edge,n_interval,trls]=fromPSDtoS(SScale_ALL,tmpO)

I=find(diff(tmpO)>1);
for xxx=1:length(I)
    if xxx==1
        trls {xxx}=tmpON(1:I(xxx));
    else
        trls{xxx}=tmpON(I(xxx-1)+1:I(xxx));
    end
    n_interval(xxx)=length(trls{xxx});
end

spectrum_scaled_padded = cellfun(@(x) SScale_ALL(:,x,:),trls,'UniformOutput',false);
spectrum_avg = cellfun(@(x) squeeze(nanmean(x,2)),spectrum_scaled_padded,'UniformOutput',false);
Sstd = cellfun(@(x) squeeze(nanstd(x,0,2)),spectrum_scaled_padded,'UniformOutput',false);

spectrum_avg_elecs = cellfun(@(x) squeeze(nanmean(x,2)),spectrum_avg,'UniformOutput',false);
Sstd_elecs = cellfun(@(x) squeeze(nanstd(x,0,2)),spectrum_avg,'UniformOutput',false);

for xx=1:length(I)
    S(xx).Sscale_padded = spectrum_scaled_padded{xx};
    S(xx).spectrum_avg_elecs = spectrum_avg_elecs{xx};
    S(xx).Sstd_elecs = Sstd_elecs{xx};
    S(xx).avg = spectrum_avg{xx};
    S(xx).Sstd = Sstd{xx};
    Savg_alltr(:,:,xx) = S(xx).avg;
    Savg_elecs_alltr(:,xx) = S(xx).spectrum_avg_elecs;
    for ee = 1:19
        spectral_edge(xx,ee) = find(cumsum(spectrum_avg{xx}(:,ee))/sum(spectrum_avg{xx}(:,ee))>=0.9,1);
    end
end

mean_Savg = nanmean(Savg_alltr,3);
mean_Savg_elecs = nanmean(Savg_elecs_alltr,2);
trls=length(trls);



