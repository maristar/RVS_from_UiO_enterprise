% Program to transfer the noisy triggers from Lacie Olgas disk to Astra. 
% Maria Stavrinou, 07.09.2016
% This was used for Training and now it will be modified to run for
% BaseTest. 15.9.2016

% Define where the noisy triggers are:
Source_path='E:\RVS\Analyzed_datasets_B_T\';
%'E:\RVS\Analyzed_datasets_FRN\';

% Define the location of the server to put them: (here it is astra)
Target_path='Z:\RVS\Analyzed_datasets\';

cd(Source_path)
% Notice! Source path - Olgas lacie has not all the files inside, just 27!

listing_raw=dir('RVS_Subject*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 
end
clear kk listing_raw

% Define sessions
Sessions={'Base', 'Test'};
%Sessions={'Training1', 'Training2'};

% Define which subjects to use - some will not have folders in
%% Start the new part 
% Define which subjects to keep in the analysis for FRN here
bad_subject_list=[7, 9, 13, 16, 17, 19, 20, 24, 30];
good_subj_list=[]; 
for kk=1:Num_folders, 
    if ~ismember(kk, bad_subject_list), 
        good_subj_list=[good_subj_list kk]; 
    end; 
end
clear kk 

%% Start load
for mkk=1:length(good_subj_list)
    kk=good_subj_list(mkk);
    Folder_name=temp22{kk,:};
    % Declare on which subject we are working 
    fprintf(' ***  Working on subject %s: %s\n', num2str(mkk), Folder_name)
    for jj=1:length(Sessions)
        session_temp=Sessions{jj};
                
        Source_path_folder=[Source_path temp22{kk,:} '\' session_temp '\'];
        Target_path_folder=[Target_path temp22{kk,:} '\' session_temp '\']; % temp22{kk,:} '/'
        
%         % Check that the above are fine. 
         cd(Target_path_folder)
         %delete('*.txt')
         mkdir('Triggers')
        
        % Go to Raw_path_folder
        cd(Source_path_folder);
        %copyfile('Triggers', [Target_path_folder '\Triggers\']) % WAS
        %NEEDED FOR TRAINING SESSIONS
        copyfile('*.txt', Target_path_folder);
        clear Source_path_folder Target_path_folder
    end
end

