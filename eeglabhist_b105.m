% EEGLAB history file generated on the 28-Jan-2016
% ------------------------------------------------

EEG = eeg_checkset( EEG );
EEG = eeg_checkset( EEG );
EEG = eeg_checkset( EEG );
EEG = eeg_checkset( EEG );
EEG = eeg_checkset( EEG );
EEG = pop_loadset('filename','RVS_Subject105_Base_512_ch_DC_epochs_tr2_auto.set','filepath','/Volumes/MY PASSPORT/EEG/RVS/Analyzed_datasets/RVS_Subject105/Base/');
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
EEG = pop_select( EEG,'trial',[23 49 91 94 95 106 117 133 149 152 156 190 192 201 216 239 276 282 289 290 292 293 298 300 322 335 342 343 356 358 368 406 410 416 418 425 452 455 466 476 480 481 485 490 493 512 521 524 526 532 551 584 596 606 615 623 626] );
EEG.setname='RVS_Subject105_Base_512_ch_DC_epochs_tr2_auto_double_tr_2_corr';
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG,'channel',{'Iz' 'Oz' 'POz' 'Pz' 'CPz' 'Fpz' 'AFz' 'Fz' 'FCz' 'Cz'});
EEG.setname='RVS_Subject105_Base_512_ch_DC_epochs_tr2_auto_double_tr_2_corr_Z';
EEG = eeg_checkset( EEG );
EEG = eeg_checkset( EEG );
