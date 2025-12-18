[fList, pList] = matlab.codetools.requiredFilesAndProducts('dipfitdefs.m');

fList=fList';
for tt=1:length(fList)
    I=strfind(fList{tt},'eeglab2020_0');
    [filepath,name,ext] = fileparts(fList{tt});
    
    mkdir(['C:\Users\matte\Desktop\EEGtask_v2.0\EEGlab_functions\' filepath(I:end)])
    copyfile(fList{tt},['C:\Users\matte\Desktop\EEGtask_v2.0\EEGlab_functions\' fList{tt}(I:end)])
    
    
end