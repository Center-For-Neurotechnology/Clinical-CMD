% -----------------------------------------------------------------------
% input: 
% - event_obj

% output: 
% - ch_name: return channel name

% -----------------------------------------------------------------------

% --------------------------
% Author: Fecchio Matteo
% --------------------------

function ch_name = get_ch_datatip(empt,event_obj)
% Customizes text of data tips

ch_name=event_obj.Target.DisplayName;
