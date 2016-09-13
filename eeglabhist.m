% EEGLAB history file generated on the 25-Jan-2016
% ------------------------------------------------

EEG = pop_biosig('/Volumes/MY PASSPORT/EEG/RVS/RAW_datasets/RVS_Subject104/Test/Subject104_Test.bdf', 'ref',[65 66] ,'refoptions',{'keepref' 'off'});
EEG.setname='RVS_Subject104_Test';
EEG = eeg_checkset( EEG );
EEG = pop_resample( EEG, 512);
EEG.setname='RVS_Subject104_Test_512';
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG,'nochannel',{'EXG5' 'EXG6' 'EXG7' 'EXG8'});
EEG.setname='RVS_Subject104_Test_512_ch';
EEG = eeg_checkset( EEG );
% End of eeglabhist
%% Apply DC filter 
%  Run the DCoffset_removal_21_10_2011_a_final.m made as function
input_data=EEG.data;
data_filt=DC_offset_removal(input_data);
EEG.data=data_filt;
clear data_filt input_data;
EEG.setname=[EEG.setname '_DC']
eeglab redraw