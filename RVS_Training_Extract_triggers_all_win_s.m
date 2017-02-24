% Maria Stavrinou for PSI - UiO 
% For RVS analysis, 1st June 2016
% This program just reads the Eprime file and extracts the triggers for
% each condition. Here we have COrrect, Wrong, HR, LR. It then saves them
% in the Analyzed path folder of each subject. It does not need any EEG file 
% for this. 
clear all 
close all 

%% Path information
% Raw_Path='Z:\RVS\RAW_datasets\DataRVS\';
%'/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/RVS/'; 
%'/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/'%RVS_Subject104/Base/';
%
% Analyzed_path='Z:\RVS\Analyzed_datasets\';%;/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/RVS/';
%
Raw_Path='Y:\Prosjekt\RVS_43_subjects\Raw_datasets\DataRVS\';
Analyzed_path='Y:\Prosjekt\RVS_43_subjects\Analyzed_datasets\';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/';

cd(Raw_Path)
% Define list of folders 
listing_raw=dir('RVS_Subject*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 
end
% test22=temp22(1,1)
clear kk listing_raw
%% Define sessions
Sessions={'Training1', 'Training2'};


%% Define which subjects to keep in the analysis 
bad_subject_list=[];%[6,8,16,18,22,32];
good_subj_list=[]; for kk=1:Num_folders, if ~ismember(kk, bad_subject_list), good_subj_list=[good_subj_list kk]; end; end
good_subj_list=[32]

%% Start load
for mkk=1:length(good_subj_list)
    kk=good_subj_list(mkk);
    Subject_filename=temp22{kk,:}; 
    % Print a message on screen to show on which subject we are working
    fprintf(' ***  Working on subject %s: %s\n', num2str(mkk), Subject_filename)
    
    % Work for each session independently 
    for jj=1:length(Sessions)
        session_temp=Sessions{jj};
        fprintf(' *******  Working on session %s: %s\n', num2str(jj), session_temp)
        cd(Raw_Path);
        cd(temp22{kk,:});
        cd(temp22{kk,:});
        mkdir(session_temp); %%???
        cd(session_temp);%%% ????
        Analyzed_path_folder=[Analyzed_path temp22{kk,:} '\'  session_temp '\'];
        Raw_path_folder=[Raw_Path temp22{kk,:} '\' temp22{kk,:} '\' session_temp '\'];
        
        % Go to Raw_path_folder
        cd(Raw_path_folder);
        
        % Load the exported edat2 file (later named Tfinal).
        listing_raw2=dir('*matlab.txt');
        if length(listing_raw2)==0
            listing_raw2=dir('*MATLAB.txt');
        end
        if length(listing_raw2)==0
            display('No txt file for matlab found');
        end
        Edat2file=listing_raw2(1).name;
        Filename_matlab=Edat2file;
    
        %     [FileName, Raw_Path] = uigetfile('*.*','Select the MATLAB T table (Tfinal) file "txt", or "mat" ');
        %     cd(Raw_Path)
        T = readtable((Filename_matlab), ...
        'Delimiter','\t','ReadVariableNames',false);
        clear Filename_matlab
        % Or load the Tfenal (if you are working with RVS_Subject101 -103
    
        %% Define if there is big onset Delay 
        %% Automate start
        % Find which row in the T table is Condition, and the StimTwoACC.
        % Find it iteratively:
        all_headers=T(1,:);
        all_headers2=table2cell(all_headers);
        clear all_headers
        
        % Find for the Feedback Onset delay
        for jjj=1:length(all_headers2)
            a=strcmp(all_headers2{1,jjj}, 'Feedback.OnsetDelay');
            if a==1
                indexFeedbackDelay=jjj;
            end
        end
        clear a jjj % OK

        Feedback_OnsetDelay_table=T(2:end, indexFeedbackDelay); % 131 for JackLoe, tested first!
        FeedbackDelay=table2cell(Feedback_OnsetDelay_table);
    
        % Find for the Stim.ACC
        for jjj=1:length(all_headers2)
            a=strcmp(all_headers2{1,jjj}, 'Stim.ACC');
            if a==1
                indexStimACC=jjj;
            end
        end
         clear a jjj 
        
        StimACC_table=T(2:end, indexStimACC); % 131 for JackLoe, tested first!
        StimAcc=table2cell(StimACC_table);
        
        clear indexStimACC
        % Find for the High and Low Reward, HR, LR
        for jjj=1:length(all_headers2)
            a=strcmp(all_headers2{1,jjj}, 'Reward');
            if a==1
                indexReward=jjj;
            end
        end
         clear a jjj 

        Reward_table=T(2:end, indexReward);
        Reward=table2cell(Reward_table);

        %% Define the 4 conditions
        conditions={'Correct','Wrong','HR','LR'};

        %% Automate end

        counter=0;
        for kkm=1:size(FeedbackDelay,1),
            if strcmp(FeedbackDelay{kkm,1},'0')==1 | strcmp(FeedbackDelay{kkm,1},'1')==1
            else
                counter=counter+1;
                indexes_StimOnsetDelay_toobig(counter)=kkm;
            end
        end
        disp(['Feedback Delay : Found ' num2str(counter) ' delays bigger than 1']);
        clear kkm counter indexes_StimOnsetDelay_toobig
        %TODO to display the indexes that are bigger and how much is it. 
        Num_triggers=size(Reward); 
        Num_triggers=Num_triggers(1);

%% Find correct or wrong answers - indexes
        correct_index_temp=zeros(Num_triggers,1);
        wrong_index_temp=zeros(Num_triggers, 1);
        for kkm=1:Num_triggers
            isequalX=strcmp(StimAcc{kkm,1},'1');
            isequalY=strcmp(StimAcc{kkm,1},'0');
            if isequalX==1; 
                correct_index_temp(kkm,1)=kkm;
            end
            if isequalY==1;
                wrong_index_temp(kkm,1)=kkm;
            end
        end

        correct_index=find(correct_index_temp>0);
        wrong_index=find(wrong_index_temp>0); % Double condition index Double condition index
        
        %% Select the noisy and unite them with wrong_index 
        cd(Analyzed_path_folder);
        % Find the txt with 'Subject'
        list_txt=dir('Subject*txt');
        Noisy_temp=list_txt.name;
        Noisy=load(Noisy_temp);
        %% End select the Noisy 
        
               Num_correct = length(correct_index);

        HR_index_temp=zeros(Num_triggers,1);
        LR_index_temp=zeros(Num_triggers, 1);
        for kkh=1:Num_triggers     
            if (strcmp(Reward{kkh,1},'H')==1 & strcmp(StimAcc{kkh,1}, '1')==1)
                HR_index_temp(kkh,1)=kkh;
            end
        end
        clear kkh
        % FOr Low Reward
        for kkh=1:Num_triggers     
            if (strcmp(Reward{kkh,1},'L')==1 & strcmp(StimAcc{kkh,1}, '1')==1)
                LR_index_temp(kkh,1)=kkh;
            end
        end
        clear kkh
        
        
        HR_index=find(HR_index_temp>0);
        LR_index=find(LR_index_temp>0);

        clear correct_index_temp wrong_index_temp HR_index_temp LR_index_temp kkh

        %% Remove the noisy from the above
        % HR; HL; correct_index; wrong_indx
        HR_clean=remove_noisy_indexes(Noisy, HR_index);
        LR_clean=remove_noisy_indexes(Noisy, LR_index);
        correct_index_clean=remove_noisy_indexes(Noisy, correct_index);
        wrong_index_clean=remove_noisy_indexes(Noisy, wrong_index);
           
        %% Save the triggers
        %TODO otherwise
        %dataset_info=EEG.filepath;
        Dataset_name=Subject_filename;% Subject_X
        Dataset_set=session_temp;  % Training
        cd(Analyzed_path_folder) 
        
        % Make some exceptions 
        % Exception 1. Subject 114, Training1, has 598 triggers and in
        % Eprime it has 800
        if strcmp(Subject_filename, 'RVS_Subject114')==1
            correct_index_clean=correct_index_clean(correct_index_clean<599);
            wrong_index_clean=wrong_index_clean(wrong_index_clean<599);
            LR_clean=LR_clean(LR_clean<599);
            HR_clean=HR_clean(HR_clean<599);
        end
        
         if strcmp(Subject_filename, 'RVS_Subject102')==1
            correct_index_clean=correct_index_clean(correct_index_clean<799);
            wrong_index_clean=wrong_index_clean(wrong_index_clean<799);
            LR_clean=LR_clean(LR_clean<799);
            HR_clean=HR_clean(HR_clean<799);
        end
        
        mkdir('Triggers')
        cd Triggers
        
        temp_filename=['triggers' '_Correct'];
        create_triggers_in_txt(temp_filename, correct_index_clean);
        clear temp_filename
        
        temp_filename=['triggers' '_Wrong'];
        create_triggers_in_txt(temp_filename, wrong_index_clean);
        clear temp_filename
        
        temp_filename=['triggers' '_LR'];
        create_triggers_in_txt(temp_filename, LR_clean);
        clear temp_filename
        
        temp_filename=['triggers' '_HR'];
        create_triggers_in_txt(temp_filename, HR_clean);
        clear temp_filename

    end % for sessions
end % for folders




