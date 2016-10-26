function [Pooled_means] = pool_channels(chan_indexes, Mean_Subjects, good_subj_list, startfolder )
% This function pools together channels and gives a mean value (Average)
% from all of them. (input is also means, we assume linearity).
%   Detailed explanation goes here
%       input arguments
%      - chan_indexes, an array for example [6,7, 8, 9]
%      - Mean_Subjects, the result of the program RVS_BaseTest_extract_mean_and_peak_general_win_s.m
%      - good_subject_list, the list of good subjects to use for analysis
%       (Folder number, index)
%      - startfolder, the number of the first index of folder to use to
%      start analysis
%     Output arguments
%        - pooled_mean, the mean of the channels 

subGA=[];

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

% What we put inside the dir function changes with the triggers we want
% every time. SOS.
% For 4 reward levels, use: listing_raw=dir('double_one_*0*_corr.txt');
listing_raw=dir('double_80_20_*0_corr.txt');
Num_triggers=length(listing_raw);
for kkm=1:Num_triggers
    temp23{kkm,:}=listing_raw(kkm).name;
end
clear kkm listing_raw


%% Start load
for mkk=startfolder:length(good_subj_list)
    jjk=good_subj_list(mkk);
    Folder_name=temp22{jjk,:};
    fprintf(' ***  Working on subject %s: %s\n', num2str(mkk), Folder_name)
    % To be deleted
%     Analyzed_path_folder=[Analyzed_path temp22{jjk,:} '\'];
%     Raw_path_folder=[Raw_Path temp22{jjk,:} '\'];
%     cd(Raw_path_folder);
    % For every Session: Training1 or Training2 
    for mm=1:length(Sessions);
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
            subGA=[];
            for kkt=1:length(chan_indexes);          
                chan_index_temp=chan_indexes(kkt);
                temp_mean=Mean_Subjects.(Folder_name).(session_temp_char).(trigger_temp_char)(kkt,:);
                % look here dataGA_BT.(session_temp_char).(trigger_temp_char)=cat(3, dataGA_BT.(session_temp_char).(trigger_temp_char), data);
                subGA=cat(1, temp_mean, subGA);              
            end % End going through the 4 channels
            pooled_mean=mean(subGA, 1);
            Pooled_means.(Folder_name).(session_temp_char).(trigger_temp_char).pooled_data=pooled_mean;
            
            clear pooled_mean subGA
         end
    end
end


