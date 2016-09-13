%% To do the grandaverage plots for the RVS_Training
% Maria Stavrinou
% June 2016

clear all 
close all
profile on
tic
% Maria L Stavrinou. 
%% Path information
Raw_Path='/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/RVS/'; 
%%RVS_Subject104/Base/';
%
Analyzed_path='/Volumes/EEG2_MARIA/EEG/RVS/Analyzed_datasets/';
%'/Users/mstavr
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/';
cd(Raw_Path);
%% Define list of Folders - Subjects  
Name_subject_folder='*_Subject*';
listing_raw=dir(Name_subject_folder);
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
end
clear listing_raw

% Define the sessions 
Sessions={'Training1', 'Training2'};
%% Define the 4 conditions,in alphabetical order so that the listing is in 
% same order as when matlab uses 'dir' function.
conditions={'Correct', 'HR','LR','Wrong'};

for jjk=1:length(temp22); % For every subject - folder
    Folder_name=temp22{jjk,:};
    % For every Session: Training1 or Training2 
    for mm=2%:length(Sessions)
        session_temp=Sessions{:,mm}; %%% !!!!
        Subject_filemname_session=[Folder_name '_' session_temp];
        for kk=1:length(conditions) % For every condition : Wrong, Correct,HR, LR
            temp_condition=conditions(kk);
            temp_condition_char=char(temp_condition);
            % Define folder name for Analyzed and Raw for each subject 
            Analyzed_path_folder=[Analyzed_path temp22{jjk,:} '/' session_temp ];
            Raw_path_folder=[Raw_Path temp22{jjk,:} '/' temp22{jjk,:} '/' session_temp];
            %% HERE 
            
            % Go the Analyzed_path_folder for each subject
            % and search for the set files for each AX, AY condition
            cd(Analyzed_path_folder)
            Search_for_folder=['*512_ch_DC_epochs_50_triggers_*set'];
            listing_sets=dir(Search_for_folder);
            Num_setfiles=length(listing_sets);
            for mmk=1:Num_setfiles
                temp_sets{mmk,:}=listing_sets(mmk).name;
            end
            clear listing_sets mmk


        %1
        % Find where the condition starts in the filename
        B=strfind(temp_sets{kk,:}, temp_condition_char);        
        %1
        name1=temp_sets{kk,:}(1:(B-1));%'Subject_103_25_512_ch_DC_epochs_tr2_autotriggers'; %AX.txt;
        name2=temp_condition_char;
        name3='.txt3ch.set';
        name_file=[name1 name2 name3]; %Subject101_Training1_512_ch_DC_epochs_50_triggers_Correct.txt3ch.set
        name_data=[name1 name2]; %Subject101_Training1_512_ch_DC_epochs_50_triggers_Correct
        
        AreWeRight=strcmp(name_file, temp_sets{kk});
        if AreWeRight==1, 
            disp(['Working on file ' temp_sets{kk} ' for condition ' temp_condition_char]);
            EEG = pop_loadset('filename',name_file,'filepath',Analyzed_path_folder);
            EEG = eeg_checkset( EEG );
            eeglab redraw
            
            % Select smaller timepoints 
            if (jjk==1 & mm==2 & kk==1)
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
            % Change the time limits
            if (jjk==1 & mm==2)
                nchanGA=size(data, 1);
                ntimeGA=size(data, 2); 
                ntrigsGA=size(data, 3);

                dataGA_Correct=zeros(nchanGA, ntimeGA, ntrigsGA);
                dataGA_HR=zeros(nchanGA, ntimeGA, ntrigsGA);
                dataGA_LR=zeros(nchanGA, ntimeGA, ntrigsGA);
                dataGA_Wrong=zeros(nchanGA, ntimeGA, ntrigsGA);
                % if it is to have more, to make a structure with fields
                % dataGA.(temp_conidtion_char)
            end
%             TODOHERE  cat(1, arrayy1, array2)
            if strcmp(temp_condition, 'Correct')==1 
                dataCorrect=data;
                data_temp=dataCorrect;
                dataGA_Correct=cat(3, data_temp, dataGA_Correct);
                clear data_temp dataCorrect
            elseif strcmp(temp_condition, 'HR')==1 
                  dataHR=data;
                  data_temp=dataHR;
                dataGA_HR=cat(3, data_temp, dataGA_HR);
                clear data_temp dataHR
            elseif strcmp(temp_condition, 'LR')==1
                  dataLR=data;
                  data_temp=dataLR;
                dataGA_LR=cat(3, data_temp, dataGA_LR);
                clear data_temp dataBX
            elseif strcmp(temp_condition, 'Wrong')==1 
                dataWrong=data;
                data_temp=dataWrong;
                dataGA_Wrong=cat(3, data_temp, dataGA_Wrong);
                clear data_temp dataWrong
            end
            clear data
        end
        end
    end % Sessions

    
end % For every subject            


%% For the GA
GA_EEGdata_Correct=mean(dataGA_Correct,3);
GA_EEGdata_HR=mean(dataGA_HR,3);
GA_EEGdata_LR=mean(dataGA_LR,3);
GA_EEGdata_Wrong=mean(dataGA_Wrong,3);

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
mkdir('FiguresGA_RVS_Training2')
cd FiguresGA_RVS_Training2

% Plots for Correct-Wrong
for cc=1:length(chanlocs)
    figure(cc+length(chanlocs)); set(gca,'colororder',[0 0 1;1 0 0],'nextplot','add');
    set(gca,'fontsize', 16);
    plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), GA_EEGdata_Correct(cc,:), 'Linewidth', 2); hold on; 
    plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), GA_EEGdata_Wrong(cc,:), 'Linewidth', 2); 
    legend('Correct','Wrong');
    title(EEG.chanlocs(cc).labels);
    axis('tight');
    SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
    text(0,max(GA_EEGdata_HR(cc,:)), 'Feedback');
    temp_save_name_fig=[chanlocs(cc).labels '_RVS_GA_Train1' 'Correct_Wrong'];
    saveas(cc+length(chanlocs), temp_save_name_fig, 'png');
    saveas(cc+length(chanlocs), temp_save_name_fig, 'fig');
    clear temp_save_name
end

% Plots for HR- LR

for cc=1:length(chanlocs)
    fig=figure(cc); set(gca,'colororder',[0 0 1;1 0 0],'nextplot','add');
    set(gca,'fontsize', 16);
    plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), GA_EEGdata_HR(cc,:), 'Linewidth', 2); hold on; 
    plot(timeVec_msec(new_pre_trigger_index:new_post_trigger_index), GA_EEGdata_LR(cc,:), 'Linewidth', 2); 
    axis('tight');
    legend('HR','LR');
    title(EEG.chanlocs(cc).labels);
    SP=0; line([SP SP], get(gca, 'ylim'), 'Color', [0 0 1]);
    text(0,max(GA_EEGdata_HR(cc,:)), 'Feedback');
    temp_save_name_fig=[chanlocs(cc).labels '_RVS_GA_' session_temp '_HR_LR'];
%    print(fig,temp_save_name_fig,'-dpng')
    saveas(cc, temp_save_name_fig, 'fig');
    clear temp_save_name
end


% Save data for wavelets
save dataGA_WrongTrain2 dataGA_Wrong
save dataGA_CorrectTrain2 GA_EEGdata_Correct -v7.3
save dataGA_HRTrain2 GA_EEGdata_HR
save dataGA_LRTrain2 GA_EEGdata_LR
save timeVect_msecTrain2 timeVec_msec

toc