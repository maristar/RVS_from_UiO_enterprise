
%% Saves the EEGLAB datasets with the various trigger types. 
% Modified to save triggers for all kinds of triggers we are checking and
% not only the double report that we were checking before. 
% Renamed from the previous version with the filename *mac.m
% 18 June 2016 Maria L. Stavrinou at home 
tic
clear all 
close all 
tic
%% Path information
Raw_Path='/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/'%RVS_Subject104/Base/';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/'; 
Analyzed_path='/Volumes/EEG2_MARIA/EEG/RVS/Analyzed_datasets_B_T/'
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/';

cd(Analyzed_path)
% Define list of folders 
listing_raw=dir('RVS_Subject*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 
end

Sessions={'Base', 'Test'};

%% 
cd(Analyzed_path)
fid=fopen('RVS_BT_counts_of_triggers.txt', 'wt');
fprintf(fid, '%s\t%s\n', 'Name of trigger ',' Number of trials');
%% Start the mega loop for analysis 
startfolder=1;
correct_folders=[startfolder 2:6 8:12 14 15 18 21:29 31:33];
for kk=[correct_folders]
    Folder_name=temp22{kk,:};
    Analyzed_path_folder=[Analyzed_path temp22{kk,:} '/'];
    Raw_path_folder=[Raw_Path temp22{kk,:} '/'];
    cd(Raw_path_folder);
    sessions={'Base','Test'};
    for kkj=1:length(sessions)
        current_session=sessions{kkj};
        Raw_path_folder_session=[Raw_path_folder current_session '/'];
        Analyzed_path_folder_session=[Analyzed_path_folder current_session '/'];
        Name_Subject_session=[Folder_name '_' sessions{kkj}];
        % Print to log
        fprintf(fid, '%s\n', Name_Subject_session);
        
        %% Select condition, find all the trigger types we got
        cd(Analyzed_path_folder_session)
        cd Triggers
        trig_listing = dir('double_*'); % this creates a structure with all the names of the triggers
        %% start from trianing
        %% Find triggers -make this search only for the first time
        if (kk==startfolder & kkj==1)
            listing_raw=dir('double_one_*_corr.txt');
            Num_files=length(listing_raw);
            for kkm=1:Num_files
                temp23{kkm,:}=listing_raw(kkm).name;
            end
            clear kkm
        end
        
        %%end from training
        %% Loop to extract each type of trigger's single trials
        for kkj=1:length(temp23);
            % Load the triggers
            cd(Analyzed_path_folder_session);
            cd('Triggers');
            trial_type_temp=temp23{kkj};
            trial_type_temp_char=char(trial_type_temp);
            temp_trials=load(trial_type_temp);
            temp_trial_count=length(temp_trials);

            fprintf(fid, '%s\t %s\t\n', trial_type_temp, num2str(temp_trial_count));
            if ~isempty(temp_trials)
                % Load the original dataset
                cd(Analyzed_path_folder_session)
                Name_to_load=[Name_Subject_session(5:end) '_128_ch_DC_epochs_tr2.set'];
                eeglab;
                EEG = pop_loadset('filename',Name_to_load,'filepath',Analyzed_path_folder_session);
                EEG = eeg_checkset( EEG );
                eeglab redraw
                
                % Include a check bacause EEG sometimes has less triggers that
                % the e-prime missing usually the last ones. (stopped
                % recording?)
                if EEG.trials>temp_trial_count
                    temp_trials=temp_trials(temp_trials<EEG.trials);
                end

                % Select the trials 
                EEG = pop_select( EEG,'trial', temp_trials');
                temp_setname=[EEG.setname '_' temp23{kkj}(1:end-4)];
                EEG.setname=temp_setname; %'RVS_Subject105_Base_512_ch_DC_epochs_tr2_auto_double_tr_2_corr';
                EEG = eeg_checkset( EEG );
                eeglab redraw

                % Saving the dataset
                Name_to_save=[temp_setname '.set'];
                EEG = pop_saveset( EEG, 'filename',Name_to_save,'filepath',Analyzed_path_folder_session);
                EEG = eeg_checkset( EEG );
                eeglab redraw
                
                clear temp_setname Name_to_save
%               %% Save a matlab variable for wavelet or other analysis :)
%               data=EEG.data;
%               cd(Analyzed_path_folder_session)
%               temp_Namesave=[current_session(1) num2str(Folder_name(12:end)) '.mat'];
%               save data data
            else
                disp('Trigger found empty')
            end
            clear trial_type_temp temp_trials temp_trial_count
        end % For every trial type
    end % For every session 
end % For every subject 
fclose(fid)
toc