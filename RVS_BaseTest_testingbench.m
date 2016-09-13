% Run the RVS_BaseTest_extract_mean_and_peak_1_report_4rewlev_mac.m
jjk=1
mm=1
kk=1

Oz=meandata(9,:);
figure; plot(timeVec_msec, Oz)
cc=9
chanlocs_temp=chanlocs(cc).labels;
chanlocs_temp_char=char(chanlocs_temp);

chanlocs_temp=chanlocs(cc).labels;
chanlocs_temp_char=char(chanlocs_temp);
% For N1
 [ final_peak_measure_N1 ] = RVS_Training_find_peak_measure_v2(Oz, peak_start_time, peak_end_time, time_epoch_start, time_epoch_end, fs, timeVec_msec, type );

 % For P300
  [ final_peak_measure_P300 ] = RVS_Training_find_peak_measure_v2(Oz, peak_start_time, peak_end_time, time_epoch_start, time_epoch_end, fs, timeVec_msec, type );
  
  % For N2
  %% N2 detection 
% Define time limits for the peak detection 
type='min';
peak_start_time=270;
peak_end_time=300;
time_start=-200;
  [ final_peak_measure_N2 ] = RVS_Training_find_peak_measure_v2(Oz, peak_start_time, peak_end_time, time_epoch_start, time_epoch_end, fs, timeVec_msec, type );

  %% P2 detection 
% Define time limits for the peak detection 
type='max';
peak_start_time=220;
peak_end_time=270;
time_start=-200; 
  [ final_peak_measure_P2 ] = RVS_Training_find_peak_measure_v2(Oz, peak_start_time, peak_end_time, time_epoch_start, time_epoch_end, fs, timeVec_msec, type );
