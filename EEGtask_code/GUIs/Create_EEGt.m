function varargout = Create_EEGt(varargin)
% CREATE_EEGT MATLAB code for Create_EEGt.fig
%      CREATE_EEGT, by itself, creates a new CREATE_EEGT or raises the existing
%      singleton*.
%
%      H = CREATE_EEGT returns the handle to a new CREATE_EEGT or the handle to
%      the existing singleton*.
%
%      CREATE_EEGT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATE_EEGT.M with the given input arguments.
%
%      CREATE_EEGT('Property','Value',...) creates a new CREATE_EEGT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Create_EEGt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Create_EEGt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Create_EEGt

% Last Modified by GUIDE v2.5 08-Oct-2022 16:45:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Create_EEGt_OpeningFcn, ...
                   'gui_OutputFcn',  @Create_EEGt_OutputFcn, ...
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


% --- Executes just before Create_EEGt is made visible.
function Create_EEGt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Create_EEGt (see VARARGIN)

% Choose default command line output for Create_EEGt
handles.output = hObject;

if ~isempty(varargin)
    handles.eegt=varargin{1};
    set(handles.editSelFolder,'String',handles.eegt.PathName)
    set(handles.listTask,'String',fieldnames(handles.eegt.tasks))
    set(handles.editSubjID,'String',handles.eegt.subjectID)
    set(handles.editSubjID,'Enable','off')
    if ~isempty(handles.eegt.ses)
        set(handles.editSes,'String',handles.eegt.ses)
    end
    set(handles.editSes,'Enable','off')
    set(handles.pushSelFolder,'Enable','off')
    set(handles.pushSelFile,'Enable','on')
    set(handles.pushSave,'Enable','on')
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Create_EEGt wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Create_EEGt_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editSelFolder_Callback(hObject, ~, handles)
% hObject    handle to editSelFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSelFolder as text
%        str2double(get(hObject,'String')) returns contents of editSelFolder as a double


% --- Executes during object creation, after setting all properties.
function editSelFolder_CreateFcn(hObject, ~, handles)
% hObject    handle to editSelFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushSelFolder.
function pushSelFolder_Callback(hObject, ~, handles)
pathData=uigetdir;
if pathData==0; return; end
set(handles.editSelFolder,'String',pathData)
eegt.subjectID=[];
eegt.ses=[];
eegt.FileName=[];
eegt.PathName=[pathData filesep];
eegt.DateOfCreation=[];
eegt.tasks=[];
handles.eegt=eegt;
set(handles.editSubjID,'Enable','on')
set(handles.editSes,'Enable','on')
set(handles.pushSelFile,'Enable','on')
guidata(hObject, handles);


function editSubjID_Callback(hObject, ~, handles)
handles.eegt.subjectID=get(handles.editSubjID,'String');
ses=get(handles.editSes,'String');
if isempty(handles.eegt.subjectID)
    handles.eegt.FileName=[];
    set(handles.pushSave,'Enable','off')
else
    if ~isempty(ses)
        handles.eegt.FileName=['sub-' handles.eegt.subjectID '_ses-' ses];
    else
        handles.eegt.FileName=['sub-' handles.eegt.subjectID];
    end
    set(handles.pushSave,'Enable','on')
end
set(handles.editID,'String',handles.eegt.FileName)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editSubjID_CreateFcn(hObject, ~, handles)
% hObject    handle to editSubjID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushSelFile.
function pushSelFile_Callback(hObject, ~, handles)
FileName=uigetfile(fullfile(handles.eegt.PathName,'*.set'));
if isempty(strfind(FileName,'task')) 
    task = inputdlg({'Enter task name:'},'Input task',1);
else
    [token,remain]=strtok(FileName(strfind(FileName,'task')+5:end-4),'_');
    if isempty(remain)
        task=FileName(strfind(FileName,'task')+5:end-4);
    else
        task=token;
    end
    TF = isstrprop(task,'digit');
    if TF(1)
        task = inputdlg({'Enter task name:'},'Input task',1,{task});
        task=task{1};
    end
end
task=lower(task);
if ~isempty(handles.eegt.tasks)
    tasks=fieldnames(handles.eegt.tasks);
    if ismember(tasks,task)
        warning('task already inserted')
        return
    end
end
tmp.task=task;
tmp.SETfile=FileName;
% tmp.EpochLength=[];
% tmp.badCH=[];
% tmp.badEP=[];
tmp.chanlocs=struct;
tmp.analyses=struct;%.EEG_orig=EEG; % No Data Saved, only EEG
handles.eegt.tasks.(task)=tmp;
% assignin('base','handles',handles)
set(handles.listTask,'String',fieldnames(handles.eegt.tasks))
guidata(hObject, handles);


% --- Executes on selection change in listTask.
function listTask_Callback(hObject, ~, handles)
% hObject    handle to listTask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listTask contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listTask


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


% --- Executes on button press in pushSave.
function pushSave_Callback(hObject, ~, handles)
if 7~=exist(fullfile(handles.eegt.PathName,'EEGtask'),'dir')
    mkdir(handles.eegt.PathName,'EEGtask')
end
tasks=fieldnames(handles.eegt.tasks);
for kk=1:length(tasks)
   if 7~=exist(fullfile(handles.eegt.PathName,'EEGtask',tasks{kk}),'dir')
       mkdir(fullfile(handles.eegt.PathName,'EEGtask'),tasks{kk})
   end
end
handles.eegt.DateOfCreation=datetime;
eegt=handles.eegt;
save(fullfile(handles.eegt.PathName,[handles.eegt.FileName '.mat']),'eegt')
delete(gcf);


function editSes_Callback(hObject, ~, handles)
subjectID=get(handles.editSubjID,'String');
handles.eegt.ses=get(handles.editSes,'String');
if isempty(subjectID)
    handles.eegt.FileName=[];
else
   if ~isempty(handles.eegt.ses)
       handles.eegt.FileName=['sub-' subjectID '_ses-' handles.eegt.ses];
   else 
       handles.eegt.FileName=['sub-' subjectID];
   end
   set(handles.editID,'String',handles.eegt.FileName)
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editSes_CreateFcn(hObject, ~, handles)
% hObject    handle to editSes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editID_Callback(hObject, ~, handles)
% hObject    handle to editID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editID as text
%        str2double(get(hObject,'String')) returns contents of editID as a double


% --- Executes during object creation, after setting all properties.
function editID_CreateFcn(hObject, ~, handles)
% hObject    handle to editID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
