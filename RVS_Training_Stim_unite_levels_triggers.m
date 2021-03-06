% 12 June 2016. 
% Revised to run on server 08.09.2016
% Maria L Stavrinou. 
%% Path information
% Raw_Path = uigetdir('Select folder with Raw datasets');
% if Raw_Path==0
%     Raw_Path='/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/';
% end
% 
% Analyzed_path= uigetdir('Select folder with Raw datasets');
% if Analyzed_path == 0
%     Analyzed_path = '/Volumes/EEG2_MARIA/EEG/RVS/Analyzed_datasets/';
% end


%Raw_Path='/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/RVS/'; 
%%RVS_Subject104/Base/';
% Raw_path='Z:\RVS\RAW_datasets\DataRVS\';
% Analyzed_path='Z:\RVS\Analyzed_datasets\';

Raw_path='Y:\Prosjekt\RVS_43_subjects\Raw_datasets\DataRVS\';
Analyzed_path='Y:\Prosjekt\RVS_43_subjects\Analyzed_datasets\';
cd(Raw_path);

%% Define list of folders 
listing_raw=dir('*RVS_Subject*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 
end
clear kk listing_raw

%% Define sessions
Sessions={'Training1', 'Training2'};

%% Define which subjects to keep in the analysis 
bad_subject_list=[];%6,8,16,18,22,32];
bad_subject_list=[6,8,13,14,15,16,18,19,22,26]; % for Stim
good_subj_list=[]; for kk=1:Num_folders, if ~ismember(kk, bad_subject_list), good_subj_list=[good_subj_list kk]; end; end

tic
%% Start load
startfolder=1;
for mkk=startfolder:length(good_subj_list)
    kk=good_subj_list(mkk);
    Subject_filename=temp22{kk,:}; 
    % Print a message on screen to show on which subject we are working
    fprintf(' ***  Working on subject %s: %s\n', num2str(mkk), Subject_filename)
    % For every Session: Training1 or Training2 
    % Work for each session independently 
    for jj=1:length(Sessions)
        session_temp=Sessions{jj};
        cd(Analyzed_path)
        cd(temp22{kk,:});
        Subject_filemname_session=[Subject_filename '_' session_temp];
        mkdir(session_temp);
        cd(session_temp);
        Analyzed_path_folder=[Analyzed_path temp22{kk,:} '\' session_temp '\'];
        Raw_path_folder=[Raw_path temp22{kk,:} '\' session_temp '\'];
        cd(Analyzed_path_folder)
        cd Triggers
        %% Find triggers -make this search only for the first time
        if (kk==startfolder & jj==1)
            listing_raw=dir('stim_*_corr.txt');
            Num_files=length(listing_raw);
            for kkm=1:Num_files
                temp23{kkm,:}=listing_raw(kkm).name;
            end
            clear kkm
        end
        %% End finding triggers
       
        % Unite triggers - used in Stim 
        stim_triggers_all=[];
        for kkm=1:length(temp23)
            temptrig=load(temp23{kkm,:})
            stim_triggers_all=[stim_triggers_all temptrig];
            clear temptrig
        end
        clear kkm
        stim_triggers_all=sort(stim_triggers_all);
        cd(Analyzed_path_folder) 
        cd Triggers
        %create_triggers_in_txt(name, index_trigger_X_final)
        create_triggers_in_txt('stim_triggers_all', stim_triggers_all);
        
    end
end
