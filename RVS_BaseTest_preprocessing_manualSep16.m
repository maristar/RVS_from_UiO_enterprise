% History of Base- Test preprocessing
% 14.09.2016

EEG = pop_biosig('Z:\RVS\Raw_datasets\DataRVS\RVS_Subject101\RVS_Subject101\Base\RVS_Subject101_Base.bdf', 'ref',[65 66] ,'refoptions',{'keepref' 'off'});
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','RVS_Subject101_Base','gui','off'); 
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG,'channel',{'F3' 'FC3' 'C1' 'C5' 'CP3' 'P5' 'PO7' 'O1' 'Oz' 'POz' 'Pz' 'CPz' 'Fpz' 'Fp2' 'AFz' 'Fz' 'F2' 'F4' 'FC4' 'FCz' 'Cz' 'C2' 'C6' 'CP4' 'P4' 'PO8' 'O2' 'EXG3' 'EXG4' 'EXG5' 'EXG6'});
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG,);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
EEG=pop_chanedit(EEG, 'lookup','m:\\pc\\dokumenter\\MATLAB\\eeglab_sml_v3\\eeglab_sml_v3\\plugins\\dipfit2.3\\standard_BESA\\standard-10-5-cap385.elp');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG = pop_saveset( EEG, 'filename','RVS_Subject101_Base_accLuck.set','filepath','Z:\\RVS\\Raw_datasets\\DataRVS\\RVS_Subject101\\RVS_Subject101\\Base\\');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);