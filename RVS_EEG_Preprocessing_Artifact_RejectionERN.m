%% RVS_EEG_Preprocessing_Artifact_Rejection
% First we should have these triggers, and then we should check for noisy
% epochs? Yes 
%
% Revising this 31.5.2016
clear all 
close all
tic
% Read the exported e-prime file:
%% Go to raw directory
%% Path information
Raw_Path='Z:\RVS\RAW_datasets\DataRVS\';
Analyzed_path='Z:\RVS\Analyzed_datasets\';
% 
% Raw_Path='D:\RVS\Raw_datasets\';
% %'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/RVS/'; 
% %'/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/'%RVS_Subject104/Base/';
% %
% Analyzed_path='D:\RVS\Analyzed_datasets\';

cd(Raw_Path)
%% Define list of folders 
listing_raw=dir('RVS_Subject101*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 
end
% test22=temp22(1,1)
clear kk listing_raw

%% Define Sessions
Sessions={'Training1', 'Training2'}; % {'Base', 'Test'};


%% Start load
for kk=1:Num_folders
    Folder_name=temp22{kk,:};
    % Go to the analysis path
    cd(Analyzed_path)
    % Make a directory for each Subject - to save the results of preprocessing
    % for the Training1 and Training2. The folders for Training1 and
    % Training2 will be made later in the code. 
    mkdir(temp22{kk,:})
    for jj=1:length(Sessions)
        session_temp=Sessions{jj}

        Analyzed_path_folder=[Analyzed_path temp22{kk,:} '\' session_temp];
        Raw_path_folder=[Raw_Path temp22{kk,:} '\' temp22{kk,:} '\' session_temp '\'];
        % Go to Raw_path_folder
        cd(Raw_path_folder);
        % Find the EEG recording
        cd(Analyzed_path_folder)
        Name_to_load=[Folder_name '_' session_temp '_256__Luck.set']
        EEG = pop_loadset('filename',Name_to_load,'filepath',Analyzed_path_folder);
        EEG = eeg_checkset( EEG );
        eeglab redraw
    
    %% Define which electrode to use for Eye and muscle artifacts. 
    %%Define Channels to use 
    chanlocs=EEG.chanlocs;
    for kkc=1:length(chanlocs)
        chan_names{kkc,:}=chanlocs(kkc).labels;
    end
    clear kkc
    chan_names=chan_names';
    % For eye artifact rejection 
    Which_channel='EXG5'; 
    Which_channel=char(Which_channel);

    for kkc=1:length(chan_names),
        if strcmp(chan_names{:, kkc}, Which_channel)==1
            disp(num2str(kkc))
            chan_index=kkc;
        end
    end
    chan_index_eye=chan_index;
    
    % For muscle electrodes
    Which_channel='C6'; 
    Which_channel=char(Which_channel);

    for kkj=1:length(chan_names),
        if strcmp(chan_names{:, kkj}, Which_channel)==1
            disp(num2str(kkj))
            chan_index=kkj;
        end
    end
    clear kkj
    chan_index_muscle=chan_index;
    %% End define which 
    
    % For Eye artifact rejection, load the FP1,:2,:z channel
    Fp1=squeeze(EEG.data(chan_index_eye,:,:));
    T8=squeeze(EEG.data(chan_index_muscle,:,:));
    
    % For muscle artifacts, good channels to check are: FT7(8), T8(52), FT8(43), 
    %       T7(15); And threshold 35-40 microVolts
    for cc=1:length(EEG.chanlocs);
        temp=EEG.data(cc,:,:);
        chan(cc,:, :)=temp;
    end
    
    % Define number of channels,ntime points, and ntrials
    nchan=size(EEG.data, 1);
    ntrials=size(EEG.data, 3);
    ntime=size(EEG.data, 2);

    %% Define the area of interest in time to detect 
    % 0 - 400 msec -> find the indexes (datapoints)
    
    % Define the time vector for the plots
    fs=EEG.srate;
    time_start=200; % time before the stimulus (no need for negative sign), ms
    time_end=600; % time after the stimulus, in ms
    data_pre_trigger=floor(time_start*fs/1000);
    data_post_trigger=floor(time_end*fs/1000);
    timeVec=(-(data_pre_trigger):(data_post_trigger));
    timeVec_msec=timeVec.*(1000/fs);
    msec_to_dp=fs/1000;
    
    % Time to look for artifacts 
    time_before_zero=find(timeVec_msec>-100);
    time_before_zero_idp=min(time_before_zero);
    time_zero_idp=find(timeVec_msec==0); % 0 
    time_after_zero_temp=find(timeVec_msec<500);% 500
    time_after_zero_idp=max(time_after_zero_temp);
    

    % Where to look for artifacts: 0-400 msec
    time1_index=time_before_zero_idp:time_after_zero_idp;

    % Use the 75 microvolt limit 
    % Check the Fp1 amplitude if it exceeds 75 microseconds.
    threshold = 50;
    noisy=[];
    % Decide which channels to use and double their precision
    % For the eye artifact 
    Fp1=double(Fp1);
    % For the Muscle artifact
    T8=double(chan(chan_index_muscle,:,:));
    % Start
        for jj=1:ntrials
            temp_trial=Fp1(:,jj);
            temp_trial_time1=temp_trial(time1_index, 1);
            %temp_trial_time2=temp_trial(time2_index, 1);
            
            [pks1,locs1,w1,p1] = findpeaks(temp_trial_time1,fs, 'MinPeakProminence', threshold, 'MinPeakDistance', 0.200 ); 
           % [pks2,locs2,w2,p2] = findpeaks(temp_trial_time2,fs, 'MinPeakProminence', threshold, 'MinPeakDistance', 0.200 ); 
            
            % Get the muscle artifact now, use the T8 electrode
            % TODO write a function to calculate the individual threshold
            % for muscle artifact
%            single_trial_numbers=[31, 72, 91, 114, 115, 121, 149, 211, 168, 228, 234, 250, 288, 295, 251:274];
 %           for kkk=1:length(single_trial_numbers)
 %               jj=single_trial_numbers(kkk);
            T8=squeeze(T8);
            temp_trial_muscle=T8(time1_index, jj);
            temp_trial_muscle_diff=abs(diff(temp_trial_muscle));
            find_Gt_50=find(temp_trial_muscle_diff(:,1)>50);
            %disp(length(find_Gt_50))
      %      figure; plot(temp_trial_muscle_diff)
      %      find_muscle(jj,:)=length(find_Gt_50);
   %         end
            % This function returns the widths of the peaks as the vector w 
            % and the prominences of the peaks as the vector p.
            if (length(pks1)>0 | length(find_Gt_50)>0),
                noisy=[noisy, jj];
                Noisy_subj(kk).noisy=noisy;
            end
        end % End trials
        
        % Save as Noisy 
        cd(Analyzed_path_folder)
        mkdir('Triggers_newAI');
        cd('Triggers_newAI');
        save('Noisy.txt', 'noisy','-ascii' );
    clear chan_names 
    end % For session 

end    
% % Finding the threshold for muscle artifact rejection
% % Define list of noisy with muscle artifacts
% tic
% chan_index=1:6:64;
% for kkj=1:length(chan_index)
%     kk=chan_index(kkj)
%     data_channel=double(squeeze(EEG.data(kk, :,:)));%Fp1;
%     single_trial_numbers=[31, 72, 91, 114, 115, 121, 149, 211, 168, 228, 234, 250, 288, 295, 251:274];
%     [ powerHF_all, meanPowerHF, minPowerHF ] = define_threshold_muscle(data_channel, single_trial_numbers, fs, time3_index );
%     threshold_muscle(kkj,:)=minPowerHF;
%     clear minPowerHF powerHF_all meanPowerHF data_channel
% end
% toc

