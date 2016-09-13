% Found this 24.08.2016 and it works on 4 parts. 
% 
% It finds how many triggers exist for 400 trial parts. 
% Maria L. Stavrinou 
clear all 
close all
profile on
tic
% Maria L Stavrinou. 
%% Path information
%% Path information
Raw_Path = uigetdir('Select folder with Raw datasets');
if Raw_Path==0
    Raw_Path='/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/';
end

Analyzed_path= uigetdir('Select folder with Raw datasets');
if Analyzed_path == 0
    Analyzed_path = '/Volumes/EEG2_MARIA/EEG/RVS/Analyzed_datasets/';
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
Sessions={'Training1', 'Training2'};
%% Define the 4 conditions,in alphabetical order so that the listing is in 
% same order as when matlab uses 'dir' function.
conditions={'Correct', 'HR','LR','Wrong'};

part_names_all={'part_a'; 'part_b'; 'part_c'; 'part_d'};

cd(Analyzed_path)
% Define file to save things
fid=fopen('Number_of_triggers.txt', 'wt');

% Program pre_requisites start 
for jjk=1:length(temp22); % For every subject - folder
    Folder_name=temp22{jjk,:};
    % For every Session: Training1 or Training2 
    for mm=1:length(Sessions)
        session_temp=Sessions{:,mm}; %%% !!!!
        Subject_filemname_session=[Folder_name '_' session_temp];
        % Define the new paths            
        Analyzed_path_folder=[Analyzed_path '/' temp22{jjk,:} '/' session_temp ];
        Raw_path_folder=[Raw_Path '/' temp22{jjk,:} '/' temp22{jjk,:} '/' session_temp];
        
        for kk=1:length(conditions) % For every condition : Wrong, Correct,HR, LR
            temp_condition=conditions(kk);
            temp_condition_char=char(temp_condition);
            % Go the Analyzed_path_folder for each subject
            % and search for the set files for each condition
            cd(Analyzed_path_folder);
            cd 'Triggers';
            listing_triggers=dir('triggers*.txt');
            for ggk=1:length(listing_triggers);
                trigger_types{ggk}=listing_triggers(ggk).name;
            
            triggers=load(trigger_types{ggk});
            triggers_part1=triggers(triggers<401);
            triggers_part2=triggers(triggers>400);
            text1=['Found for '  Folder_name '_' session_temp '_' temp_condition_char '_part 1: ' num2str(length(triggers_part1))];
            disp(text1) 
            text2=['Found for '  Folder_name '_' session_temp '_' temp_condition_char '_part 2: ' num2str(length(triggers_part2))];
            fprintf(fid, ' %s\n ', text1);
            fprintf(fid, ' %s\n ', text2);
            end
        end % conditions
    end % sessions
end % subject 

% Program pre-requisities end
fclose(fid);


% %% 
% 
% triggers=load('triggers_Wrong.txt');
% triggers_part1=triggers(triggers<401);
% triggers_part2=triggers(triggers>400);
% disp(['Found part 1: ' num2str(length(triggers_part1))])
% disp(['Found part 2: ' num2str(length(triggers_part2))])
%% 
