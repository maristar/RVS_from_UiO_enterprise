
%% To do the grandaverage plots (?) for the RVS_Base and make the peak detection 
% automatically 
% Maria Stavrinou
% 19 June 2016 
% 21 June for Double report and detection of P1, N1, N2, p300
clear all 
close all
tic

%% Path information
Raw_Path='/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/';
Analyzed_path = '/Volumes/EEG2_MARIA/EEG/RVS/Analyzed_datasets_B_T/';

cd(Analyzed_path);
%% Define list of Folders - Subjects  
Name_subject_folder='*RVS_Subject*';
listing_raw=dir(Name_subject_folder);
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
end
clear listing_raw kk

% Define the sessions 
Sessions={'Base', 'Test'};

%%
% Define the type of triggers we are after
% Do that by going inside a folder and checking for triggers
cd(Analyzed_path)
cd('RVS_Subject104/')
cd('Base/Triggers')

listing_raw=dir('double_*txt');
Num_triggers=length(listing_raw);
for kkm=1:Num_triggers
    temp23{kkm,:}=listing_raw(kkm).name;
end
clear kkm listing_raw


%% Define empty structure;
% Initialize the structure to save the data, named dataGA_BT
for kk=1:Num_folders
    Folder_name=temp22{kk,:};
    trigger_temp='double_both_corr';
    trigger_temp_char=char(trigger_temp);
    for  yyy=1:length(Sessions) % 4
        session_temp=Sessions(yyy);
        session_temp_char=char(session_temp);   
        Mean_Subjects_BT_DR.(Folder_name).(session_temp_char).(trigger_temp_char)=[];
        %dataGA_BT.(session_temp_char).(trigger_temp_char)=[];
        clear session_temp session_temp_char 
    end
   clear Folder_name 
end
clear yyy nnn kk trigger_temp trigger_temp_char

%% Start the mega loop for analysis 
startfolder=1;
correct_folders=[startfolder 2:6 8 10:12 14 15 18 21:23 25:29 31:33];


for jjk=[correct_folders] % For every subject - folder
    Folder_name=temp22{jjk,:};
    % For every Session: Training1 or Training2 
    for mm=1:length(Sessions)
        session_temp=Sessions{:,mm}; %%% !!!!
        session_temp_char=char(session_temp);
        Subject_filename_session=[Folder_name '_' session_temp];
        
        % Define the new paths            
        Analyzed_path_folder=[Analyzed_path temp22{jjk,:} '/' session_temp ];
        Raw_path_folder=[Raw_Path temp22{jjk,:} '/' temp22{jjk,:} '/' session_temp];
        
        % Loop for every trigger type we are going to use
%         for kk=1:Num_triggers 
            trigger_temp='double_both_corr';
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
                Search_for_folder=['*128_ch_DC_epochs_tr2_' trigger_temp_char '.set'];

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
                        disp('Epoch new shorter duration done')
                        % So define again new timeVec_msec
                        timeVec_msec=timeVec_msec(new_pre_trigger_index:new_post_trigger_index);
                    end
                          
                    % Save the EEG.data with smaller epoch
                    data=EEG.data(:, new_pre_trigger_index:new_post_trigger_index, :);  %TODO
                    meandata=mean(data, 3);
                    Mean_Subjects_BT_DR.(Folder_name).(session_temp_char).(trigger_temp_char)=meandata;
                    %dataGA_BT.(session_temp_char).(trigger_temp_char)=cat(3, dataGA_BT.(session_temp_char).(trigger_temp_char), data);
                     clear data
                end % End if we are Right
            end % if there is trigger
%         end % Num_triggers
    end % Sessions
    end % Subject


%Check if we need any of this
clear jjk mm kk gg B AreWeRight data_post_trigger ...
    data_pre_trigger find_new_post_trigger find_new_pre_trigger ...
    name1 name2 name3a name3b name_data name_file ...
    Name_subject_folder ...
    trigger pre_trigger temp_condition ...
    temp_condition_char


cd(Analyzed_path)
mkdir('Mean_All_Subjects_DR')
cd('Mean_All_Subjects_DR')
save Mean_Subjects_BT_DR Mean_Subjects_BT_DR 
save new_post_trigger_index new_post_trigger_index
save new_pre_trigger_index new_pre_trigger_index
save timeVec_msec timeVec_msec
toc
% 
%% Search for the N1 a negative-going deflection between 150-200 msec. 
% Define time limits for the peak detection 
type='min';
peak_start_time=140;
peak_end_time=210;
time_epoch_start=-200;
time_epoch_end=600; % In msec -there is abs(time_start) in the function so the minus is disgarted
startfolder=1;
selected_channels=[14, 18, 15, 6, 23, 10, 8, 25, 9];
fs=128;
for jjk=[correct_folders]  % For every subject - folder
   Folder_name=temp22{jjk,:};
   Folder_name_char=char(Folder_name);
   for kk=1:length(Sessions) % For every condition : Wrong, Correct,HR, LR
       session_temp=Sessions(kk);
       session_temp_char=char(session_temp);        
       trigger_temp='double_both_corr';
       trigger_temp_char=char(trigger_temp);                
       dataAllchannels=Mean_Subjects_BT_DR.(Folder_name).(session_temp_char).(trigger_temp);
       if length(dataAllchannels)>0
            for cc=[selected_channels];
                chanlocs_temp=chanlocs(cc).labels;
                chanlocs_temp_char=char(chanlocs_temp);
                temp_chan=dataAllchannels(cc,:);
                %Here
                [ final_peak_measure ] = RVS_Training_find_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, time_epoch_start, time_epoch_end, fs, timeVec_msec, type );
                Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=final_peak_measure;
                clear temp_chan chanlocs_temp
            end % For channels
       end % if data not empty
   end % For all sessions
end % For all subjects 
cd(Analyzed_path)
cd ('Mean_All_Subjects_DR')
save Peak_results_N1 Peak_results

%% Write components to a txt file - NEW
header_raw={'Subject_Num','_Base_double_report','_Test_double_report'};

[ Tnew ] = write_peak_component_to_txt( header_raw, startfolder, correct_folders, temp22, ...
    selected_channels, Sessions, trigger_temp, Peak_results, chanlocs, 'N1' )

%% P300 detection 
% Define time limits for the peak detection 
type='max';
peak_start_time=200;
peak_end_time=500;
time_start=-200 %
selected_channels=[14, 18, 15, 6, 23, 10, 8, 25, 9];
startfolder=1;
for jjk=[correct_folders]  % For every subject - folder
   Folder_name=temp22{jjk,:};
   Folder_name_char=char(Folder_name);
   for kk=1:length(Sessions) % For every condition : Wrong, Correct,HR, LR
       session_temp=Sessions(kk);
       session_temp_char=char(session_temp);        
       trigger_temp='double_both_corr';
       trigger_temp_char=char(trigger_temp);                
       dataAllchannels=Mean_Subjects_BT_DR.(Folder_name).(session_temp_char).(trigger_temp);
       if length(dataAllchannels)>0
            for cc=[selected_channels];
                chanlocs_temp=chanlocs(cc).labels;
                chanlocs_temp_char=char(chanlocs_temp);
                temp_chan=dataAllchannels(cc,:);
                %Here
                [ final_peak_measure ] = RVS_Training_find_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, time_epoch_start, time_epoch_end, fs, timeVec_msec, type );
                Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=final_peak_measure;
                clear temp_chan chanlocs_temp
            end % For channels
       else % what to do if there is no data
           Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=[];
       end % if data not empty
   end % For all sessions
end % For all subjects 
cd(Analyzed_path)
cd ('Mean_All_Subjects_DR')
save Peak_results_P300 Peak_results

%% Write components to a txt file - NEW
header_raw={'Subject_Num','_Base_double_report','_Test_double_report'};

[ Tnew ] = write_peak_component_to_txt( header_raw, startfolder, correct_folders, temp22, ...
    selected_channels, Sessions, trigger_temp, Peak_results, chanlocs, 'P300' )
clear Peak_results

%% N2 detection 
% Define time limits for the peak detection 
type='min';
peak_start_time=270;
peak_end_time=300;
time_start=-200;
selected_channels=[14, 18, 15, 6, 23, 10, 8, 25, 9];
startfolder=1;
for jjk=[correct_folders]  % For every subject - folder
   Folder_name=temp22{jjk,:};
   Folder_name_char=char(Folder_name);
   for kk=1:length(Sessions) % For every condition : Wrong, Correct,HR, LR
       session_temp=Sessions(kk);
       session_temp_char=char(session_temp);        
       trigger_temp='double_both_corr';
       trigger_temp_char=char(trigger_temp);                
       dataAllchannels=Mean_Subjects_BT_DR.(Folder_name).(session_temp_char).(trigger_temp);
       if length(dataAllchannels)>0
            for cc=[selected_channels];
                chanlocs_temp=chanlocs(cc).labels;
                chanlocs_temp_char=char(chanlocs_temp);
                temp_chan=dataAllchannels(cc,:);
                %Here
                [ final_peak_measure ] = RVS_Training_find_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, time_epoch_start, time_epoch_end, fs, timeVec_msec, type );
                Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=final_peak_measure;
                clear temp_chan chanlocs_temp
            end % For channels
       end % if data not empty
   end % For all sessions
end % For all subjects 
cd(Analyzed_path)
cd ('Mean_All_Subjects_DR')
save Peak_results_N2 Peak_results

%% Write components to a txt file - NEW
header_raw={'Subject_Num','_Base_double_report','_Test_double_report'};

[ Tnew ] = write_peak_component_to_txt( header_raw, startfolder, correct_folders, temp22, ...
    selected_channels, Sessions, trigger_temp, Peak_results, chanlocs, 'N2' )
clear Peak_results

%% P2 detection 
% Define time limits for the peak detection 
type='max';
peak_start_time=220;
peak_end_time=270;
time_start=-200; % put a minus if pretrigger
selected_channels=[14, 18, 15, 6, 23, 10, 8, 25, 9];
startfolder=1;
for jjk=[correct_folders]  % For every subject - folder
   Folder_name=temp22{jjk,:};
   Folder_name_char=char(Folder_name);
   for kk=1:length(Sessions) % For every condition : Wrong, Correct,HR, LR
       session_temp=Sessions(kk);
       session_temp_char=char(session_temp);        
       trigger_temp='double_both_corr';
       trigger_temp_char=char(trigger_temp);                
       dataAllchannels=Mean_Subjects_BT_DR.(Folder_name).(session_temp_char).(trigger_temp);
       if length(dataAllchannels)>0
            for cc=[selected_channels];
                chanlocs_temp=chanlocs(cc).labels;
                chanlocs_temp_char=char(chanlocs_temp);
                temp_chan=dataAllchannels(cc,:);
                %Here
                [ final_peak_measure ] = RVS_Training_find_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, time_epoch_start, time_epoch_end, fs, timeVec_msec, type );
                Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=final_peak_measure;
                clear temp_chan chanlocs_temp
            end % For channels
       end % if data not empty
   end % For all sessions
end % For all subjects 
cd(Analyzed_path)
cd ('Mean_All_Subjects_DR')
save Peak_results_P2 Peak_results

%% Write components to a txt file - NEW
header_raw={'Subject_Num','_Base_double_report','_Test_double_report'};

[ Tnew ] = write_peak_component_to_txt( header_raw, startfolder, correct_folders, temp22, ...
    selected_channels, Sessions, trigger_temp, Peak_results, chanlocs, 'P2' )

% %% Write to a cell, to be a table and then exported to file - to be opened with comma delimiter in excel
% % Header sent by Thomas
% %header={'Subject_Num','CPz_Correct_a','CPz_Correct_b', 'CPz_Correct_c',	'CPz_Correct_d', 'CPz_Incorrect_a',	'CPz_Incorrect_b',	'CPz_Incorrect_c',	'CPz_Incorrect_d','CPz_HR_a', 'CPz_HR_b','CPz_HR_c','CPz_HR_d',	'CPz_LR_a',	'CPz_LR_b',	'CPz_LR_c',	'CPz_LR_d'};
% header_raw={'Subject_Num','_Base_double_report','_Test_double_report'};
% startfolder=1;
% correct_folders=[startfolder 2:6 8 10:12 14 15 18 21:23 25:29 31:33];
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
%     for jjk=[correct_folders]
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
% correct_folders=[startfolder 2:6 8 10:12 14 15 18 21:23 25:29 31:33];
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
%     for jjk=[correct_folders]
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