function Pooled_means = pool_trials_channels(chan_indexes_left, chan_indexes_right, All_trials_subjects, good_subj_list, startfolder )
% This function pools together trials from selected channels and gives a mean value (Average)
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
%Maria Stavrinou, 29.9.2016 fixed to take only those triggers that have
%inside something. 

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
listing_raw=dir('double_80_20_*0_*t_corr.txt');
Num_triggers=length(listing_raw);
for kkm=1:Num_triggers
    temp23{kkm,:}=listing_raw(kkm).name;
end
clear kkm listing_raw

%% Define empty structure: All_trials_subjects, 
% Initialize the structure to save the data, named Mean_Subjects, a general
% name
% for kk=1:Num_folders
%     Folder_name=temp22{kk,:};
%     for  yyy=1:length(Sessions) % 4
%         session_temp=Sessions(yyy);
%         session_temp_char=char(session_temp);
%         for tt=1:length(temp23) 
%             trigger_temp=temp23{tt,:}(1:end-4);
%             trigger_temp_char=char(trigger_temp);
%             Pooled_means.(Folder_name).(session_temp_char).(trigger_temp_char).ipsi=[];
%             Pooled_means.(Folder_name).(session_temp_char).(trigger_temp_char).contra=[];
%             Pooled_means.(Folder_name).(session_temp_char).(trigger_temp_char).means_contra=[];
%             Pooled_means.(Folder_name).(session_temp_char).(trigger_temp_char).means_ipsi=[];
%             Pooled_means.(Folder_name).(session_temp_char).(trigger_temp_char).contra_minus_ipsi=[];
%         end % For trigger temp%dataGA_BT.(session_temp_char).(trigger_temp_char)=[];
%     end
% end


%% Start load
for mkk=startfolder:length(good_subj_list)
    jjk=good_subj_list(mkk);
    Folder_name=temp22{jjk,:};
    fprintf(' ***  Working on subject %s: %s\n', num2str(mkk), Folder_name)
    for mm=1:length(Sessions);
        session_temp=Sessions{:,mm}; %%% !!!!
        session_temp_char=char(session_temp);
        fprintf(' ***   on session %s:\n', session_temp_char)
          
        % Define the new paths            
        Analyzed_path_folder=[Analyzed_path temp22{jjk,:} '\' session_temp ];
        Raw_path_folder=[Raw_Path temp22{jjk,:} '\' temp22{jjk,:} '\' session_temp];
        % Loop for every trigger type we are going to use - Left Brain side
        for kk=1:Num_triggers 
            trigger_temp=temp23{kk,:}(1:end-4);
            trigger_temp_char=char(trigger_temp);
            fprintf(' ***        on trigger %s:\n', trigger_temp_char)
            temp_trials_all=[];
            sample=All_trials_subjects.(Folder_name).(session_temp_char);
            %fieldnames=fieldnames
            % Check if there is this trigger-type inside 
            if sum(strcmp(fieldnames(sample), trigger_temp_char)) == 1, 
                % Define empty structures to host data
%                 pooled_trials_ipsi=[];
%                 pooled_mean_ipsi=[];
%                 pooled_trials_contra=[];
%                 pooled_mean_contra=[];
%             
                %% *Left* side Brain electrodes
                temp_trials_all=[];
                for kkt=1:length(chan_indexes_left);          
                    chan_index_temp=chan_indexes_left(kkt);
                    temp_trials(:, :)=All_trials_subjects.(Folder_name).(session_temp_char).(trigger_temp_char)(chan_index_temp,:,:);
                    disp(['size temp_trials is ', num2str(size(temp_trials))]) %temp_trials_all=[temp_trials_all temp_trials]; %subGA=cat(1, temp_trials, subGA);  
                    [s1 s2]=size(temp_trials);
                    % When there is only one single trial, then its
                    % dimension is 1x205, instead of 205x26. Therefore we
                    % have to invert, because then the cat unifies the 205
                    % and leaves the dimension 1 as 1. 
                    if s1==1
                        temp_trials=temp_trials';
                        %temp_trials_all=cat(2, temp_trials, temp_trials_all);
                    end
                    temp_trials_all=cat(2, temp_trials, temp_trials_all);
                    disp(['size of temp_trials_all is ' num2str(size(temp_trials_all))])
                    clear temp_trials
                end% End going through the 4 channels -pooling   
                clear kkt
                temp_trials_all_leftB=temp_trials_all;
                
                % Define if it is contra - or ipsi                
                if findstr(trigger_temp_char, 'left')>0
                    pooled_trials_ipsi=temp_trials_all;
                    pooled_mean_ipsi=mean(temp_trials_all, 2);
                elseif findstr(trigger_temp_char, 'right')>0
                    pooled_trials_contra=temp_trials_all;
                    pooled_mean_contra=mean(temp_trials_all, 2);
                end
                clear temp_trials_all
                
                temp_trials_all=[];         
                %% Separate the *Right* Brain -side 
                                temp_trials_all=[];
                                
                for kkt=1:length(chan_indexes_right);          
                    chan_index_temp=chan_indexes_right(kkt);
                    temp_trials(:, :)=All_trials_subjects.(Folder_name).(session_temp_char).(trigger_temp_char)(chan_index_temp,:,:);
                    disp(['size temp_trials is ', num2str(size(temp_trials))]) %temp_trials_all=[temp_trials_all temp_trials]; %subGA=cat(1, temp_trials, subGA);  
                    [s1 s2]=size(temp_trials);
                    % When there is only one single trial, then its
                    % dimension is 1x205, instead of 205x26. Therefore we
                    % have to invert, because then the cat unifies the 205
                    % and leaves the dimension 1 as 1. 
                    if s1==1
                        temp_trials=temp_trials';
                        %temp_trials_all=cat(2, temp_trials, temp_trials_all);
                    end
                    temp_trials_all=cat(2, temp_trials, temp_trials_all);
                    disp(['size of temp_trials_all is ' num2str(size(temp_trials_all))])
                    clear temp_trials
                end% End going through the 4 channels -pooling   
                clear kkt
                temp_trials_all_rightB=temp_trials_all;
                
                % Define if it is contra - or ipsi  
                if findstr(trigger_temp_char, 'right')>0
                    pooled_trials_ipsi=temp_trials_all;
                    pooled_mean_ipsi=mean(temp_trials_all, 2);
                elseif findstr(trigger_temp_char, 'left')>0
                    pooled_trials_contra=temp_trials_all;
                    pooled_mean_contra=mean(temp_trials_all, 2);
                end
                clear kkt temp_trials_all 
                
                %% Fill in the n ew structure for each subject,session, trigger_type
                Pooled_means.(Folder_name).(session_temp_char).(trigger_temp_char).ipsi=pooled_trials_ipsi;
                Pooled_means.(Folder_name).(session_temp_char).(trigger_temp_char).contra=pooled_trials_contra;
                Pooled_means.(Folder_name).(session_temp_char).(trigger_temp_char).means_ipsi=pooled_mean_ipsi;
                Pooled_means.(Folder_name).(session_temp_char).(trigger_temp_char).means_contra=pooled_mean_contra;
                Pooled_means.(Folder_name).(session_temp_char).(trigger_temp_char).contra_minus_ipsi=pooled_mean_contra - pooled_mean_ipsi;
                
                % TODO HERE ok done
                clear pooled_trials_contra pooled_trials_ipsi pooled_mean_contra pooled_mean_ipsi 
            end % End if this trigger type exists 
        end % For number of triggers
        clear sample
    end % End for each Session 
end % End of each Subject

end


