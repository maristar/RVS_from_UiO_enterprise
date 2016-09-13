% Analyzing EEG dataset for RVS - Training data. 
% November 2015, Maria Stavrinou at PSI, UiO
% January 2016. This program makes a directory where it saves the different
% triggers needed for further EEG analysis. For now the selection done is
% refering to: 
% 'Correct
% 'Wrong
% 'Low Reward
% 'High Reward
% First we should have these triggers, and then we should check for noisy
% epochs? Yes 
%
% Revising this 31.5.2016
clear all 
close all
tic
% Read the exported e-prime file:
%% Go to raw directory
%% Path information
Raw_Path='E:\EEG\RVS\Raw_datasets\';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/RVS/'; 
%'/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/'%RVS_Subject104/Base/';
%
Analyzed_path='E:\EEG\RVS\Analyzed_datasets\';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/RVS/';
%'/Volumes/EEG2_MARIA/EEG/RVS/Analyzed_datasets/'
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

Sessions={'Training1', 'Training2'};
%% Start load
for kk=1:Num_folders
    Folder_name=temp22{kk,:};
    % Go to the analysis path
    cd(Analyzed_path)
    % Make a directory for each Subject - to save the results of preprocessing
    % for the Training1 and Training2. The folders for Training1 and
    % Training2 will be made later in the code. 
    mkdir(temp22{kk,:})
    for jj=1:length(Sessions)
        session_temp=Sessions{jj}

        Analyzed_path_folder=[Analyzed_path temp22{kk,:} '\' temp22{kk,:} '\' session_temp '\'];
        Raw_path_folder=[Raw_Path temp22{kk,:} '\' temp22{kk,:} '\' session_temp '\'];
        % Go to Raw_path_folder
        cd(Raw_path_folder);
        % Find the EEG recording
        listing_rawbdf=dir('*.bdf');
        
        Num_filesbdf=length(listing_rawbdf);
        if Num_filesbdf>1
            display('Warning, 2 data bdfs found')
        elseif Num_filesbdf==0
            display('No EEG *.bdf file found')
        end
        % Give a name of the subject & session 
        Name_Subject_session=[Folder_name '_' session_temp];
         %% Load the raw dataset 
        
        [ALLEEG EEG CURRENTSET ALLCOM]=eeglab;
        %EEG= pop_biosig(); % '/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/MariaLoizou/Maria1.bdf', 'ref',[65 66] ,'refoptions',{'keepref' 'off'});
        % 'ref',[65 66] ,'refoptions',{'keepref' 'off'});
        Raw_path_folder_data=[Raw_path_folder listing_rawbdf(1).name];
        EEG= pop_biosig(Raw_path_folder_data, 'ref',[65 66] ,'refoptions',{'keepref' 'off'});
        EEG.setname=Name_Subject_session;
        eeglab redraw
        EEG = eeg_checkset( EEG );
        
        %% Select which channels to use
        ChanNames={'Fz' 'Cz' 'FCz' 'CPz' 'EXG3'};
        EEG = pop_select( EEG,'channel',ChanNames);
        EEG = eeg_checkset( EEG );
        eeglab redraw

        %% Resample
        fs_new=128;
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
        clear input_data;
        EEG.setname=[temp_setname_resample '_ch_DC']
        eeglab redraw
        
         %% Apply low pass filter
        data=data_filt;
        clear data_filt
        filter_from=0;
        filter_to=20;
        lowpass_filt=eegfiltfft(data, fs_new, filter_from, filter_to);
        EEG.data=lowpass_filt;
        clear input_data from to
        EEG.setname=[temp_setname_resample '_ch_DC']
        eeglab redraw
        
        NameForSet='_ch_DC_epochs_tr50_auto_5_cFRN_filt';
        temp_epochname=[Name_Subject_session '_' num2str(fs_new)  NameForSet ];
        % TODO check if it accepts the temp_epochname below
        trigger='50';
        epoch_from_sec=-0.2;
        epoch_to_sec=0.8;
        
        EEG = pop_epoch( EEG, {  trigger }, [epoch_from_sec epoch_to_sec], 'newname', temp_epochname, 'epochinfo', 'yes');
        EEG = eeg_checkset( EEG );
        baseline_from=-200;
        baseline_to=-150;
        EEG = pop_rmbase( EEG, [baseline_from baseline_to]);
        EEG.setname=temp_epochname;
        eeglab redraw
        
        % Make a directory and save
        cd(Analyzed_path)
        cd(temp22{kk,1})
        % Make a directory for each session -Training1 or Training2
        mkdir(session_temp)
        cd(session_temp)
        EEG = pop_saveset( EEG, 'filename',temp_epochname,'filepath', Analyzed_path_folder);
        clear session_temp Name_subject_session temp_epochname temp_setname_resample
    end % for session 
    clear Folder_name
end % for subject 

%% End load - preprocess

toc