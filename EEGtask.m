function varargout = EEGtask(varargin)
% EEGTASK MATLAB code for EEGtask.fig
%      EEGTASK, by itself, creates a new EEGTASK or raises the existing
%      singleton*.
%
%      H = EEGTASK returns the handle to a new EEGTASK or the handle to
%      the existing singleton*.
%
%      EEGTASK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EEGTASK.M with the given input arguments.
%
%      EEGTASK('Property','Value',...) creates a new EEGTASK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EEGtask_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EEGtask_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EEGtask

% Last Modified by GUIDE v2.5 27-Jul-2023 13:38:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EEGtask_OpeningFcn, ...
                   'gui_OutputFcn',  @EEGtask_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before EEGtask is made visible.
function EEGtask_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EEGtask (see VARARGIN)

% Choose default command line output for EEGtask
handles.output = hObject;
analyses={'1 - High-Pass Filter';'2 - Epoch and Channel Selection';...
    '3 - Run re-reference to the average and epoching';...
    '4 - Run ICA and Epoch Selection ICA based'; '5 - ICA component(s) selection';...
    '6 - Low-Pass Filter'; '7 - Re-referencing and PSD';'8 - SVM'};
set(handles.popAnalyses,'String',analyses)

plotAnalyses={'PSD All Channels','PSD Topograhy','PSD F/C/P/O', 'PSD L/M/R', 'PSD barplot'};
set(handles.popPlot,'String',plotAnalyses)

plotAnalyses={'Weight Topography','Spectra by Weight'};
set(handles.popPlotSVM,'String',plotAnalyses)

if spm_matlab_version_chk('8.6') > 0 %|| spm_matlab_version_chk('9.8') < 0
    
    [welcome]=EEGtask_controlpath('open',[]);
    handles.welcome=welcome;
    
%     handles=EEGsetLayout(handles,'open');
else
    
    warndlg('This tool requires a Matlab version between R2016 and 2019')
%     handles=EEGsetLayout(handles,'open');
%     handles=EEGsetLayout(handles,'freeze');
    
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EEGtask wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EEGtask_OutputFcn(hObject, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% hObject    handle to pushBIDS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushLoadPT.
function pushLoadPT_Callback(hObject, ~, handles)
[FileName,PathName]=uigetfile('*.mat');
if FileName==0; return; end
set(handles.textComm,'String','Loading Structure...','FontSize',8)
pause(0.1)
load(fullfile(PathName,FileName),'eegt')
if 1~=exist('eegt','var')
    return
end
if ~isequal(PathName,eegt.PathName)
    eegt.PathName=PathName;
    save(fullfile(PathName,FileName),'eegt')
end
handles.eegt=eegt;
set(handles.listTask,'Value',1)
set(handles.listTask,'String',fieldnames(eegt.tasks))
set(handles.listAnalyses,'Value',1);
set(handles.listAnalyses,'String',[]);
set(handles.popAnalyses,'Value',1);
set(handles.popPlot,'Value',1)
set(handles.textComm,'String','Structure Loaded','FontSize',8)
set(handles.textSubjPath,'String',fullfile(PathName,FileName),'FontSize',8)
guidata(hObject, handles);

% --- Executes on selection change in listTask.
function listTask_Callback(hObject, ~, handles)
tasks = cellstr(get(hObject,'String'));
if isempty(tasks{1});return; end
task=tasks{get(hObject,'Value')};
analyses=fieldnames(handles.eegt.tasks.(task).analyses);
set(handles.listAnalyses,'String',analyses)
set(handles.listAnalyses,'Value',1)
if length(analyses)==8
    set(handles.popAnalyses,'Value',length(analyses))
else
    set(handles.popAnalyses,'Value',length(analyses)+1)
end
set(handles.textComm,'String','')
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function listTask_CreateFcn(hObject, ~, handles)
% hObject    handle to listTask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listAnalyses.
function listAnalyses_Callback(hObject, ~, handles)
tasks = cellstr(get(handles.listTask,'String'));
if isempty(tasks{1});return; end
task=tasks{get(handles.listTask,'Value')};
analyses = cellstr(get(handles.listAnalyses,'String'));
if isempty(analyses{1});return; end
analysis=analyses{get(handles.listAnalyses,'Value')};
[testo] = EEGgetTextFromParams(handles.eegt,task,analysis);
set(handles.textComm,'String',testo,'FontSize',8)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function listAnalyses_CreateFcn(hObject, ~, handles)
% hObject    handle to listAnalyses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushRunAnalyses.
function pushRunAnalyses_Callback(hObject, ~, handles)
if isfield(handles,'eegt')
    tasks = cellstr(get(handles.listTask,'String'));
    task=tasks{get(handles.listTask,'Value')};
    analyses = cellstr(get(handles.popAnalyses,'String'));
    % analysis=analyses{get(handles.popAnalyses,'Value')};
    analysis_v=get(handles.popAnalyses,'Value');
    testo={['Running ''' analyses{analysis_v} ' ''analysis'];'';'Wait...'};
    set(handles.textComm,'String',testo,'FontSize',8)
    
    set(handles.pushLoadPT,'Enable','off')
    set(handles.pushRunAnalyses,'Enable','off')
    set(handles.listTask,'Enable','off')
    set(handles.listAnalyses,'Enable','off')
    set(handles.pushPlot,'Enable','off')
    set(handles.pushclear,'Enable','off')
    
    [handles.eegt]=eegt_analyses(handles.eegt,task,analysis_v);
    
    set(handles.listAnalyses,'String',fieldnames(handles.eegt.tasks.(task).analyses))
    if analysis_v+1<=length(analyses)
        set(handles.popAnalyses,'Value',analysis_v+1)
    end
    testo={['Running ''' analyses{analysis_v} ' ''analysis'];'';'Wait...';...
        '';['' analyses{analysis_v} ''' analysis completed']};
    set(handles.textComm,'String',testo,'FontSize',8)
    
    set(handles.pushLoadPT,'Enable','on')
    set(handles.pushRunAnalyses,'Enable','on')
    set(handles.listTask,'Enable','on')
    set(handles.listAnalyses,'Enable','on')
    set(handles.pushPlot,'Enable','on')
    set(handles.pushclear,'Enable','on')
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function Data_Structure_Callback(hObject, ~, handles)
% hObject    handle to Data_Structure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function NewDataset_Callback(hObject, ~, handles)
Create_EEGt()
% hObject    handle to NewDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function EditDataset_Callback(hObject, ~, handles)
[FileName,PathName]=uigetfile('*.mat');
if FileName==0; return; end
load(fullfile(PathName,FileName),'eegt')
if 1~=exist('eegt','var')
    return
end
Create_EEGt(eegt)


% --- Executes on selection change in popAnalyses.
function popAnalyses_Callback(hObject, ~, handles)
% hObject    handle to popAnalyses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popAnalyses contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popAnalyses


% --- Executes during object creation, after setting all properties.
function popAnalyses_CreateFcn(hObject, ~, handles)
% hObject    handle to popAnalyses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function EEGtask_CloseRequestFcn(hObject, ~, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

EEGtask_controlpath('close',handles.welcome);

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in pushPlot.
function pushPlot_Callback(hObject, ~, handles)
tasks = cellstr(get(handles.listTask,'String'));
task=tasks{get(handles.listTask,'Value')};
if ~isfield(handles,'eegt');return
else; eegt=handles.eegt; end

analyses = cellstr(get(handles.popPlot,'String'));
analysis=analyses{get(handles.popPlot,'Value')};

if ~isfield(eegt.tasks.(task).analyses, 'ReRef_PSD_7');return;end
switch analysis
    case 'PSD All Channels'
        fig_type='DisplayAllPSD';
    case 'PSD Topograhy'
        fig_type='PSD_Topography';
    case 'PSD F/C/P/O'
        fig_type='PSD_F_C_P_O';
    case 'PSD L/M/R'
        fig_type='PSD_L_M_R';
    case 'PSD barplot'
        fig_type='PSD_Bar_L_M_R';
end
EEGt_runPlotPSD(handles.eegt,task,'ReRef_PSD_7',fig_type)

% hObject    handle to pushPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popPlot.
function popPlot_Callback(hObject, ~, handles)
% hObject    handle to popPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popPlot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popPlot


% --- Executes during object creation, after setting all properties.
function popPlot_CreateFcn(hObject, ~, handles)
% hObject    handle to popPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushPlotSVM.
function pushPlotSVM_Callback(hObject, eventdata, handles)
tasks = cellstr(get(handles.listTask,'String'));
task=tasks{get(handles.listTask,'Value')};
if ~isfield(handles,'eegt');return
else; eegt=handles.eegt; end

analyses = cellstr(get(handles.popPlotSVM,'String'));
analysis=analyses{get(handles.popPlotSVM,'Value')};
if ~isfield(eegt.tasks.(task).analyses, 'SVM_8'); return;end
switch analysis
    case 'Weight Topography'
%         fig_type='W_Topo';
        pooled_wt_avg=eegt.tasks.(task).analyses.SVM_8.parameters.SVM.pooled_wt_avg;
        pooled_wt_avg_freq=eegt.tasks.(task).analyses.SVM_8.parameters.SVM.pooled_wt_avg_freq;
        goodCH=eegt.tasks.(task).analyses.SVM_8.parameters.goodchannels;
%         hfig=figure;topoplot(abs(pooled_wt_avg),eegt.tasks.(task).chanlocs(goodCH))
%         caxis([-0.3 0.3])
        hfig=figure;topoplot(mean(abs(pooled_wt_avg_freq),1),eegt.tasks.(task).chanlocs(goodCH))
        caxis([-0.3 0.3])
    case 'Spectra by Weight'
        fig_type='SpectraByWT';
        EEGt_runPlotSVM(eegt,task,'ReRef_PSD_7',fig_type)
end




% --- Executes on selection change in popPlotSVM.
function popPlotSVM_Callback(hObject, eventdata, handles)
% hObject    handle to popPlotSVM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popPlotSVM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popPlotSVM


% --- Executes during object creation, after setting all properties.
function popPlotSVM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popPlotSVM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushclear.
function pushclear_Callback(hObject, ~, handles)
set(handles.textComm,'String','')
set(handles.listTask,'Value',1);
set(handles.listTask,'String',[]);
set(handles.listAnalyses,'Value',1);
set(handles.listAnalyses,'String',[]);
set(handles.popAnalyses,'Value',1);
set(handles.popPlot,'Value',1)
set(handles.textSubjPath,'String',[]);
if isfield(handles,'eegt')
    handles=rmfield(handles,'eegt');
end
guidata(hObject, handles);

% hObject    handle to pushclear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Export_eegt_Callback(hObject, ~, handles)
% hObject    handle to Export_eegt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function EEGtStrcut_Callback(hObject, ~, handles)
assignin('base','eegt',handles.eegt)
% hObject    handle to EEGtStrcut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function FromTo_Callback(hObject, ~, handles)
% hObject    handle to FromTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in pushBIDS.
function pushBIDS_Callback(hObject, ~, handles)
EEGt_fromBIDS2EEGtask_getfile
guidata(hObject, handles);

% --------------------------------------------------------------------
function fromEDF2EEGtask_Callback(hObject, ~, handles)
EEGt_fromEDF2EEGtask_getfile
guidata(hObject, handles);


% --------------------------------------------------------------------
function fromBrainVision2EEGtask_Callback(hObject, ~, handles)
% hObject    handle to fromBrainVision2EEGtask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

