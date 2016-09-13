
EEG = pop_biosig('E:\BDFdata\RVS\RVS_Subject128\RVS_Subject128\Training1\RVS_Subject128_Training1.bdf', 'ref',[65 66] ,'refoptions',{'keepref' 'off'});
EEG.setname='Subject128_Training1';
EEG = eeg_checkset( EEG );
EEG = pop_resample( EEG, 512);
EEG.setname='Subject128_Training1_512';
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG,'nochannel',{'EXG5' 'EXG6' 'EXG7' 'EXG8'});
EEG.setname='Subject128_Training1_512_ch';
EEG = eeg_checkset( EEG );
EEG = pop_epoch( EEG, {  '50'  }, [-2  1], 'newname', 'Subject128_Training1_512_ch_DC_epochs', 'epochinfo', 'yes');
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [-2000 -1950]);
EEG.setname='Subject128_Training1_512_ch_DC_epochs_50';
EEG = pop_loadset('filename','Subject128_Training1_512_ch_DC_epochs_50.set','filepath','D:\\EEG_PRE-PROCESSING_DATA\\RVS_Subject128\\Training1\\');
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG,'notrial',[59 62 67 141 153 206 226 286 289 299 311 332 334 342 351 477 509 517 532 550 551 561 569 571 572 576 603 607 678 680 681 690 691 719 720 728 730 733:3:739 758 765 766 785 799] );
EEG.setname='Subject128_Training1_512_ch_DC_epochs_50_noisy';
EEG = pop_loadset('filename','Subject128_Training1_512_ch_DC_epochs_50_noisy.set','filepath','/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/RVS_Subject102/RVS_Subject128/Training1/');
EEG = eeg_checkset( EEG );