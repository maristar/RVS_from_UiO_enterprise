% RVS_Training 16 June 2016

function [ MEGADATA_erp, Result_peaks, mean_Go, mean_Stop ] = erp_peak_amplitudes( MEGADATA_artrej, Raw_Path, channel_num, time_start, time_end, trigger_types );
% Finds Peak amplitudes for P300 and N200 for channel_num
% This function gets as input the structure with the data and gives out a
% structure which contains for each subject the average for each channel
% and an array Result_peaks with the N200 and P300 peaks for each subject.
%
% Input arguments
% - MEGADATA_artrej: Structure containing the structures from all data 
%        from all subjects and the artifact free data 
% - Raw_Path : string containing the path of input data structure
% - channel_num integer: containing the number of channel to be plotted
% - time_start: integer, in msec, time to start the trial for example -200
% - time_end: integer, in msec, time to end the trial, for example 800
% - trigger_types: a cell containing the stings of the trigger types, for
%               example {'GoTrials', 'ValidStopTrials'} 
%
% Output arguments
% - MEGADATA_erp: structure like the input structure but with the ERPs of
% each subject for each condition
% - Result_peaks: array with peak info for P300 and N200 for each of the 13
% subject
% - mean_Go: Grandaverage for all subjects for channel selected, Go
% condition
% - mean_Stop: Grandaverage for all subjects for Stop condition
%
%

%% Go to Directory with the data
echo off
cd(Raw_Path);

% Initialize the structure to save the ERPs.
MEGADATA_erp=MEGADATA_artrej;

% clear MEGADATA_epoched
% Define the number of subjects.
Num_subjects=length(MEGADATA_artrej);

% Check the number of types of triggers 
Num_types=length(trigger_types);

% Check the number of channels
num_chan=size(MEGADATA_artrej(1).datasaved.EEGdataepoched_Go, 1);

% Define sampling frequency first, named fs.
fs=1/(MEGADATA_artrej(1).datasaved.Properties.SamplingInterval*10^-6);
% Then define the dp to msec factor and ms to dp factor.
dp_to_msec=1000/fs;
msec_to_dp=fs/1000;

% Find the channel's of interest name.  
channel_name=MEGADATA_artrej(1).datasaved.Properties.Channels(channel_num).Name;

%Define the time vector for the plots
data_pre_trigger=floor(time_start*fs/1000);
data_post_trigger=floor(time_end*fs/1000);
timeVec=(-(data_pre_trigger):(data_post_trigger));
timeVec_msec=timeVec.*(1000/fs);
msec_to_dp=fs/1000;

% Initialize empty arrays to store the grandaverage data for Go and Stop.
mean_all_Go=zeros(Num_subjects, length(timeVec));
mean_all_Stop=zeros(Num_subjects, length(timeVec));

for kk=1:Num_subjects % For every subject
    % Take the data from Go condition for subject kk:
    datatempGo=squeeze(MEGADATA_artrej(kk).datasaved.EEGdataepoched_Go(channel_num, :, :));
    % Get the mean of all trials, so we have the mean signal, the ERP.
    meantempGo=mean(datatempGo, 2);
    
    
    % Take the data from Stop condition for subject kk:
    datatempStop=squeeze(MEGADATA_artrej(kk).datasaved.EEGdataepoched_Stop(channel_num, :, :));
    % Get the mean of all trials, so we have the mean signal, the ERP.
    meantempStop=mean(datatempStop, 2);
    
    % Get all the means to make the grandaverage for Go,
    mean_all_Go(kk,:)=meantempGo;
    
    % Get all the means to make the grandaverage for Stop,
    mean_all_Stop(kk,:)=meantempStop;
   
    % Plot ERP for each channel.
    title_name=[channel_name ', Subject: ' num2str(kk)];
    figure; plot(timeVec_msec, meantempGo);
    title(title_name);hold on;
    plot(timeVec_msec, meantempStop,'r'); legend_handle=legend('GoTrials', 'ValidStopTrials');
    
    %% For P300, for Go condition
    % Define where to start looking for the peak (peak_start_time) in msec
    peak_start_time=250;
    % Define where to end looking for the peak (peak_end_time) in msec
    peak_end_time=350;
    [ final_peak_measure_Go_P300 ] = find_peak_measure(meantempGo, peak_start_time, peak_end_time,time_start,fs );
    [ final_peak_measure_Stop_P300 ] = find_peak_measure(meantempStop, peak_start_time, peak_end_time,time_start,fs );
    
    %% For N200, for Go condition
    % Define where to start looking for the peak (peak_start_time) in msec
    peak_start_time=150;
    % Define where to end looking for the peak (peak_end_time) in msec
    peak_end_time=249;
    [ final_peak_measure_Go_N200 ] = find_peak_measure(meantempGo, peak_start_time, peak_end_time,time_start,fs );
    [ final_peak_measure_Stop_N200 ] = find_peak_measure(meantempStop, peak_start_time, peak_end_time,time_start,fs );
    
    Result_peaks(kk).P300_Go=final_peak_measure_Go_P300;
    Result_peaks(kk).P300_Stop=final_peak_measure_Stop_P300;
    
    Result_peaks(kk).N200_Go=final_peak_measure_Go_N200;
    Result_peaks(kk).N200_Stop=final_peak_measure_Stop_N200;
    
    MEGADATA_erp(kk).Go=meantempGo;
    MEGADATA_erp(kk).Stop=meantempStop;
    MEGADATA_erp(kk).datasaved=rmfield(MEGADATA_erp(kk).datasaved, 'EEGdataepoched_artrej_Go');
    MEGADATA_erp(kk).datasaved=rmfield(MEGADATA_erp(kk).datasaved, 'EEGdataepoched_artrej_Stop');

end

% For calculating and plotting the grandaverage
mean_Go=mean(mean_all_Go,1);
mean_Stop=mean(mean_all_Stop, 1);
figure; plot(timeVec, mean_Go); hold on; plot(timeVec, mean_Stop, 'r'); 
title_name=['Grandaverage, Channel: ' channel_name];
title(title_name);
legend_handle=legend('GoTrials', 'ValidStopTrials');

end

