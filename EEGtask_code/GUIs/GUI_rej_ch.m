function varargout = GUI_rej_ch(varargin)
% GUI_REJ_CH MATLAB code for GUI_rej_ch.fig
%      GUI_REJ_CH, by itself, creates a new GUI_REJ_CH or raises the existing
%      singleton*.
%
%      H = GUI_REJ_CH returns the handle to a new GUI_REJ_CH or the handle to
%      the existing singleton*.
%
%      GUI_REJ_CH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_REJ_CH.M with the given input arguments.
%
%      GUI_REJ_CH('Property','Value',...) creates a new GUI_REJ_CH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_rej_ch_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_rej_ch_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_rej_ch

% Last Modified by GUIDE v2.5 02-Jan-2018 11:43:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_rej_ch_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_rej_ch_OutputFcn, ...
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


% --- Executes just before GUI_rej_ch is made visible.
function GUI_rej_ch_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_rej_ch (see VARARGIN)

% Choose default command line output for GUI_rej_ch
handles.output = hObject;

handles.chanlocs=varargin{1};
handles.badchs=varargin{2};

handles.all_ch={num2str([1:size(handles.chanlocs,2)]')};
set(handles.all_list,'String',handles.all_ch);
set(handles.bad_list,'String',num2str(handles.badchs));
cla(handles.ch_axes);
axes(handles.ch_axes);
topoplot(-2*zeros(length(handles.chanlocs),1),handles.chanlocs,'maplimits',[-2 2],'electrodes','ptslabels','emarker2',{handles.badchs,'o','r',7,1},'conv','on');%%%256
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_rej_ch wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_rej_ch_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in all_list.
function all_list_Callback(hObject, eventdata, handles)
% hObject    handle to all_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns all_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from all_list


% --- Executes during object creation, after setting all properties.
function all_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to all_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in bad_list.
function bad_list_Callback(hObject, eventdata, handles)

% hObject    handle to bad_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns bad_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from bad_list


% --- Executes during object creation, after setting all properties.
function bad_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bad_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rej_butt.
function rej_butt_Callback(hObject, eventdata, handles)

bbb=get(handles.all_list,'Value');
bbb=bbb';
handles.badchs=unique([handles.badchs;bbb]);
handles.badchs=sort(handles.badchs);
set(handles.bad_list,'String',num2str(handles.badchs));

cla(handles.ch_axes);
axes(handles.ch_axes);
topoplot(-2*zeros(length(handles.chanlocs),1),handles.chanlocs,'maplimits',[-2 2],'electrodes','ptslabels','emarker2',{handles.badchs,'o','r',7,1},'conv','on');%%%256

guidata(hObject, handles);

% hObject    handle to rej_butt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in acc_butt.
function acc_butt_Callback(hObject, eventdata, handles)

if ~isempty (handles.badchs)
    bbb=get(handles.bad_list,'Value');
    handles.badchs(bbb)=[];
    handles.badchs=sort(handles.badchs);
    if bbb~=1
        set(handles.bad_list,'Value',bbb-1);
    end
    set(handles.bad_list,'String',num2str(handles.badchs));
    
    cla(handles.ch_axes);
    axes(handles.ch_axes);
    topoplot(-2*zeros(length(handles.chanlocs),1),handles.chanlocs,'maplimits',[-2 2],'electrodes','ptslabels','emarker2',{handles.badchs,'o','r',7,1},'conv','on');%%%256
end
guidata(hObject, handles);
% hObject    handle to acc_butt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_butt.
function save_butt_Callback(hObject, eventdata, handles)

assignin('base','bad_elec',handles.badchs);
close(handles.figure1)

% hObject    handle to save_butt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function handles_exported_Callback(hObject, eventdata, handles)

assignin('base','handles_exported',handles);

% hObject    handle to handles_exported (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
