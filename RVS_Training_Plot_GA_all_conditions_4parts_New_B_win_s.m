%% To do the grandaverage plots for the RVS_Training

% 14 June 2016 under construction
% 08.09.2019 to work under windows and server
% 12.09.2016 Modified to create here the Mean_Subjects. 
% Maria Stavrinou

clear all 
close all
%profile on
tic
% Maria L Stavrinou. 
%% Path information
%% Path information
% Raw_path='Z:\RVS\RAW_datasets\DataRVS\';
% %Raw_Path='/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/';
% %'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/RVS/'; 
% %%RVS_Subject104/Base/';
% %
% Analyzed_path='Z:\RVS\Analyzed_datasets\';
%
Raw_path='Y:\Prosjekt\RVS_43_subjects\Raw_datasets\DataRVS\';
Analyzed_path='Y:\Prosjekt\RVS_43_subjects\Analyzed_datasets\';

% Path to save the figures 
path_figures='Figures_GA_Training_Stim_4parts_RL_10MARCH2017';
% Path to save the data of GA 
path_dataGA='Data_GA_Training_Stim_4parts_RL_10MARCH2017';

%% Define list of Folders - Subjects  
cd(Raw_path);
Name_subject_folder='*RVS_Subject*';
listing_raw=dir(Name_subject_folder);
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
end
clear listing_raw kk

% Define the sessions 
Sessions={'Training1', 'Training2'};

%% Define the 4 conditions,in alphabetical order so that the listing is in 
% same order as when matlab uses 'dir' function.
% conditions={'Correct', 'HR','LR','Wrong'}; % For FRN 
conditions={'stim_20L_corr', 'stim_50L_corr','stim_50H_corr','stim_80H_corr'};
% conditions= {'stim_triggers_all'}% % For Stim
conditions_short={'20L', '50H', '50L', '80H'};
part_names_all={'part_a'; 'part_b'; 'part_c'; 'part_d'};

% Define empty structure dataGA;
% Initialize the structure to save the data
for  yyy=1:length(conditions) % 4
    temp_condition=conditions(yyy);
    temp_condition_char=char(temp_condition);
    for nnn=1:length(part_names_all) % 4
        part_name_temp=part_names_all(nnn);
        part_name_temp_char=char(part_name_temp);
        dataGA.(temp_condition_char).(part_name_temp_char)=[];
    end
end
clear yyy nnn temp_part_name temp_condition
% Great!! It worked!!!

%% Define which subjects to keep in the analysis 
bad_subject_list=[1, 4, 8, 18, 22, 26, 30]; % ch 02.01.2017 Stim 

%bad_subject_list=[6,8,16,18,22,32,34,37,40]; % FRN 
good_subj_list=[]; for kk=1:Num_folders, if ~ismember(kk, bad_subject_list), good_subj_list=[good_subj_list kk]; end; end


%% Start load
for mkk=1:length(good_subj_list)
    jjk=good_subj_list(mkk);
    Folder_name=temp22{jjk,:}; 
    % Print a message on screen to show on which subject we are working
    fprintf(' ***  Working on subject %s: %s\n', num2str(mkk), Folder_name)
   % For every Session: Training1 or Training2 
    for mm=1:length(Sessions)
        session_temp=Sessions{:,mm}; %%% !!!!
        Subject_filemname_session=[Folder_name '_' session_temp];
        % Define the part names again
        %% Start defining part names
        if strcmp(session_temp, 'Training1')
            part_names={'part_a'; 'part_b'};
        elseif strcmp(session_temp, 'Training2')
            part_names={'part_c'; 'part_d'};
        end
        
        % Define the new paths            
        Analyzed_path_folder=[Analyzed_path temp22{jjk,:} '\' session_temp '\'];
        Raw_path_folder=[Raw_path temp22{jjk,:} '\' temp22{jjk,:} '\' session_temp '\'];
        
        
        for kk=1:length(conditions) % For every condition : Wrong, Correct,HR, LR
            temp_condition=conditions(kk);
            temp_condition_char=char(temp_condition);

            % Go the Analyzed_path_folder for each subject
            % and search for the set files for each AX, AY condition
            cd(Analyzed_path_folder)
            %Search_for_folder=['*_256__Luck_triggers_' temp_condition_char '*part*.set']; % for FRN
            Search_for_folder=['*_256__Luck_stim_' temp_condition_char '*part*.set']; % for Stim 
            listing_sets=dir(Search_for_folder);
            
            % The program must have found 2 sets, one for part_a and one
            % for part_b for each condition.
            Num_setfiles=length(listing_sets);
            
            for mmk=1:Num_setfiles
                temp_sets{mmk,:}=listing_sets(mmk).name;
            end
            clear listing_sets mmk

            for gg=1:2
                part_name_temp=part_names{gg};
                part_name_temp_char=char(part_name_temp);
                
                % Find where the condition starts in the filename
                B=strfind(temp_sets{gg,:}, temp_condition_char);        
                %1
                name1=temp_sets{gg,:}(1:(B-1));%'Subject_103_25_512_ch_DC_epochs_tr2_autotriggers'; %AX.txt;
                name2=temp_condition_char;
                name3a=part_name_temp;
                name3b=['.set'];
                name_file=[name1 name2 '_' name3a name3b]; %Subject101_Training1_512_ch_DC_epochs_50_triggers_Correct.txt3ch.se
                name_data=[name1 name2]; %Subject101_Training1_512_ch_DC_epochs_50_triggers_Correct
             
                AreWeRight=strcmp(name_file, temp_sets{gg});
                if AreWeRight==1, 
                    disp(['Working on file ' temp_sets{gg} ' for condition ' temp_condition_char]);
                    eeglab
                    EEG = pop_loadset('filename',name_file,'filepath',Analyzed_path_folder);
                    EEG = eeg_checkset( EEG );
                    eeglab redraw
                    

                    %% Select smaller timepoints, run only once, at start! run all times, 141216
                    %if (jjk==1 & mm==1 && kk==1 && gg==1)
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
                        new_post_trigger=post_trigger; %600;
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
                  %  end

                    % Save the EEG.data with smaller epoch
                    
                    data=EEG.data(:, new_pre_trigger_index:new_post_trigger_index, :);  %TODO
                    nchanGA=size(data, 1);
                     if nchanGA>5
                         numchans=[21, 22, 25, 26, 29, 30, 31, 32, 33, 38, 47, 48, 58, 59, 62, 63]; % 
                         % numchans=[29, 32, 38, 47, 48];
                         data2=EEG.data(numchans, new_pre_trigger_index:new_post_trigger_index, :);
                         clear data
                         data=data2;
                     end
%                     ntimeGA=size(data, 2); 
%                     ntrigsGA=size(data, 3);
                                          
                    % Edw einai ola ta lefta. 
                     dataGA.(temp_condition_char).(part_name_temp_char)=cat(3, dataGA.(temp_condition_char).(part_name_temp_char), data);
                     %% Added Here 12.09.2016 to calculate the Mean_Subjects here and not at the program RVS_Training_Plot_GA_allconditions_4parts_New_B_win_s.m
                    meandata=mean(data, 3);
                    Mean_Subjects.(Folder_name).(temp_condition_char).(part_name_temp_char)=meandata;
                     clear data
                end
              
            end
        end
    end % Sessions 
end % Subject

%Check if we need any of this
clear jjk mm kk gg B AreWeRight data_post_trigger data_pre_trigger find_new_post_trigger find_new_pre_trigger name1 name2 name3a name3b name_data name_file Name_subject_folder new_post_trigger new_pre_trigger part_names part_name_temp_char part_name_temp post_trigger pre_trigger temp_condition temp_condition_char

% Now extract interactively the Grand averages for each condition 
for kk=1:length(conditions)
    temp_condition=conditions(kk);
    temp_condition_char=char(temp_condition);
    for gg=1:length(part_names_all)
        part_name_temp=part_names_all(gg);
        part_name_temp_char=char(part_name_temp);
        name_field=[part_name_temp_char '_GA'];
        dataGA.(temp_condition_char).(name_field)=mean(dataGA.(temp_condition_char).(part_name_temp_char),3);
    end
end

%% Save the Grand average
cd(Analyzed_path)
mkdir(path_dataGA);
cd(path_dataGA);
save dataGA dataGA

%% Save the mean ¨for each subject and condition and parts!
save Mean_Subjects Mean_Subjects 
save new_post_trigger_index new_post_trigger_index
save new_pre_trigger_index new_pre_trigger_index
save timeVec_msec timeVec_msec
% toc
% % 
% % %% Find the correct limits for the plot 
% 
% % Get the above new shorter epoch limits
% time_epoch_from_ms=new_pre_trigger_index;
% time_epoch_to_ms_idp=new_post_trigger_index;
% 
% % % Time of baseline  
% % % Remember the pretrigger saved in EEGLAB has no minus infront
% % time_epoch_from_ms=find(timeVec_msec>-200);%pre_trigger
% % time_epoch_from_ms_idp=min(time_epoch_from_ms);
% % 
% % % Time of end of epoch
% % time_epoch_to_ms=find(timeVec_msec<post_trigger);
% % time_epoch_to_ms_idp=max(time_epoch_to_ms);
% 
% % New! Get the electrodes we got!
%numchans=[29, 32, 38, 47, 48];
chanlocs=EEG.chanlocs(numchans); 
save chanlocs chanlocs
clear EEG ALLEEG CURRENTSET CURRENTSTUDY LASTCOM STUDY
%% Ploting area

% Make where to save
cd(Analyzed_path)
%cd FiguresGA_RVS_Testing_4parts_stim_triggers_all_43subjs
mkdir(path_figures);
cd(path_figures);

% Plots for 80-20 in 4 subplots for block1, 2, 3, 4
for cc=1:length(numchans);% [30,37, 38, 47]%  
    kkm=2%1:length(conditions)
        fig=figure(cc+1); %(cc+length(chanlocs)); 
        
        set(gca,'colororder',[0 0 1;1 0 1],'nextplot','add'); % ; 1 0 1; 0 1 1
        % set(gca,'colororder',[0 0 1;0 0 1; 0 0 1; 0 0 1],'nextplot','add');
        set(gca,'fontsize', 16);
        temp_condition_80=conditions(4);
        temp_condition_80_char=char(temp_condition_80);
        
        temp_condition_20=conditions(1);
        temp_condition_20_char=char(temp_condition_20);
        
        
        temp_data_to_plot_80a=dataGA.(temp_condition_80_char).part_a_GA(cc,:);
        temp_data_to_plot_80b=dataGA.(temp_condition_80_char).part_b_GA(cc,:);
        temp_data_to_plot_80c=dataGA.(temp_condition_80_char).part_c_GA(cc,:);
        temp_data_to_plot_80d=dataGA.(temp_condition_80_char).part_d_GA(cc,:);
        
        % since our statistical significant result, p300 increases with
        % blocks, we take this as max and min 
        max_for_plot=max(temp_data_to_plot_80d);
        min_for_plot=min(temp_data_to_plot_80d);
        
        temp_data_to_plot_20a=dataGA.(temp_condition_20_char).part_a_GA(cc,:);
        temp_data_to_plot_20b=dataGA.(temp_condition_20_char).part_b_GA(cc,:);
        temp_data_to_plot_20c=dataGA.(temp_condition_20_char).part_c_GA(cc,:);
        temp_data_to_plot_20d=dataGA.(temp_condition_20_char).part_d_GA(cc,:);
        
        % have in the title the channel 
        title_text=[chanlocs(cc).labels];
               
        for jj=1:length(title_text); 
            if ( title_text(jj)=='_' || title_text(jj)==' '); title_text(jj)='-';
            end; 
        end
        clear jj 
        
       
        a=subplot(4,1,1);  
        plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_80a, 'Linewidth', 2, 'LineStyle', '-'); hold on; 
        plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_20a, 'Linewidth', 2, 'LineStyle', '-'); 
        axis('tight');
        SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
        ylabel('amplitude (uV)');xlabel('time (msec)')
        ylim([min_for_plot max_for_plot])
        
        b=subplot(4,1,2); 
        plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_80b, 'Linewidth', 2, 'LineStyle', '-'); hold on; 
        plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_20b, 'Linewidth', 2, 'LineStyle', '-'); 
        ylim([min_for_plot max_for_plot])
        
        c=subplot(4,1,3); 
        plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_80c, 'Linewidth', 2, 'LineStyle', '-'); hold on; 
        plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_20c, 'Linewidth', 2, 'LineStyle', '-'); 
        ylim([min_for_plot max_for_plot])
        
        
        d=subplot(4,1,4); 
        plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_80d, 'Linewidth', 2, 'LineStyle', '-'); hold on; 
        plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_20d, 'Linewidth', 2, 'LineStyle', '-'); 
        legend('80','20',  'Location', 'best');
        ylim([min_for_plot max_for_plot])
        
        
        % give a title

        %text(0,max(temp_data_to_plot_a), 'Feedback');
        temp_save_name_fig=[chanlocs(cc).labels '_RVS_GA_4RL_4bl_10mar17'];
        saveas(fig, temp_save_name_fig, 'png');
        saveas(fig, temp_save_name_fig, 'fig');
        clear temp_save_name
        close(fig)
    end

%

% % % Plots for HR- LR FRN
% for cc=1:length(chanlocs)   
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
%         % I had detrend and I deleted it. 
%         %temp_data_to_plot_a=detrend(dataGA.(temp_condition_char).part_a_GA(cc,:));
%         temp_data_to_plot_a=dataGA.(temp_condition_char).part_a_GA(cc,:);
%         temp_data_to_plot_b=dataGA.(temp_condition_char).part_b_GA(cc,:);
%         temp_data_to_plot_c=dataGA.(temp_condition_char).part_c_GA(cc,:);
%         temp_data_to_plot_d=dataGA.(temp_condition_char).part_d_GA(cc,:);
%         
%         temp_LR_data_part_a=dataGA.(temp_condition_LR_char).part_a_GA(cc,:);
%         temp_LR_data_part_b=dataGA.(temp_condition_LR_char).part_b_GA(cc,:);
%         temp_LR_data_part_c=dataGA.(temp_condition_LR_char).part_c_GA(cc,:);
%         temp_LR_data_part_d=dataGA.(temp_condition_LR_char).part_d_GA(cc,:);
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
%         legend('part a HR','part b HR', 'part c HR', 'part d HR', 'part a LR','part b LR', 'part c LR', 'part d LR', 'Location', 'best');
%         title_text=[chanlocs(cc).labels '- HR - LR' ];
%         title(title_text);
%         axis('tight');
%         SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
%         %text(0,max(temp_data_to_plot_a), 'Feedback');
%         temp_save_name_fig=[chanlocs(cc).labels '_RVS_GA_LR-HR_4_parts_accLuck'];
%         saveas(fig, temp_save_name_fig, 'png');
%         saveas(fig, temp_save_name_fig, 'fig');
%         clear temp_save_name
%         close(fig)
% end
% 
% 
% 
% % % Plots for HR- LR FRN
% for cc=1:length(chanlocs)   
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
%         % I had detrend and I deleted it. 
%         %temp_data_to_plot_a=detrend(dataGA.(temp_condition_char).part_a_GA(cc,:));
%         temp_data_to_plot_a=dataGA.(temp_condition_char).part_a_GA(cc,:);
%         temp_data_to_plot_b=dataGA.(temp_condition_char).part_b_GA(cc,:);
%         temp_data_to_plot_c=dataGA.(temp_condition_char).part_c_GA(cc,:);
%         temp_data_to_plot_d=dataGA.(temp_condition_char).part_d_GA(cc,:);
%         
%         temp_LR_data_part_a=dataGA.(temp_condition_LR_char).part_a_GA(cc,:);
%         temp_LR_data_part_b=dataGA.(temp_condition_LR_char).part_b_GA(cc,:);
%         temp_LR_data_part_c=dataGA.(temp_condition_LR_char).part_c_GA(cc,:);
%         temp_LR_data_part_d=dataGA.(temp_condition_LR_char).part_d_GA(cc,:);
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
%         legend('part a HR','part b HR', 'part c HR', 'part d HR', 'part a LR','part b LR', 'part c LR', 'part d LR', 'Location', 'best');
%         title_text=[chanlocs(cc).labels '- HR - LR' ];
%         title(title_text);
%         axis('tight');
%         SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
%         %text(0,max(temp_data_to_plot_a), 'Feedback');
%         temp_save_name_fig=[chanlocs(cc).labels '_RVS_GA_LR-HR_4_parts_accLuck'];
%         saveas(fig, temp_save_name_fig, 'png');
%         saveas(fig, temp_save_name_fig, 'fig');
%         clear temp_save_name
%         close(fig)
% end
% 
% 
% Plot only for Day 1 
% for cc=1:length(chanlocs)   % [30, 37, 38, 47]%
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
%         temp_data_to_plot_a=dataGA.(temp_condition_char).part_a_GA(cc,:);
%         temp_data_to_plot_b=dataGA.(temp_condition_char).part_b_GA(cc,:);
%         
%         
%         temp_LR_data_part_a=dataGA.(temp_condition_LR_char).part_a_GA(cc,:);
%         temp_LR_data_part_b=dataGA.(temp_condition_LR_char).part_b_GA(cc,:);
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
%         legend('part a HR','part b HR', 'part a LR','part b LR', 'Location', 'best');
%         title_text=[chanlocs(cc).labels '- HR - LR - day 1' ];
%         title(title_text);
%         axis('tight');
%         SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
%         %text(0,max(temp_data_to_plot_a),0, 'Feedback');
%         temp_save_name_fig=[chanlocs(cc).labels '_RVS_GA_LR-HR_day1_accLuck'];
%         saveas(fig, temp_save_name_fig, 'png');
%         saveas(fig, temp_save_name_fig, 'fig');
%         clear temp_save_name
%         close(fig)
% end

toc
