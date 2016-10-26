% 2 June 2016. 
% Maria L Stavrinou. 
clear all
close all

%% Path information
Raw_Path='D:\RVS\Raw_datasets\';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/RVS/'; 
%'/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/'%RVS_Subject104/Base/';
%
Analyzed_path='D:\RVS\Analyzed_datasets\';
cd(Raw_Path)
% Define list of folders 
listing_raw=dir('*Subject*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 
end
% test22=temp22(1,1)
clear kk listing_raw

%% Define sessions
Sessions={'Training1', 'Training2'};

for kk=2:7%Num_folders
    Subject_filename=temp22{kk,:}; 
    % Work for each session independently 
    for jj=1:length(Sessions)
        session_temp=Sessions{jj};
        cd(Analyzed_path)
        cd(temp22{kk,:});
        Subject_filemname_session=[Subject_filename '_' session_temp];
        mkdir(session_temp);
        cd(session_temp);
        Analyzed_path_folder=[Analyzed_path temp22{kk,:} '\' session_temp '\'];
        Raw_path_folder=[Raw_Path temp22{kk,:} '\' temp22{kk,:} '\' session_temp '\'];
        cd(Analyzed_path_folder)
        cd TriggersERN
        %% Find triggers
        listing_raw=dir('triggers*txt');
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
                name_to_load_temp=dir('*_128_ch_DC_epochs_tr1_5_chan_5_filt_ERN.set');
                name_to_load=name_to_load_temp.name;
                %Name_to_load=[Subject_filename(5:end) '_' session_temp '_128_ch_DC_epochs_tr1_5_chan_5_filt_ERN.set']
                EEG = pop_loadset('filename',name_to_load,'filepath',Analyzed_path_folder);
                EEG = eeg_checkset( EEG );
                eeglab redraw
                % End loading the original EEG set that we need
                
                % Start selecting the trials we need
                EEG = pop_select( EEG,'trial', temp_trials');
                temp_setname=[EEG.setname '_' temp23{kkj} 'ERN'];
                EEG.setname=temp_setname; %'RVS_Subject105_Base_512_ch_DC_epochs_tr2_auto_double_tr_2_corr';
                EEG = eeg_checkset( EEG );
                eeglab redraw
                
                % Saving the dataset
                Name_to_save=[temp_setname '.set'];
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
                temp_Namesave=[Subject_filename '_' temp23{kkj} '.mat'];
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