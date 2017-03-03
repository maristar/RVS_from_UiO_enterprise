%% To do the grandaverage plots for the RVS_Training, without separating in 4 blocks. 
% Maria Stavrinou
% June 2016

clear all 
close all
%profile on
tic
% Maria L Stavrinou. 
%% Path information
% Raw_Path='/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/RVS/'; 
%%RVS_Subject104/Base/';
%
%Analyzed_path='/Volumes/EEG2_MARIA/EEG/RVS/Analyzed_datasets_FRN_1_20Hz/';
%'/Users/mstavr
% %'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/';
% 
% Raw_path='Z:\RVS\RAW_datasets\DataRVS\';
% 
% Analyzed_path='Z:\RVS\Analyzed_datasets\';


Raw_path='Y:\Prosjekt\RVS_43_subjects\Raw_datasets\DataRVS\';
Analyzed_path='Y:\Prosjekt\RVS_43_subjects\Analyzed_datasets\';
%Raw_Path='/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/RVS/'; 
%%RVS_Subject104/Base/';
%
cd(Raw_path);
%% Define list of Folders - Subjects  
Name_subject_folder='RVS_Subject*';
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
% conditions={'stim_20L_corr','stim_50L_corr','stim_50H_corr','stim_80H_corr'}; 
conditions={ 'Correct', 'HR', 'LR', 'Wrong'};
%% Define which subjects to keep in the analysis 
% bad_subject_list=[6,8,16,18,22,32]; % For FRN
% bad_subject_list=[1, 4, 8, 18, 22, 26, 30]; % for Stim added 28 
% bad_subject_list=[8, 12, 16,  18, 22, 26, 30]; % for Stim bad pupil by Thomas: 12, 16,  18, 22, 26
good_subj_list=[]; for kk=1:Num_folders, if ~ismember(kk, bad_subject_list), good_subj_list=[good_subj_list kk]; end; end


%% Start load
startfolder=1;
for mkk=startfolder:length(good_subj_list)
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
            Search_for_folder=['*_256__Luck_stim_unfilt_EOG_triggers_' temp_condition_char '.set']; 
            
            %Search_for_folder=['*_256__Luck_stim_ICA_' temp_condition_char
            %'.set']; % Stim and ICA
            listing_sets=dir(Search_for_folder);
            Num_setfiles=length(listing_sets);
            for mmk=1:Num_setfiles
                temp_sets{mmk,:}=listing_sets(mmk).name;
            end
            clear listing_sets mmk


        %1
        % Find where the condition starts in the filename
        B=strfind(temp_sets{:}, temp_condition_char);        
        %1
        name1=temp_sets{:}(1:(B-1));%'Subject_103_25_512_ch_DC_epochs_tr2_autotriggers'; %AX.txt;
        name2=temp_condition_char;
        name3='.set';
        name_file=[name1 name2 name3]; %Subject101_Training1_512_ch_DC_epochs_50_triggers_Correct.txt3ch.set
        name_data=[name1 name2]; %Subject101_Training1_512_ch_DC_epochs_50_triggers_Correct
        
        AreWeRight=strcmp(name_file, temp_sets{:});
        if AreWeRight==1, 
            disp(['Working on file ' temp_sets{:} ' for condition ' temp_condition_char]);
            EEG = pop_loadset('filename',name_file,'filepath',Analyzed_path_folder);
            EEG = eeg_checkset( EEG );
            eeglab redraw
            
            % Select smaller timepoints 
            if (jjk==good_subj_list(1) & mm==1 & kk==1)
                Fs=EEG.srate;
                pre_trigger = -EEG.xmin*1000; %msec  200 700
                post_trigger = EEG.xmax*1000; %msec 1100 1600
                data_pre_trigger = floor(pre_trigger*Fs/1000);
                data_post_trigger = floor(post_trigger*Fs/1000);
                timeVec = (-(data_pre_trigger):(data_post_trigger));
                timeVec = timeVec';
                timeVec_msec = timeVec.*(1000/Fs);
                
                new_pre_trigger=-200;
                new_post_trigger=5000;
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
            data=EEG.data(:, new_pre_trigger_index:new_post_trigger_index, :);  %TODO
            % Change the time limits
            if (jjk==good_subj_list(1) & mm==1)
                nchanGA=64;
                ntimeGA=size(data, 2); 
                ntrigsGA=size(data, 3);

                dataGA_stim20L=zeros(nchanGA, ntimeGA, ntrigsGA);
                dataGA_stim50H=zeros(nchanGA, ntimeGA, ntrigsGA);
                dataGA_stim50L=zeros(nchanGA, ntimeGA, ntrigsGA);
                dataGA_stim80H=zeros(nchanGA, ntimeGA, ntrigsGA);
                

                % if it is to have more, to make a structure with fields
                % dataGA.(temp_conidtion_char)
            end
%             TODOHERE  cat(1, arrayy1, array2)
              % For stim and EOG 

              


            % Remove the eye channels
            nchan_temp=size(data,1);
            if nchan_temp>64
                data=data(1:64,:,:);
            end
            
            
            
            
            % Save when Stim-EOG_HR. LR etc is involved
            nchanGA=2; %  fOR eog
                for hh=1:length(conditions)
                    dataGA_EOG.(temp_condition_char)=zeros(nchanGA, ntimeGA, ntrigsGA);
              end
              clear hh
            % Save when Stim, 80, 20, etc is involved.
%             if strcmp(temp_condition, conditions(1))==1 % 
%                 data_stim20L=data;
%                 data_temp=data_stim20L;
%                 dataGA_stim20L=cat(3, data_temp, dataGA_stim20L);
%                 clear data_temp dataStim20L
%             elseif strcmp(temp_condition, 'stim_50L_corr')==1 
%                   data_stim50L=data;
%                   data_temp=data_stim50L;
%                 dataGA_stim50L=cat(3, data_temp, dataGA_stim50L);
%                 clear data_temp data_stim50L
%             elseif strcmp(temp_condition, 'stim_50H_corr')==1
%                   data_stim50H=data;
%                   data_temp=data_stim50H;
%                 dataGA_stim50H=cat(3, data_temp, dataGA_stim50H);
%                 clear data_temp data_stim50H
%             elseif strcmp(temp_condition, 'stim_80H_corr')==1 
%                 data_stim80H=data;
%                 data_temp=data_stim80H;
%                 dataGA_stim80H=cat(3, data_temp, dataGA_stim80H);
%                 clear data_temp datastim_80H
%             end
            
            % 
            if strcmp(temp_condition, conditions(1))==1 % 
                data_condition1=data;
                data_temp=data_condition1;
                dataGA_EOG.(temp_condition_char)=cat(3, data_temp, dataGA_EOG.(temp_condition_char));
                clear data_temp data_condition1
            elseif strcmp(temp_condition, conditions(2))==1 
                  data_condition2=data;
                  data_temp=data_condition2;
                dataGA_EOG.(temp_condition_char)=cat(3, data_temp, dataGA_EOG.(temp_condition_char));
                clear data_temp data_condition2
            elseif strcmp(temp_condition, conditions(3))==1
                  data_condition3=data;
                  data_temp=data_condition3;
                dataGA_EOG.(temp_condition_char)=cat(3, data_temp, dataGA_EOG.(temp_condition_char));
                clear data_temp  data_condition3
            elseif strcmp(temp_condition, conditions(4))==1 
                data_condition4=data;
                data_temp=data_condition4;
                dataGA_EOG.(temp_condition_char)=cat(3, data_temp, dataGA_EOG.(temp_condition_char));
                clear data_temp data_condition4
            end
            
            clear data
        end
        end
    end % Sessions

    
end % For every subject            


%% For the GA
% GA_EEGdata_stim20L=mean(dataGA_stim20L,3);
% GA_EEGdata_stim50L=mean(dataGA_stim50H,3);
% GA_EEGdata_stim50H=mean(dataGA_stim50L,3);
% GA_EEGdata_stim80H=mean(dataGA_stim80H,3);

% For the EOG _ Stim 
GA_EEGdata_Correct=mean(dataGA_EOG.Correct,3);
GA_EEGdata_HR=mean(dataGA_EOG.HR,3);
GA_EEGdata_LR=mean(dataGA_EOG.LR,3);
GA_EEGdata_Wrong=mean(dataGA_EOG.Wrong,3);
%% Find the correct limits for the plot 

% Get the above new shorter epoch limits
time_epoch_from_ms=new_pre_trigger_index;
time_epoch_to_ms_idp=new_post_trigger_index;

% % Time of baseline  
% % Remember the pretrigger saved in EEGLAB has no minus infront
% time_epoch_from_ms=find(timeVec_msec>-200);%pre_trigger
% time_epoch_from_ms_idp=min(time_epoch_from_ms);
% 
% % Time of end of epoch
% time_epoch_to_ms=find(timeVec_msec<post_trigger);
% time_epoch_to_ms_idp=max(time_epoch_to_ms);

% New! Get the electrodes we got!
chanlocs=EEG.chanlocs; 

%% Ploting area

% Make where to save
cd(Analyzed_path)
mkdir('FiguresGA_Training_Stim_EOG')
cd FiguresGA_Training_Stim_EOG

% Plots for 4 reward levels

%Plots for HR- LR  % 20-80
% 
% for cc=1:length(chanlocs)
%     fprintf('figure %s:\n', num2str(cc))
%     hFig2=figure(cc+1); set(gca,'colororder',[0 0 1;1 0 0],'nextplot','add');
%     set(gca,'fontsize', 16);
%     plot(timeVec_msec, GA_EEGdata_stim20L(cc,:), 'Linewidth', 2); hold on; 
%     plot(timeVec_msec, GA_EEGdata_stim80H(cc,:), 'Linewidth', 2); 
%     axis('tight');
%     legend('20L','80H',  'Location','northwest');
%     title(EEG.chanlocs(cc).labels);
%     SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
%     %text(0, max(GA_EEGdata_HR(cc,:)),[], 'Feedback');
%     temp_save_name_fig=[chanlocs(cc).labels '_RVS_Training_Stim_ICA_accLuck_20_80'];
% %    print(fig,temp_save_name_fig,'-dpng')
%     saveas(hFig2, temp_save_name_fig, 'fig');
%     saveas(hFig2, temp_save_name_fig, 'png');
%     clear temp_save_name
%     close(hFig2)
% end
% 
% % Plot for all reward levels
% for cc=1:length(chanlocs)
%     fprintf('figure %s:\n', num2str(cc))
%     hFig2=figure(cc+1); set(gca,'colororder',[0 0 1;1 1 0; 1 0 0; 0 1 1],'nextplot','add');
%     set(gca,'fontsize', 16);
%     plot(timeVec_msec, GA_EEGdata_stim20L(cc,:), 'Linewidth', 2); hold on; 
%     plot(timeVec_msec, GA_EEGdata_stim50L(cc,:), 'Linewidth', 2); hold on; 
%     plot(timeVec_msec, GA_EEGdata_stim50H(cc,:), 'Linewidth', 2); hold on; 
%     plot(timeVec_msec, GA_EEGdata_stim80H(cc,:), 'Linewidth', 2); 
%     axis('tight');
%     legend('20L','50L', '50H','80H', 'Location','northwest');
%     title(EEG.chanlocs(cc).labels);
%     SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
%     %text(0, max(GA_EEGdata_HR(cc,:)),[], 'Feedback');
%     temp_save_name_fig=[chanlocs(cc).labels '_RVS_Training_Stim_ICA_accLuck_20_50H_L_80'];
% %    print(fig,temp_save_name_fig,'-dpng')
%     saveas(hFig2, temp_save_name_fig, 'fig');
%     saveas(hFig2, temp_save_name_fig, 'png');
%     clear temp_save_name
%     close(hFig2)
% end

% Plots for Correct-Wrong
% Figure 1 is reserved for EEGLAB gui. 

for cc=1:(length(chanlocs))
    fprintf('figure %s:\n', num2str(cc))
    % As Figure 1 is reserved for EEGLAB, then we start from figure 2
    hFig=figure(cc+1); set(gca,'colororder',[0 0 1;1 0 0],'nextplot','add');
    
    set(gca,'fontsize', 16);
    plot(timeVec_msec, GA_EEGdata_Correct(cc,:), 'Linewidth', 2); hold on; 
    plot(timeVec_msec, GA_EEGdata_Wrong(cc,:), 'Linewidth', 2); 
    legend('Correct','Wrong');
    title(EEG.chanlocs(cc).labels);
    axis('tight');
    SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
    %text(0,max(GA_EEGdata_HR(cc,:)), 'Feedback');
    temp_save_name_fig=[chanlocs(cc).labels '_Training_Stim_EOG_' 'Correct_Wrong'];
    saveas(cc+1, temp_save_name_fig, 'png');
    saveas(hFig, temp_save_name_fig, 'fig');
    clear temp_save_name
    close(hFig)
end

%Plots for HR- LR

for cc=1:length(chanlocs)
    fprintf('figure %s:\n', num2str(cc))
    hFig2=figure(cc+1); set(gca,'colororder',[0 0 1;1 0 0],'nextplot','add');
    set(gca,'fontsize', 16);
    plot(timeVec_msec, GA_EEGdata_HR(cc,:), 'Linewidth', 2); hold on; 
    plot(timeVec_msec, GA_EEGdata_LR(cc,:), 'Linewidth', 2); 
    axis('tight');
    legend('HR','LR');
    title(EEG.chanlocs(cc).labels);
    SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
    text(0, 1500,[], 'Feedback');
    temp_save_name_fig=[chanlocs(cc).labels '_Training_Stim_EOG_HR_LR' ];
%    print(fig,temp_save_name_fig,'-dpng')
%     saveas(hFig2, temp_save_name_fig, 'fig');
%     saveas(hFig2, temp_save_name_fig, 'png');
    clear temp_save_name
    close(hFig2)
end


% % Stim: 2017: Find the maximum channel, amplitude and latency 
% display('20L :')
% data=GA_EEGdata_stim20L;
% [ latency_max20L  amplitude_max20L electrode_max20L] = RVS_find_max_fromGA( data, chanlocs, timeVec_msec );
% clear data
% 
% % For the 50L
% display('50L :')
% data=GA_EEGdata_stim50L;
% [ latency_max50L  amplitude_max50L electrode_max50L] = RVS_find_max_fromGA( data, chanlocs, timeVec_msec );
% clear data
% 
% % For the 50H
% display('50H :')
% data=GA_EEGdata_stim50L;
% [ latency_max50H  amplitude_max50H electrode_max50H] = RVS_find_max_fromGA( data, chanlocs, timeVec_msec );
% clear data
% 
% % For the 50H
% display('80H :')
% data=GA_EEGdata_stim80H;
% [ latency_max80H  amplitude_max80H electrode_max80H] = RVS_find_max_fromGA( data, chanlocs, timeVec_msec );
% clear data

% % Save data for wavelets or topoplots of GA data 
% % Commented because I prefer unfiltered data for wavelets
% save dataGA_stim20L GA_EEGdata_stim20L -v7.3
% save dataGA_stim50L GA_EEGdata_stim50L -v7.3
% save dataGA_stim50H GA_EEGdata_stim50H -v7.3
% save dataGA_stim80H GA_EEGdata_stim80H -v7.3
% save timeVect_msec timeVec_msec
% save chanlocs chanlocs
% 
% Save for EOG - Stim 
for hh=1:length(conditions)
    temp_condition=conditions(hh);
    temp_condition_char=char(temp_condition);
    GA_EEGdata_EOG.(temp_condition_char)=mean(dataGA_EOG.(temp_condition_char));
end


GA_EEGdata_Correct=mean(dataGA_EOG.Correct);
GA_EEGdata_HR=mean(dataGA_EOG.HR);
GA_EEGdata_LR=mean(dataGA_EOG.LR);
GA_EEGdata_Wrong=mean(dataGA_EOG.Wrong);

toc