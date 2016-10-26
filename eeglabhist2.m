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
EEG = eeg_checkset( EEG );
EEG = pop_saveset( EEG, 'filename','RVS_Subject104_Test_512_ch_DC.set','filepath','/Volumes/MY PASSPORT/EEG/RVS/Analyzed_datasets/RVS_Subject104/Test/');
EEG = eeg_checkset( EEG );
EEG = pop_editset(EEG, 'setname', 'RVS_Subject104_Test_512_ch_DC');
EEG = eeg_checkset( EEG );
EEG = pop_epoch( EEG, {  '2'  }, [-0.5           4], 'newname', 'RVS_Subject104_Test_512_ch_DC_epochs_tr2', 'epochinfo', 'yes');
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [-500 -450]);
EEG = eeg_checkset( EEG );
EEG = pop_saveset( EEG, 'filename','RVS_Subject104_Test_512_ch_DC_epochs_tr2.set','filepath','/Volumes/MY PASSPORT/EEG/RVS/Analyzed_datasets/RVS_Subject104/Test/');
EEG = eeg_checkset( EEG );
