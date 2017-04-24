
%% To do the grandaverage plots (?) for the RVS_Base and make the peak detection 
% automatically 
% Maria Stavrinou
% 20.9.2016
% 29.03.2017

clear all 
close all 
tic

Raw_path='Y:\Prosjekt\RVS_43_subjects\Raw_datasets\DataRVS\';
Analyzed_path='Y:\Prosjekt\RVS_43_subjects\Analyzed_datasets\';

% Define folder to save the results
cd(Analyzed_path)
saving_data_folder=['Mean_All_Subjects_BT_double_none_report' date];
Saving_path=[Analyzed_path saving_data_folder];
mkdir(saving_data_folder)

% Get the list of folders from the raw folder. 
cd(Raw_path)
% Define list of folders 
listing_raw=dir('RVS_Subject*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 
end
clear kk

% Define sessions
Sessions={'Base', 'Test'};

%%
% Define the type of triggers we are after
% Do that by going inside a folder and checking for triggers
cd(Analyzed_path)
cd('RVS_Subject104/')
cd('Base/Triggers')

% What we put inside the dir function changes with the triggers we want
% every time. SOS.
% For 4 reward levels, use: listing_raw=dir('double_one_*0*_corr.txt');
listing_raw=dir('double_none_corr.txt');
Num_triggers=length(listing_raw);
for kkm=1:Num_triggers
    temp23{kkm,:}=listing_raw(kkm).name;
end
clear kkm listing_raw

%% Define empty structure;
% Initialize the structure to save the data, named Mean_Subjects
for kk=1:Num_folders
    Folder_name=temp22{kk,:};
    for  yyy=1:length(Sessions) % 4
        session_temp=Sessions(yyy);
        session_temp_char=char(session_temp);
        for tt=1:length(temp23) 
            trigger_temp=temp23{tt,:}(1:end-4);
            trigger_temp_char=char(trigger_temp);
            Mean_Subjects.(Folder_name).(session_temp_char).(trigger_temp_char)=[];
        end % For trigger temp%dataGA_BT.(session_temp_char).(trigger_temp_char)=[];
    end
end

clear yyy nnn kk ...
temp_session session_temp_char trigger_temp trigger_temp_char

%% Start the mega loop for analysis 
% Define which subjects are good and which are bad. 

bad_subject_list=[7, 9, 13, 16, 17, 19, 20, 24, 30, 34, 36]; % 40 (Subj209) is now in. as it was in 80_20_20 that had no trigger
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
                clear B 
                AreWeRight=strcmp(name_file, listing_sets.name);
                if AreWeRight==1, 
                    disp(['Working on file ' listing_sets.name ' for trigger ' trigger_temp_char]);
                    EEG = pop_loadset('filename',name_file,'filepath',Analyzed_path_folder);
                    EEG = eeg_checkset( EEG );
                    eeglab redraw
                    
                    % Get the data and the dimensions of it. 
                    % Select smaller timepoints, run only once, at start!
                    if (jjk==startfolder & mm==1 & kk==1)
                        Fs=EEG.srate;
                        chanlocs=EEG.chanlocs; 
                        pre_trigger = EEG.xmin*1000; %msec  EEGLAB has the minus infront, 12.09.2016
                        post_trigger = EEG.xmax*1000; %msec 
                        data_pre_trigger = floor(pre_trigger*Fs/1000);
                        data_post_trigger = floor(post_trigger*Fs/1000);
                        timeVec = ((data_pre_trigger):(data_post_trigger));
                        timeVec = timeVec';
                        timeVec_msec = timeVec.*(1000/Fs);
                        
                        % Select new  pre-trigger
                        new_pre_trigger=-200;
                        new_post_trigger=600;
                        find_new_pre_trigger=find(timeVec_msec>new_pre_trigger);
                        new_pre_trigger_index=min(find_new_pre_trigger);

                        find_new_post_trigger=find(timeVec_msec<new_post_trigger);
                        new_post_trigger_index=max(find_new_post_trigger);
                        disp('Epoch new shorter duration done')
                        timeVec_msec_new=timeVec_msec(new_pre_trigger_index:new_post_trigger_index);
                        clear timeVec_msec
                        % Seems important and a correction made in
                        % Copenhagen
                        timeVec_msec=timeVec_msec_new;
                        clear timeVec_msec_new;
                    end
                    % Save the EEG.data with smaller epoch
                    data=EEG.data(:, new_pre_trigger_index:new_post_trigger_index, :);  %TODO
                    meandata=mean(data, 3);
                    Mean_Subjects.(Folder_name).(session_temp_char).(trigger_temp_char)=meandata;
                    %dataGA_BT.(session_temp_char).(trigger_temp_char)=cat(3, dataGA_BT.(session_temp_char).(trigger_temp_char), data);
                     clear data
                end % End if we are Right
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


cd(Analyzed_path)
cd(saving_data_folder)
Mean_Subjects_BT_none_rep=Mean_Subjects;
save Mean_Subjects_BT_none_rep Mean_Subjects_BT_none_rep
save new_post_trigger_index new_post_trigger_index
save new_pre_trigger_index new_pre_trigger_index
save timeVec_msec timeVec_msec
toc
% 
%% Define Electrodes to work on. 20.9.16
% now we have the 66 electrodes
selected_channels=[21, 22, 26, 27, 29, 30, 32, 37, 38, 47, 51, 58, 59, 63, 64]; % for B-T
% P3, P5, PO3, O1, OZ, POZ, CPZ, AFZ, FZ, FCZ, C6, P4,P6, PO4, O2
% P3=21, P5=22, PO3=26, O1=27, OZ=29, POZ=30, CPZ=32, AFZ=37, FZ=38,
% FCZ=47, C6=51, P4=58,P6=59, PO4=63, O2=64
%% Search for the N1 a negative-going deflection between 150-200 msec. 
% Define time limits for the peak detection 
name_component = 'N1';
type='mean';
peak_start_time=150;
peak_end_time=200;
time_epoch_start=new_pre_trigger;
time_epoch_end=new_post_trigger; % TODO to use the new_pre_trigger and new_post_trigger
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
            dataAllchannels=Mean_Subjects_BT_none_rep.(Folder_name).(session_temp_char).(trigger_temp_char);
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

%% Write components to a txt file - NEW
header_raw={'Subject_Num','_Base_none_report','_Test_none_report'};
%header_raw={'Subject_Num','_Base_20L','_Base_50L','_Base_50H','_Base_80H','_Test_20L','_Test_50L','_Test_50H','_Test_80H'};

write_peak_component_to_txt_1_report_4rewlev( header_raw, startfolder, good_subj_list , temp22, ...
    selected_channels, Sessions, Peak_results, chanlocs, name_component, temp23, type, Analyzed_path, saving_data_folder)
clear Peak_results


%% P300 detection 
% Define time limits for the peak detection 
name_component = 'P300'
type='mean';
peak_start_time=320;
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
            %TODO
            dataAllchannels=Mean_Subjects_BT_none_rep.(Folder_name).(session_temp_char).(trigger_temp_char);
            if length(dataAllchannels)>0
                for cc=[selected_channels];
                    chanlocs_temp=chanlocs(cc).labels;
                    chanlocs_temp_char=char(chanlocs_temp);
                    temp_chan=dataAllchannels(cc,:);
                    disp(chanlocs_temp_char)
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
mkdir('P300_from320ms_450ms')
cd('P300_from320ms_450ms')
save Peak_results_P300 Peak_results

% Write components to a txt file - NEW
%header_raw={'Subject_Num','_Base_20L','_Base_50H','_Base_50L','_Base_80H','_Test_20L','_Test_50H','_Test_50L','_Test_80H'};
name_component=[name_component '_' num2str(peak_start_time) '_' num2str(peak_end_time)];
write_peak_component_to_txt_1_report_4rewlev( header_raw, startfolder, good_subj_list , temp22, ...
    selected_channels, Sessions, Peak_results, chanlocs, name_component , temp23, type, Analyzed_path, saving_data_folder)
clear Peak_results 
%% N2 detection 
% Define time limits for the peak detection 
name_component ='N2';
type='mean';
peak_start_time=270;
peak_end_time=300;
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
            dataAllchannels=Mean_Subjects_BT_none_rep.(Folder_name).(session_temp_char).(trigger_temp_char);
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
            else % what to do if there is no data
           Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=[];
       end % if data not empty
       end % For all trigger types 
   end % For all sessions
end % For all subjects 
cd(Analyzed_path)
cd(saving_data_folder)
save Peak_results_N2 Peak_results

% Write components to a txt file - NEW
write_peak_component_to_txt_1_report_4rewlev( header_raw, startfolder, good_subj_list , temp22, ...
    selected_channels, Sessions, Peak_results, chanlocs, name_component, temp23, type, Analyzed_path, saving_data_folder)

%% P2 detection 
% Define time limits for the peak detection 
name_component = 'P2';
type='mean';
peak_start_time=220;
peak_end_time=270;
startfolder=1;
% Start the loop
for jjk=[good_subj_list]; % For every subject - folder
   Folder_name=temp22{jjk,:};
   Folder_name_char=char(Folder_name);
   for mm=1:length(Sessions); % For every condition : Wrong, Correct,HR, LR
       session_temp=Sessions(mm);
       session_temp_char=char(session_temp); 
       for kk=1:length(temp23);
           trigger_temp=temp23{kk,:}(1:end-4);
            trigger_temp_char=char(trigger_temp);  
            %TODO
            dataAllchannels=Mean_Subjects_BT_none_rep.(Folder_name).(session_temp_char).(trigger_temp_char);
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
cd(Analyzed_path)
cd(saving_data_folder)
save Peak_results_P2 Peak_results

%Write components to a txt and an excel file - NEW

write_peak_component_to_txt_1_report_4rewlev( header_raw, startfolder, good_subj_list , temp22, ...
    selected_channels, Sessions, Peak_results, chanlocs, name_component, temp23, type, Analyzed_path, saving_data_folder )

%% P1 detection, new 2017 mars
%% P2 detection 
% Define time limits for the peak detection 
name_component = 'P1';
type='mean';
peak_start_time=90; % to check the grandaverage for this. 
peak_end_time=140;
startfolder=1;
% Start the loop
for jjk=[good_subj_list]; % For every subject - folder
   Folder_name=temp22{jjk,:};
   Folder_name_char=char(Folder_name);
   for mm=1:length(Sessions); % For every condition : Wrong, Correct,HR, LR
       session_temp=Sessions(mm);
       session_temp_char=char(session_temp); 
       for kk=1:length(temp23);
           trigger_temp=temp23{kk,:}(1:end-4);
            trigger_temp_char=char(trigger_temp);  
            %TODO
            dataAllchannels=Mean_Subjects_BT_none_rep.(Folder_name).(session_temp_char).(trigger_temp_char);
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
cd(Analyzed_path)
cd(saving_data_folder)
save Peak_results_P1 Peak_results

%Write components to a txt and an excel file - NEW

write_peak_component_to_txt_1_report_4rewlev( header_raw, startfolder, good_subj_list , temp22, ...
    selected_channels, Sessions, Peak_results, chanlocs, name_component, temp23, type, Analyzed_path, saving_data_folder )

%% P1 end

% %% Write to a cell, to be a table and then exported to file - to be opened with comma delimiter in excel
% % Header sent by Thomas
% %header={'Subject_Num','CPz_Correct_a','CPz_Correct_b', 'CPz_Correct_c',	'CPz_Correct_d', 'CPz_Incorrect_a',	'CPz_Incorrect_b',	'CPz_Incorrect_c',	'CPz_Incorrect_d','CPz_HR_a', 'CPz_HR_b','CPz_HR_c','CPz_HR_d',	'CPz_LR_a',	'CPz_LR_b',	'CPz_LR_c',	'CPz_LR_d'};
% header_raw={'Subject_Num','_Base_double_report','_Test_double_report'};
% startfolder=1;
% good_subj_list =[startfolder 2:6 8 10:12 14 15 18 21:23 25:29 31:33];
% selected_channels=[14, 18, 15, 6, 23, 10, 8, 25, 9];
% for cc=[selected_channels]
%     chanlocs_temp=chanlocs(cc).labels;   
%     chanlocs_temp_char=char(chanlocs_temp);   
%     %% Make new header
%     for hh=2:length(header_raw);
%         temp=header_raw{1, hh};
%         temp_new=[chanlocs_temp temp];
%         header_new{1,1}=header_raw{1,1};
%         header_new{1,hh}=temp_new;
%     end
%     T(1, :)=header_new;
%     
%     for jjk=[good_subj_list ]
%      % For every subject - folder
%         Folder_name=temp22{jjk,:};
%         T(jjk+1,1)={Folder_name(5:end)};
%         column_counter=0;
%         for kk=1:length(Sessions) % For every condition : Correct,Wrong, HR, LR
%             session_temp=Sessions(kk);
%             session_temp_char=char(session_temp); 
%             column_counter=column_counter+1;
%             trigger_temp='double_both_corr';
%             trigger_temp_char=char(trigger_temp);
%                temp_peak_results=Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp);
%                T(jjk+1,1+column_counter)=num2cell(temp_peak_results);
%         end % End for sessions 
%     end % End for every subject
%     %% Save the cell into a table and then export to txt, which can be imported in 
%     % excel as a comma delimiter
%     Tnew=cell2table(T, 'VariableNames', header_new);
%     filename_to_save=[chanlocs_temp 'P2_results.txt'];
%     writetable(Tnew, filename_to_save);
% end % End for chanlocs
% 
% 
% %% %% Write to a cell, to be a table and then exported to file - to be opened with comma delimiter in excel
% % Header sent by Thomas
% %header={'Subject_Num','CPz_Correct_a','CPz_Correct_b', 'CPz_Correct_c',	'CPz_Correct_d', 'CPz_Incorrect_a',	'CPz_Incorrect_b',	'CPz_Incorrect_c',	'CPz_Incorrect_d','CPz_HR_a', 'CPz_HR_b','CPz_HR_c','CPz_HR_d',	'CPz_LR_a',	'CPz_LR_b',	'CPz_LR_c',	'CPz_LR_d'};
% header_raw={'Subject_Num','_Base_double_report_P2','_Test_double_report_P2'};
% startfolder=1;
% good_subj_list =[startfolder 2:6 8 10:12 14 15 18 21:23 25:29 31:33];
% selected_channels=[14, 18, 15, 6, 23, 10, 8, 25, 9];
% for cc=[selected_channels]
%     chanlocs_temp=chanlocs(cc).labels;   
%     chanlocs_temp_char=char(chanlocs_temp);   
%     %% Make new header
%     for hh=2:length(header_raw);
%         temp=header_raw{1, hh};
%         temp_new=[chanlocs_temp temp];
%         header_new{1,1}=header_raw{1,1};
%         header_new{1,hh}=temp_new;
%     end
%     T(1, :)=header_new;
%     
%     for jjk=[good_subj_list ]
%      % For every subject - folder
%         Folder_name=temp22{jjk,:};
%         T(jjk+1,1)={Folder_name(5:end)};
%         column_counter=0;
%         for kk=1:length(Sessions) % For every condition : Correct,Wrong, HR, LR
%             session_temp=Sessions(kk);
%             session_temp_char=char(session_temp); 
%             column_counter=column_counter+1;
%             trigger_temp='double_both_corr';
%             trigger_temp_char=char(trigger_temp);
%                temp_peak_results=Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp);
%                T(jjk+1,1+column_counter)=num2cell(temp_peak_results);
%         end % End for sessions 
%     end % End for every subject
%     %% Save the cell into a table and then export to txt, which can be imported in 
%     % excel as a comma delimiter
%     Tnew=cell2table(T, 'VariableNames', header_new);
%     filename_to_save=[chanlocs_temp '_P2_results.txt'];
%     writetable(Tnew, filename_to_save);
% end % End for chanlocs

% % New way of doing this 
% %% N2
% %% N2 detection 
% % Define time limits for the peak detection 
% type='min';
% peak_start_time=270;
% peak_end_time=300;
% time_start=-200;
% type='min';
% selected_channels=[14, 18, 15, 6, 23, 10, 8, 25, 9];
% startfolder=1;
% correct_folders=[startfolder 2:6 8 10:12 14 15 18 21:23 25:29 31:33];
% trigger_temp='double_both_corr';
% name_component='N2'
% 
% [ Peak_results, Tnew ] = RVS_BaseTest_peak_component_measure(peak_start_time, peak_end_time, ...
%     time_start, type, selected_channels, startfolder, correct_folders, temp22, Sessions, trigger_temp, name_component )
toc