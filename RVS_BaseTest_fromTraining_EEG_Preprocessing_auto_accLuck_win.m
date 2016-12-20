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
% Revising this 26.08.2016 and adding, how to include Electrode positions, commented
% Final touch 06.09.2016 version for the stat server at uio

close all
tic
% Read the exported e-prime file:
%% Go to raw directory
%% Path information
% Raw_Path='Z:\RVS\RAW_datasets\DataRVS\';
% Analyzed_path='Z:\RVS\Analyzed_datasets\';
Raw_Path='Y:\Prosjekt\RVS_43_subjects\Raw_datasets\DataRVS\';
%'/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/RVS/'; 
%'/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/'%RVS_Subject104/Base/';
%
% Analyzed_path='Z:\RVS\Analyzed_datasets\';
Analyzed_path='Y:\Prosjekt\RVS_43_subjects\Analyzed_datasets\';
%% Look how many subjects we have 
cd(Raw_Path)
% Define list of folders 
listing_raw=dir('RVS_Subject211*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 end
% test22=temp22(1,1)
clear kk listing_raw

% Define which subjects to keep in the analysis for FRN here
% bad_subject_list=[7, 9, 13, 16, 17, 19, 20, 24, 26, 30];
bad_subject_list=[];
good_subj_list=[]; 
for kk=1:Num_folders, 
    if ~ismember(kk, bad_subject_list), 
        good_subj_list=[good_subj_list kk]; 
    end; 
end
clear kk 

% Define sessions
Sessions={'Base', 'Test'};
%% Start load
for mkk=1:length(good_subj_list)
    kk=good_subj_list(mkk);
    Folder_name=temp22{kk,:};
    fprintf(' ***  Working on subject %s: %s\n', num2str(mkk), Folder_name)
    % Go to the analysis path
    cd(Analyzed_path)
    % Make a directory for each Subject - to save the results of preprocessing
    % for the Sessions (Here Base and Test. The folders for Training1 and
    % Training2 will be made later in the code. 
    mkdir(temp22{kk,:})
    cd(temp22{kk,:});
    for jj=1:length(Sessions)
        session_temp=Sessions{jj};
        % In case it is not created to create a directory for base-test
        mkdir(session_temp)
        
        Analyzed_path_folder=[Analyzed_path temp22{kk,:} '\' session_temp '\'];
        Raw_path_folder=[Raw_Path temp22{kk,:} '\' temp22{kk,:} '\' session_temp '\']; % temp22{kk,:} '/'
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
        Raw_path_folder_data=[Raw_path_folder listing_rawbdf(1).name];
        EEG= pop_biosig(Raw_path_folder_data, 'ref',[65 66] ,'refoptions',{'keepref' 'off'});
        EEG.setname=Name_Subject_session;
     %   eeglab redraw

        %% Select which channels to use
%         ChanNames={'F3' 'FC3' 'C1' 'C3' 'C5' 'CP1' 'CP3' 'P3' 'P5' 'PO3' 'PO7' 'O1' 'Oz' 'POz' 'Pz' 'CPz' 'Fpz' 'AFz' 'Fz' 'F4' 'FC4' 'FCz' 'Cz' 'C2' 'C4' 'C6' 'CP2' 'CP4' 'P4' 'P6' 'PO4' 'PO8' 'O2' 'EXG3'};
%        % EEG = pop_select( EEG,'channel',{'F3' 'FC3' 'C1' 'C5' 'CP5' 'P3' 'P5' 'P7' 'PO7' 'PO3' 'O1' 'Oz' 'POz' 'Pz' 'CPz' 'Fpz' 'AFz' 'Fz' 'F4' 'FC4' 'FCz' 'Cz' 'C2' 'C6' 'CP4' 'P4' 'P6' 'PO8' 'PO4' 'O2' 'EXG3' 'EXG4'});
%         EEG = pop_select( EEG,'channel',ChanNames);
%         EEG = eeg_checkset( EEG );
%         % Or make it to run for all electrodes
        EEG = pop_select( EEG,'nochannel',{'EXG5' 'EXG6' 'EXG7' 'EXG8'});
        
        %  Luck's filter   
        EEG  = pop_basicfilter( EEG,  1:length(EEG.chanlocs) , 'Boundary', 'boundary', 'Cutoff', [ 0.0253 45], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  2 ); % GUI: 30-Aug-2016 15:34:37
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
        
        
        % *. Downsample to 256 Hz. 
        EEG = pop_resample( EEG, 256);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname',Name_Subject_session,'overwrite','on','gui','off'); 
        % My filter
%                 %% Apply DC filter 
%         %  Run the DCoffset_removal_21_10_2011_a_final.m made as function
%         input_data=EEG.data;
%         data_filt=DC_offset_removal(input_data, Fs);
%         EEG.data=data_filt;
%         clear input_data;
%         EEG.setname=[temp_setname_resample '_ch_DC']
%         eeglab redraw
        
       
        % 7. Epoch 
        % 
        % Use as baseline a -200 to 0 period 
        extraNameForSet='_Luck';
        Name_Subject_Session=temp22{kk,:};
        temp_epochname=[temp22{kk,:} '_' session_temp '_' num2str(EEG.srate) '_' extraNameForSet ];
        % TODO check if it accepts the temp_epochname below
        trigger='2';
        epoch_from_sec=-0.5;%-0.2;
        epoch_to_sec=1;%0.8;

        EEG = pop_epoch( EEG, {  trigger }, [epoch_from_sec epoch_to_sec], 'newname', temp_epochname, 'epochinfo', 'yes');
        EEG = eeg_checkset( EEG );
        baseline_from=-500;
        baseline_to=0;
        EEG = pop_rmbase( EEG, [baseline_from baseline_to]);
        EEG.setname=temp_epochname;
        %eeglab redraw

      
        % Make a directory and save
        cd(Analyzed_path)
        cd(temp22{kk,1})
        % Make a directory for each session -Training1 or Training2
        mkdir(session_temp)
        cd(session_temp)
        EEG = pop_saveset(EEG, 'filename', temp_epochname);
        clear session_temp Name_subject_session temp_epochname temp_setname_resample
    end % for session 
    clear Folder_name
end % for subject 

%% End load - preprocess

toc