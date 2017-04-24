%% To do the grandaverage plots (?) for the RVS_Base and make the peak detection 
% automatically 
% Maria Stavrinou
% 20.9.2016
% For N2pc , checking 23.03.2017
clear all 
close all 
tic
%% Path information
Raw_Path='Z:\RVS\RAW_datasets\DataRVS\';
Analyzed_path='Z:\RVS\Analyzed_datasets\';

cd(Raw_Path)
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

%% Here is done the selection of trigger type to use in the whole program
% (because they are many)!
% Little History
% 1. For double_cond 1 report: listing_raw=dir('double_one_*0*_corr.txt'); 
% 2. For 4rewlevels: listing_raw=dir('double_one_corr.txt'); for double_report
% 3. For double condition, double report: listing_raw=dir('double_both_corr.txt');
% 4. For double_condition, 1 report, 80_20_80, 80_20_20: listing_raw=dir('double_80_20_*0_corr.txt'); 
% 5. For N2pc, trigger_type='80_20_8020_left_right'; listing_raw=dir('double_80_20_*0_*t_corr.txt');
% Text_to_search for. How we will name the folder to save
% results,figures,variables,etc. 

% This text will be used as an identifier for the folder to save the
% results.
trigger_type='80_20_8020_N2pc';
% Write what the dir type can write to find out the triggers
listing_raw=dir('double_80_20_*0_*t_corr.txt')
Num_triggers=length(listing_raw);
for kkm=1:Num_triggers
    temp23{kkm,:}=listing_raw(kkm).name;
end
clear kkm

%% Make a folder to save the results in the Analyzed_path
% Use what we put in the text of |trigger_type| to name the folder
% correctly. 
cd(Analyzed_path)
% Name for the folder to save the results. 
New_saving_path_results=['Mean_All_Subjects_' trigger_type];
mkdir(New_saving_path_results)
disp(['Data will be saved in ' New_saving_path_results])
% Savename for the matlab variable with the grandaverage.
savename2=['Mean_Subjects_' trigger_type];
savename_all_trials=['All_trials_' trigger_type];
%% Define electrodes of interest
chan_numbers=[1:30];

%% Define empty structure;
% Initialize the structure to save the data, named Mean_Subjects, a general
% name
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
% SOS Subject103 is out only for 80_20_2080 comparisons (it has 0 triggers
% at Test)
% SOS Subject127 had no triggers 80_20_80 at Test
% SUBJECT 126 DOES NOT HAVE GOOD BEHAV DATA SO I PUT IT OUT TODAY
% 06.10.2016
bad_subject_list=[7, 9, 13, 16, 17, 19, 20, 24, 26, 30];
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
%     Raw_path_folder=[Raw_Path temp22{jjk,:} '\'];
%     cd(Raw_path_folder);
    % For every Session: Training1 or Training2 
    for mm=1:length(Sessions)
        session_temp=Sessions{:,mm}; %%% !!!!
        session_temp_char=char(session_temp);
        Subject_filename_session=[Folder_name '_' session_temp];
        
        % Define the new paths            
        Analyzed_path_folder=[Analyzed_path temp22{jjk,:} '\' session_temp ];
        Raw_path_folder=[Raw_Path temp22{jjk,:} '\' temp22{jjk,:} '\' session_temp];
        
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
                % Here TODO to put if it finds, if it does not find, to
                % do sth else. 
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
                    % In this variable we are saving the average for each
                    % subject. 
                    Mean_Subjects.(Folder_name).(session_temp_char).(trigger_temp_char)=meandata;
                    % In this variable we are saving all the trials for
                    % each subject. 
                    All_trials_subjects.(Folder_name).(session_temp_char).(trigger_temp_char)=data;
                    %dataGA_BT.(session_temp_char).(trigger_temp_char)=cat(3, dataGA_BT.(session_temp_char).(trigger_temp_char), data);
                     clear data meandata
                end % End if we are Right
            end % if there is trigger
         end % Num_triggers
    end % Sessions
    end % Subject


%Check if we need any of this
clear jjk mm kk gg B mkk ...
    AreWeRight ...
    bad_subject_list ...
    data_post_trigger ...
    data_pre_trigger ...
    find_new_post_trigger ...
    find_new_pre_trigger ...
    name1 name2 name3a name3b ...
    name_data name_file Name_subject_folder ...
    part_names part_name_temp_char part_name_temp ...
    post_trigger ...
    pre_trigger ...
    temp_condition ...
    temp_condition_char ...
    Num_triggers ...
    session_temp session_temp_char ...
    Subject_filename_session ...
    trigger_temp trigger_temp_char ...
    tt trigger_name ...
    Analyzed_path_folder Folder_name Raw_path_folder ...
    listing_sets load_trig ...
    timeVec Search_for_folder

% Save what we need
cd(Analyzed_path)
cd(New_saving_path_results)
eval(['save ' savename2 ' Mean_Subjects All_trials_subjects good_subj_list new_post_trigger_index new_pre_trigger_index timeVec_msec trigger_type'])

% Pool channels together for N2pc
chan_indexes_left=[3,4,6,7,8, 10];
chan_indexes_right=[23,24,25,27, 28,30];
Pooled_means=pool_trials_channels(chan_indexes_left, chan_indexes_right, All_trials_subjects, good_subj_list, startfolder );
% Save what we need
cd(Analyzed_path)
cd(New_saving_path_results)
save Pooled_means Pooled_means

% new_saving_dir
%% Define Electrodes to work on. 20.9.16
% N2pc start
selected_channels=[chan_indexes_left chan_indexes_right];
% selected_channels=[4, 6, 7, 9, 10, 11, 12, 14, 16, 17, 20, 23, 25,26, 28, 29];
% C5 P3, P5, PO3, O1, OZ, POZ, CPZ, AFZ, FZ, FCZ, C6, P4,P6, PO4, O2

%% 11.10.2016
% Put the plotter here so we can see the waveforms so we can set the limits. 

RVS_BaseTest_plotter_80_20_2080_N2pc(good_subj_list, Pooled_means, temp22, Sessions, timeVec_msec)

%% Search for the N2pc a negative-going deflection between 250-300 msec. 
% Define time limits for the peak detection 
type='mean';
peak_start_time=200;
peak_end_time=270;

% What to do here, and how to name it. 
orientations={'contra','ipsi'};%orientations={'contra_minus_ipsi'}
name_component = 'N2pc';
startfolder=1;
Fs=256;

% Here to take from the start
for jjk=[good_subj_list]  % For every subject - folder
   Folder_name=temp22{jjk,:};
   Folder_name_char=char(Folder_name);
   for mm=1:length(Sessions) % For every condition : Wrong, Correct,HR, LR
       session_temp=Sessions(mm);
       session_temp_char=char(session_temp); 
       for kk=1:length(temp23)
           trigger_temp=temp23{kk,:}(1:end-4);
            trigger_temp_char=char(trigger_temp);   
            % Check if trigger is empty
            cd(Analyzed_path)
            cd(Folder_name)
            cd(session_temp_char)
            cd('Triggers')
            temp_trigger=load(temp23{kk,:}); % it will show the number of triggers, 
            if length(temp_trigger)>0
                for oo=1:length(orientations)
                    temp_orientation=orientations{:, oo};
                    %temp_orientation_text=['means_' temp_orientation];
                    temp_orientation_text=[temp_orientation];
                    temp_orientation_text_char=char(temp_orientation_text);
                    cd(Analyzed_path)
                    cd(New_saving_path_results)
                    % TODO load the Pooled_means if we need to. 
                    data=Pooled_means.(Folder_name).(session_temp_char).(trigger_temp_char).(temp_orientation_text_char);
                    disp(['Size of data is ' num2str(size(data))])
                    if length(data)>0 % double check if the dataset-due to empty trigger-is empty!
                        [ final_peak_measure ] = RVS_Training_find_mean_ar_peak_measure_v2(data, peak_start_time, peak_end_time, Fs, timeVec_msec, type );
                        % Old below 
                        %[ final_peak_measure ] = RVS_Training_find_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, time_epoch_start, time_epoch_end, fs, timeVec_msec, type );
                        Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(temp_orientation_text_char)=final_peak_measure;
                    clear temp_chan chan
%                     else % what to do if there is no data
%                         Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(temp_orientation_text_char)=[];
                    end % if data not empty
                end % For all orientations -contra vs ipsi
%             elseif length(temp_trigger)==0 
%                     Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(temp_orientation_text_char)=[];
                    clear trigger_temp trigger_temp_char temp_trigger
            end % If the trigger is not empty.
       end % For all trigger types 
   end % For all sessions
end % For all subjects 
cd(Analyzed_path)
cd(New_saving_path_results)
mkdir('N2pc_200_270ms')
cd('N2pc')
save Peak_results_N2pc Peak_results
%% Write components to a txt file - NEW
% Header for the difference contra minus ipsi
%header_raw={'Subject_Num','Base_20_contra_ipsi','Base_80_contra_ipsi', 'Test_20_contra_ipsi', 'Test_80_contra_ipsi'};

header_raw={'Subject_Num','Base_20_contra','Base_20_ipsi','Base_80_contra','Base_80_ipsi', 'Test_20_contra','Test_20_ipsi', 'Test_80_contra', 'Test_80_ipsi'};
write_peak_component_to_txt_N2pc(Analyzed_path, header_raw, good_subj_list, temp22, Sessions, Peak_results, name_component, temp23, type, orientations)

% New function to plot the N2pc
cd(Analyzed_path)
cd(New_saving_path_results)
mkdir('N2pc')
cd('N2pc')
% The plotter was here but moved upstraIRS
% RVS_BaseTest_plotter_80_20_2080_N2pc(good_subj_list, Pooled_means, temp22, Sessions, timeVec_msec)

% %% New section plot the N2pc
% %orientations={'contra','ipsi'};t,30,
% orientations={'contra_minus_ipsi'}
% for jjk=[good_subj_list]  % For every subject - folder
%    Folder_name=temp22{jjk,:};
%    Folder_name_char=char(Folder_name);
%    for mm=1:length(Sessions) % For every condition : Wrong, Correct,HR, LR
%        session_temp=Sessions(mm);
%        session_temp_char=char(session_temp); 
%        for kk=1:length(temp23)
%            trigger_temp=temp23{kk,:}(1:end-4);
%             trigger_temp_char=char(trigger_temp);   
%             % Check if trigger is empty
%             cd(Analyzed_path)
%             cd(Folder_name)
%             cd(session_temp_char)
%             cd('Triggers')
%             temp_trigger=load(temp23{kk,:}); % it will show the number of triggers, 
%             if length(temp_trigger)>0
%                 for oo=1:length(orientations)
%                     temp_orientation=orientations{:, oo};
%                     %temp_orientation_text=['means_' temp_orientation];
%                     temp_orientation_text=[temp_orientation];
%                     temp_orientation_text_char=char(temp_orientation_text);
%                     cd(Analyzed_path)
%                     cd(New_saving_path_results)
%                     % TODO load the Pooled_means if we need to. 
%                     data=Pooled_means.(Folder_name).(session_temp_char).(trigger_temp_char).(temp_orientation_text_char);
%                     disp(['Size of data is ' num2str(size(data))])
%                     if length(data)>0 % double check if the dataset-due to empty trigger-is empty!
%                        fig=figure; 
%                        plot(timeVec_msec, data);hold on;
%                        title([Folder_name '_' session_temp_char  '_Contra-ipsi'])
%                        savename=[Folder_name_char '_' session_temp_char '_contra_minus_ipsi'];
%                        saveas(fig,  savename, 'png');
%                        saveas(fig,  savename, 'fig');
%                     end % if data not empty
%                 end % For all orientations -contra vs ipsi
% %             elseif length(temp_trigger)==0 
% %                     Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(temp_orientation_text_char)=[];
%                     clear trigger_temp trigger_temp_char temp_trigger
%             end % If the trigger is not empty.
%        end % For all trigger types 
%    end % For all sessions
% end % For all subjects 
% 
% %% Make the GA of Base_20_conta, Base_20_ipsi, Base_80_contra, Base_80_ipsi, Test_20_contra, Test_20_ipsi, Test_80_contra, Test_80_ipsi
% 
% 
% 
% %% End of section plotting the N2pc
% 
% % n2pc end
% selected_channels=chan_numbers;
% %selected_channels=[4, 6, 7, 9, 10, 11, 12, 14, 16, 17, 20, 23, 25,26, 28, 29];
% % C5 P3, P5, PO3, O1, OZ, POZ, CPZ, AFZ, FZ, FCZ, C6, P4,P6, PO4, O2
% %% Search for the N1 a negative-going deflection between 150-200 msec. 
% % Define time limits for the peak detection 
% type='mean';
% peak_start_time=160;
% peak_end_time=190;
% time_epoch_start=-200;
% time_epoch_end=60; % TODO to use the new_pre_trigger and new_post_trigger
% startfolder=1;
% name_component = 'N1';
% for jjk=[good_subj_list]  % For every subject - folder
%    Folder_name=temp22{jjk,:};
%    Folder_name_char=char(Folder_name);
%    for mm=1:length(Sessions) % For every condition : Wrong, Correct,HR, LR
%        session_temp=Sessions(mm);
%        session_temp_char=char(session_temp); 
%        for kk=1:length(temp23)
%            trigger_temp=temp23{kk,:}(1:end-4);
%             trigger_temp_char=char(trigger_temp);   
%             % Check if trigger is empty
%             cd(Analyzed_path)
%             cd(Folder_name)
%             cd(session_temp_char)
%             cd('Triggers')
%             temp_trigger=load(temp23{kk,:});
%             if length(temp_trigger)>0
%                 cd(Analyzed_path)
%                 cd(New_saving_path_results)
%                 dataAllchannels=Mean_Subjects.(Folder_name).(session_temp_char).(trigger_temp_char);
%                 if length(dataAllchannels)>0
%                     for cc=[chan_numbers];
%                         chanlocs_temp=chanlocs(cc).labels;
%                         chanlocs_temp_char=char(chanlocs_temp);
%                         temp_chan=dataAllchannels(cc,:);
%                         %Here
%                         [ final_peak_measure ] = RVS_Training_find_mean_ar_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, Fs, timeVec_msec, type );
%                         % Old below 
%                         %[ final_peak_measure ] = RVS_Training_find_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, time_epoch_start, time_epoch_end, fs, timeVec_msec, type );
%                         Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=final_peak_measure;
%                     clear temp_chan chanlocs_temp
%                 end % For channels
%                 else % what to do if there is no data
%                     Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=[];
%                 end % if data not empty
%             elseif length(temp_trigger)==0 
%                     Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=[];
%                     clear trigger_temp trigger_temp_char temp_trigger
%             end % If the trigger is not empty.
%        end % For all trigger types 
%    end % For all sessions
% end % For all subjects 
% cd(Analyzed_path)
% cd(New_saving_path_results)
% mkdir('N1_mean_160-190')
% cd('N1_mean_160-190')
% save Peak_results_N1 Peak_results
% 
% %% Write components to a txt file - NEW
% header_raw={'Subject_Num','_Base_80_20_20','_Base_80_20_80','_Test_80_20_20', '_Test_80_20_80'};
% %header_raw={'Subject_Num','_Base_20L','_Base_50L','_Base_50H','_Base_80H','_Test_20L','_Test_50L','_Test_50H','_Test_80H'};
% 
% write_peak_component_to_txt_1_report_4rewlev( header_raw, startfolder, good_subj_list , temp22, ...
%     selected_channels, Sessions, Peak_results, chanlocs, name_component, temp23, type)
% clear Peak_results
% 
% 
% %% P300 detection 
% % Define time limits for the peak detection 
% name_component = 'P300'
% type='mean';
% peak_start_time=270;
% peak_end_time=500;
% time_start=-200 %
% startfolder=1;
% for jjk=[good_subj_list]  % For every subject - folder
%    Folder_name=temp22{jjk,:};
%    Folder_name_char=char(Folder_name);
%    for kk=1:length(Sessions) % For every condition : Wrong, Correct,HR, LR
%        session_temp=Sessions(kk);
%        session_temp_char=char(session_temp);        
%        for kk=1:length(temp23)
%            trigger_temp=temp23{kk,:}(1:end-4);
%             trigger_temp_char=char(trigger_temp); 
%             %TODO
%             
%             dataAllchannels=Mean_Subjects.(Folder_name).(session_temp_char).(trigger_temp_char);
%             if length(dataAllchannels)>0
%                 for cc=[selected_channels];
%                     chanlocs_temp=chanlocs(cc).labels;
%                     chanlocs_temp_char=char(chanlocs_temp);
%                     temp_chan=dataAllchannels(cc,:);
%                     disp(chanlocs_temp_char)
%                     %Here
%                     [final_peak_measure] = RVS_Training_find_mean_ar_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, Fs, timeVec_msec, type );
%                     %[ final_peak_measure ] = RVS_Training_find_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, time_epoch_start, time_epoch_end, fs, timeVec_msec, type );
%                     Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=final_peak_measure;
%                     clear temp_chan chanlocs_temp
%                 end % For channels
%        else % what to do if there is no data
%            Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=[];
%        end % if data not empty
%        end % For triggers
%    end % For all sessions
% end % For all subjects 
% cd(Analyzed_path)
% cd(New_saving_path_results)
% mkdir('P300_from270ms_500ms')
% cd('P300_from270ms_500ms')
% save Peak_results_P300 Peak_results
% 
% %% Write components to a txt file - NEW
% %header_raw={'Subject_Num','_Base_20L','_Base_50H','_Base_50L','_Base_80H','_Test_20L','_Test_50H','_Test_50L','_Test_80H'};
% 
% write_peak_component_to_txt_1_report_4rewlev( header_raw, startfolder, good_subj_list , temp22, ...
%     selected_channels, Sessions, Peak_results, chanlocs, name_component , temp23, type)
% clear Peak_results 
% %% N2 detection 
% % Define time limits for the peak detection 
% name_component ='N2';
% type='mean';
% peak_start_time=270;
% peak_end_time=300;
% startfolder=1;
% for jjk=[good_subj_list];  % For every subject - folder
%    Folder_name=temp22{jjk,:};
%    Folder_name_char=char(Folder_name);
%    for mm=1:length(Sessions) % For every condition : Wrong, Correct,HR, LR
%        session_temp=Sessions(mm);
%        session_temp_char=char(session_temp); 
%        for kk=1:length(temp23);
%            trigger_temp=temp23{kk,:}(1:end-4);
%             trigger_temp_char=char(trigger_temp);                
%             dataAllchannels=Mean_Subjects.(Folder_name).(session_temp_char).(trigger_temp_char);
%             if length(dataAllchannels)>0
%                 for cc=[selected_channels];
%                     chanlocs_temp=chanlocs(cc).labels;
%                     chanlocs_temp_char=char(chanlocs_temp);
%                     temp_chan=dataAllchannels(cc,:);
%                     %Here
%                     [final_peak_measure] = RVS_Training_find_mean_ar_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, Fs, timeVec_msec, type )
%                     Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=final_peak_measure;
%                 clear temp_chan chanlocs_temp
%             end % For channels
%             else % what to do if there is no data
%            Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=[];
%        end % if data not empty
%        end % For all trigger types 
%    end % For all sessions
% end % For all subjects 
% cd(Analyzed_path)
% cd(New_saving_path_results);
% mkdir('N2_mean')
% cd('N2_mean')
% save Peak_results_N2 Peak_results
% 
% %% Write components to a txt file - NEW
% write_peak_component_to_txt_1_report_4rewlev( header_raw, startfolder, good_subj_list , temp22, ...
%     selected_channels, Sessions, Peak_results, chanlocs, name_component, temp23, type)
% 
% %% P2 detection 
% % Define time limits for the peak detection 
% name_component = 'P2';
% type='mean';
% peak_start_time=220;
% peak_end_time=270;
% startfolder=1;
% for jjk=[good_subj_list]; % For every subject - folder
%    Folder_name=temp22{jjk,:};
%    Folder_name_char=char(Folder_name);
%    for mm=1:length(Sessions); % For every condition : Wrong, Correct,HR, LR
%        session_temp=Sessions(mm);
%        session_temp_char=char(session_temp); 
%        for kk=1:length(temp23);
%            trigger_temp=temp23{kk,:}(1:end-4);
%             trigger_temp_char=char(trigger_temp);  
%             %TODO
%             dataAllchannels=Mean_Subjects.(Folder_name).(session_temp_char).(trigger_temp_char);
%             if length(dataAllchannels)>0
%                 for cc=[selected_channels];
%                     chanlocs_temp=chanlocs(cc).labels;
%                     chanlocs_temp_char=char(chanlocs_temp);
%                     temp_chan=dataAllchannels(cc,:);
%                     %Here
%                     [final_peak_measure] = RVS_Training_find_mean_ar_peak_measure_v2(temp_chan, peak_start_time, peak_end_time, Fs, timeVec_msec, type );
%                     Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=final_peak_measure;
%                 clear temp_chan chanlocs_temp
%             end % For channels
%             else % what to do if there is no data
%            Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp_char)=[];
%        end % if data not empty
%        end % For all trigger types 
%    end % For all sessions
% end % For all subjects 
% cd(Analyzed_path)
% cd(New_saving_path_results)
% save Peak_results_P2 Peak_results
% 
% %% Write components to a txt and an excel file - NEW
% 
% write_peak_component_to_txt_1_report_4rewlev( header_raw, startfolder, good_subj_list , temp22, ...
%     selected_channels, Sessions, Peak_results, chanlocs, name_component, temp23, type )
% 
% % %% Write to a cell, to be a table and then exported to file - to be opened with comma delimiter in excel
% % % Header sent by Thomas
% % %header={'Subject_Num','CPz_Correct_a','CPz_Correct_b', 'CPz_Correct_c',	'CPz_Correct_d', 'CPz_Incorrect_a',	'CPz_Incorrect_b',	'CPz_Incorrect_c',	'CPz_Incorrect_d','CPz_HR_a', 'CPz_HR_b','CPz_HR_c','CPz_HR_d',	'CPz_LR_a',	'CPz_LR_b',	'CPz_LR_c',	'CPz_LR_d'};
% % header_raw={'Subject_Num','_Base_double_report','_Test_double_report'};
% % startfolder=1;
% % good_subj_list =[startfolder 2:6 8 10:12 14 15 18 21:23 25:29 31:33];
% % selected_channels=[14, 18, 15, 6, 23, 10, 8, 25, 9];
% % for cc=[selected_channels]
% %     chanlocs_temp=chanlocs(cc).labels;   
% %     chanlocs_temp_char=char(chanlocs_temp);   
% %     %% Make new header
% %     for hh=2:length(header_raw);
% %         temp=header_raw{1, hh};
% %         temp_new=[chanlocs_temp temp];
% %         header_new{1,1}=header_raw{1,1};
% %         header_new{1,hh}=temp_new;
% %     end
% %     T(1, :)=header_new;
% %     
% %     for jjk=[good_subj_list ]
% %      % For every subject - folder
% %         Folder_name=temp22{jjk,:};
% %         T(jjk+1,1)={Folder_name(5:end)};
% %         column_counter=0;
% %         for kk=1:length(Sessions) % For every condition : Correct,Wrong, HR, LR
% %             session_temp=Sessions(kk);
% %             session_temp_char=char(session_temp); 
% %             column_counter=column_counter+1;
% %             trigger_temp='double_both_corr';
% %             trigger_temp_char=char(trigger_temp);
% %                temp_peak_results=Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp);
% %                T(jjk+1,1+column_counter)=num2cell(temp_peak_results);
% %         end % End for sessions 
% %     end % End for every subject
% %     %% Save the cell into a table and then export to txt, which can be imported in 
% %     % excel as a comma delimiter
% %     Tnew=cell2table(T, 'VariableNames', header_new);
% %     filename_to_save=[chanlocs_temp 'P2_results.txt'];
% %     writetable(Tnew, filename_to_save);
% % end % End for chanlocs
% % 
% % 
% % %% %% Write to a cell, to be a table and then exported to file - to be opened with comma delimiter in excel
% % % Header sent by Thomas
% % %header={'Subject_Num','CPz_Correct_a','CPz_Correct_b', 'CPz_Correct_c',	'CPz_Correct_d', 'CPz_Incorrect_a',	'CPz_Incorrect_b',	'CPz_Incorrect_c',	'CPz_Incorrect_d','CPz_HR_a', 'CPz_HR_b','CPz_HR_c','CPz_HR_d',	'CPz_LR_a',	'CPz_LR_b',	'CPz_LR_c',	'CPz_LR_d'};
% % header_raw={'Subject_Num','_Base_double_report_P2','_Test_double_report_P2'};
% % startfolder=1;
% % good_subj_list =[startfolder 2:6 8 10:12 14 15 18 21:23 25:29 31:33];
% % selected_channels=[14, 18, 15, 6, 23, 10, 8, 25, 9];
% % for cc=[selected_channels]
% %     chanlocs_temp=chanlocs(cc).labels;   
% %     chanlocs_temp_char=char(chanlocs_temp);   
% %     %% Make new header
% %     for hh=2:length(header_raw);
% %         temp=header_raw{1, hh};
% %         temp_new=[chanlocs_temp temp];
% %         header_new{1,1}=header_raw{1,1};
% %         header_new{1,hh}=temp_new;
% %     end
% %     T(1, :)=header_new;
% %     
% %     for jjk=[good_subj_list ]
% %      % For every subject - folder
% %         Folder_name=temp22{jjk,:};
% %         T(jjk+1,1)={Folder_name(5:end)};
% %         column_counter=0;
% %         for kk=1:length(Sessions) % For every condition : Correct,Wrong, HR, LR
% %             session_temp=Sessions(kk);
% %             session_temp_char=char(session_temp); 
% %             column_counter=column_counter+1;
% %             trigger_temp='double_both_corr';
% %             trigger_temp_char=char(trigger_temp);
% %                temp_peak_results=Peak_results.(Folder_name).(session_temp_char).(trigger_temp_char).(chanlocs_temp);
% %                T(jjk+1,1+column_counter)=num2cell(temp_peak_results);
% %         end % End for sessions 
% %     end % End for every subject
% %     %% Save the cell into a table and then export to txt, which can be imported in 
% %     % excel as a comma delimiter
% %     Tnew=cell2table(T, 'VariableNames', header_new);
% %     filename_to_save=[chanlocs_temp '_P2_results.txt'];
% %     writetable(Tnew, filename_to_save);
% % end % End for chanlocs
% 
% % % New way of doing this 
% % %% N2
% % %% N2 detection 
% % % Define time limits for the peak detection 
% % type='min';
% % peak_start_time=270;
% % peak_end_time=300;
% % time_start=-200;
% % type='min';
% % selected_channels=[14, 18, 15, 6, 23, 10, 8, 25, 9];
% % startfolder=1;
% % correct_folders=[startfolder 2:6 8 10:12 14 15 18 21:23 25:29 31:33];
% % trigger_temp='double_both_corr';
% % name_component='N2'
% % 
% % [ Peak_results, Tnew ] = RVS_BaseTest_peak_component_measure(peak_start_time, peak_end_time, ...
% %     time_start, type, selected_channels, startfolder, correct_folders, temp22, Sessions, trigger_temp, name_component )
% toc