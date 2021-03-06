% Step 3 in the analysis
% 2 June 2016. 
% Maria L Stavrinou.
% 08.09.2016 the extension win_s means it is corrected for windows and run
% on server stat
% This does not change the epoch length
%% Path information
% Raw_Path='Z:\RVS\RAW_datasets\DataRVS\'; % FRN
%Raw_Path='/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/RVS/'; 
%%RVS_Subject104/Base/';
%
% Analyzed_path='Z:\RVS\Analyzed_datasets\'; % FRN
%Analyzed_path='/Volumes/EEG2_MARIA/EEG/RVS/Analyzed_datasets_FRN_1_20Hz/';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/RVS/';

% Added 04.01.2017 
clear all 
close all 

Raw_Path='Y:\Prosjekt\RVS_43_subjects\Raw_datasets\DataRVS\';
Analyzed_path='Y:\Prosjekt\RVS_43_subjects\Analyzed_datasets\';

%Go to Raw_path to find all folders. Important to go there. 
cd(Raw_Path)
% Define list of folders 
clear temp22 
listing_raw=dir('RVS_Subject114*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 
end
% test22=temp22(1,1)
clear kk listing_raw

%% Define sessions
Sessions={'Training1', 'Training2'};


%% Define which subjects to keep in the analysis 
%bad_subject_list=[6,8,13,14,15,16,18,19,22,26,32]; % for Stim oLD
bad_subject_list=[];
%bad_subject_list=[1, 4, 8, 18, 22, 26, 30]; % ch 02.01.2017  for Stim
%bad_subject_list=[8, 12, 16,  18, 22, 26, 30]; % for Stim bad pupil by Thomas: 12, 16,  18, 22, 26
% bad_subject_list=[6,8,18,22,26,32, 34,37,40]; % for FRN, 25.02.2017
good_subj_list=[]; for kk=1:Num_folders, if ~ismember(kk, bad_subject_list), good_subj_list=[good_subj_list kk]; end; end


%% Start load
for mkk=1:length(good_subj_list)
    kk=good_subj_list(mkk);
    Subject_filename=temp22{kk,:}; 
    % Print a message on screen to show on which subject we are working
    fprintf(' ***  Working on subject %s: %s\n', num2str(mkk), Subject_filename)
    % Work for each session independently 
    for jj=1:length(Sessions)
        session_temp=Sessions{jj};
        cd(Analyzed_path)
        cd(temp22{kk,:});
        Subject_filename_session=[Subject_filename '_' session_temp];
        mkdir(session_temp);
        cd(session_temp);
        Analyzed_path_folder=[Analyzed_path temp22{kk,:} '\' session_temp '\'];
        Raw_path_folder=[Raw_Path temp22{kk,:} '\' session_temp '\'];
        cd(Analyzed_path_folder)
        cd Triggers
        %% Find triggers
        listing_raw=dir('triggers*txt'); % for FRN and pupil data EOG 23-02.2017
        %listing_raw=dir('stim_*_corr.txt'); % for Stim
        Num_files=length(listing_raw);
        for kkm=1:Num_files
             temp23{kkm,:}=listing_raw(kkm).name;
        end
        clear kkm
        %% End finding triggers
        
        %% Loop to extract each type of trigger's single trials
        for kkj=1:length(temp23);
            % Load the triggers
            trial_type_temp=temp23{kkj};
            temp_trials=load(trial_type_temp);
            if ~isempty(temp_trials)
                % Load the original EEG set that we need  
                cd(Analyzed_path_folder)
                % list_filename=dir('*_256__Luck.set');  % TODO ADD AS ARGUMENT For FRN
                list_filename=dir('*_256__Luck_stim_unfilt_EOG.set');  % TODO ADD AS ARGUMENT For Stim
                %list_filename=dir('*_256__Luck_stim.set');  % TODO ADD AS ARGUMENT For Stim

                Name_to_load=list_filename.name;
                %[Subject_filename_session '_128_ch_DC_epochs_tr50_auto_5_chan_filt_FRN.set']
                EEG = pop_loadset('filename', Name_to_load,'filepath',Analyzed_path_folder);
                EEG = eeg_checkset( EEG );
                eeglab redraw
                % End loading the original EEG set that we need
                
                % In Subject102, TRaining2, numtrials=799, and one was
                % having the 800 trial inside. to solve this we do the
                % following:
                num_trials_in_eeg=EEG.trials;
                temp_trials=temp_trials(temp_trials<num_trials_in_eeg+1);
                
                
                % Start selecting the trials we need
                EEG = pop_select( EEG,'trial', temp_trials');
                temp_setname=[EEG.filename(1:end-4) '_' temp23{kkj}(1:end-4)];
                EEG.setname=temp_setname; %'RVS_Subject105_Base_512_ch_DC_epochs_tr2_auto_double_tr_2_corr';
                EEG = eeg_checkset( EEG );
                eeglab redraw
                
                % Saving the dataset
                Name_to_save=[temp_setname '.set'];
                %Name_to_save=name_file;
                EEG = pop_saveset( EEG, 'filename',Name_to_save,'filepath',Analyzed_path_folder);
                EEG = eeg_checkset( EEG );
                eeglab redraw
                % Select channels - to be commented
                % EEG = pop_select( EEG,'channel',{'Iz' 'Oz' 'POz' 'Pz' 'CPz' 'Fpz' 'AFz' 'Fz' 'FCz' 'Cz'});
                % EEG.setname='RVS_Subject105_Base_512_ch_DC_epochs_tr2_auto_double_tr_2_corr_Z';
                % EEG = eeg_checkset( EEG );
                % eeglab redraw
                % Save Matlab array for further processing.
                data=EEG.data;
                temp_Namesave=[temp_setname '.mat'];
                %save temp_Namesave data
                eval(['save ' temp_Namesave ' data Name_to_save'])
        else 
            disp('Trigger found empty')
        end
        cd(Analyzed_path_folder)
        cd Triggers
    end

    clear data
    end % End for each session

end % End for each subject