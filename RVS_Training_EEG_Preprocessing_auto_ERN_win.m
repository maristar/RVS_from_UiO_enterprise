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
Raw_path='Z:\RVS\RAW_datasets\DataRVS\';

Analyzed_path='Z:\RVS\Analyzed_datasets\';

cd(Raw_path)
% Define list of folders 
listing_raw=dir('RVS_Subject*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 
end
% test22=temp22(1,1)
clear kk listing_raw

Sessions={'Training1', 'Training2'};

%% Define which subjects to keep in the analysis for FRN here
bad_subject_list_ERN=[1,6,8,13,16,18,19,22,23, 25, 30, 31, 32, 33];
good_subj_list=[]; for kk=1:Num_folders, if ~ismember(kk, bad_subject_list_ERN), good_subj_list=[good_subj_list kk]; end; end

%% Start load
for mkk=1:length(good_subj_list)
    kk=good_subj_list(mkk);
    Folder_name=temp22{kk,:};
    fprintf(' ***  Working on subject %d: %s\n', num2str(mkk), Folder_name)
    % Go to the analysis path
    cd(Analyzed_path);
    % Make a directory for each Subject - to save the results of preprocessing
    % for the Training1 and Training2. The folders for Training1 and
    % Training2 will be made later in the code. 
    mkdir(temp22{kk,:})
    for jj=1:length(Sessions)
        session_temp=Sessions{jj}

        Analyzed_path_folder=[Analyzed_path temp22{kk,:} '\' session_temp '\'];
        Raw_path_folder=[Raw_path temp22{kk,:} '\' temp22{kk,:} '\' session_temp '\'];
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
        Name_Subject_session=[listing_rawbdf.name(1:end-4)];
         %% Load the raw dataset 
        
        [ALLEEG EEG CURRENTSET ALLCOM]=eeglab;
        %EEG= pop_biosig(); % '/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/MariaLoizou/Maria1.bdf', 'ref',[65 66] ,'refoptions',{'keepref' 'off'});
        % 'ref',[65 66] ,'refoptions',{'keepref' 'off'});
        Raw_path_folder_data=[Raw_path_folder listing_rawbdf(1).name];
        EEG= pop_biosig(Raw_path_folder_data, 'ref',[65 66] ,'refoptions',{'keepref' 'off'});
        EEG.setname=Name_Subject_session;
        %eeglab redraw
        EEG = eeg_checkset( EEG );
        
        %% Select which channels to use
        ChanNames={'Fz' 'Cz' 'FCz' 'CPz' 'EXG3'};
        EEG = pop_select( EEG,'channel',ChanNames);
        EEG = eeg_checkset( EEG );
       % eeglab redraw

%         %% Resample
%         fs_new=128;
%         EEG = pop_resample( EEG, fs_new);
%         temp_setname_resample=[Name_Subject_session '_' num2str(fs_new)];
%         EEG.setname=temp_setname_resample;
%         EEG = eeg_checkset( EEG );
%         eeglab redraw
%         
%         %% Apply DC filter 
%         %  Run the DCoffset_removal_21_10_2011_a_final.m made as function
%         input_data=EEG.data;
%         data_filt=DC_offset_removal(input_data);
%         EEG.data=data_filt;
%         clear input_data;
%         EEG.setname=[temp_setname_resample '_ch_DC']
%         eeglab redraw
%         
%          %% Apply low pass filter
%         data=data_filt;
%         clear data_filt
%         filter_from=0;
%         filter_to=20;
%         lowpass_filt=eegfiltfft(data, fs_new, filter_from, filter_to);
%         EEG.data=lowpass_filt;
%         clear input_data from to
%         EEG.setname=[temp_setname_resample '_ch_DC']
%         eeglab redraw
%         
        %% New filters and downsampling according to Luck
        EEG  = pop_basicfilter( EEG,  1:5 , 'Boundary', 'boundary', 'Cutoff', [ 0.0253 45], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  2 ); % GUI: 30-Aug-2016 15:34:37
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 

        % *. Downsample to 256 Hz. 
        fs_new=256; % Hz
        EEG = pop_resample( EEG, fs_new);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname','RVS_Subject128_Training1_elist_resampled','overwrite','on','gui','off'); 

        %% End new filters according to Luck
        %% Extract_triggers for ERN
        %Define triggers for ERN. Stim (50
        % Go to Raw_path_folder
        cd(Raw_path_folder);
        
        % Load the exported edat2 file (later named Tfinal).
        listing_raw2=dir('*matlab.txt');
        if length(listing_raw2)==0
            listing_raw2=dir('*MATLAB.txt');
        end
        if length(listing_raw2)==0
            display('No txt file for matlab found');
        end
        Edat2file=listing_raw2(1).name;
        Filename_matlab=Edat2file;
    
        %     [FileName, Raw_Path] = uigetfile('*.*','Select the MATLAB T table (Tfinal) file "txt", or "mat" ');
        %     cd(Raw_Path)
        T = readtable((Filename_matlab), ...
        'Delimiter','\t','ReadVariableNames',false);
        clear Filename_matlab
        % Or load the Tfenal (if you are working with RVS_Subject101 -103
    
        %% Define if there is big onset Delay 
        %% Automate start
        % Find which row in the T table is Condition, and the StimTwoACC.
        % Find it iteratively:
        all_headers=T(1,:);
        all_headers2=table2cell(all_headers);
    
        % Find for the Feedback Onset delay
        for jjj=1:length(all_headers2)
            a=strcmp(all_headers2{1,jjj}, 'Stim.RT');
            if a==1
                indexRT=jjj;
            end
        end
        clear a jjj % OK

        StimRT_table=T(2:end, indexRT); % 131 for JackLoe, tested first!
        RT=table2cell(StimRT_table);
         
        %% End Extract triggers
        NameForSet='_accLuck_ERN';
        temp_epochname=[Name_Subject_session '_' num2str(fs_new)  NameForSet ];
        % TODO check if it accepts the temp_epochname below
        triggers={'1', '5'};
        epoch_from_sec=-1;
        epoch_to_sec=1;
        
        EEG = pop_epoch( EEG, triggers, [epoch_from_sec epoch_to_sec], 'newname', temp_epochname, 'epochinfo', 'yes');
        EEG = eeg_checkset( EEG );
        baseline_from=-200;
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
        EEG = pop_saveset( EEG, 'filename',temp_epochname,'filepath', Analyzed_path_folder);
        clear session_temp Name_subject_session temp_epochname temp_setname_resample
    end % for session 
    clear Folder_name
end % for subject 

%% End load - preprocess

toc