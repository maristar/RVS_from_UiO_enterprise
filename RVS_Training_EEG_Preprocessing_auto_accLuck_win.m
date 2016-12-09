% Analyzing EEG dataset for RVS - Training data. For Feedback 
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

clear all 
close all
tic
% Read the exported e-prime file:
%% Go to raw directory
%% Path information
Raw_Path='Z:\RVS\RAW_datasets\DataRVS\';
%'/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/RVS/'; 
%'/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/'%RVS_Subject104/Base/';
%
Analyzed_path='Z:\RVS\Analyzed_datasets\';
%'/Volumes/EEG2_MARIA/EEG/RVS/Analyzed_datasets/';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/RVS/';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/';

cd(Raw_Path)
% Define list of folders 
listing_raw=dir('RVS_Subject2*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 
end
% test22=temp22(1,1)
clear kk listing_raw

% Define which subjects to keep in the analysis for FRN here
bad_subject_list=[6,8,18,22,32];
good_subj_list=[]; for kk=1:Num_folders, if ~ismember(kk, bad_subject_list), good_subj_list=[good_subj_list kk]; end; end


Sessions={'Training1', 'Training2'};
%% Start load
for mkk=1:length(good_subj_list)
    kk=good_subj_list(mkk);
    Folder_name=temp22{kk,:};
    fprintf(' ***  Working on subject %d: %s\n', num2str(mkk), Folder_name)
    % Go to the analysis path
    cd(Analyzed_path)
    % Make a directory for each Subject - to save the results of preprocessing
    % for the Training1 and Training2. The folders for Training1 and
    % Training2 will be made later in the code. 
    mkdir(temp22{kk,:})
    cd(temp22{kk,:});
    for jj=1:length(Sessions)
        session_temp=Sessions{jj}
        mkdir(session_temp)
        
        Analyzed_path_folder=[Analyzed_path temp22{kk,:} '\' session_temp '\'];
        Raw_path_folder=[Raw_Path temp22{kk,:} '\' temp22{kk,:} '\' session_temp '\']; % temp22{kk,:} '/'
        % Go to Raw_path_folder
        cd(Raw_path_folder);
        % Find the EEG recording6å,<
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
     %   eeglab redraw
        EEG = eeg_checkset( EEG );
        
%         %% Remove the extra channels
%         
%         %% Add electrode locations
%         EEG=pop_chanedit(EEG, 'lookup','/Users/mstavrin/Documents/MATLAB/EEGLAB_WORKSHOP_SML/eeglab_sml_v3/eeglab_sml_v3/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp');
%         
        %% Select which channels to use
        EEG = pop_select( EEG,'nochannel',{'EXG5' 'EXG6' 'EXG7' 'EXG8'});
%         ChanNames={'Fz' 'Cz' 'FCz' 'CPz' 'Oz'};
%         % ChanNames={'FCz'};
%         EEG = pop_select( EEG,'channel',ChanNames);
        EEG = eeg_checkset( EEG );
    %    eeglab redraw

%         %% Resample
%         fs_new=256;
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
%         EEG.setname=[temp_setname_resample '_ch_DC'];
%         eeglab redraw
        
EEG  = pop_basicfilter( EEG,  1:5 , 'Boundary', 'boundary', 'Cutoff', [ 0.0253 45], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  2 ); % GUI: 30-Aug-2016 15:34:37
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 

% *. Downsample to 256 Hz. 
EEG = pop_resample( EEG, 256);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname','RVS_Subject128_Training1_elist_resampled','overwrite','on','gui','off'); 

% HERE
% 7. Epoch 
% 
% Use as baseline a -200 to 0 period 
extraNameForSet='_Luck';
Name_Subject_Session=temp22{kk,:};
temp_epochname=[temp22{kk,:} '_' session_temp '_' num2str(EEG.srate) '_' extraNameForSet ];
% TODO check if it accepts the temp_epochname below
trigger='50';
epoch_from_sec=-0.2;%-0.2;
epoch_to_sec=0.8;%0.8;

EEG = pop_epoch( EEG, {  trigger }, [epoch_from_sec epoch_to_sec], 'newname', temp_epochname, 'epochinfo', 'yes');
EEG = eeg_checkset( EEG );
baseline_from=-200;
baseline_to=0;
EEG = pop_rmbase( EEG, [baseline_from baseline_to]);
EEG.setname=temp_epochname;
%eeglab redraw



%         % File indentifier
%         %NameForSet='_ch_DC_epochs_tr50_auto_5_chan_filt';
%         NameForSet='_Luck_test';
%         temp_epochname=[Name_Subject_session '_' num2str(fs_new)  NameForSet ];
%         % TODO check if it accepts the temp_epochname below
%         trigger='50';
%         epoch_from_sec=-1;%-0.2;
%         epoch_to_sec=2;%0.8;
%         
%         EEG = pop_epoch( EEG, {  trigger }, [epoch_from_sec epoch_to_sec], 'newname', temp_epochname, 'epochinfo', 'yes');
%         EEG = eeg_checkset( EEG );
%         baseline_from=-200;
%         baseline_to=-1;
%         EEG = pop_rmbase( EEG, [baseline_from baseline_to]);
%         EEG.setname=temp_epochname;
%         eeglab redraw
        
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