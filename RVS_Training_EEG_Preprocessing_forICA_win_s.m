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
% Final touch 06.09.2016 version for the stat server at uio; 201216,
% psi-ts01 server
% Maria L. Stavrinou 
% 28.12. Electrode locations does not work. Ica works but not saving. 

clear all 
close all
tic
% Read the exported e-prime file:
%% Go to raw directory
%% Path information
Raw_Path='Y:\Prosjekt\RVS_43_subjects\Raw_datasets\DataRVS\';
Analyzed_path='Y:\Prosjekt\RVS_43_subjects\Analyzed_datasets\';

%% Define list of folders 
cd(Raw_Path)
listing_raw=dir('RVS_Subject*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 
end
% test22=temp22(1,1)
clear kk 
%% Define which subjects to keep in the analysis for FRN here
bad_subject_list=[]%1 2 3 6 8 13 14 15 18 19 22 28 34 36 37 41 ]; %[1, 5, 8];%[6,8,18,22,32];
good_subj_list=[13 14 15 18 19 22 26 28 34 36 37 41]; for kk=1:Num_folders, if ~ismember(kk, bad_subject_list), good_subj_list=[good_subj_list kk]; end; end
% it was run before 34 36 37 41
%% Other definitions 
Sessions={'Training1', 'Training2'};
%% Start load
for mkk=2:length(good_subj_list)
    kk=good_subj_list(mkk);
    Folder_name=temp22{kk,:};
    fprintf(' ***  Working on subject %s: %s\n', num2str(mkk), Folder_name)
    % Go to the analysis path
    cd(Analyzed_path)
    % Make a directory for each Subject - to save the results of preprocessing
    % for the Training1 and Training2. The folders for Training1 and
    % Training2 will be made later in the code. 
    mkdir(temp22{kk,:})
    cd(temp22{kk,:});
    for jj=1:length(Sessions)
        session_temp=Sessions{jj};
        session_temp_char=char(session_temp);
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
        Raw_path_folder_data=[Raw_path_folder listing_rawbdf(1).name ];
        %% Look for sets
        cd(Analyzed_path_folder)
            Search_for_folder=[Name_Subject_session '_256__Luck_stim.set'];
            listing_sets=dir(Search_for_folder);
            Num_setfiles=length(listing_sets);
            
            % It should be only one set with this name. Why the next, do
            % not know. 
            for mmk=1:Num_setfiles
                temp_sets{mmk,:}=listing_sets(mmk).name;
            end
            clear listing_sets mmk

        temp_condition_char=session_temp_char;
        %1
        % Find where the condition starts in the filename
        B=strfind(temp_sets{:}, temp_condition_char);        
        %1
        name1=temp_sets{:}(1:(B-1));%'Subject_103_25_512_ch_DC_epochs_tr2_autotriggers'; %AX.txt;
        name2=temp_condition_char;
        name3='_256__Luck_stim.set';
        name_file=[name1 name2 name3]; %Subject101_Training1_512_ch_DC_epochs_50_triggers_Correct.txt3ch.set
        name_data=[name1 name2 '_stim']; %Subject101_Training1_512_ch_DC_epochs_50_triggers_Correct
        
        AreWeRight=strcmp(name_file, temp_sets{:});
        if AreWeRight==1, 
            disp(['Working on file ' temp_sets{:} ' for condition ' temp_condition_char]);
            EEG = pop_loadset('filename',name_file,'filepath',Analyzed_path_folder);
            EEG = eeg_checkset( EEG );
            eeglab redraw

                           
        %% Select which channels to use
        if EEG.nbchan>64
            % Create a new dataset 
            temp_setname=[name_file 'forICA'];
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', temp_setname); % Save as new dataset.
            [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
            % And save this dataset. 
            % Remove the eye channels
            EEG = pop_select( EEG,'nochannel',{'EXG3' 'EXG4'});
            
            
            % Create a new dataset 
            [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
            % And save this dataset. 
            temp_epochname=[name_file 'withICA'];
            EEG = pop_saveset(EEG, 'filename', temp_epochname);
            EEG = eeg_checkset( EEG );
        end
%         %% Add electrode locations % NOT WORKING 
%         EEG.chanlocs=pop_chanedit(EEG.chanlocs, 'load',{'M:\pc\Dokumenter\MATLAB\eeglab_sml_v3\eeglab_sml_v3\plugins\dipfit2.3\standard_BESA\standard-10-5-cap385.elp', 'filetype', 'autodetect'});
%         EEG = pop_saveset( EEG, 'savemode','resave');
%         EEG = eeg_checkset( EEG );
%         eeglab redraw      
        %% Run ICA 
        EEG = pop_runica(EEG, 'extended',1,'interupt','on');
        
        
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        %%  Make a directory and save
        cd(Analyzed_path)
        cd(temp22{kk,1})

        %% Make a directory for each session -Training1 or Training2
        mkdir(session_temp)
        cd(session_temp)
        EEG = pop_saveset( EEG, 'savemode','resave');
        EEG = eeg_checkset( EEG );
        %temp_epochname=[name_file 'forICA_ICApruned'];
        %EEG = pop_saveset(EEG, 'filename', temp_epochname);
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        clear session_temp Name_subject_session temp_epochname temp_setname_resample
        end % if we are right
    end % for session 
    clear Folder_name
end % for subject 

%% End load - preprocess

toc