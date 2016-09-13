function [ final_peak_measure ] = find_peak_measure(meantempGo, peak_start_time, peak_end_time,time_start, fs )
% The function gives the peak value. 
% Input arguments
% - meantempGo: the average waveform
% - peak_start_time: the time to start looking for the peak
% - peak_end_time: the time to stop looking for the peak
% - time_start: integer, in msec, time to start the trial for example -200
% - fs: sampling frequency
%
% Output arguments
% - final_peak_measure: the peak value and the -/+2 values around the peak

    % Time interval to look for P300, in msec, Important add the
    % prestimulus interval (time_start)
    msec_to_dp=fs/1000;
    timeP300=[peak_start_time+time_start, peak_end_time+time_start];
    timeP300_dp=ceil(timeP300.*msec_to_dp);
    
    % Find the maximum in the previous defined time interval
    peakP300=max(meantempGo(timeP300_dp(1):timeP300_dp(2)));
    % Find the index(in datapoints) of the maximum
    peakP300_index=find(meantempGo==peakP300);
    
%     % Add -/+2 values around the peak 
%     final_peak_measure=(meantempGo(peakP300_index)+ ...
%     meantempGo(peakP300_index+1)+meantempGo(peakP300_index+2)+...
%         meantempGo(peakP300_index-1)+meantempGo(peakP300_index-2))/5;

end

