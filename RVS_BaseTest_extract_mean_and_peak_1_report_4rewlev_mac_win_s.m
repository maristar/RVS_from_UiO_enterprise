
%% To do the grandaverage plots (?) for the RVS_Base and make the peak detection 
% automatically 
% Maria Stavrinou
% 19 June 2016 
% 21 June for double trigger, single report and 4 levels of reward
% 19.9.2016
% Revising it for 80_20_20 or 80 conditions 23.3.2017 MLS
% Revising it for 4 rewlevs, 24.3.2017, MLS
clear all 
close all 
tic
%% Path information
% Raw_path='Z:\RVS\RAW_datasets\DataRVS\';
% Analyzed_path='Z:\RVS\Analyzed_datasets\';

Raw_path='Y:\Prosjekt\RVS_43_subjects\Raw_datasets\DataRVS\';
Analyzed_path='Y:\Prosjekt\RVS_43_subjects\Analyzed_datasets\';

cd(Raw_path)
% Define list of folders 
listing_raw=dir('RVS_Subject*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 
end

% Where the results will be saved. 
cd(Analyzed_path)
saving_data_folder='Mean_All_Subjects_BT_4rewlev_28MARS2017';
mkdir(saving_data_folder)

% Sessions
Sessions={'Base', 'Test'};

% Parts or blocks of data
part_names_all=[];

%% Define the type of triggers we are after
% Do that by going inside a folder and checking for triggers
cd(Analyzed_path)
cd('RVS_Subject104/')
cd('Base/Triggers')

% What we put inside the dir function changes with the triggers we want
% every time. SOS.
% For 4 reward levels, use: listing_raw=dir('double_one_*0*_corr.txt');
 listing_raw=dir('double_one_*0*_corr.txt');
% listing_raw=dir('double*0_corr.txt')
% listing_raw=dir('double*0_corr.txt'); % 21.3.2017
Num_triggers=length(listing_raw);
for kkm=1:Num_triggers
    temp23{kkm,:}=listing_raw(kkm).name;
end
clear kkm listing_raw
disp(temp23)


% List of triggers. 
for kkk=1:length(temp23); 
    temp23_new{kkk,:}=temp23{kkk,:}; 
    trigger_descr_short{kkk,:}=temp23{kkk,:}(8:end-9);
end
clear kkk
disp(trigger_descr_short)
conditions=trigger_descr_short;


%% Define header_raw
%%Generate header_raw
% General header based on conditions - it works now! magic maria 23.3.2017


header_raw_exp=['Subject_Num_'];
for ssk=1:length(Sessions) %  Base, Test 
    session_temp=Sessions(ssk);
    session_temp_char=char(session_temp);
    for kk=1:length(conditions) % triggers_descr_short  
        temp_condition=conditions(kk);
        temp_condition_char=char(temp_condition);
        if length(part_names_all)==0
            middle_temp_name=cellstr([session_temp_char '_' temp_condition_char ]); % for ex. Base_triggertype1 
            header_raw_exp=[header_raw_exp middle_temp_name ];
        elseif length(part_names_all)>0
            for jj=1:length(part_names_all)
                temp_parts=part_names_all(jj);
                temp_parts_char=char(temp_parts);
                middle_temp_name=cellstr([session_temp_char '_'  temp_condition_char '_' temp_parts_char]);
                header_raw_exp=[header_raw_exp middle_temp_name ];
            end
        end
    end
end
clear kk jj

header_raw=header_raw_exp;
disp(header_raw);
clear header_raw_exp

%% Define empty structure;
% Initialize the structure to save the data, named Mean_Subjects_BT
for kk=1:Num_folders
    Folder_name=temp22{kk,:};
    for  yyy=1:length(Sessions) % 4
        session_temp=Sessions(yyy);
        session_temp_char=char(session_temp);
        for tt=1:length(temp23) 
            trigger_temp=temp23{tt,:}(1:end-4);
            trigger_temp_char=char(trigger_temp);
            Mean_Subjects_BT.(Folder_name).(session_temp_char).(trigger_temp_char)=[];
        end % For trigger temp%dataGA_BT.(session_temp_char).(trigger_temp_char)=[];
    end
end

clear yyy nnn kk ...
temp_session session_temp_char trigger_temp trigger_temp_char

%% Start the mega loop for analysis 
% Define which subjects are good and which are bad. 
%bad_subject_list=[7, 9, 13, 16, 17, 19, 20, 24, 30];
bad_subject_list=[7, 9, 13, 16, 17, 19, 20, 24, 30, 34, 36, 40]; % updated 21.3.2017  209 should be inside as it has nothing 80_20_20
% Old correct_folders=[startfolder 2:6 8:12 14 15 18 21:29 31:33];
good_subj_list=[]; 
for kk=1:Num_folders, 
    if ~ismember(kk, bad_subject_list), 
        good_subj_list=[good_subj_list kk]; 
    end; 
end
clear kk 

%% Start load
startfolder=1;

for mkk=1:length(good_subj_list)
    jjk=good_subj_list(mkk);
    Folder_name=temp22{jjk,:};
    fprintf(' ***  Working on subject %s: %s\n', num2str(mkk), Folder_name)
    % To be deleted
%     Analyzed_path_folder=[Analyzed_path temp22{jjk,:} '\'];
%     Raw_path_folder=[Raw_path temp22{jjk,:} '\'];
%     cd(Raw_path_folder);
    % For every Session: Training1 or Training2 
    for mm=1:length(Sessions)
        session_temp=Sessions{:,mm}; %%% !!!!
        session_temp_char=char(session_temp);
        Subject_filename_session=[Folder_name '_' session_temp];
        
        % Define the new paths            
        Analyzed_path_folder=[Analyzed_path temp22{jjk,:} '\' session_temp ];
        Raw_path_folder=[Raw_path temp22{jjk,:} '\' temp22{jjk,:} '\' session_temp];
        
        % Loop for every trigger type we are going to use
         for kk=1:Num_triggers 
            trigger_temp=temp23{kk,:}(1:end-4);
            trigger_temp_char=char(trigger_temp);
            % new part
            cd(Analyzed_path_folder)
            cd('Triggers')
            trigger_name=[trigger_temp '.txt'];
            load_trig=load(trigger_name);
            if length(load_trig)>0
                % Go the Analyzed_path_folder for each subject
                % and search for the set files for each AX, AY condition
                cd(Analyzed_path_folder)
                Search_for_folder=['*__Luck_' trigger_temp_char '.set'];

                listing_sets=dir(Search_for_folder);
            
               % Find where the condition starts in the filename
                B=strfind(listing_sets.name, trigger_temp_char);        
                %1
                name1=listing_sets.name(1:(B-1));%'Subject_103_25_512_ch_DC_epochs_tr2_autotriggers'; %AX.txt;
                name2=trigger_temp_char;
                name3b=['.set'];
                name_file=[name1 name2 name3b]; %Subject101_Training1_512_ch_DC_epochs_50_triggers_Correct.txt3ch.se
                name_data=[name1 name2]; %Subject101_Training1_512_ch_DC_epochs_50_triggers_Correct
             
                AreWeRight=strcmp(name_file, listing_sets.name);
                if AreWeRight==1, 
                    disp(['Working on file ' listing_sets.name ' for trigger ' trigger_temp_char]);
                    EEG = pop_loadset('filename',name_file,'filepath',Analyzed_path_folder);
                    EEG = eeg_checkset( EEG );
                    eeglab redraw
                    
                    % Get the data and the dimensions of it. 
                    % Select smaller timepoints, run only once, at start!
                    if (jjk==startfolder & mm==1)
                        Fs=EEG.srate;
                        chanlocs=EEG.chanlocs;
                        pre_trigger = -EEG.xmin*1000; %msec  200 700
                        post_trigger = EEG.xmax*1000; %msec 1100 1600
                        data_pre_trigger = floor(pre_trigger*Fs/1000);
                        data_post_trigger = floor(post_trigger*Fs/1000);
                        timeVec = (-(data_pre_trigger):(data_post_trigger));
                        timeVec = timeVec';
                        timeVec_msec = timeVec.*(1000/Fs);

                        new_pre_trigger=-200;
                        new_post_trigger=600;
                        find_new_pre_trigger=find(timeVec_msec>-200);
                        new_pre_trigger_index=min(find_new_pre_trigger);

                        find_new_post_trigger=find(timeVec_msec<600);
                        new_post_trigger_index=max(find_new_post_trigger);
                        timeVec_msec_new=timeVec_msec(new_pre_trigger_index:new_post_trigger_index);
                        clear timeVec_msec
                        % TODO here I change to a new timeVec_msec 
                        % To check what to do - what i did before in
                        % >Training
                        timeVec_msec=timeVec_msec_new;
                        clear timeVec_msec_new
                        disp('Epoch new shorter duration done')
                    end
                          
                    % Save the EEG.data with smaller epoch
                    data=EEG.data(:, new_pre_trigger_index:new_post_trigger_index, :); 
                    meandata=mean(data, 3);
                    Mean_Subjects_BT.(Folder_name).(session_temp_char).(trigger_temp_char)=meandata;
                    Num_triggers_BT.(Folder_name).(session_temp_char).(trigger_temp_char)=size(data, 3); % new March 2017
                    %dataGA_BT.(session_temp_char).(trigger_temp_char)=cat(3, dataGA_BT.(session_temp_char).(trigger_temp_char), data);
                     clear data meandata 
                end % End if we are Right
            elseif length(load_trig)==0 % what to do when trigger is empty. 
                Mean_Subjects_BT.(Folder_name).(session_temp_char).(trigger_temp_char)=0;
                Num_triggers_BT.(Folder_name).(session_temp_char).(trigger_temp_char)=0; % new March 2017
            end % if there is trigger
         end % Num_triggers
    end % Sessions
    end % Subject


%Check if we need any of this
clear jjk mm kk gg B ...
    AreWeRight ...
    data_post_trigger ...
    data_pre_trigger ...
    find_new_post_trigger ...
    find_new_pre_trigger ...
    name1 name2 name3a name3b name_data name_file Name_subject_folder ...
    part_names part_name_temp_char part_name_temp ...
    post_trigger ...
    pre_trigger ...
    temp_condition ...
    temp_condition_char

%% Depending on case name the variable and save it in the desired folder
cd(Analyzed_path)
cd(saving_data_folder)
% Rename according to description of analysis % TODO to automate
Mean_Subjects_BT_80_20=Mean_Subjects_BT;
Num_triggers_BT_80_20=Num_triggers_BT;

save Mean_Subjects_BT_80_20 Mean_Subjects_BT_80_20
save Num_triggers_BT_80_20 Num_triggers_BT_80_20
save new_post_trigger_index new_post_trigger_index
save new_pre_trigger_index new_pre_trigger_index
save timeVec_msec timeVec_msec
toc
% 
%% Define Electrodes to work on. 20.9.16
% selected_channels=[6, 7, 9, 10, 11, 12, 14, 16, 17, 20, 23, 25, 28, 29];
% March 2017 * we have all the electrodes now * 66
% P3, P5, PO3, O1, OZ, POZ, CPZ, AFZ, FZ, FCZ, C6, P4, PO4, O2
selected_channels=[21 22 26 27 29 30 32 37 38 47 51 58 63 64];
% Now the structure has all the electrodes, so these electrodes have other
% numbers
% P3= 21
% P5 = 22
% PO3= 26
% O1=27
% OZ=29
% POZ=30
% CPZ=32
% AFZ=37
% FZ=38
% FCZ=47
% C6=51
% P4=58
% PO4=63
% O2=64

%% Search for the N1 a negative-going deflection between 150-200 msec. 
% Define time limits for the peak detection 
name_component = 'N1';
type='mean';
peak_start_time=140;
peak_end_time=210;
time_epoch_start=new_pre_trigger; %-200;
time_epoch_end=new_post_trigger; % 600; % 
startfolder=1;

for jjk=[good_subj_list]  % For every subject - folder
   Folder_name=temp22{jjk,:};
   Folder_name_char=char(Folder_name);
   for mm=1:length(Sessions) % For every condition : Wrong, Correct,HR, LR
       session_temp=Sessions(mm);
       session_temp_char=char(session_temp); 
       for kk=1:length(temp23)
           trigger_temp=temp23{kk,:}(1:end-4);
            trigger_temp_char=char(trigger_temp);                
            dataAllchannels=Mean_Subjects_BT.(Folder_name).(session_temp_char).(trigger_temp_char);
            if length(dataAllchannels)>0
                for cc=[selected_channels];
                    chanlocs_temp=chanlocs(cc).labels;
                    chanlocs_temp_char=char(chanlocs_temp);
                    temp_chan=dataAllchannels(cc,:);
                    %Here
                    [ final_peak_measure ] = RVS_Training_find_mean_ar_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, Fs, timeVec_msec, type );
                    % Old below 
                    %[ final_peak_measure ] = RVS_Training_find_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, time_epoch_start, time_epoch_end, fs, timeVec_msec, type );
                    Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=final_peak_measure;
                clear temp_chan chanlocs_temp
            end % For channels
            else % what to do if there is no data
           Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=[];
       end % if data not empty
       end % For all trigger types 
   end % For all sessions
end % For all subjects 
cd(Analyzed_path)
cd(saving_data_folder)
save Peak_results_N1 Peak_results

% Write components to a txt file - NEW
% header_raw={'Subject_Num','_Base_20L','_Base_50L','_Base_50H','_Base_80H','_Test_20L','_Test_50L','_Test_50H','_Test_80H'};

write_peak_component_to_txt_1_report_4rewlev( header_raw, startfolder, good_subj_list , temp22, ...
    selected_channels, Sessions, Peak_results, chanlocs, name_component, temp23, type, Analyzed_path,saving_data_folder )
clear Peak_results


%% P300 detection 
% Define time limits for the peak detection 
name_component = 'P300'
type='mean';
peak_start_time=340;
peak_end_time=450;
time_start=-200 %
startfolder=1;
for jjk=[good_subj_list]  % For every subject - folder
   Folder_name=temp22{jjk,:};
   Folder_name_char=char(Folder_name);
   for kk=1:length(Sessions) % For every condition : Wrong, Correct,HR, LR
       session_temp=Sessions(kk);
       session_temp_char=char(session_temp);        
       for kk=1:length(temp23)
           trigger_temp=temp23{kk,:}(1:end-4);
            trigger_temp_char=char(trigger_temp);                
            dataAllchannels=Mean_Subjects_BT.(Folder_name).(session_temp_char).(trigger_temp_char);
            if length(dataAllchannels)>0
                for cc=[selected_channels];
                    chanlocs_temp=chanlocs(cc).labels;
                    chanlocs_temp_char=char(chanlocs_temp);
                    temp_chan=dataAllchannels(cc,:);
                    %Here
                    [final_peak_measure] = RVS_Training_find_mean_ar_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, Fs, timeVec_msec, type );
                    %[ final_peak_measure ] = RVS_Training_find_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, time_epoch_start, time_epoch_end, fs, timeVec_msec, type );
                    Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=final_peak_measure;
                    clear temp_chan chanlocs_temp
                end % For channels
       else % what to do if there is no data
           Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=[];
       end % if data not empty
       end % For triggers
   end % For all sessions
end % For all subjects 
cd(Analyzed_path)
cd(saving_data_folder)
mkdir('P300_from340ms')
cd('P300_from340ms')
save Peak_results_P300 Peak_results

% Write components to a txt file - NEW
%header_raw={'Subject_Num','_Base_20L','_Base_50H','_Base_50L','_Base_80H','_Test_20L','_Test_50H','_Test_50L','_Test_80H'};

write_peak_component_to_txt_1_report_4rewlev( header_raw, startfolder, good_subj_list , temp22, ...
    selected_channels, Sessions, Peak_results, chanlocs, name_component , temp23, type, Analyzed_path, saving_data_folder)
clear Peak_results 

%% N2 detection 
% Define time limits for the peak detection 
name_component ='N2';
type='mean';
peak_start_time=270; % in msec
peak_end_time=320; % in msec
startfolder=1;
for jjk=[good_subj_list];  % For every subject - folder
   Folder_name=temp22{jjk,:};
   Folder_name_char=char(Folder_name);
   for mm=1:length(Sessions) % For every condition : Wrong, Correct,HR, LR
       session_temp=Sessions(mm);
       session_temp_char=char(session_temp); 
       for kk=1:length(temp23);
           trigger_temp=temp23{kk,:}(1:end-4);
            trigger_temp_char=char(trigger_temp);                
            dataAllchannels=Mean_Subjects_BT.(Folder_name_char).(session_temp_char).(trigger_temp_char); % to clear dataAllchannels
            if length(dataAllchannels)>0
                for cc=[selected_channels];
                    chanlocs_temp=chanlocs(cc).labels;
                    chanlocs_temp_char=char(chanlocs_temp);
                    temp_chan=dataAllchannels(cc,:);
                    %Here
                    [final_peak_measure] = RVS_Training_find_mean_ar_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, Fs, timeVec_msec, type )
                    Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=final_peak_measure;
                clear temp_chan chanlocs_temp
            end % For channels
            else % what to do if there is no data - for ex. subject 209, base, 80_20_20 is empty 
           Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=[];
       end % if data not empty
       end % For all trigger types 
   end % For all sessions
end % For all subjects 
clear mm kk cc jjk
cd(Analyzed_path)
cd(saving_data_folder)
save Peak_results_N2 Peak_results

% Write components to a txt file 
write_peak_component_to_txt_1_report_4rewlev( header_raw, startfolder, good_subj_list , temp22, ...
    selected_channels, Sessions, Peak_results, chanlocs, name_component, temp23, type, Analyzed_path, saving_data_folder)
clear peak_start_time peak_end_time name_component
clear Peak_results 


%% P2 detection 
% Define time limits for the peak detection 
name_component = 'P2';
type='mean';
peak_start_time=220;
peak_end_time=270;
startfolder=1;
for jjk=[good_subj_list]; % For every subject - folder
   Folder_name=temp22{jjk,:};
   Folder_name_char=char(Folder_name);
   for mm=1:length(Sessions); % For every condition : Wrong, Correct,HR, LR
       session_temp=Sessions(mm);
       session_temp_char=char(session_temp); 
       for kk=1:length(temp23);
           trigger_temp=temp23{kk,:}(1:end-4);
            trigger_temp_char=char(trigger_temp);                
            dataAllchannels=Mean_Subjects_BT.(Folder_name).(session_temp_char).(trigger_temp_char);
            if length(dataAllchannels)>0
                for cc=[selected_channels];
                    chanlocs_temp=chanlocs(cc).labels;
                    chanlocs_temp_char=char(chanlocs_temp);
                    temp_chan=dataAllchannels(cc,:);
                    %Here
                    [final_peak_measure] = RVS_Training_find_mean_ar_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, Fs, timeVec_msec, type );
                    Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=final_peak_measure;
                clear temp_chan chanlocs_temp
            end % For channels
            else % what to do if there is no data
           Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=[];
       end % if data not empty
       end % For all trigger types 
   end % For all sessions
end % For all subjects 
clear mm kk cc jjk

cd(Analyzed_path)
cd(saving_data_folder)
save Peak_results_P2 Peak_results

% Write components to a txt and an excel file 

write_peak_component_to_txt_1_report_4rewlev( header_raw, startfolder, good_subj_list , temp22, ...
    selected_channels, Sessions, Peak_results, chanlocs, name_component, temp23, type, Analyzed_path, saving_data_folder )
clear peak_start_time peak_end_time name_component
clear Peak_results 

%% The End

toc