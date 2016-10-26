%% To do the grandaverage plots for the RVS_Training
% Maria Stavrinou
% 14 June 2016 under construction

clear all 
close all
profile on
tic
% Maria L Stavrinou. 
%% Path information
%% Path information
% Raw_Path = uigetdir('Select folder with Raw datasets');
% if Raw_Path==0
    Raw_Path='/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/';
% end

% Analyzed_path= uigetdir('Select folder with Raw datasets');
% if Analyzed_path == 0
    Analyzed_path = '/Volumes/EEG2_MARIA/EEG/RVS/Analyzed_datasets_FRN_1_20Hz/';
% end

cd(Analyzed_path);
%% Define list of Folders - Subjects  
Name_subject_folder='*_Subject*';
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
conditions={'Correct', 'HR','LR','Wrong'};

part_names_all={'part_a'; 'part_b'; 'part_c'; 'part_d'};

% Define empty structure;
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


for jjk=1:length(temp22); % For every subject - folder
    Folder_name=temp22{jjk,:};
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
        Analyzed_path_folder=[Analyzed_path '/' temp22{jjk,:} '/' session_temp ];
        Raw_path_folder=[Raw_Path temp22{jjk,:} '/' temp22{jjk,:} '/' session_temp];
        
        
        for kk=1:length(conditions) % For every condition : Wrong, Correct,HR, LR
            temp_condition=conditions(kk);
            temp_condition_char=char(temp_condition);

            % Go the Analyzed_path_folder for each subject
            % and search for the set files for each AX, AY condition
            cd(Analyzed_path_folder)
            Search_for_folder=['*128_ch_DC_epochs_tr50_auto_5_chan_filt_FRN_triggers_' temp_condition_char '*part*.set'];
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
                    EEG = pop_loadset('filename',name_file,'filepath',Analyzed_path_folder);
                    EEG = eeg_checkset( EEG );
                    eeglab redraw
                    
                    % Get the data and the dimensions of it. 
                    % Select smaller timepoints, run only once, at start!
                    if (jjk==1 & mm==1 && kk==1 && gg==1)
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
                    meandata=mean(data, 3);
                    Mean_Subjects.(Folder_name).(temp_condition_char).(part_name_temp_char)=meandata;
                    
                    % Edw einai ola ta lefta. 
                    % dataGA.(temp_condition_char).(part_name_temp_char)=cat(3, dataGA.(temp_condition_char).(part_name_temp_char), data);
                     clear data
                end
              
            end
        end
    end % Sessions 
end % Subject

%Check if we need any of this
clear jjk mm kk gg B AreWeRight data_post_trigger data_pre_trigger find_new_post_trigger find_new_pre_trigger name1 name2 name3a name3b name_data name_file Name_subject_folder new_post_trigger new_pre_trigger part_names part_name_temp_char part_name_temp post_trigger pre_trigger temp_condition temp_condition_char
cd(Analyzed_path)
mkdir('Mean_All_Subjects')
cd('Mean_All_Subjects')
save Mean_Subjects Mean_Subjects 
save new_post_trigger_index new_post_trigger_index
save new_pre_trigger_index new_pre_trigger_index
save timeVec_msec timeVec_msec
toc




% % Now extract interactively the Grand averages for each condition 
% for kk=1:length(conditions)
%     temp_condition=conditions(kk);
%     temp_condition_char=char(temp_condition);
%     for gg=1:length(part_names_all)
%         part_name_temp=part_names_all(gg);
%         part_name_temp_char=char(part_name_temp);
%         name_field=[part_name_temp_char '_GA'];
%         dataGA.(temp_condition_char).(name_field)=mean(dataGA.(temp_condition_char).(part_name_temp_char),3);
%     end
% end
% 
% 
% cd(Analyzed_path)
% mkdir('FiguresGA_RVS_Testing_4parts')
% cd FiguresGA_RVS_Testing_4parts
% save dataGA dataGA
% % toc
% % % 
% % % %% Find the correct limits for the plot 
% % 
% % % Get the above new shorter epoch limits
% % time_epoch_from_ms=new_pre_trigger_index;
% % time_epoch_to_ms_idp=new_post_trigger_index;
% % 
% % % % Time of baseline  
% % % % Remember the pretrigger saved in EEGLAB has no minus infront
% % % time_epoch_from_ms=find(timeVec_msec>-200);%pre_trigger
% % % time_epoch_from_ms_idp=min(time_epoch_from_ms);
% % % 
% % % % Time of end of epoch
% % % time_epoch_to_ms=find(timeVec_msec<post_trigger);
% % % time_epoch_to_ms_idp=max(time_epoch_to_ms);
% % 
% % % New! Get the electrodes we got!
% chanlocs=EEG.chanlocs; 
% clear EEG ALLEEG CURRENTSET CURRENTSTUDY LASTCOM STUDY
% %% Ploting area
% 
% % Make where to save
% 
% 
% % Plots for Correct-Wrong
% for cc=[30,37, 38, 47]% 1:length(chanlocs)   
%     for kkm=1:length(conditions)
%         fig=figure; %(cc+length(chanlocs)); 
%         set(gca,'colororder',[0 0 1;1 0 0; 1 0 1; 0 1 1],'nextplot','add');
%         set(gca,'fontsize', 16);
%         temp_condition=conditions(kkm);
%         temp_condition_char=char(temp_condition);
%         temp_data_to_plot_a=detrend(dataGA.(temp_condition_char).part_a_GA(cc,:));
%         temp_data_to_plot_b=detrend(dataGA.(temp_condition_char).part_b_GA(cc,:));
%         temp_data_to_plot_c=detrend(dataGA.(temp_condition_char).part_c_GA(cc,:));
%         temp_data_to_plot_d=detrend(dataGA.(temp_condition_char).part_d_GA(cc,:));
%         
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_a, 'Linewidth', 2); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_b, 'Linewidth', 2); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_c, 'Linewidth', 2); hold on; 
%         plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), temp_data_to_plot_d, 'Linewidth', 2); 
%         
%         
%         legend('part a','part b', 'part c', 'part d');
%         title_text=[chanlocs(cc).labels '-' temp_condition_char];
%         title(title_text);
%         axis('tight');
%         SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
%         text(0,max(temp_data_to_plot_a), 'Feedback');
%         temp_save_name_fig=[chanlocs(cc).labels '_RVS_GA_' temp_condition_char '_4_parts'];
%         saveas(fig, temp_save_name_fig, 'png');
%         saveas(fig, temp_save_name_fig, 'fig');
%         clear temp_save_name
%     end
% end
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
% 
% toc
