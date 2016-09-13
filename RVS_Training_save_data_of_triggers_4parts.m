% 12 June 2016. 
% Maria L Stavrinou. 
%% Path information
Raw_Path = uigetdir('Select folder with Raw datasets');
if Raw_Path==0
    Raw_Path='/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/';
end

Analyzed_path= uigetdir('Select folder with Raw datasets');
if Analyzed_path == 0
    Analyzed_path = '/Volumes/EEG2_MARIA/EEG/RVS/Analyzed_datasets/';
end

cd(Raw_Path)
% Define list of folders 
listing_raw=dir('*Subject*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 
end
clear kk listing_raw

%% Define sessions
Sessions={'Training1', 'Training2'};
startfolder=2;
for kk=startfolder%:Num_folders
    Subject_filename=temp22{kk,:}; 
    % Work for each session independently 
    for jj=1:length(Sessions)
        session_temp=Sessions{jj};
        cd(Analyzed_path)
        cd(temp22{kk,:});
        Subject_filemname_session=[Subject_filename '_' session_temp];
        mkdir(session_temp);
        cd(session_temp);
        Analyzed_path_folder=[Analyzed_path temp22{kk,:} '/' session_temp '/'];
        Raw_path_folder=[Raw_Path temp22{kk,:} '/' session_temp '/'];
        cd(Analyzed_path_folder)
        cd Triggers
        %% Find triggers -make this search only for the first time
        if (kk==startfolder & jj==1)
            listing_raw=dir('triggers*txt');
            Num_files=length(listing_raw);
            for kkm=1:Num_files
                temp23{kkm,:}=listing_raw(kkm).name;
            end
            clear kkm
        end
        %% End finding triggers
        
        %% Start defining part names
        if strcmp(session_temp, 'Training1')
            part_names={'part_a'; 'part_b'};
        elseif strcmp(session_temp, 'Training2')
            part_names={'part_c'; 'part_d'};
        end
        
        %% End defining part names
        %% Loop to extract each type of trigger's single trials
        for kkj=1:length(temp23);
            % Load the triggers
            trial_type_temp=temp23{kkj};
            temp_trials=load(trial_type_temp);
            temp_trials_part_1=temp_trials(temp_trials<401);
            temp_trials_part_2=temp_trials(temp_trials>400);
            
            if ~isempty(temp_trials)
                
            %% Divide each training in two blocks
                for tt=1:2
                % Start selecting the trials we need -part_a /or part_c
                    switch tt
                        case 1
                            temp_trials=temp_trials_part_1;
                        case 2
                            temp_trials=temp_trials_part_2;
                    end
                    
                    % Load the original EEG set that we need  
                    cd(Analyzed_path_folder)
                    eeglab;
                    %TODO to search with 'dir , detect DC_epochs, stop
                    %there
                    Name_to_load=[Subject_filename(5:end) '_' session_temp '_512_ch_DC_epochs_50.set']
                    EEG = pop_loadset('filename', Name_to_load,'filepath',Analyzed_path_folder);
                    EEG = eeg_checkset( EEG );
                    eeglab redraw
                    % End loading the original EEG set that we need
                    EEG = pop_select( EEG,'trial', temp_trials');

                    part_name_to_save=part_names{tt};
                    temp_setname=[EEG.setname '_' temp23{kkj}(1:end-4) '_' part_name_to_save];
                    EEG.setname=temp_setname; %'RVS_Subject105_Base_512_ch_DC_epochs_tr2_auto_double_tr_2_corr';
                    EEG = eeg_checkset( EEG );
                    eeglab redraw

                    % Saving the dataset
                    Name_to_save=[temp_setname '.set'];
                    EEG = pop_saveset( EEG, 'filename',Name_to_save,'filepath',Analyzed_path_folder);
                    EEG = eeg_checkset( EEG );
                    eeglab redraw
                   
                end
        else 
            disp('Trigger found empty')
        clear temp_trials
            end
        cd(Analyzed_path_folder)
        cd Triggers
    end

    clear data
    end % End for each session

end % End for each subject
toc