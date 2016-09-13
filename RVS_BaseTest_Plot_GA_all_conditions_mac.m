%% To do the grandaverage plots for the RVS_Training
% Maria Stavrinou

% 19 June, based on the RVS_Training_Plot_GA_all_conditions/.m *and #_4_parts_B.m
clear all 
close all
profile on
tic
 
%% Path information
Raw_Path = uigetdir('Select folder with Raw datasets');
if Raw_Path==0
    Raw_Path='/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/';
end

Analyzed_path= uigetdir('Select folder with Raw datasets');
if Analyzed_path == 0
    Analyzed_path = '/Volumes/EEG2_MARIA/EEG/RVS/Analyzed_datasets_B_T/';
end

cd(Raw_Path);
%% Define list of Folders - Subjects  
Name_subject_folder='*_Subject*';
listing_raw=dir(Name_subject_folder);
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
end
clear listing_raw kk

% Define the sessions 
Sessions={'Base', 'Test'};

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
clear kkm


% Define empty structure;
% Initialize the structure to save the data, named dataGA_BT
for  yyy=1:length(Sessions) % 4
    temp_session=Sessions(yyy);
    temp_session_char=char(temp_session);
    for nnn=1:Num_triggers % 4
        trigger_temp=temp23{nnn, :}(1:end-4);
        trigger_temp_char=char(trigger_temp);
        dataGA_BT.(temp_session_char).(trigger_temp_char)=[];
    end
end
clear yyy nnn temp_session temp_session_char trigger_temp trigger_temp_char
% Great!! 

%% Start the mega loop for analysis 
startfolder=5;
for jjk=startfolder:6% length(temp22); % For every subject - folder
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
        for kk=1:Num_triggers % For every condition : Wrong, Correct,HR, LR
            trigger_temp=temp23{kk,:}(1:end-4);
            trigger_temp_char=char(trigger_temp);

            % Go the Analyzed_path_folder for each subject
            % and search for the set files for each AX, AY condition
            cd(Analyzed_path_folder)
            Search_for_folder=['*512_ch_DC_epochs_tr2_' trigger_temp_char '.set'];
            listing_sets=dir(Search_for_folder);
            
%             % Search just one time 
%             if (kk==1 && jjk==startfolder && mm==1)
%                 disp('For one time only')
%                 listing_sets=dir(Search_for_folder);
%                 Num_setfiles=length(listing_sets);
%                 for mmk=1:Num_setfiles
%                     temp_sets{mmk,:}=listing_sets(mmk).name;
%                 end
%                 clear listing_sets mmk
%             end
%             
                
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
                    if (jjk==startfolder & mm==1 & kk==1)
                        Fs=EEG.srate;
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
                    end
                          
                    % Save the EEG.data with smaller epoch
                    data=EEG.data(:, new_pre_trigger_index:new_post_trigger_index, :);  %TODO
%                     nchanGA=size(data, 1);
%                     ntimeGA=size(data, 2); 
%                     ntrigsGA=size(data, 3);

                    % Edw einai ola ta lefta. 
                     dataGA_BT.(session_temp_char).(trigger_temp_char)=cat(3, dataGA_BT.(session_temp_char).(trigger_temp_char), data);
                     clear data
                end % End if we are Right
              
        end % Num_triggers
    end % Sessions
    end % Subject


%Check if we need any of this
clear jjk mm kk gg B AreWeRight data_post_trigger data_pre_trigger find_new_post_trigger find_new_pre_trigger name1 name2 name3a name3b name_data name_file Name_subject_folder new_post_trigger new_pre_trigger part_names part_name_temp_char part_name_temp post_trigger pre_trigger temp_condition temp_condition_char

% Now extract interactively the Grand averages for each condition 
for kk=1:length(Sessions)
    session_temp=Sessions{:,kk}; 
    session_temp_char=char(session_temp);
    for gg=1:Num_triggers
        trigger_name_temp=temp23{gg,:}(1:end-4);
        trigger_name_temp_char=char(trigger_name_temp);
        name_field=[trigger_name_temp_char '_GA'];
        dataGA_BT.(session_temp_char).(name_field)=mean(dataGA_BT.(session_temp_char).(trigger_name_temp_char),3);
    end
end

cd(Analyzed_path)
mkdir('FiguresGA_BT')
cd FiguresGA_BT
save dataGA_BT dataGA_BT
% toc
chanlocs=EEG.chanlocs; 
clear EEG ALLEEG CURRENTSET CURRENTSTUDY LASTCOM STUDY
%% Ploting area
% Plots for Baseline  80-20_80 condition & 80-20-20 condition vs Test 80-20_80 condition & 80-20-20 condition
for cc=[30,37, 38, 47]% 1:length(chanlocs)   
     %for kkm=1:length(Sessions)
        fig=figure; %(cc+length(chanlocs)); 
        set(gca,'colororder',[0 0 1;0 0 1;1 0 0;1 0 0],'nextplot','add');
        set(gca,'fontsize', 16);
         %session_temp=Sessions{:, kkm};
         %session_temp_char=char(session_temp);
        temp_data_to_plot_Base_a=dataGA_BT.Base.double_80_20_80_corr_GA(cc,:);
        temp_data_to_plot_Base_b=dataGA_BT.Base.double_80_20_20_corr_GA(cc,:);
        temp_data_to_plot_Test_a=dataGA_BT.Test.double_80_20_80_corr_GA(cc,:);
        temp_data_to_plot_Test_b=dataGA_BT.Test.double_80_20_20_corr_GA(cc,:);
        
        plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Base_a, 'Linewidth', 2); hold on; 
        plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Base_b, 'Linewidth', 2,'LineStyle', '--'); hold on; 
        plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Test_a, 'Linewidth', 2); hold on; 
        
        plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Test_b, 'Linewidth', 2,'LineStyle', '--');  

        legend('80-20-80 Base', '80-20-20 Base', '80-20-80 Test', '80-20-20 Test');
        title_text=[chanlocs(cc).labels ' Base vs Test' ]
        title(title_text);
        axis('tight');
        SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
        text(0,max(temp_data_to_plot_Base), 'Stim');
        temp_save_name_fig=[chanlocs(cc).labels '80_20_BT_GA' ];
        saveas(fig, temp_save_name_fig, 'png');
        saveas(fig, temp_save_name_fig, 'fig');
        clear temp_save_name
end

%% Plot 2: Base vs Test 80_20_80 

for cc=[30,37, 38, 47]% 1:length(chanlocs)   
     %for kkm=1:length(Sessions)
        fig=figure; %(cc+length(chanlocs)); 
        set(gca,'colororder',[0 0 1;1 0 0],'nextplot','add');
        set(gca,'fontsize', 16);
         %session_temp=Sessions{:, kkm};
         %session_temp_char=char(session_temp);
        temp_data_to_plot_Base_a=dataGA_BT.Base.double_80_20_80_corr_GA(cc,:);
        temp_data_to_plot_Test_a=dataGA_BT.Test.double_80_20_80_corr_GA(cc,:);
      
        plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Base_a, 'Linewidth', 2); hold on;  
        plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Test_a, 'Linewidth', 2); 

        legend('80-20-80 Base', '80-20-80 Test');
        title_text=[chanlocs(cc).labels ' 80-20-80 Base vs Test' ]
        title(title_text);
        axis('tight');
        SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
        text(0,max(temp_data_to_plot_Base), 'Stim');
        temp_save_name_fig=[chanlocs(cc).labels '80_20_80_BT_GA' ];
        saveas(fig, temp_save_name_fig, 'png');
        saveas(fig, temp_save_name_fig, 'fig');
        clear temp_save_name
    end

%% Plot 3, 80_20_20 Base vs Test 

for cc=[30,37, 38, 47]% 1:length(chanlocs)   
        fig=figure; %(cc+length(chanlocs)); 
        set(gca,'colororder',[0 0 1;1 0 0],'nextplot','add');
        set(gca,'fontsize', 16);

        temp_data_to_plot_Base_b=dataGA_BT.Base.double_80_20_20_corr_GA(cc,:);
        temp_data_to_plot_Test_b=dataGA_BT.Test.double_80_20_20_corr_GA(cc,:);
        
        
        plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Base_b, 'Linewidth', 2); hold on; 
        plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Test_b, 'Linewidth', 2);  

        legend('80-20-20 Base', '80-20-20 Test');
        title_text=[chanlocs(cc).labels ' 80-20-20 Base vs Test' ]
        title(title_text);
        axis('tight');
        SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
        text(0,max(temp_data_to_plot_Base), 'Stim');
        temp_save_name_fig=[chanlocs(cc).labels '80_20_20_BT_GA' ];
        saveas(fig, temp_save_name_fig, 'png');
        saveas(fig, temp_save_name_fig, 'fig');
        clear temp_save_name
end

% % % Plots for HR- LR
% for cc=[30, 37, 38, 47]% 1:length(chanlocs)   
%     kkm=2
%         fig=figure; %(cc+length(chanlocs)); 
%         set(gca,'colororder',[0 0 1;1 0 0; 1 0 1; 0 1 1; 0 0 1;1 0 0; 1 0 1; 0 1 1],'nextplot','add');
%         set(gca,'fontsize', 16);
%         temp_condition=conditions(kkm);
%         temp_condition_char=char(temp_condition);
%         
%         temp_condition_LR=conditions(kkm+1);
%         temp_condition_LR_char=char(temp_condition_LR);
%         
%         temp_data_to_plot_a=detrend(dataGA.(temp_condition_char).part_a_GA(cc,:));
%         temp_data_to_plot_b=detrend(dataGA.(temp_condition_char).part_b_GA(cc,:));
%         temp_data_to_plot_c=detrend(dataGA.(temp_condition_char).part_c_GA(cc,:));
%         temp_data_to_plot_d=detrend(dataGA.(temp_condition_char).part_d_GA(cc,:));
%         
%         temp_LR_data_part_a=detrend(dataGA.(temp_condition_LR_char).part_a_GA(cc,:));
%         temp_LR_data_part_b=detrend(dataGA.(temp_condition_LR_char).part_b_GA(cc,:));
%         temp_LR_data_part_c=detrend(dataGA.(temp_condition_LR_char).part_c_GA(cc,:));
%         temp_LR_data_part_d=detrend(dataGA.(temp_condition_LR_char).part_d_GA(cc,:));
%         
%         
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_a, 'Linewidth', 2); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_b, 'Linewidth', 2); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_c, 'Linewidth', 2); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_d, 'Linewidth', 2); hold on; 
%         
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_LR_data_part_a, 'Linewidth', 2, 'LineStyle', '--'); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_LR_data_part_b, 'Linewidth', 2, 'LineStyle', '--'); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_LR_data_part_c, 'Linewidth', 2, 'LineStyle', '--'); hold on;
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_LR_data_part_d, 'Linewidth', 2, 'LineStyle', '--');  
%         
%         legend('part a HR','part b HR', 'part c HR', 'part d HR', 'part a LR','part b LR', 'part c LR', 'part d LR');
%         title_text=[chanlocs(cc).labels '- HR - LR' ];
%         title(title_text);
%         axis('tight');
%         SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
%         text(0,max(temp_data_to_plot_a), 'Feedback');
%         temp_save_name_fig=[chanlocs(cc).labels '_RVS_GA_LR-HR_4_parts'];
%         saveas(fig, temp_save_name_fig, 'png');
%         saveas(fig, temp_save_name_fig, 'fig');
%         clear temp_save_name
%     
% end
% 
% 
% % Plot only for Day 1 
% for cc=[30, 37, 38, 47]% 1:length(chanlocs)   
%     kkm=2
%         fig=figure; %(cc+length(chanlocs)); 
%         set(gca,'colororder',[0 0 1;0 1 1],'nextplot','add');
%         set(gca,'fontsize', 16);
%         temp_condition=conditions(kkm);
%         temp_condition_char=char(temp_condition);
%         
%         temp_condition_LR=conditions(kkm+1);
%         temp_condition_LR_char=char(temp_condition_LR);
%         
%         temp_data_to_plot_a=detrend(dataGA.(temp_condition_char).part_a_GA(cc,:));
%         temp_data_to_plot_b=detrend(dataGA.(temp_condition_char).part_b_GA(cc,:));
%         
%         
%         temp_LR_data_part_a=detrend(dataGA.(temp_condition_LR_char).part_a_GA(cc,:));
%         temp_LR_data_part_b=detrend(dataGA.(temp_condition_LR_char).part_b_GA(cc,:));
%         
%         
%         
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_a, 'Linewidth', 2); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_b, 'Linewidth', 2); hold on; 
%         
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_LR_data_part_a, 'Linewidth', 2, 'LineStyle', '--'); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_LR_data_part_b, 'Linewidth', 2, 'LineStyle', '--');  
%         
%         
%         legend('part a HR','part b HR', 'part a LR','part b LR');
%         title_text=[chanlocs(cc).labels '- HR - LR - day 1' ];
%         title(title_text);
%         axis('tight');
%         SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
%         text(0,max(temp_data_to_plot_a), 'Feedback');
%         temp_save_name_fig=[chanlocs(cc).labels '_RVS_GA_LR-HR_2_parts-day1'];
%         saveas(fig, temp_save_name_fig, 'png');
%         saveas(fig, temp_save_name_fig, 'fig');
%         clear temp_save_name
%     
% end

toc
