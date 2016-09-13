% Program to transfer the noisy triggers from Lacie Olgas disk to Astra. 
% Maria Stavrinou, 07.09.2016

% Define where the noisy triggers are:
Source_path='E:\RVS\Analyzed_datasets_FRN\';

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
Sessions={'Training1', 'Training2'};
%% Start load
for kk=1:Num_folders
    % This is 
    Folder_name=temp22{kk,:};
    for jj=1:length(Sessions)
        session_temp=Sessions{jj}
                
        Source_path_folder=[Source_path temp22{kk,:} '\' session_temp '\'];
        Target_path_folder=[Target_path temp22{kk,:} '\' session_temp '\']; % temp22{kk,:} '/'
        
%         % Check that the above are fine. 
         cd(Target_path_folder)
         delete('*.txt')
         mkdir('Triggers')
        
        % Go to Raw_path_folder
        cd(Source_path_folder);
        copyfile('Triggers', [Target_path_folder '\Triggers\'])
        copyfile('*.txt', Target_path_folder);
        clear Source_path_folder Target_path_folder
    end
end

