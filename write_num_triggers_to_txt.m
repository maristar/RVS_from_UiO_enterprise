%% To do the grandaverage plots for the RVS_Training
% Maria Stavrinou

% 19 June, based on the RVS_Training_Plot_GA_all_conditions/.m *and #_4_parts_B.m
clear all 
close all
profile on
tic
 
%% Path information
%Raw_Path = uigetdir('Select folder with Raw datasets');
%if Raw_Path==0
    Raw_Path='D:\RVS\Raw_datasets\';
%end

% Analyzed_path= uigetdir('Select folder with Raw datasets');
% if Analyzed_path == 0
    Analyzed_path = 'D:\RVS\Analyzed_datasets_B_T\';
%end

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
Sessions={'Base', 'Test'};

% Define the type of triggers we are after
% Do that by going inside a folder and checking for triggers
cd(Analyzed_path)
cd('RVS_Subject104\')
cd('Base\Triggers')

listing_raw=dir('double_80_20_*_corr.txt');
Num_triggers=length(listing_raw);
for kkm=1:Num_triggers
    temp23{kkm,:}=listing_raw(kkm).name;
end
clear kkm
startfolder=1;
correct_folders=[startfolder 2:6 8:12 14 15 18 21:29 31:33];
cd(Analyzed_path)
fid=fopen('Num_triggers.txt', 'wt');
for jjk=[correct_folders] % For every subject - folder
    Folder_name=temp22{jjk,:};
    % For every Session: Training1 or Training2 
    fprintf(fid, '%s\n', Folder_name);
    for mm=1:length(Sessions)
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
            Sessiontrigger=[session_temp_char '_' trigger_temp_char]
            % new part
            cd(Analyzed_path_folder)
            cd('Triggers')
            trigger_name=[trigger_temp '.txt'];
            load_trig=load(trigger_name);
            NUM_trigger.(Folder_name).(session_temp_char).(trigger_temp_char)=length(load_trig);
            fprintf(fid, '%s\t%s\n', Sessiontrigger, num2str(length(load_trig)));
    end
    end
end
fclose(fid)

