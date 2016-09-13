% Makes the 4-5 preprocesing steps automatically.
%% Path information
Raw_Path='/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/'%RVS_Subject104/Base/';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/'; 
Analyzed_path='/Volumes/MY PASSPORT/EEG/RVS/Analyzed_datasets/'
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/';

cd(Raw_Path)
% Define list of folders 
listing_raw=dir('RVS_Subject*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 
end
% test22=temp22(1,1)
clear kk listing_raw
%% Instruction: The folder name should be the same and as defined above
 % Lets start the mega loop
for kk=1% 1:Num_folders
    Folder_name=temp22{kk,:};
    Analyzed_path_folder=[Analyzed_path temp22{kk,:} '/'];
    Raw_path_folder=[Raw_Path temp22{kk,:} '/' temp22{kk,:} '/'];
    cd(Raw_path_folder);
    sessions={'Base','Test'}
    for kkj=1:length(sessions)
        current_session=sessions{kkj};
        Raw_path_folder_session=[Raw_path_folder current_session '/']
        Analyzed_path_folder_session=[Analyzed_path_folder current_session '/']
        Name_Subject_session=[Folder_name '_' sessions{kkj}]
        %% Load the raw dataset 
        
        [ALLEEG EEG CURRENTSET ALLCOM]=eeglab;
        EEG= pop_biosig(); % '/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/MariaLoizou/Maria1.bdf', 'ref',[65 66] ,'refoptions',{'keepref' 'off'});
        EEG.setname=Name_Subject_session(5:end);
        eeglab redraw
        EEG = eeg_checkset( EEG );

%         %% Detect noisy channels
%         hfigure=pop_eegplot( EEG, 1, 1, 1);
%         f=warndlg('Scroll the data and select the noisy channels. Close this window only when you are done to continue', 'A warning dialog');
%         disp('This prints immediately');
%         drawnow
%         waitfor(f);
%         disp('This prints when you finished closing the window');
        EEG = pop_select( EEG,'nochannel',{'EXG5' 'EXG6' 'EXG7' 'EXG8'});
        % EEG = pop_select( EEG,'channel',{'C1' 'CP3' 'PO7' 'Oz' 'POz' 'Pz' 'CPz' 'Fpz' 'AFz' 'Fz' 'FCz' 'Cz' 'C2' 'CP4' 'PO8'});
        EEG = eeg_checkset( EEG );
        eeglab redraw
        %% TODO to run the DC offset filter -i run it after

        %% Resample
        fs_new=512;
        EEG = pop_resample( EEG, fs_new);
        temp_setname_resample=[Name_Subject_session '_' num2str(fs_new)];
        EEG.setname=temp_setname_resample;
        EEG = eeg_checkset( EEG );
        eeglab redraw
        
        %% Apply DC filter 
        %  Run the DCoffset_removal_21_10_2011_a_final.m made as function
        input_data=EEG.data;
        data_filt=DC_offset_removal(input_data);
        EEG.data=data_filt;
        clear data_filt input_data;
        EEG.setname=[temp_setname_resample '_ch_DC']
        eeglab redraw
        
        % TODO - Add filtering 0.1 - 100 Hz
        data_filt_smoot=eegfilt(EEG.data, fs_new, 1, 1);
        EEG.data=data_filt_smooth;
        % Epoch
        temp_epochname=[Name_Subject_session '_' num2str(fs_new)  '_ch_DC_epochs_tr2' ];
        % TODO check if it accepts the temp_epochname below
        EEG = pop_epoch( EEG, {  '2'  }, [-0.5 4], 'newname', temp_epochname, 'epochinfo', 'yes');
        EEG = eeg_checkset( EEG );
        EEG = pop_rmbase( EEG, [-500 -450]);
        EEG.setname=temp_epochname;
        eeglab redraw
        EEG = pop_saveset( EEG, 'filename',temp_epochname,'filepath', Analyzed_path_folder_session);
    end
end
    


      
%         %% EWS EDW 25.1.2016 1:08AM
%         
%         % Store & save the dataset
%         [ALLEEG EEG]=eeg_store(ALLEEG, EEG, 1); % New to store the data 
%         EEG = eeg_checkset( EEG );
%         eeglab redraw
% 
%         EEG = pop_saveset(EEG, 'filename', Set_CURRENT_1,'filepath', Analyzed_path_folder, 'check', 'on' );
%         eeglab redraw
% 
%         filename_saved=[Set_CURRENT_1 '.set'];

% %% If all the above have been done once, do this: // START HERE FOR EPOCHED
% % Restart - reset the eeglab
% [ALLEEG EEG CURRENTSET ALLCOM]=eeglab;
% %filename_saved='MariaLo_512_epochs_ch_clear.set'
% %Set_CURRENT_1='MariaLo_512_epochs_ch_clear';
% 
% filename_saved='Jacob_512_ch_DC_epochs.set';
% Set_CURRENT_1='Jacob_512_ch_DC_epochs';
% EEG =pop_loadset('filename', filename_saved, 'filepath', Analyzed_path_folder);
% eeglab redraw
% 
% cd(Analyzed_path_folder)
% Noisy = dlmread('Noisy.rtf',' ',6,2);
% 
% %%TODO add to the noisy the uncorrect indices
% %% 
% for jj=1:length(conditions)
%     temp_condition=conditions(jj);
%     %temp_condition=cellstr(temp_condition);
%     temp_condition_char=char(temp_condition);
%     
%     % Make sure to load the epoched dataset
%     % for ex. Set_CURRENT_1='MariaLo_512_epochs_ch_clear';   
%     EEG =pop_loadset('filename', filename_saved, 'filepath', Analyzed_path_folder);
%     eeglab redraw
%     
%     index=zeros(1,EEG.trials); % Should be 200 or 300 in our case
%     for kk=1:EEG.trials, 
%         if strcmp(a.Var48(kk,1),temp_condition)==1, 
%             index(kk)=1; 
%         end;
%     end
%     % index is an array of 1s and 0s. 1 means that in that position (index)
%     % there is an 'AX' (for example).
%     % Isolate the indexes that have the condition (AX) we want
%     indexAX=find(index>0);
% 
%     % Set to zero the indexes that belong to AX condition but also belong
%     % to Noisy
%     
%     % Combine error responses and noisy triggers
%     Noisy_error=[Noisy, indexes_error'];
%     Noisy_error2=unique(Noisy_error);
%     
%     for mm=1:length(indexAX),
%         if ismember(indexAX(mm), Noisy_error2)==1,
%             indexAX(mm)=0;
%         end
%     end
%     
%     % Remove the zeros (which are noisy epochs)
%     indexfinal=find(indexAX>0);
%     indexAXfinal=indexAX(indexfinal);
%        
%     % Make a structure to save each condition's trials
%     indexAXCPT.(temp_condition_char)=indexAXfinal;
%     temp_new_setname=[EEG.setname '_' temp_condition_char];
%     
%     % Select out these noisy trials
%     %% Start Problem here
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, jj+1, 'setname', temp_new_setname, 'overwrite', 'off');
%     eeglab redraw
%     % Now we are at the # 2, (look above, what about the jj there jj=1, it should be 2)
%    
%     EEG = pop_select( EEG,'trial',indexAXfinal);
%     [ALLEEG EEG CURRENTSET]=eeg_store(ALLEEG, EEG, CURRENTSET); 
%     eeglab redraw
%     % edw einai to problima---
%     
%     EEG = pop_saveset(EEG, 'filename', temp_new_setname,'filepath', Analyzed_path_folder, 'check', 'on' );
%     eeglab redraw
%     
%     %% End problem here
%     % Set the new current dataset to 
%     % Current 2
%     
%     % Make a txt file that would open for EEGLAB epoch selection.
%     temp_filename=[Set_CURRENT_1 '_EEGtriggers' temp_condition_char '.txt'];
%     fileID = fopen(temp_filename,'w');
%     fprintf(fileID,'%i ',indexAXfinal);
%     fclose(fileID);
%     clear temp_condition_char temp_new_setname temp_condition
% end
% save indexAXCPT indexAXCPT
