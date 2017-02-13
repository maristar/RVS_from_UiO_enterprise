%% To do the grandaverage plots for the RVS_Training
% Maria Stavrinou
% 14 June 2016 under construction
% 08.09.2016. Changing the previous program,
% RVS_Training_extract_mean_and_peak_detection_4parts_B.m to detect only
% the mean.
% Corrected the time_start to take the shorter time_epoch_start.
% 09.09.2016, Added a new type 'base_peak'
% 14.12.2016, added bad channels for all 43 subjects. 
% 04.01.2017. Make it work for the whole parts. 
% 09.01.2017 making work for both cases. 

clear all 
close all
tic

%% Define global variables 2017
global Raw_path Analyzed_path folder_data_save folder_figures_save temp22 ...
    Sessions conditions conditions_short part_names_all bad_subject_list good_subj_list...
    type_files_identifier new_pre_trigger new_post_trigger numchans ...
    chanlocs header_raw 

% Or make a class, or make a structure

% data_Properties.scope='analysis of stim training no parts and 4 rew levels 43 subjects'
data_Properties.scope='analysis of stim training 4 parts and 4 rew levels 43 subjects'
data_Properties.scope_short='Stim_4Parts_4RL_43subjs';
data_Properties.date=date;

%% Define new directories to save data and figures
Raw_path='Y:\Prosjekt\RVS_43_subjects\Raw_datasets\DataRVS\';
Analyzed_path='Y:\Prosjekt\RVS_43_subjects\Analyzed_datasets\';
data_Properties.Raw_path=Raw_path;
data_Properties.Analyzed_path=Analyzed_path;

% Directory for data
folder_data_save=['Results_Training_' data_Properties.scope_short];
cd(Analyzed_path)
mkdir(folder_data_save)

%Directory for figures
folder_figures_save=['Figures_Training_' data_Properties.scope_short];
cd(Analyzed_path)
mkdir(folder_figures_save)

data_Properties.folder_data_save=folder_data_save;
data_Properties.folder_figures_save=folder_figures_save;
%% Define list of Folders - Subjects  
cd(Raw_path);
Name_subject_folder='*RVS_Subject*';
listing_raw=dir(Name_subject_folder);
Num_folders=length(listing_raw);

for kk=1:Num_folders
    folders_list{kk,:}=listing_raw(kk).name;
end
clear listing_raw kk
temp22=folders_list;
clear folders_list

data_Properties.temp22=temp22;
%% Define the sessions, conditions and parts of data

Sessions={'Training1', 'Training2'};
data_Properties.Sessions=Sessions;
% Define the 4 conditions,in alphabetical order so that the listing is in 
% same order as when matlab uses 'dir' function. Define the names of the 4
% parts. 

% conditions={'Correct', 'HR','LR','Wrong'}; for FRN
conditions={'stim_20L_corr', 'stim_50H_corr', 'stim_50L_corr', 'stim_80H_corr'};

conditions_short={'20L', '50H', '50L', '80H'};

% Parts
% For analysis with 4 parts 
part_names_all={'part_a'; 'part_b'; 'part_c'; 'part_d'};

% For analysis with one part only 
%part_names_all={};


data_Properties.conditions=conditions;
data_Properties.part_names_all=part_names_all;

%% Define the header for the excel file

% Header for FRN 
% header_raw={'Subject_Num','_Correct_a','_Correct_b', '_Correct_c',	'_Correct_d', '_Incorrect_a',	'_Incorrect_b',	'_Incorrect_c',	'_Incorrect_d','_HR_a', '_HR_b','_HR_c','_HR_d','_LR_a',	'_LR_b',	'_LR_c',	'_LR_d'};

%% Write to a cell, to be a table and then exported to file - to be opened with comma delimiter in excel
%header={'Subject_Num','CPz_Correct_a','CPz_Correct_b', 'CPz_Correct_c',	'CPz_Correct_d', 'CPz_Incorrect_a',	'CPz_Incorrect_b',	'CPz_Incorrect_c',	'CPz_Incorrect_d','CPz_HR_a', 'CPz_HR_b','CPz_HR_c','CPz_HR_d',	'CPz_LR_a',	'CPz_LR_b',	'CPz_LR_c',	'CPz_LR_d'};

% Stim, 4 parts and 4 reward levels. 
%header_raw={'Subject_Num','_20L_a','_20L_b', '_20L_c',	'_20L_d', '_50H_a',	'_50H_b',	'_50H_c',	'_50H_d','_50L_a', '_50L_b','_50L_c','_50L_d','_80H_a',	'_80H_b',	'_80H_c',	'_80H_d'};

% Stim 4 reward levels only 
header_raw={'Subject_Num', '20L', '50H', '50L', '80H'};

% Stim 4 parts only 
% header_raw={'Subject_Num', 'block_a', 'block_b', 'block_c', 'block_d'};


% General header based on conditions - it works now! magic maria 
header_raw_exp=['Subject_Num_'];
for kk=1:length(conditions)
    temp_condition=conditions_short(kk);
    temp_condition_char=char(temp_condition);
    if length(part_names_all)==0
        header_raw_exp=[header_raw_exp  temp_condition ];
    elseif length(part_names_all)>0
        for jj=1:length(part_names_all)
            temp_parts=part_names_all(jj);
            temp_parts_char=char(temp_parts);
            middle_temp_name=cellstr([temp_condition_char '_' temp_parts_char]);
            header_raw_exp=[header_raw_exp middle_temp_name ];
        end
    end
end
clear kk jj

data_Properties.header_raw=header_raw_exp; % changed 13-1-2017
%% Define which subjects to keep in the analysis for FRN here

% bad_subject_list=[6,8,16,18,22,26,32,34,37,40]; % FRN
bad_subject_list=[6,8,13,14,15,16,18,19,22,26,28]; % for Stim
good_subj_list=[]; for kk=1:Num_folders, if ~ismember(kk, bad_subject_list), good_subj_list=[good_subj_list kk]; end; end

data_Properties.bad_subject_list=bad_subject_list;
data_Properties.good_subj_list=good_subj_list;
%% Define channels of interest

% For FRN numchans=[29, 32, 38, 47, 48];
numchans=[29, 32, 38, 47, 48, 26, 27, 21, 18, 13, 10, 5, 40, 45, 50, 55, 58, 63, 64];

% For Stim to choose parietal and occipital electrodes. but can start with
% the same as FRn TODO 
data_Properties.numchans=numchans;
%% Define time duration of each epoch -usually smaller than the original 

new_pre_trigger=-200;
new_post_trigger=700;

data_Properties.new_pre_trigger=new_pre_trigger;
data_Properties.new_post_trigger=new_post_trigger;


startfolder=1;
for mkk=startfolder% :length(good_subj_list)
    jjk=good_subj_list(mkk);
    Folder_name=temp22{jjk,:};
    % Print a message on screen to show on which subject we are working
    fprintf(' ***  Working on subject %s: %s\n', num2str(mkk), Folder_name)
    % For every Session: Training1 or Training2 
    for mm=1:length(Sessions)
        session_temp=Sessions{:,mm}; %%% !!!!
        Subject_filemname_session=[Folder_name '_' session_temp];
        for kk=1:length(conditions) % For every condition : Wrong, Correct,HR, LR
            temp_condition=conditions(kk);
            temp_condition_char=char(temp_condition);
            % Define folder name for Analyzed and Raw for each subject 
            Analyzed_path_folder=[Analyzed_path temp22{jjk,:} '\' session_temp '\' ];
            Raw_path_folder=[Raw_path temp22{jjk,:} '\' temp22{jjk,:} '\' session_temp '\'];
            %% HERE 
            clear temp_sets
            % Go the Analyzed_path_folder for each subject
            % and search for the set files for each AX, AY condition
            cd(Analyzed_path_folder)
            type_files_identifier='*_256__Luck_stim_';
            Search_for_folder=[type_files_identifier temp_condition_char '.set'];
            listing_sets=dir(Search_for_folder);
            Num_setfiles=length(listing_sets);
            for mmk=1:Num_setfiles
                temp_sets{mmk,:}=listing_sets(mmk).name;
            end
            clear listing_sets mmk

%              if length(part_names_all)==0
%                  part_name_temp_char=[];
%                  [ data, meandata ] = get_EEG_data( temp_condition_char, part_name_temp_char, temp_sets, new_pre_trigger, new_post_trigger )
%                  part_name_temp_char_save='allparts';
%              elseif length(part_names_all)>0
                for gg=1:2
                    part_name_temp=part_names_all{gg};
                    part_name_temp_char=char(part_name_temp);
                    part_name_temp_char_save=part_name_temp_char;  
                    % function [ data, meandata ] = get_EEG_data( temp_condition_char, part_name_temp_char, temp_sets, new_pre_trigger, new_post_trigger )
%UNTITLED Summary of this function goes here
                  %  [ data, meandata ] = get_EEG_data( temp_condition_char, part_name_temp_char, temp_sets, new_pre_trigger, new_post_trigger )
        % Find where the condition starts in the filename
        B=strfind(temp_sets{:}, temp_condition_char);        
        %1
        name1=temp_sets{:}(1:(B-1));%'Subject_103_25_512_ch_DC_epochs_tr2_autotriggers'; %AX.txt;
        name2=[temp_condition_char]
        name3a=[part_name_temp_char];
        name3b='.set';
        name_file=[name1 name2 name3a name3b]; %Subject101_Training1_512_ch_DC_epochs_50_triggers_Correct.txt3ch.set
        name_data=[name1 name2]; %Subject101_Training1_512_ch_DC_epochs_50_triggers_Correct
        
        AreWeRight=strcmp(name_file, temp_sets{:});
        if AreWeRight==1, 
            disp(['Working on file ' temp_sets{:} ' for condition ' temp_condition_char]);
            EEG = pop_loadset('filename',name_file,'filepath',Analyzed_path_folder);
            EEG = eeg_checkset( EEG );
            eeglab redraw
            
            % Select smaller timepoints 
            if (jjk==startfolder & mm==1 & kk==1)
                Fs=EEG.srate;
                pre_trigger = -EEG.xmin*1000; %msec  200 700
                post_trigger = EEG.xmax*1000; %msec 1100 1600
                data_pre_trigger = floor(pre_trigger*Fs/1000);
                data_post_trigger = floor(post_trigger*Fs/1000);
                timeVec = (-(data_pre_trigger):(data_post_trigger));
                timeVec = timeVec';
                timeVec_msec = timeVec.*(1000/Fs);
                
%                 new_pre_trigger=-200;
%                 new_post_trigger=700;
                find_new_pre_trigger=find(timeVec_msec>new_pre_trigger);
                new_pre_trigger_index=min(find_new_pre_trigger);
                
                find_new_post_trigger=find(timeVec_msec<new_post_trigger);
                new_post_trigger_index=max(find_new_post_trigger);
                disp('Epoch new shorter duration done')
                timeVec_msec_new=timeVec_msec(new_pre_trigger_index:new_post_trigger_index);
                clear timeVec_msec
                timeVec_msec=timeVec_msec_new;
                clear timeVec_msec_new;
            end
            
            % Save the EEG.data with smaller epoch

                
                        data=EEG.data(:, new_pre_trigger_index:new_post_trigger_index, :);
                        nchanGA=size(data, 1);
                     if nchanGA>5
                         
                         data2=EEG.data(numchans, new_pre_trigger_index:new_post_trigger_index, :);
                         clear data
                         data=data2;
                     end
                     
                    % Save the EEG.data with smaller epoch
                    % data=EEG.data(:,
                    % new_pre_trigger_index:new_post_trigger_index, :);
                    % 13012017
                    meandata=mean(data, 3);
                    
                    if isempty(part_name_temp_char)
                        disp('Doing for non parts')
                        part_name_temp_char='allparts'
                    end
                    
                    Mean_Subjects.(Folder_name).(temp_condition_char).(part_name_temp_char_save)=meandata;
                    clear data
        end % if we are right
                end   % for gg
          %  end % if length part_names_all >0
    end % conditions
end % Sessions  
end % Subject
% chanlocs=EEG.chanlocs; 

chanlocs=EEG.chanlocs(numchans); 
data_Properties.chanlocs=chanlocs;

%% Save the Mean_All_Subjects 
cd(Analyzed_path)
%mkdir('Results_Training_FRN_P3_43subj')
cd(folder_data_save)
save Mean_Subjects Mean_Subjects 
% What else I need 
save timeVec_msec timeVec_msec
save new_pre_trigger new_pre_trigger
save new_post_trigger new_post_trigger
save Fs Fs
save chanlocs chanlocs

data_Properties.timeVec_msec=timeVec_msec;
data_Properties.Fs=Fs;
save data_Properties data_Properties

% %Check if we need any of this
% clear jjk mm kk gg B AreWeRight ...
%     data_post_trigger ...
%     data_pre_trigger ...
%     name1 name2 name3a name3b ...
%     name_data ...
%     name_file ...
%     Name_subject_folder ...
%     part_names ...
%     part_name_temp_char ...
%     part_name_temp ...
%     post_trigger ...
%     pre_trigger ...
%     temp_condition ...
%     temp_condition_char

%% Search for the FRN or N2(Stim) : 250-300 msec. 
%
%% C1
% Define time limits for the peak detection 
name_component='C1';
type='mean';
peak_start_time=60;
peak_end_time=100;
time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
time_end=new_post_trigger;
% In msec 
[ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
clear Peak_results Tnew


%% N1
% Define time limits for the peak detection 
name_component='N1';
type='mean';
peak_start_time=140;
peak_end_time=190;
time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
time_end=new_post_trigger;
% In msec 
[ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
clear Peak_results Tnew


%% P1
% Define time limits for the peak detection 
name_component='P1';
type='mean';
peak_start_time=100;
peak_end_time=140;
time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
time_end=new_post_trigger;
% In msec 
[ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
clear Peak_results Tnew

%% Define time limits for the peak detection 
name_component='N2';
type='base_peak';
peak_start_time=250;
peak_end_time=300;
time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
time_end=new_post_trigger; %600; % TODO sth here why it is deleted 

[ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )

clear Peak_results Tnew

%% P2
% Define time limits for the peak detection 
name_component='P2';
type='mean';
peak_start_time=190;
peak_end_time=240;
time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
time_end=new_post_trigger;
% In msec 
[ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
clear Peak_results Tnew


%% P300 -a detection 
% Define time limits for the peak detection 
name_component='P3a';
type='mean';
peak_start_time=360;
peak_end_time=420;
time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
time_end=new_post_trigger;
% In msec 
[ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
clear Peak_results Tnew

%% P300 -b detection 
% Define time limits for the peak detection 
name_component='P3b';
type='mean';
peak_start_time=500;
peak_end_time=550;
time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
time_end=new_post_trigger;
% In msec 
[ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
clear Peak_results Tnew


%%  Peak detection 
name_component='N3';
type='min';
peak_start_time=430;
peak_end_time=490;
time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
time_end=new_post_trigger; %600; % TODO sth here why it is deleted 

[ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )

clear Peak_results Tnew

toc
display(['Took ' num2str(toc/60) ' seconds']);
