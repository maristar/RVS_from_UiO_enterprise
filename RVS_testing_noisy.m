
Raw_Path='/Volumes/MY PASSPORT/EEG/RVS/RAW_datasets/';%RVS_Subject104/Base/';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/'; 
Analyzed_path='/Volumes/MY PASSPORT/EEG/RVS/Analyzed_datasets/';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/';

% We go to Raw_Path because because there are only the 9 datasets we need
cd(Raw_Path)
% Define list of folders 
listing_raw=dir('RVS_Subject*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 
end
% test22=temp22(1,1)
clear kk listing_raw
%% 
nchanGA=10;
ntimeGA=2304;
ntrigsGA=0;
dataGA=zeros(nchanGA, ntimeGA, ntrigsGA);

sessions={'Base','Test'};

for kkj=1%1:length(sessions)
    current_session=sessions{kkj};
    if kkj==1
        dataGA=zeros(nchanGA, ntimeGA, ntrigsGA);
    end
    for kk=1:Num_folders
        Folder_name=temp22{kk,:};
        Analyzed_path_folder=[Analyzed_path temp22{kk,:} '/'];
        Raw_path_folder=[Raw_Path temp22{kk,:} '/'];
        cd(Analyzed_path_folder);
        Raw_path_folder_session=[Raw_path_folder current_session '/'];
        Analyzed_path_folder_session=[Analyzed_path_folder current_session '/']; %/Volumes/MY PASSPORT/EEG/RVS/Analyzed_datasets/RVS_Subject101/Test/
        Name_Subject_session=[Folder_name '_' sessions{kkj}]; % RVS_Subject101_Test
        cd(Analyzed_path_folder_session)
        data_temp=load('data.mat');
        chPOZ=data(3,:,:);
        chPOZ=squeeze(chPOZ);
        mchPOZ=mean(chPOZ,2);
        figure;(plot(mchPOZ));title(Name_Subject_session)
    end
end