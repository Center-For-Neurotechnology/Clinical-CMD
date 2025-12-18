% -----------------------------------------------------------------------
% Plot all EEG channels superimposed (averaged across trials) 
% Plot topography of voltages with a slidebar that allows to select a
% specific timepoint

% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------

function varargout = Bplot_Topo(varargin)
% BPLOT_TOPO MATLAB code for Bplot_Topo.fig
%      BPLOT_TOPO, by itself, creates a new BPLOT_TOPO or raises the existing
%      singleton*.
%
%      H = BPLOT_TOPO returns the handle to a new BPLOT_TOPO or the handle to
%      the existing singleton*.
%
%      BPLOT_TOPO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BPLOT_TOPO.M with the given input arguments.
%
%      BPLOT_TOPO('Property','Value',...) creates a new BPLOT_TOPO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Bplot_Topo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Bplot_Topo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Bplot_Topo

% Last Modified by GUIDE v2.5 10-Jan-2018 18:04:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Bplot_Topo_OpeningFcn, ...
                   'gui_OutputFcn',  @Bplot_Topo_OutputFcn, ...
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


% --- Executes just before Bplot_Topo is made visible.
function Bplot_Topo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Bplot_Topo (see VARARGIN)

% Choose default command line output for Bplot_Topo
handles.output = hObject;
if length(varargin)==5
    handles.data=varargin{1};
    handles.EEG.times=varargin{2};
    handles.EEG.nbchan=varargin{3};
    handles.EEG.badchannels=varargin{4};
    handles.EEG.chanlocs=varargin{5};
    handles.goodchannels=setdiff([1:handles.EEG.nbchan],handles.EEG.badchannels);

    set(handles.slider1,'Value',1)
    set(handles.slider1,'Max',length(handles.EEG.times))
    set(handles.slider1,'Min',1)
    set(handles.slider1,'SliderStep', [1/length(handles.EEG.times) ,10/length(handles.EEG.times)]);   
    
    axes(handles.b_plot)
    htmp=plot(handles.EEG.times,handles.data(handles.goodchannels,:),'Color','k');
    set(htmp,{'DisplayName'},{handles.EEG.chanlocs(handles.goodchannels).labels}')
    Y=get(handles.b_plot,'Ylim');
    hold on
    plot([handles.EEG.times(1) handles.EEG.times(1)],Y,'r','DisplayName','SLIDE','LineWidth',2)
    hold off

    set(handles.editY,'String',[num2str(Y(1)) ' ' num2str(Y(2))])
    set(handles.editX,'String',num2str([round(handles.EEG.times(1)) round(handles.EEG.times(end))]))

    axes(handles.topovolt)
    topoplot(handles.data(handles.goodchannels,1),handles.EEG.chanlocs(handles.goodchannels),'electrodes','on','maplimits','maxmin','plotrad',0.55);
    colorbar
    
    set(handles.text_time,'String',['Time: ' num2str(round(handles.EEG.times(1)*10)/10)])
    set(handles.figure1,'Color',[0.94 0.94 0.94])
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Bplot_Topo wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Bplot_Topo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editY_Callback(hObject, eventdata, handles)
Y=get(handles.editY,'String');
Y=str2num(Y);
Y=sort(Y);
if length(Y)==2
    set(handles.b_plot,'Ylim',Y)
else
    Y=get(handles.b_plot,'Ylim');
    set(handles.editY,'String',[num2str(Y(1)) ' ' num2str(Y(2))]);
end
I=findobj(handles.b_plot,'DisplayName','SLIDE');
set(I,'YData',Y);

guidata(hObject, handles);

% hObject    handle to editY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editY as text
%        str2double(get(hObject,'String')) returns contents of editY as a double


% --- Executes during object creation, after setting all properties.
function editY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editX_Callback(hObject, eventdata, handles)
X=get(handles.editX,'String');
X=str2num(X);
X=sort(X);
if length(X)==2
    It(1)=max(find(abs(handles.EEG.times-X(1))==min(abs(handles.EEG.times-X(1)))));
    It(2)=max(find(abs(handles.EEG.times-X(2))==min(abs(handles.EEG.times-X(2)))));
    set(handles.slider1,'Value',It(1))
    set(handles.slider1,'Max',It(2))
    set(handles.slider1,'Min',It(1))
    set(handles.slider1,'SliderStep', [1/(It(2)-It(1)) ,10/(It(2)-It(1))]);   

    I=findobj(handles.b_plot,'DisplayName','SLIDE');
    I_sl=unique(get(I,'XData'));
    if I_sl<handles.EEG.times(It(1))
        set(I,'XData',[handles.EEG.times(It(1)) handles.EEG.times(It(1))]);
        
        cla(handles.topovolt)
        axes(handles.topovolt)
        topoplot(handles.data(handles.goodchannels,It(1)),handles.EEG.chanlocs(handles.goodchannels),'electrodes','on','maplimits','maxmin','plotrad',0.55);
        colorbar
        set(handles.figure1,'Color',[0.94 0.94 0.94])
        
        set(handles.text_time,'String',['Time: ' num2str(round(handles.EEG.times(It(1))*10)/10)])
    end
    if I_sl>handles.EEG.times(It(2))
        set(I,'XData',[handles.EEG.times(It(2)) handles.EEG.times(It(2))]);
        
        cla(handles.topovolt)
        axes(handles.topovolt)
        topoplot(handles.data(handles.goodchannels,It(2)),handles.EEG.chanlocs(handles.goodchannels),'electrodes','on','maplimits','maxmin','plotrad',0.55);
        colorbar
        set(handles.figure1,'Color',[0.94 0.94 0.94])
        
        set(handles.text_time,'String',['Time: ' num2str(round(handles.EEG.times(It(2))*10)/10)])

    end
    
    set(handles.b_plot,'Xlim',[handles.EEG.times(It(1)) handles.EEG.times(It(2))])
    set(handles.editX,'String',num2str([round(handles.EEG.times(It(1))) round(handles.EEG.times(It(2)))]))

else
    X=get(handles.b_plot,'Xlim');
    set(handles.editX,'String',num2str(X));
end

guidata(hObject, handles);



% hObject    handle to editX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editX as text
%        str2double(get(hObject,'String')) returns contents of editX as a double


% --- Executes during object creation, after setting all properties.
function editX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)

slide=get(handles.slider1,'Value');
slide=round(slide);
set(handles.slider1,'Value',slide);

I=findobj(handles.b_plot,'DisplayName','SLIDE');
set(I,'XData',[handles.EEG.times(slide) handles.EEG.times(slide)]);

cla(handles.topovolt)
axes(handles.topovolt)
topoplot(handles.data(handles.goodchannels,slide),handles.EEG.chanlocs(handles.goodchannels),'electrodes','on','maplimits','maxmin','plotrad',0.55);
colorbar
set(handles.figure1,'Color',[0.94 0.94 0.94])

set(handles.text_time,'String',['Time: ' num2str(round(handles.EEG.times(slide)*10)/10)])

guidata(hObject, handles);

% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function text_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in data_cursor.
function data_cursor_Callback(hObject, eventdata, handles)
if strcmp(get(handles.data_cursor,'UserData'),'on')
    datacursormode off
    set(handles.data_cursor,'UserData','off')
else
    set(handles.data_cursor,'UserData','on')
    datacursormode on
end
dcm_obj = datacursormode;
set(dcm_obj,'UpdateFcn',@get_ch_datatip)
guidata(hObject, handles);


% hObject    handle to data_cursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in exp_but.
function exp_but_Callback(hObject, eventdata, handles)
figure
htmp=plot(handles.EEG.times,handles.data(handles.goodchannels,:),'Color','k');
set(htmp,{'DisplayName'},{handles.EEG.chanlocs(handles.goodchannels).labels}')

% hObject    handle to exp_but (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
