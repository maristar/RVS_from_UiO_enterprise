function [ final_peak_measure ] = RVS_Training_find_peak_measure(meantempGo, peak_start_time, peak_end_time,time_start, fs, timeVec_msec, type )
% NOT USED. SEE VERSION V2
% The function gives the peak value. 
% Input arguments
% - meantempGo: the average waveform
% - peak_start_time: the time to start looking for the peak
% - peak_end_time: the time to stop looking for the peak
% - time_start: integer, in msec, time to start the trial for example -200
% - fs: sampling frequency
% - type: a string containing the words 'min' or 'max'. Then the program
%       finds the minimum or maximum 
% Output arguments
% - final_peak_measure: the peak value and the -/+2 values around the peak

    % Time interval to look for P300, in msec, Important add the
    % prestimulus interval (time_start)
    msec_to_dp=fs/1000;
    
    % new add start
%     fs=128;
%     pre_trigger = 200 %-EEG.xmin*1000; %msec  200 700 FORGET ABOUT MINUS HERE
%     post_trigger = 600 %EEG.xmax*1000; %msec 1100 1600
%     data_pre_trigger = floor(pre_trigger*fs/1000);
%     data_post_trigger = floor(post_trigger*fs/1000);
%     timeVec = (-(data_pre_trigger):(data_post_trigger));% MINUS IS HERE
%     timeVec = timeVec';
%     timeVec_msec = timeVec.*(1000/fs);
% 
% %     peak_start_time=200;
% %     peak_end_time=350;
%     find_peak_start=find(timeVec_msec>peak_start_time);
%     peak_start_time_index=min(find_peak_start);
% % 
%    find_peak_end_time=find(timeVec_msec<peak_end_time);
%    peak_end_time_index=max(find_peak_end_time);
% %     disp('Epoch new shorter duration done')
    
    % new add end
    timeFRN=[peak_start_time+abs(time_start), peak_end_time+abs(time_start)];
    timeFRN_dp=ceil(timeFRN.*msec_to_dp);
    switch type
        case 'min'
            % Find the minimum in the previous defined time interval
            peakFRN=min(meantempGo(timeFRN_dp(1):timeFRN_dp(2)));
            % Find the index(in datapoints) of the maximum
            peakFRN_index=find(meantempGo==peakFRN);
            final_peak_measure=meantempGo(peakFRN_index);
        case 'max'
            % Find the minimum in the previous defined time interval
            peakFRN=max(meantempGo(timeFRN_dp(1):timeFRN_dp(2)));
            % Find the index(in datapoints) of the maximum
            peakFRN_index=find(meantempGo==peakFRN);
            final_peak_measure=meantempGo(peakFRN_index);
    end
    
% For unfiltered signals, you can uncomment the following. 
%     % Add -/+2 values around the peak 
%     final_peak_measure=(meantempGo(peakP300_index)+ ...
%     meantempGo(peakP300_index+1)+meantempGo(peakP300_index+2)+...
%         meantempGo(peakP300_index-1)+meantempGo(peakP300_index-2))/5;

end

