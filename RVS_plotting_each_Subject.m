
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
%% 
for kkj=1% :length(sessions)
    current_session=sessions{kkj};
%     if kkj==1
%         data_temp=zeros(nchanGA, ntimeGA, ntrigsGA);
%     end
    for kk=2:Num_folders
        Folder_name=temp22{kk,:};
        Analyzed_path_folder=[Analyzed_path temp22{kk,:} '/'];
        Raw_path_folder=[Raw_Path temp22{kk,:} '/'];
        cd(Analyzed_path_folder);
        Raw_path_folder_session=[Raw_path_folder current_session '/'];
        Analyzed_path_folder_session=[Analyzed_path_folder current_session '/']; %/Volumes/MY PASSPORT/EEG/RVS/Analyzed_datasets/RVS_Subject101/Test/
        Name_Subject_session=[Folder_name '_' sessions{kkj}]; % RVS_Subject101_Test
        cd(Analyzed_path_folder_session)
        data_temp=load('data.mat'); % 10 x 2304 x 50 in a struct 
        Ch_all(kk,:,:)=data_temp; % a struct that increases in size
        clear data_temp
      end
       name_save=[sessions{kkj} 'ChanA']; % TestGA
        cd(Analyzed_path)
        eval(['save ' name_save ' Ch_all']);
end

cd(Analyzed_path)
% Load Base
load('BaseChanA.mat')
Base=Mean_Ch_all;% dataGA_Base=dataGA;

clear Mean_Ch_all;

% Load Test
load('TestChanA.mat')
Test=Mean_Ch_all;

% Plot all channels all sessions
for kkl=1:(length(Base))
    temp_base=Base(kkl,:, :); % still a structure
    temp_base2=temp_base.data; % double 
    mean_temp_base_2=mean(temp_base2, 3);
    for kk=1:nchan    
    figure;plot(timeVec_msec, mean_temp_base_2(kk,:), 'b'); 
    axis([-200,1000,-20,13]);
    title(names_chan{kk});
    end
end

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
