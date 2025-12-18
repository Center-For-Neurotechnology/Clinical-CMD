% -----------------------------------------------------------------------
% Input: 
% - EEG structure
% - hp: low frequency cut-off [Hz]; default [1]; order filter is set to 3
% - lp: high frequency cut-off [Hz]; default [80]; order filter is set to 3
% - bs1 and bs2: band stop range [Hz]; default [59 61]; order filter is set to 5
% - dws: downsampling; string 'Y' or 'N'
% Output: 
% - EEG structure updated with EEG.data filtered/downsampled

% -----------------------------------------------------------------------

% --------------------------
% Authors: Fecchio Matteo, Adenauer Girardi Casali, Silvia Casarotto
% --------------------------

function [EEG]=EEGfilters_v2(EEG,hp,lp,bs1,bs2)
if isempty(hp)
    hp=0;
end
if isempty(lp)
    lp=0;
end
if isempty(bs1) || isempty(bs2)
    bs1=0;
    bs2=0;
end

if hp==0 && lp==0 && bs1==0 && bs2==0
    
    prompt = {'high pass [Hz] CANCEL to skip','low pass [Hz] CANCEL to skip','Notch [Hz] CANCEL to skip'};
    dlg_title = 'Filter Parameters ';
    num_lines = 1;
    def = {'1','80','59 61'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    clear def num_lines dlg_title prompt
    if isempty(answer)
        answer=cell(3,1);
    end
    if isempty(answer{1})
        hp=0;
    else
        hp=str2double(answer{1});
        disp([answer{1} 'Hz high-pass filtering will be applied'])
    end
    if isempty(answer{2})
        lp=0;
    else
        lp=str2double(answer{2});
        disp([answer{2} 'Hz high-pass filtering will be applied'])
    end
    if ~isempty(answer{3}) && length(str2num(answer{3}))==2
        tmp=sort(str2num(answer{3}));
        bs1=tmp(1);
        bs2=tmp(2);
        disp([answer{3} 'Hz Band stop filtering will be applied'])
    else
        bs1=0;
        bs2=0;
    end
    
    clear answer
end
filters=[];
%BANDPASS
if lp~=0 || hp~=0
    w2=2*lp/EEG.srate;
    w1=2*hp/EEG.srate;
%     w=[w1 w2];
    order=3;
    if (w1==0 && w2>0)
        [B1,A1]=butter(order,w2,'low');
        filters(end+1).B=B1;
        filters(end).A=A1;
    elseif (w2==0 && w1>0)
        [B1,A1]=butter(order,w1,'high');
        filters(end+1).B=B1;
        filters(end).A=A1;
    elseif (w2>0 && w1>0)
        [B2,A2]=butter(order,w2,'low');
        [B1,A1]=butter(order,w1,'high');
        filters(end+1).B=B2;
        filters(end).A=A2;
        filters(end+1).B=B1;
        filters(end).A=A1;
    end
end

if bs1~=0 && bs2~=0
    order=3;
    BS=[];
    if bs1>0
        if bs2>0
            w3=2*bs1/EEG.srate;
            w4=2*bs2/EEG.srate;
            w=[w3 w4];
            [BS,AS]=butter(order,w,'stop');
        end
    end
    filters(end+1).B=BS;
    filters(end).A=AS;
end
clear A* B* w* order

% Apply filters
h=waitbar(0,'Filtering...');
if length(size(EEG.data))~=2
    % if EEG.data is [channels x time x epochs]
    datatmp=squeeze(num2cell(EEG.data,[1 2]))';
    for fff=1:1:length(filters)
        datatmp=cellfun(@(x) filtfilt(filters(fff).B,filters(fff).A,double(x'))',datatmp,'UniformOutput', false);
    end
    EEG.data=reshape(cell2mat(datatmp),size(datatmp{1},1),size(datatmp{1},2),size(datatmp,2));
    clear datatmp
else
    % if EEG.data is [channels x time]
    for fff=1:1:length(filters)
        EEG.data=filtfilt(filters(fff).B,filters(fff).A,double(EEG.data)')';
    end
end

waitbar(1,h);
delete(h)
if ~isfield(EEG,'filters')
    EEG.filters.highpass=[];
    EEG.filters.lowpass=[];
    EEG.filters.bandstop=[];
end
if lp~=0 && hp~=0
    EEG.filters.lowpass=lp;
    EEG.filters.highpass=hp;
elseif lp~=0
    EEG.filters.lowpass=lp;
elseif hp~=0
    EEG.filters.highpass=hp;
end

if bs1~=0 && bs2~=0
    EEG.filters.bandstop=[bs1 bs2];
end