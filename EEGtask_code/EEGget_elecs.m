% input: electrode labels
% Output: 
% - frontal_elecs
% - central_elecs
% - parietal_elecs
% - occipital_elecs
% - left_elecs
% - middle_elecs
% - right_elecs

function [frontal_elecs, central_elecs, parietal_elecs, occipital_elecs,...
    left_elecs, middle_elecs, right_elecs] = EEGget_elecs(Labels)
% Labels={EEG.chanlocs.labels}';
if any(strcmpi(Labels,'T3'))
    Labels{strcmpi(Labels,'T3')}='T7';
end
if any(strcmpi(Labels,'T4'))
    Labels{strcmpi(Labels,'T4')}='T8';
end
if any(strcmpi(Labels,'T5'))
    Labels{strcmpi(Labels,'T5')}='P7';
end
if any(strcmpi(Labels,'T6'))
    Labels{strcmpi(Labels,'T6')}='P8';
end

frontal_elecs = find(cellfun(@(x) strcmpi(x(1),'F') || strcmpi(x(1:2),'AF'),Labels,'UniformOutput',true));
central_elecs = find(cellfun(@(x) strcmpi(x(1),'C') || strcmpi(x(1),'T'),Labels,'UniformOutput',true));
parietal_elecs = find(cellfun(@(x) strcmpi(x(1),'P'),Labels,'UniformOutput',true));
occipital_elecs = find(cellfun(@(x) strcmpi(x(1),'O'),Labels,'UniformOutput',true));

left_elecs = find(cellfun(@(x) rem(str2double(x(end)),2),Labels,'UniformOutput',true)==1);
right_elecs = find(cellfun(@(x) rem(str2double(x(end)),2),Labels,'UniformOutput',true)==0);
middle_elecs = find(isnan(cellfun(@(x) rem(str2double(x(end)),2),Labels,'UniformOutput',true)));

