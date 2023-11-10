function [parameters]=EEGtask_getParams

parameters.epochDuration=[];
parameters.srate=[];
parameters.ref=[];
parameters.eventsOrig=struct;
parameters.eventsAllOrig=struct;
parameters.dimAllEventsOrig=[];
parameters.eventsAll=struct;
parameters.dimAllEvents=[];
parameters.filters=struct;
parameters.filters2=struct;

parameters.badchannels=[];
parameters.goodchannels=[];
parameters.badepochs=[];
parameters.goodepochs=[];

parameters.interp=[];
parameters.eventSel=[];
parameters.dimSelEvents=[];

parameters.ICA.muscleP=[];
parameters.ICA.eyeP=[];
parameters.ICA.heartP=[];
parameters.ICA.Cpca=[];
parameters.ICA.dim_icaact=[];
parameters.ICA.comp2remove=[];
parameters.ICA.compproj_dim=[];
parameters.ICA.var_compproj=[];

parameters.PSD.ref='';
parameters.PSD.distSelected=[];
parameters.PSD.fpass=[];
parameters.PSD.trigON='';
parameters.PSD.trigOFF='';
parameters.PSD.dimSpecON=[];
parameters.PSD.dimSpecOFF=[];
parameters.PSD.dimTrigONall=[];
parameters.PSD.dimTrigOFFall=[];
parameters.PSD.Bad_Tr=[];

parameters.SVM.n_rep=[];
parameters.SVM.folds=[];
parameters.SVM.all_iter=[];
parameters.SVM.p_value=[];
parameters.SVM.accuracy=[];
parameters.SVM.precision=[];
parameters.SVM.recall=[];
parameters.SVM.dur=[];
parameters.SVM.pooled_wt_all=[];
parameters.SVM.pooled_wt_avg=[];
parameters.SVM.pooled_wt_avg_freq=[];

parameters.SVM_wn.n_rep=[];
parameters.SVM_wn.folds=[];
parameters.SVM_wn.all_iter=[];
parameters.SVM_wn.p_value=[];
parameters.SVM_wn.accuracy=[];
parameters.SVM_wn.precision=[];
parameters.SVM_wn.recall=[];
parameters.SVM_wn.dur=[];
parameters.SVM_wn.pooled_wt_all=[];
parameters.SVM_wn.pooled_wt_avg=[];
parameters.SVM_wn.pooled_wt_avg_freq=[];
