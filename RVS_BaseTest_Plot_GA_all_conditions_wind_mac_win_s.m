%% Program to do the grandaverage plots for the RVS_Training
% Maria Stavrinou. 

% 19 June, based on the RVS_Training_Plot_GA_all_conditions/.m *and #_4_parts_B.m
%Made the 4 reward levels and the plots showing 80-20 in
%FiguresGA_BT_4rewlevels
% 20 September 2016. 
% 29.03.2017
clear all 
close all
Raw_path='Y:\Prosjekt\RVS_43_subjects\Raw_datasets\DataRVS\';
Analyzed_path='Y:\Prosjekt\RVS_43_subjects\Analyzed_datasets\';


cd(Raw_path)
% Define list of folders 
listing_raw=dir('RVS_Subject*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 end

Sessions={'Base', 'Test'};

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
% 4. For double_condition, 1 report, 80_20_80, 80_20_20: listing_raw=dir('double_80_20_*0_corr.txt'); trigger_type='80_20_8020';
% 5. For N2pc related analysis, with left and right visual hemifield
% separated we need to write:
% listing_raw=dir('double_80_20_*0_*t_corr.txt'); trigger_type='80_20_8020';
% Text_to_search for. How we will name the folder to save
% results,figures,variables,etc. 

%TODO change 1
trigger_type='double_none_corr';
% TODO change 2
% Write what the dir type can write to find out the triggers
listing_raw=dir('double_none_corr.txt');
Num_triggers=length(listing_raw);
for kkm=1:Num_triggers
    temp23{kkm,:}=listing_raw(kkm).name;
end
clear kkm

%% Make a folder to save the results in the Analyzed_path
cd(Analyzed_path)
% TODO change the folder name to be created
% Name for the folder to save the results. 
New_saving_path_results=['FiguresGA_BT_all' trigger_type date];
mkdir(New_saving_path_results)

% Savename for the matlab variable with the grandaverage.
savename=['dataGA_BT_' trigger_type];

%% Define electrodes of interest
chan_numbers=[1:66];

%% Define empty structure;
% Initialize the structure to save the data, named dataGA_BT
% TODO: change the name here: 
% 1. double report: dataGA_BT 
% 2. dataGA_BT is going to be a general name 
% - I decided not to change the name here. 
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

%%
% Define which subjects are good and which are bad. 
%bad_subject_list=[7, 9, 13, 16, 17, 19, 20, 24, 26, 30]; old for 33
%subjects only 
bad_subject_list=[7, 9, 13, 16, 17, 19, 20, 24, 30, 34, 36, 40]; % updated 21.3.2017  209 should be inside as it has nothing 80_20_20
% Old correct_folders=[startfolder 2:6 8:12 14 15 18 21:29 31:33];
good_subj_list=[]; 
for kk=1:Num_folders, 
    if ~ismember(kk, bad_subject_list), 
        good_subj_list=[good_subj_list kk]; 
    end; 
end
clear kk 

%% Start the mega loop for analysis 
startfolder=1;
for mkk=1:length(good_subj_list)
    jjk=good_subj_list(mkk);
    Folder_name=temp22{jjk,:};
    fprintf(' ***  Working on subject %s: %s\n', num2str(mkk), Folder_name)
    Analyzed_path_folder=[Analyzed_path temp22{jjk,:} '\'];
    Raw_path_folder=[Raw_path temp22{jjk,:} '\'];
    cd(Raw_path_folder);
    for mm=1:length(Sessions)
        session_temp=Sessions{:,mm}; %%% !!!!
        session_temp_char=char(session_temp);
        Subject_filename_session=[Folder_name '_' session_temp];
        
        % Define the new paths            
        Analyzed_path_folder=[Analyzed_path temp22{jjk,:} '\' session_temp ];
        Raw_path_folder=[Raw_path temp22{jjk,:} '\' temp22{jjk,:} '\' session_temp];
        
        % Loop for every trigger type we are going to use
        for kk=1:Num_triggers % For every condition : Wrong, Correct,HR, LR
            trigger_temp=temp23{kk,:}(1:end-4);
            trigger_temp_char=char(trigger_temp);
            cd(Analyzed_path_folder)
            cd('Triggers')
            load_trig=load(temp23{kk,:});
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
                        disp(['Working on file ' listing_sets.name ' for trigger type: ' trigger_temp_char]);
                        EEG = pop_loadset('filename',name_file,'filepath',Analyzed_path_folder);
                        EEG = eeg_checkset( EEG );
                        eeglab redraw

                        % Get the data and the dimensions of it. 
                        % Select smaller timepoints, run only once, at start!
                        if (jjk==startfolder & mm==1 && kk==1)
                        Fs=EEG.srate;
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
    %                     nchanGA=size(data, 1);
    %                     ntimeGA=size(data, 2); 
    %                     ntrigsGA=size(data, 3);

                        % Edw einai ola ta lefta. 
                         dataGA_BT.(session_temp_char).(trigger_temp_char)=cat(3, dataGA_BT.(session_temp_char).(trigger_temp_char), data);
                         clear data
                end % End if we are Right
            end % If there is trigger
        end % Num_triggers
    end % Sessions
    end % Subject


%Check if we need any of this
% clear jjk mm kk gg B AreWeRight data_post_trigger ...
%     data_pre_trigger find_new_post_trigger find_new_pre_trigger ...
%     name1 name2 name3a name3b name_data name_file ...
%     Name_subject_folder ...
%     part_names part_name_temp_char part_name_temp ...
%     post_trigger ...
%     pre_trigger ...
%     temp_condition ...
%     temp_condition_char

% Now extract interactively the Grand averages for each condition 
for kk=1:length(Sessions)
    session_temp=Sessions{:,kk}; 
    session_temp_char=char(session_temp);
    % For each session separately
    for gg=1:Num_triggers
        %Get the name of the trigger without the extension '.txt'
        trigger_name_temp=temp23{gg,:}(1:end-4); 
        % Have it in char
        trigger_name_temp_char=char(trigger_name_temp);
        % This name will define the field of the structure with the  average
        % results
        name_field=[trigger_name_temp_char '_GA'];
        dataGA_BT.(session_temp_char).(name_field)=mean(dataGA_BT.(session_temp_char).(trigger_name_temp_char),3);
    end
end
%% Get the channels names before you delete the EEG structure
chanlocs=EEG.chanlocs; 
%clear EEG ALLEEG CURRENTSET CURRENTSTUDY LASTCOM STUDY

%% Make a folder to save the results in the Analyzed_path
% TODO. Change here
cd(Analyzed_path)
cd(New_saving_path_results)
eval(['save ' savename ' dataGA_BT'])
save timeVec_msec timeVec_msec
save chanlocs chanlocs

%% Ploting area %TODO to make it as functions

%% Plot double report - or one-corrct from the double condition
selected_channels=[21, 22, 26, 27, 29, 30, 32, 37, 38, 47, 51, 58, 59, 63, 64]; % for B-T
for cc=[selected_channels]% 1:length(chanlocs)  
    
     %for kkm=1:length(Sessions)
        fig=figure; %(cc+length(chanlocs)); 
        %set(gca,'colororder',[0 0 1;0 0 1;0 0 1; 1 0 0;1 0 0;1 0 0],'nextplot','add'); % green 010
        set(gca,'colororder',[0 0 1; 1 0 0],'nextplot','add'); % green 010
        set(gca,'fontsize', 16);
         %session_temp=Sessions{:, kkm};
         %session_temp_char=char(session_temp);
        temp_data_to_plot_Base_double=dataGA_BT.Base.double_none_corr_GA(cc,:);
        %temp_data_to_plot_Base_one=dataGA_BT.Base.double_one_corr_GA(cc,:);
        %temp_data_to_plot_Base_none=dataGA_BT.Base.double_none_corr_GA(cc,:);
        
        temp_data_to_plot_Test_double=dataGA_BT.Test.double_none_corr_GA(cc,:);
        %temp_data_to_plot_Test_one=dataGA_BT.Test.double_one_corr_GA(cc,:);
        %temp_data_to_plot_Test_none=dataGA_BT.Test.double_none_corr_GA(cc,:);
        
        plot(timeVec_msec, temp_data_to_plot_Base_double, 'Linewidth', 2); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Base_one, 'Linewidth', 2,'LineStyle', '--'); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Base_none, 'Linewidth', 2,'LineStyle', '-.'); hold on; 
        plot(timeVec_msec, temp_data_to_plot_Test_double, 'Linewidth', 2, 'LineStyle', '--'); 
        
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Test_one, 'Linewidth', 2,'LineStyle', '--');  
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Test_none, 'Linewidth', 2,'LineStyle', '-.');  
        legend('double none correct Base', 'double none correct Test', 'Location', 'best');
        %legend('double report Base', 'one Base', 'none Base', 'double report Test', 'one Test', 'none Test');
        title_text=[chanlocs(cc).labels ' Base vs Test' ]
        title(title_text);
        axis('tight');
        SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
%         text(0,max(temp_data_to_plot_Base_a), 'Stim');
        temp_save_name_fig=[chanlocs(cc).labels 'double_none_correct_BT_GA' ];
        saveas(fig, temp_save_name_fig, 'png');
        saveas(fig, temp_save_name_fig, 'fig');
        clear temp_save_name
    
end


%% Base-test double report, butterfly plot **new sweet march 17**
selected_channels=[21, 22, 26, 27, 29, 30, 32, 37, 38, 47, 51, 58, 59, 63, 64]; % for B-T
% Start one figure only
fig=figure; %(cc+length(chanlocs)); 
set(gca,'fontsize', 16);
for cc=1:64%[selected_channels]% 1:length(chanlocs)  
    if cc~=55
     %for kkm=1:length(Sessions)     
        set(gca,'colororder',[0 0 1;1 0 0],'nextplot','add'); % green 010
         %session_temp=Sessions{:, kkm};
         %session_temp_char=char(session_temp);
        temp_data_to_plot_Base_double=dataGA_BT.Base.double_none_corr_GA(cc,:);
        %temp_data_to_plot_Base_one=dataGA_BT.Base.double_one_corr_GA(cc,:);
        %temp_data_to_plot_Base_none=dataGA_BT.Base.double_none_corr_GA(cc,:);
        
        temp_data_to_plot_Test_double=dataGA_BT.Test.double_none_corr_GA(cc,:);
        %temp_data_to_plot_Test_one=dataGA_BT.Test.double_one_corr_GA(cc,:);
        %temp_data_to_plot_Test_none=dataGA_BT.Test.double_none_corr_GA(cc,:);
        
        plot(timeVec_msec, temp_data_to_plot_Base_double, 'Linewidth', 2); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Base_one, 'Linewidth', 2,'LineStyle', '--'); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Base_none, 'Linewidth', 2,'LineStyle', '-.'); hold on; 
        plot(timeVec_msec, temp_data_to_plot_Test_double, 'Linewidth', 2, 'LineStyle', '--'); hold on;
        
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Test_one, 'Linewidth', 2,'LineStyle', '--');  
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Test_none, 'Linewidth', 2,'LineStyle', '-.');  

        %legend('double report Base', 'one Base', 'none Base', 'double report Test', 'one Test', 'none Test');
        axis('tight');
    
%         text(0,max(temp_data_to_plot_Base_a), 'Stim');
    end
end

legend('double none correct Base', 'double none correct Test', 'Location', 'best');
title_text=[' Base vs Test no report GA' ]
title(title_text);

SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
temp_save_name_fig=['Double_no_report_butterfly_BT_GA_64_channels' ];
saveas(fig, temp_save_name_fig, 'png');
saveas(fig, temp_save_name_fig, 'fig');

clear temp_save_name
% 
% % Plot double - one -one report from the doubl condition
% for cc=[5, 6, 8, 9, 10, 12, 14, 15, 18, 19, 22, 23, 25]% 1:length(chanlocs)   
%      %for kkm=1:length(Sessions)
%         fig=figure; %(cc+length(chanlocs)); 
%         set(gca,'colororder',[0 0 1;0 0 1;0 0 1; 1 0 0;1 0 0;1 0 0],'nextplot','add'); % green 010
%         set(gca,'fontsize', 16);
%          %session_temp=Sessions{:, kkm};
%          %session_temp_char=char(session_temp);
%         temp_data_to_plot_Base_double=dataGA_BT.Base.double_both_corr_GA(cc,:);
%         temp_data_to_plot_Base_one=dataGA_BT.Base.double_one_corr_GA(cc,:);
%         temp_data_to_plot_Base_none=dataGA_BT.Base.double_none_corr_GA(cc,:);
%         
%         temp_data_to_plot_Test_double=dataGA_BT.Test.double_both_corr_GA(cc,:);
%         temp_data_to_plot_Test_one=dataGA_BT.Test.double_one_corr_GA(cc,:);
%         temp_data_to_plot_Test_none=dataGA_BT.Test.double_none_corr_GA(cc,:);
%         
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Base_double, 'Linewidth', 2); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Base_one, 'Linewidth', 2,'LineStyle', '--'); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Base_none, 'Linewidth', 2,'LineStyle', '-.'); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Test_double, 'Linewidth', 2); hold on; 
%         
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Test_one, 'Linewidth', 2,'LineStyle', '--');  
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Test_none, 'Linewidth', 2,'LineStyle', '-.');  
% 
%         legend('double report Base', 'one Base', 'none Base', 'double report Test', 'one Test', 'none Test');
%         title_text=[chanlocs(cc).labels ' Base vs Test' ]
%         title(title_text);
%         axis('tight');
%         SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
% %         text(0,max(temp_data_to_plot_Base_a), 'Stim');
%         temp_save_name_fig=[chanlocs(cc).labels 'double_all_repo_BT_GA' ];
%         saveas(fig, temp_save_name_fig, 'png');
%         saveas(fig, temp_save_name_fig, 'fig');
%         clear temp_save_name
% end

% %Plot double dondition, single report base/test 4 reward levels
% selected_channels=[21 22 26 27 29 30 32 37 38 47 51 58 63 64];
% dataGA_BT_4rewlev=dataGA_BT;
% for cc=[21 22 26 27 29 30 32 37 38 47 51 58 63 64];% 1:length(chanlocs)   
%      for kkm=1:length(Sessions)
%         fig=figure; %(cc+length(chanlocs)); 
%         set(gca,'colororder',[0 0 1;1 0 0;0 0 1; 1 0 0],'nextplot','add'); % green 010
%         set(gca,'fontsize', 16);
%          session_temp=Sessions{:, kkm};
%          session_temp_char=char(session_temp);
%         temp_data_to_plot_Base_double_one_80H=dataGA_BT_4rewlev.Base.double_one_80H_corr_GA(cc,:);
%         temp_data_to_plot_Base_double_one_20L=dataGA_BT_4rewlev.Base.double_one_20L_corr_GA(cc,:);
%         temp_data_to_plot_Test_double_one_80H=dataGA_BT_4rewlev.Test.double_one_80H_corr_GA(cc,:);
%         temp_data_to_plot_Test_double_one_20L=dataGA_BT_4rewlev.Test.double_one_20L_corr_GA(cc,:);
%         
%         plot(timeVec_msec, temp_data_to_plot_Base_double_one_80H, 'Linewidth', 2); hold on; 
%         plot(timeVec_msec, temp_data_to_plot_Base_double_one_20L, 'Linewidth', 2, 'LineStyle', '--'); hold on; 
%         plot(timeVec_msec, temp_data_to_plot_Test_double_one_80H, 'Linewidth', 2); hold on; 
%         plot(timeVec_msec, temp_data_to_plot_Test_double_one_20L, 'Linewidth', 2, 'LineStyle', '--'); 
% 
%         legend('80H Base','20L Base','80H Test', '20L Test', 'Location', 'Southeast');
%         title_text=[chanlocs(cc).labels ' Base vs Test' ]
%         title(title_text);
%         axis('tight');
%         SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
%         %text(0,max(temp_data_to_plot_Base_double_one_80H), 'Stim');
%         temp_save_name_fig=[chanlocs(cc).labels 'double_one_4rewlev_GA' ];
%         saveas(fig, temp_save_name_fig, 'png');
%         saveas(fig, temp_save_name_fig, 'fig');
%         clear temp_save_name
% end
% end


% %% Plot double report B T ,plot  all 4 reward levels (is not run on September 19).
% % Found [5, 6, 7, 8, 9, 10, 12, 14, 15, 18, 19, 22, 23, 24, 25]
% % New selection 6,10, 11, 12, 14, 16, 17, 20, 21, 25,29 
% for cc=[6, 7, 9, 10, 11, 12, 14, 16, 17, 20, 23, 25, 28, 29]% 1:length(chanlocs)   
%      %for kkm=1:length(Sessions)
%         fig=figure; %(cc+length(chanlocs)); 
%         set(gca,'colororder',[0 0 1;0 0 1;0 0 1; 0 0 1;1 0 0;1 0 0;1 0 0;1 0 0],'nextplot','add'); % green 010
%         set(gca,'fontsize', 16);
%          %session_temp=Sessions{:, kkm};
%          %session_temp_char=char(session_temp);
%         temp_data_to_plot_Base_double_one_80H=dataGA_BT_4rewlev.Base.double_one_80H_corr_4rewlevGA(cc,:);
%         temp_data_to_plot_Base_double_one_20L=dataGA_BT_4rewlev.Base.double_one_20L_corr_4rewlevGA(cc,:);
%         temp_data_to_plot_Base_double_one_50H=dataGA_BT_4rewlev.Base.double_one_50H_corr_4rewlevGA(cc,:);
%         temp_data_to_plot_Base_double_one_50L=dataGA_BT_4rewlev.Base.double_one_50L_corr_4rewlevGA(cc,:);
% 
%         
%         temp_data_to_plot_Test_double_one_80H=dataGA_BT_4rewlev.Test.double_one_80H_corr_4rewlevGA(cc,:);
%         temp_data_to_plot_Test_double_one_20L=dataGA_BT_4rewlev.Test.double_one_20L_corr_4rewlevGA(cc,:);
%         temp_data_to_plot_Test_double_one_50H=dataGA_BT_4rewlev.Test.double_one_50H_corr_4rewlevGA(cc,:);
%         temp_data_to_plot_Test_double_one_50L=dataGA_BT_4rewlev.Test.double_one_50L_corr_4rewlevGA(cc,:);
% 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Base_double_one_80H, 'Linewidth', 2); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Base_double_one_50H, 'Linewidth', 2, 'LineStyle', '-.'); hold on;
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Base_double_one_50L, 'Linewidth', 2, 'LineStyle', ':'); hold on;
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Base_double_one_20L, 'Linewidth', 2, 'LineStyle', '--'); hold on;
%         
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Test_double_one_80H, 'Linewidth', 2); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Test_double_one_50H, 'Linewidth', 2, 'LineStyle', '-.'); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Test_double_one_50L, 'Linewidth', 2, 'LineStyle', ':'); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Test_double_one_20L, 'Linewidth', 2, 'LineStyle', '--'); 
%         
%         legend('80H Base','50H Base', '50L Base','20L Base', '80H Test', '50H Test', '50L Test', '20L Test');
%         title_text=[chanlocs(cc).labels ' Base vs Test' ]
%         title(title_text);
%         axis('tight');
%         SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
% %         text(0,max(temp_data_to_plot_Base_a), 'Stim');
%         temp_save_name_fig=[chanlocs(cc).labels 'double_one_4rewlev_all_BT_GA' ];
%         saveas(fig, temp_save_name_fig, 'png');
%         saveas(fig, temp_save_name_fig, 'fig');
%         clear temp_save_name
% end

% % % Plots for Baseline  80-20_80 condition & 80-20-20 condition vs Test 80-20_80 condition & 80-20-20 condition
% cd(Analyzed_path)
% cd(New_saving_path_results)
% for cc=chan_numbers; % 1:length(chanlocs)   
% %      %for kkm=1:length(Sessions)
%         fig=figure; %(cc+length(chanlocs)); 
%         set(gca,'colororder',[0 0 1;0 0 1;1 0 0;1 0 0],'nextplot','add');
%         set(gca,'fontsize', 16);
%          %session_temp=Sessions{:, kkm};
%          %session_temp_char=char(session_temp);
%         temp_data_to_plot_Base_a=dataGA_BT.Base.double_80_20_80_corr_GA(cc,:);
%         temp_data_to_plot_Base_b=dataGA_BT.Base.double_80_20_20_corr_GA(cc,:);
%         temp_data_to_plot_Test_a=dataGA_BT.Test.double_80_20_80_corr_GA(cc,:);
%         temp_data_to_plot_Test_b=dataGA_BT.Test.double_80_20_20_corr_GA(cc,:);
%         
%         plot(timeVec_msec, temp_data_to_plot_Base_a, 'Linewidth', 2); hold on; 
%         plot(timeVec_msec, temp_data_to_plot_Base_b, 'Linewidth', 2,'LineStyle', '--'); hold on; 
%         plot(timeVec_msec, temp_data_to_plot_Test_a, 'Linewidth', 2); hold on;   
%         plot(timeVec_msec, temp_data_to_plot_Test_b, 'Linewidth', 2,'LineStyle', '--');  
% 
%         legend('80-20-80 Base', '80-20-20 Base', '80-20-80 Test', '80-20-20 Test', 'Location','southeast' );
%         title_text=[chanlocs(cc).labels ' Base vs Test' ]
%         title(title_text);
%         axis('tight');
%         SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
% %         text(0,max(temp_data_to_plot_Base_a), 'Stim');
%         temp_save_name_fig=[chanlocs(cc).labels '80_20_BT_GA' ];
%         saveas(fig, temp_save_name_fig, 'png');
%         saveas(fig, temp_save_name_fig, 'fig');
%         clear temp_save_name
% end
% 
% % %% Plot 2: Base vs Test 80_20_80 
% % 
% % for cc=[6, 9, 10, 12, 14, 15, 18, 19, 23]% 1:length(chanlocs)   
% %      %for kkm=1:length(Sessions)
% %         fig=figure; %(cc+length(chanlocs)); 
% %         set(gca,'colororder',[0 0 1;1 0 0],'nextplot','add');
% %         set(gca,'fontsize', 16);
% %          %session_temp=Sessions{:, kkm};
% %          %session_temp_char=char(session_temp);
% %         temp_data_to_plot_Base_a=dataGA_BT.Base.double_80_20_80_corr_GA(cc,:);
% %         temp_data_to_plot_Test_a=dataGA_BT.Test.double_80_20_80_corr_GA(cc,:);
% %       
% %         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Base_a, 'Linewidth', 2); hold on;  
% %         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Test_a, 'Linewidth', 2); 
% % 
% %         legend('80-20-80 Base', '80-20-80 Test');
% %         title_text=[chanlocs(cc).labels ' 80-20-80 Base vs Test' ]
% %         title(title_text);
% %         axis('tight');
% %         SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
% %         text(0,max(temp_data_to_plot_Base), 'Stim');
% %         temp_save_name_fig=[chanlocs(cc).labels '80_20_80_BT_GA' ];
% %         saveas(fig, temp_save_name_fig, 'png');
% %         saveas(fig, temp_save_name_fig, 'fig');
% %         clear temp_save_name
% %     end
% % 
% % %% Plot 3, 80_20_20 Base vs Test 
% % 
% % for cc=[6, 9, 10, 12, 14, 15, 18, 19, 23]% 1:length(chanlocs)   
% %         fig=figure; %(cc+length(chanlocs)); 
% %         set(gca,'colororder',[0 0 1;1 0 0],'nextplot','add');
% %         set(gca,'fontsize', 16);
% % 
% %         temp_data_to_plot_Base_b=dataGA_BT.Base.double_80_20_20_corr_GA(cc,:);
% %         temp_data_to_plot_Test_b=dataGA_BT.Test.double_80_20_20_corr_GA(cc,:);
% %         
% %         
% %         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Base_b, 'Linewidth', 2); hold on; 
% %         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_Test_b, 'Linewidth', 2);  
% % 
% %         legend('80-20-20 Base', '80-20-20 Test');
% %         title_text=[chanlocs(cc).labels ' 80-20-20 Base vs Test' ]
% %         title(title_text);
% %         axis('tight');
% %         SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
% %         %text(0,max(temp_data_to_plot_Base), 'Stim');
% %         temp_save_name_fig=[chanlocs(cc).labels '80_20_20_BT_GA' ];
% %         saveas(fig, temp_save_name_fig, 'png');
% %         saveas(fig, temp_save_name_fig, 'fig');
% %         clear temp_save_name
% % end
% 
% % % % Plots for HR- LR
% % for cc=[30, 37, 38, 47]% 1:length(chanlocs)   
% %     kkm=2
% %         fig=figure; %(cc+length(chanlocs)); 
% %         set(gca,'colororder',[0 0 1;1 0 0; 1 0 1; 0 1 1; 0 0 1;1 0 0; 1 0 1; 0 1 1],'nextplot','add');
% %         set(gca,'fontsize', 16);
% %         temp_condition=conditions(kkm);
% %         temp_condition_char=char(temp_condition);
% %         
% %         temp_condition_LR=conditions(kkm+1);
% %         temp_condition_LR_char=char(temp_condition_LR);
% %         
% %         temp_data_to_plot_a=detrend(dataGA.(temp_condition_char).part_a_GA(cc,:));
% %         temp_data_to_plot_b=detrend(dataGA.(temp_condition_char).part_b_GA(cc,:));
% %         temp_data_to_plot_c=detrend(dataGA.(temp_condition_char).part_c_GA(cc,:));
% %         temp_data_to_plot_d=detrend(dataGA.(temp_condition_char).part_d_GA(cc,:));
% %         
% %         temp_LR_data_part_a=detrend(dataGA.(temp_condition_LR_char).part_a_GA(cc,:));
% %         temp_LR_data_part_b=detrend(dataGA.(temp_condition_LR_char).part_b_GA(cc,:));
% %         temp_LR_data_part_c=detrend(dataGA.(temp_condition_LR_char).part_c_GA(cc,:));
% %         temp_LR_data_part_d=detrend(dataGA.(temp_condition_LR_char).part_d_GA(cc,:));
% %         
% %         
% %         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_a, 'Linewidth', 2); hold on; 
% %         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_b, 'Linewidth', 2); hold on; 
% %         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_c, 'Linewidth', 2); hold on; 
% %         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_d, 'Linewidth', 2); hold on; 
% %         
% %         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_LR_data_part_a, 'Linewidth', 2, 'LineStyle', '--'); hold on; 
% %         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_LR_data_part_b, 'Linewidth', 2, 'LineStyle', '--'); hold on; 
% %         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_LR_data_part_c, 'Linewidth', 2, 'LineStyle', '--'); hold on;
% %         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_LR_data_part_d, 'Linewidth', 2, 'LineStyle', '--');  
% %         
% %         legend('part a HR','part b HR', 'part c HR', 'part d HR', 'part a LR','part b LR', 'part c LR', 'part d LR');
% %         title_text=[chanlocs(cc).labels '- HR - LR' ];
% %         title(title_text);
% %         axis('tight');
% %         SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
% %         text(0,max(temp_data_to_plot_a), 'Feedback');
% %         temp_save_name_fig=[chanlocs(cc).labels '_RVS_GA_LR-HR_4_parts'];
% %         saveas(fig, temp_save_name_fig, 'png');
% %         saveas(fig, temp_save_name_fig, 'fig');
% %         clear temp_save_name
% %     
% % end
% % 
% % 
% % % Plot only for Day 1 
% % for cc=[30, 37, 38, 47]% 1:length(chanlocs)   
% %     kkm=2
% %         fig=figure; %(cc+length(chanlocs)); 
% %         set(gca,'colororder',[0 0 1;0 1 1],'nextplot','add');
% %         set(gca,'fontsize', 16);
% %         temp_condition=conditions(kkm);
% %         temp_condition_char=char(temp_condition);
% %         
% %         temp_condition_LR=conditions(kkm+1);
% %         temp_condition_LR_char=char(temp_condition_LR);
% %         
% %         temp_data_to_plot_a=detrend(dataGA.(temp_condition_char).part_a_GA(cc,:));
% %         temp_data_to_plot_b=detrend(dataGA.(temp_condition_char).part_b_GA(cc,:));
% %         
% %         
% %         temp_LR_data_part_a=detrend(dataGA.(temp_condition_LR_char).part_a_GA(cc,:));
% %         temp_LR_data_part_b=detrend(dataGA.(temp_condition_LR_char).part_b_GA(cc,:));
% %         
% %         
% %         
% %         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_a, 'Linewidth', 2); hold on; 
% %         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_b, 'Linewidth', 2); hold on; 
% %         
% %         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_LR_data_part_a, 'Linewidth', 2, 'LineStyle', '--'); hold on; 
% %         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_LR_data_part_b, 'Linewidth', 2, 'LineStyle', '--');  
% %         
% %         
% %         legend('part a HR','part b HR', 'part a LR','part b LR');
% %         title_text=[chanlocs(cc).labels '- HR - LR - day 1' ];
% %         title(title_text);
% %         axis('tight');
% %         SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
% %         text(0,max(temp_data_to_plot_a), 'Feedback');
% %         temp_save_name_fig=[chanlocs(cc).labels '_RVS_GA_LR-HR_2_parts-day1'];
% %         saveas(fig, temp_save_name_fig, 'png');
% %         saveas(fig, temp_save_name_fig, 'fig');
% %         clear temp_save_name
% %     
% % end
% 
