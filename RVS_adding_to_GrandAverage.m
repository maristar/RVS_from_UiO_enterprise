
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

for kkj=1:length(sessions)
    current_session=sessions{kkj};
    if kkj==1
        dataGA=zeros(nchanGA, ntimeGA, ntrigsGA);
    end
    for kk=2:Num_folders
        Folder_name=temp22{kk,:};
        Analyzed_path_folder=[Analyzed_path temp22{kk,:} '/'];
        Raw_path_folder=[Raw_Path temp22{kk,:} '/'];
        cd(Analyzed_path_folder);
        Raw_path_folder_session=[Raw_path_folder current_session '/'];
        Analyzed_path_folder_session=[Analyzed_path_folder current_session '/']; %/Volumes/MY PASSPORT/EEG/RVS/Analyzed_datasets/RVS_Subject101/Test/
        Name_Subject_session=[Folder_name '_' sessions{kkj}]; % RVS_Subject101_Test
        cd(Analyzed_path_folder_session)
        data_temp=load('data.mat');
        dataGA=cat(3, data_temp.data, dataGA); 
        clear data_temp
        name_save=[sessions{kkj} 'GA']; % TestGA
        cd(Analyzed_path)
        eval(['save ' name_save ' dataGA']);
    end
       
end

cd(Analyzed_path)
% Load Base
load('BaseGA.mat')
dataGA_Base=dataGA;
Mean_Base_Ch=mean(dataGA_Base,3);
MeanBase=mean(dataGA, 3);
clear dataGA

% Load Test
load('TestGA.mat')
dataGA_Test=dataGA;
Mean_Test_Ch=mean(dataGA_Test,3);
MeanTest=mean(dataGA,3);
clear dataGA

% Define necessities 
[nchan ntime]=size(MeanBase);
Fs=512;
pre_trigger = 500; %msec  200 700
post_trigger = 4000; %msec 1100 1600
data_pre_trigger = floor(pre_trigger*Fs/1000);
data_post_trigger = floor(post_trigger*Fs/1000);
timeVec = (-(data_pre_trigger):(data_post_trigger-1));
timeVec = timeVec';
timeVec_msec = timeVec.*(1000/Fs);
names_chan={'Iz', 'Oz', 'POZ', 'Pz', 'CPZ', 'FPZ', 'AFZ', 'FZ', 'FCZ', 'CZ'}

% % Plot all channels all sessions
% for kk=1:nchan
%     temp_chan_base=Mean_Base_Ch(kk,:);
%     figure;plot(timeVec_msec, temp_chan_base, 'b'); 
%     axis([-200,1000,-20,13]);
%     title(names_chan{kk});
%     clear temp_chan_base
% end

% Plot all GrandAverages from the 10 channels
cd(Analyzed_path)

for kk=1:nchan
    temp_chan_base=MeanBase(kk, :);
    temp_chan_test=MeanTest(kk, :);
    set(0,'defaultAxesFontName', 'Arial')
    figure(kk);plot(timeVec_msec, temp_chan_base, 'b'); 
    axis([-200,1200,-20,11]);
    set(gca,'FontSize',24)
    title(names_chan{kk}, 'FontSize', 24);
    hold on;
    plot(timeVec_msec, temp_chan_test, 'r');
    legend on; 
    legend(sessions, 'FontSize', 24);
    ylabel('EEG amplitude (uV)', 'FontSize', 24); 
    xlabel('time (ms)', 'FontSize', 24);
    clear temp_chan
    cd(Analyzed_path)
    cd figures
    saveas(kk, names_chan{kk}, 'png')
    saveas(kk, names_chan{kk}, 'fig')
    
end
% figure(1); % Creates the figure with handle 1
% 
% plot(t, [s1 s2 s3]); % Plot your variables
% 
% saveas(1, 'file', 'png')
