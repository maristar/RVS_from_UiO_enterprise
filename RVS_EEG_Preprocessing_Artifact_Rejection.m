%% AXCPT_EEG_Preprocessing_Artifact_Rejection
% First we should have these triggers, and then we should check for noisy
% epochs? Yes 
%
% Revising this 31.5.2016
% Revising this 17.8.2016 and seeing that it is written for training
% sessions
clear all 
close all
tic
% Read the exported e-prime file:
%% Go to raw directory
%% Path information
Raw_Path='/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/RVS/'; 
%'/Volumes/EEG2_MARIA/EEG/RVS/RAW_datasets/'%RVS_Subject104/Base/';
%
Analyzed_path='/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/RVS/';
%'/Volumes/EEG2_MARIA/EEG/RVS/Analyzed_datasets/'
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

Sessions={'Training1', 'Training2'};
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

        Analyzed_path_folder=[Analyzed_path temp22{kk,:} '/' session_temp];
        Raw_path_folder=[Raw_Path temp22{kk,:} '/' session_temp '/'];
        % Go to Raw_path_folder
        cd(Raw_path_folder);
        % Find the EEG recording
    cd(Analyzed_path_folder)
    Name_to_load=[Folder_name '_' session_temp '_128_ch_DC_epochs_tr50_auto_4b_chan_filt.set']
    EEG = pop_loadset('filename',Name_to_load,'filepath',Analyzed_path_folder);
    EEG = eeg_checkset( EEG );
    eeglab redraw

    % For Eye artifact rejection, load the FP1,:2,:z channel
    Fp1=squeeze(EEG.data(2,:,:));
%     Fp2=squeeze(EEG.data(34,:,:));
%     Fpz=squeeze(EEG.data(33,:,:));
%     Frontal=cat(2, Fp1,Fp2,Fpz); 
%     
     % % Make the mean of frontals
    % mFrontal=mean(Frontal, 2);
    % figure; plot(mFrontal);
    % 
    % figure; plot(Fp1(4000:12000));
    % % Divide in two parts and find the two maxs

    % For muscle artifacts, good channels to check are: FT7(8), T8(52), FT8(43), 
    %       T7(15); And threshold 35-40 microVolts
    for cc=1:length(EEG.chanlocs);
        chan(cc,:,:)=squeeze(EEG.data(cc,:,:));
    end
  %  {'CPz';'Fz';'FCz';'Cz'}
%     FT7=squeeze(EEG.data(8,:,:));
%     T8=squeeze(EEG.data(52,:,:));
%     T7=squeeze(EEG.data(15,:,:));
%     FT8=squeeze(EEG.data(48,:,:));
%     C1=squeeze(EEG.data(12,:,:));
%     T8_all=(T8+FT8)/2;
    
    % Define number of channels,ntime points, and ntrials
    nchan=size(EEG.data, 1);
    ntrials=size(EEG.data, 3);
    ntime=size(EEG.data, 2);

    %% Define two areas of interest in time
    % 0 - 500 msec -> find the indexes (datapoints)
    % 3000 - 3500 msec -> # #

    %Define the time vector for the plots
    fs=EEG.srate;
    time_start=200; % time before the stimulus (no need for negative sign), ms
    time_end=800; % time after the stimulus, in ms
    data_pre_trigger=floor(time_start*fs/1000);
    data_post_trigger=floor(time_end*fs/1000);
    timeVec=(-(data_pre_trigger):(data_post_trigger));
    timeVec_msec=timeVec.*(1000/fs);
    msec_to_dp=fs/1000;
    
    % TimeVec TODO substract 1 it is 3585 and not 3584
    time_minus200_idp=find(timeVec_msec-200);
    time_zero_idp=find(timeVec_msec==0); % 0 
    time_after_zero_temp=find(timeVec_msec<500);% 500
    time_after_zero_idp=max(time_after_zero_temp);
    


    time1_index=time_zero_idp:time_after_zero_idp;
%     time2_index=time_before_stim2_idp:time_after_stim2_idp;
%     % Time for muscle artifact detection
%     time3_index=time_zero_idp:time_after_stim2_idp;
    
    % Use the 75 microvolt limit 
    % Check the Fp1 amplitude if it exceeds 75 microseconds.
    threshold = 75;
    noisy=[];
    % Decide which to use and double their precision
    % For the eye artifact 
    Fp1=double(Fp1);
    
    % For the Muscle artifact
    T8=double(chan(3,:,:));
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
        cd('Triggers')
        save('Noisy.txt', 'noisy','-ascii' )
%         %% Remove those noisy trials 
%         goodvector=[];
%         for mm=1:ntrials,
%             if ismember(mm, noisy)==1,
%                % do nothing
%             else
%                 goodvector=[goodvector, mm];
%             end
%         end
%         
%         initial_data=EEG.data;
%         clean_data(kk).data=initial_data(:,:, goodvector);
%         
%          % Save the EEG structure 
%     temp_savename=[Name_to_load(1:end-4) '_clean'];    
%     EEG = pop_saveset( EEG, 'filename', temp_savename,'filepath', Analyzed_path_folder);
%     EEG.data=initial_data(:,:, goodvector);
% 
%     EEG = pop_saveset( EEG, 'filename', temp_savename,'filepath', Analyzed_path_folder);
%     EEG = eeg_checkset( EEG );
%     eeglab redraw
%     clear initial data temp_savename Name_to_load Analyzed_path_folder Raw_path_folder
    end
clear chan
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

